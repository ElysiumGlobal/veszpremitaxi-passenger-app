import 'package:e_taxi/core/api/exception/app_exception.dart';
import 'package:e_taxi/core/debug/driver_flow_debug.dart';
import 'package:e_taxi/feature/auth/service/auth_service.dart';
import 'package:e_taxi/utils/app_colors.dart';
import 'package:e_taxi/utils/app_preferences.dart';
import 'package:e_taxi/utils/navigation_utils/navigation.dart';
import 'package:e_taxi/utils/navigation_utils/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DriverLoginScreen extends StatefulWidget {
  const DriverLoginScreen({super.key});

  @override
  State<DriverLoginScreen> createState() => _DriverLoginScreenState();
}

class _DriverAccount {
  const _DriverAccount({
    required this.label,
    required this.email,
    required this.userId,
  });

  final String label;
  final String email;
  final int userId;
}

class _DriverLoginScreenState extends State<DriverLoginScreen> {
  static const List<_DriverAccount> _accounts = <_DriverAccount>[
    _DriverAccount(
      label: '1. sofőr',
      email: 'sofor1@veszpremitaxi.hu',
      userId: 16,
    ),
    _DriverAccount(
      label: '2. sofőr',
      email: 'sofor2@veszpremitaxi.hu',
      userId: 17,
    ),
    _DriverAccount(
      label: '3. sofőr',
      email: 'sofor3@veszpremitaxi.hu',
      userId: 18,
    ),
    _DriverAccount(
      label: '4. sofőr',
      email: 'sofor4@veszpremitaxi.hu',
      userId: 19,
    ),
    _DriverAccount(
      label: '5. sofőr',
      email: 'sofor5@veszpremitaxi.hu',
      userId: 20,
    ),
  ];

  final TextEditingController _pinController = TextEditingController();
  final FocusNode _pinFocus = FocusNode();

  _DriverAccount _selectedAccount = _accounts.first;
  bool _isLoading = false;
  bool _obscurePin = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    DriverFlowDebug.send(
      'driver_pin_login_screen_opened',
      data: <String, dynamic>{'account_count': _accounts.length},
    );
  }

  @override
  void dispose() {
    _pinController.dispose();
    _pinFocus.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_isLoading) return;

    final String pin = _pinController.text.trim();
    if (!RegExp(r'^\d{8}$').hasMatch(pin)) {
      setState(() {
        _errorMessage = 'Adj meg egy 8 számjegyű sofőrkódot.';
      });
      DriverFlowDebug.send(
        'driver_pin_login_validation_failed',
        data: <String, dynamic>{
          'selected_user_id': _selectedAccount.userId,
          'pin_length': pin.length,
        },
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    DriverFlowDebug.send(
      'driver_pin_login_requested',
      data: <String, dynamic>{'selected_user_id': _selectedAccount.userId},
    );

    try {
      final result = await AuthService.driverPasswordLogin(
        identifier: _selectedAccount.email,
        password: pin,
      );

      final String token = result.token?.trim() ?? '';
      if (token.isEmpty) {
        throw Exception('A szerver nem adott vissza belépési tokent.');
      }

      await AppPreference.setBoolean(
        AppPreference.onboardingDone,
        value: true,
      );
      await AppPreference.setString(AppPreference.userToken, token);
      await AppPreference.setString(
        AppPreference.userId,
        result.driver?.id ?? _selectedAccount.userId.toString(),
      );
      await AppPreference.setInt(AppPreference.userStep, 4);
      await AppPreference.setBoolean(
        AppPreference.profileApprove,
        value: true,
      );
      final bool serverOnline = (result.driver?.isOnline ?? '0') == '1';
      final bool storedDutyState =
          AppPreference.getBoolean(AppPreference.driverOnline);
      final bool resumeDuty = serverOnline || storedDutyState;
      await AppPreference.setBoolean(
        AppPreference.driverOnline,
        value: resumeDuty,
      );

      DriverFlowDebug.send(
        'driver_pin_login_succeeded',
        data: <String, dynamic>{
          'selected_user_id': _selectedAccount.userId,
          'returned_user_id': result.driver?.id ?? '',
          'server_online': serverOnline,
          'stored_online': storedDutyState,
          'resume_duty': resumeDuty,
        },
      );
      DriverFlowDebug.kick();

      if (!mounted) return;
      Navigation.replaceAll(Routes.homeScreen);
    } catch (error, stack) {
      DriverFlowDebug.send(
        'driver_pin_login_failed',
        data: <String, dynamic>{
          'selected_user_id': _selectedAccount.userId,
          'error': error.toString(),
          'stack': stack.toString(),
        },
      );
      if (!mounted) return;
      setState(() {
        _errorMessage = _cleanError(error);
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _cleanError(Object error) {
    if (error is AppException) return error.message;
    String message = error.toString().trim();
    message = message.replaceFirst(RegExp(r'^Exception:\s*'), '');
    message = message.replaceFirst(RegExp(r'^AppException:\s*'), '');
    if (message.isEmpty || message == 'null') {
      return 'A belépés nem sikerült. Ellenőrizd a sofőrt és a kódot.';
    }
    return message;
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white,
      counterText: '',
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.textFieldBorderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.textFieldBorderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: AppColors.mainPrimaryColor,
          width: 1.5,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteGrey,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final bool wide = constraints.maxWidth >= 760;
            final double horizontalPadding = wide ? 36 : 18;
            return Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: 22,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 620),
                  child: Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: wide ? 34 : 22,
                        vertical: wide ? 30 : 24,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          wide
                              ? Row(
                                  children: <Widget>[
                                    _logo(104),
                                    const SizedBox(width: 24),
                                    const Expanded(child: _LoginHeading()),
                                  ],
                                )
                              : Column(
                                  children: <Widget>[
                                    _logo(92),
                                    const SizedBox(height: 16),
                                    const _LoginHeading(centered: true),
                                  ],
                                ),
                          const SizedBox(height: 24),
                          DropdownButtonFormField<_DriverAccount>(
                            value: _selectedAccount,
                            isExpanded: true,
                            decoration: _inputDecoration(
                              label: 'Sofőr',
                              icon: Icons.badge_outlined,
                            ),
                            items: _accounts
                                .map(
                                  (_DriverAccount account) =>
                                      DropdownMenuItem<_DriverAccount>(
                                    value: account,
                                    child: Text(account.label),
                                  ),
                                )
                                .toList(),
                            onChanged: _isLoading
                                ? null
                                : (_DriverAccount? account) {
                                    if (account == null) return;
                                    setState(() {
                                      _selectedAccount = account;
                                      _errorMessage = null;
                                      _pinController.clear();
                                    });
                                    DriverFlowDebug.send(
                                      'driver_account_selected',
                                      data: <String, dynamic>{
                                        'selected_user_id': account.userId,
                                      },
                                    );
                                    _pinFocus.requestFocus();
                                  },
                          ),
                          const SizedBox(height: 14),
                          TextField(
                            controller: _pinController,
                            focusNode: _pinFocus,
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.done,
                            obscureText: _obscurePin,
                            maxLength: 8,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(8),
                            ],
                            onSubmitted: (_) => _login(),
                            decoration: _inputDecoration(
                              label: '8 számjegyű sofőrkód',
                              icon: Icons.pin_outlined,
                              suffixIcon: IconButton(
                                tooltip: _obscurePin
                                    ? 'Kód megjelenítése'
                                    : 'Kód elrejtése',
                                onPressed: () {
                                  setState(() {
                                    _obscurePin = !_obscurePin;
                                  });
                                },
                                icon: Icon(
                                  _obscurePin
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                              ),
                            ),
                          ),
                          if (_errorMessage != null) ...<Widget>[
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFE8EC),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                _errorMessage!,
                                style: const TextStyle(
                                  color: Color(0xFF9B263C),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 18),
                          SizedBox(
                            height: 54,
                            child: FilledButton.icon(
                              onPressed: _isLoading ? null : _login,
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.mainPrimaryColor,
                                foregroundColor: const Color(0xFF061225),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              icon: _isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.login_rounded),
                              label: Text(
                                _isLoading ? 'Belépés…' : 'Belépés',
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _logo(double size) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: Image.asset(
        'assets/vap_driver_logo.png',
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          width: size,
          height: size,
          color: AppColors.mainPrimaryColor,
          alignment: Alignment.center,
          child: Icon(
            Icons.local_taxi,
            size: size * .48,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _LoginHeading extends StatelessWidget {
  const _LoginHeading({this.centered = false});

  final bool centered;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          centered ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Sofőr belépés',
          textAlign: centered ? TextAlign.center : TextAlign.start,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: AppColors.titleTextColor,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Válaszd ki a sofőrt, majd add meg a 8 számjegyű kódot.',
          textAlign: centered ? TextAlign.center : TextAlign.start,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.bodyText,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
