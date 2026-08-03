import 'dart:async';

import 'package:e_taxi/feature/home/controller/home_controller.dart';
import 'package:e_taxi/core/debug/driver_flow_debug.dart';
import 'package:e_taxi/feature/home/pages/home_screen.dart';
import 'package:e_taxi/utils/app_colors.dart';
import 'package:e_taxi/utils/assets.dart';
import 'package:e_taxi/widgets/app_snackbar.dart';
import 'package:e_taxi/widgets/common_text.dart';
import 'package:e_taxi/widgets/custom_button.dart';
import 'package:e_taxi/widgets/custome_img.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../utils/app_string.dart';
import '../../../utils/constants.dart';
import '../../../utils/navigation_utils/routes.dart';
import '../../../utils/utils.dart';

class CustomerOtpVerify extends StatefulWidget {
  const CustomerOtpVerify({super.key});

  @override
  State<CustomerOtpVerify> createState() => _CustomerOtpVerifyState();
}

class _CustomerOtpVerifyState extends State<CustomerOtpVerify> {
  final homeController = Get.find<HomeController>();
  final TextEditingController _otpController = TextEditingController();
  final FocusNode _otpFocus = FocusNode();
  bool _isSubmitting = false;
  bool _allowFocusRecovery = true;
  Timer? _focusRecoveryTimer;
  Timer? _focusGuardTimer;
  late final String _bookingId;
  late final LatLng _dropLatLng;
  late final String _dropAddress;
  late final String _customerName;

  @override
  void initState() {
    super.initState();
    final dynamic args = Get.arguments;
    final Map<dynamic, dynamic> data =
        args is Map ? args : <dynamic, dynamic>{};
    _bookingId = (data['booking_id'] ??
            rideDataModel.value?.bookingId ??
            Constants.bookingId)
        .toString()
        .trim();
    _dropLatLng = LatLng(
      double.tryParse((data['drop_latitude'] ??
                  rideDataModel.value?.dropoff?.latitude ??
                  '')
              .toString()) ??
          0,
      double.tryParse((data['drop_longitude'] ??
                  rideDataModel.value?.dropoff?.longitude ??
                  '')
              .toString()) ??
          0,
    );
    _dropAddress = (data['drop_address'] ??
            rideDataModel.value?.dropoff?.address ??
            '')
        .toString();
    _customerName = (data['customer_name'] ??
            rideDataModel.value?.customer?.customerName ??
            'az utas')
        .toString();

    _otpFocus.addListener(_handleOtpFocusChange);
    _focusGuardTimer = Timer.periodic(const Duration(milliseconds: 700), (_) {
      if (!_allowFocusRecovery || _isSubmitting || !mounted) return;
      if (Get.currentRoute != Routes.customerOtpVerify) return;
      if (!_otpFocus.hasFocus) _restoreOtpFocus();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _restoreOtpFocus(delay: const Duration(milliseconds: 250));
    });
  }

  void _handleOtpFocusChange() {
    if (!_otpFocus.hasFocus) {
      DriverFlowDebug.send(
        'otp_input_focus_lost',
        bookingId: _bookingId,
        data: <String, dynamic>{
          'text_length': _otpController.text.length,
        },
      );
      _restoreOtpFocus();
    }
  }

  void _restoreOtpFocus({
    Duration delay = const Duration(milliseconds: 90),
  }) {
    _focusRecoveryTimer?.cancel();
    if (!_allowFocusRecovery || _isSubmitting || !mounted) return;

    _focusRecoveryTimer = Timer(delay, () {
      if (!_allowFocusRecovery || _isSubmitting || !mounted) return;
      if (Get.currentRoute != Routes.customerOtpVerify) return;
      if (!_otpFocus.hasFocus) {
        _otpFocus.requestFocus();
        SystemChannels.textInput.invokeMethod<void>('TextInput.show');
        DriverFlowDebug.send(
          'otp_input_focus_recovered',
          bookingId: _bookingId,
          data: <String, dynamic>{
            'text_length': _otpController.text.length,
          },
        );
      }
      final length = _otpController.text.length;
      _otpController.selection = TextSelection.collapsed(offset: length);
    });
  }

  @override
  void dispose() {
    _allowFocusRecovery = false;
    _focusRecoveryTimer?.cancel();
    _focusGuardTimer?.cancel();
    _otpFocus.removeListener(_handleOtpFocusChange);
    _otpController.dispose();
    _otpFocus.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    if (_isSubmitting) return;

    final code = _otpController.text.trim();
    if (code.length != 4 && code.length != 6) {
      AppSnackBar.showErrorSnackBar(
        message: 'Adj meg egy 4 vagy 6 számjegyű utazási kódot.',
        isError: true,
      );
      _restoreOtpFocus();
      return;
    }
    if (_bookingId.isEmpty) {
      AppSnackBar.showErrorSnackBar(
        message: 'A fuvar azonosítója hiányzik. Lépj vissza, majd nyisd meg újra a kódbevitelt.',
        isError: true,
      );
      _restoreOtpFocus();
      return;
    }

    setState(() => _isSubmitting = true);
    final normalizedCode = code.length == 4 ? code.padLeft(6, '0') : code;
    DriverFlowDebug.send(
      'otp_screen_submit',
      bookingId: _bookingId,
      data: <String, dynamic>{
        'entered_length': code.length,
        'submitted_length': normalizedCode.length,
      },
    );

    try {
      final result = await homeController.verifyCustomerOtpAndStartTrip(
        bookingId: _bookingId,
        dropLatLng: _dropLatLng,
        dropAddress: _dropAddress,
        otp: normalizedCode,
      );
      if (result) {
        _allowFocusRecovery = false;
        FocusManager.instance.primaryFocus?.unfocus();
        Get.back();
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
        if (_allowFocusRecovery) _restoreOtpFocus();
      }
    }
  }

  Widget _buildCodeField({required bool tablet}) {
    return Semantics(
      label: 'Négy vagy hat számjegyű utazási kód',
      textField: true,
      child: TextField(
        controller: _otpController,
        focusNode: _otpFocus,
        autofocus: true,
        keyboardType: const TextInputType.numberWithOptions(
          signed: false,
          decimal: false,
        ),
        textInputAction: TextInputAction.none,
        autocorrect: false,
        enableSuggestions: false,
        showCursor: true,
        readOnly: _isSubmitting,
        enableInteractiveSelection: false,
        maxLengthEnforcement: MaxLengthEnforcement.enforced,
        textAlign: TextAlign.center,
        maxLength: 6,
        style: TextStyle(
          fontSize: tablet ? 42.sp : 34.sp,
          fontWeight: FontWeight.w800,
          letterSpacing: tablet ? 18.w : 12.w,
          color: AppColors.blackColor,
        ),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(6),
        ],
        decoration: InputDecoration(
          counterText: '',
          hintText: '000000',
          hintStyle: TextStyle(
            color: AppColors.textCaptionColor.withValues(alpha: .35),
            letterSpacing: tablet ? 18.w : 12.w,
          ),
          filled: true,
          fillColor: const Color(0xFFF8FAFC),
          contentPadding: EdgeInsets.symmetric(
            horizontal: tablet ? 28.w : 18.w,
            vertical: tablet ? 24.h : 20.h,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18.r),
            borderSide: BorderSide(
              color: AppColors.mainPrimaryColor,
              width: 2,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18.r),
            borderSide: BorderSide(
              color: AppColors.mainPrimaryColor,
              width: 3,
            ),
          ),
        ),
        onTap: _restoreOtpFocus,
        onTapOutside: (_) => _restoreOtpFocus(),
        onEditingComplete: _restoreOtpFocus,
        onSubmitted: (_) => _restoreOtpFocus(),
        onChanged: (_) {},
      ),
    );
  }

  Widget _buildForm({required bool tablet}) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(maxWidth: tablet ? 560 : 620),
      padding: EdgeInsets.all(tablet ? 30.w : 20.w),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .10),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommonText(
            string:
                'Add meg $_customerName utazási kódját',
            fontSize: tablet ? 28.sp : 24.sp,
            fontWeight: FontWeight.w700,
            softWrap: true,
          ),
          8.verticalSpace,
          CommonText(
            string:
                'Az utas képernyőjén látható 4 vagy 6 számjegyű kód indítja el a fuvart.',
            color: AppColors.textCaptionColor,
            fontSize: tablet ? 17.sp : 14.sp,
            softWrap: true,
          ),
          24.verticalSpace,
          _buildCodeField(tablet: tablet),
          20.verticalSpace,
          CustomButton(
            text: AppString.verifyAndStartTrip.tr,
            onTap: _verify,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isTabletLandscape = size.width > size.height && size.width >= 900;

    return WillPopScope(
      onWillPop: () async {
        _allowFocusRecovery = false;
        return true;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: const Color(0xFFF3F5F8),
        body: SafeArea(
        bottom: Utils().checkPlatForm,
        child: Stack(
          children: [
            Positioned(
              top: 18.h,
              left: 18.w,
              child: GestureDetector(
                onTap: () {
                  _allowFocusRecovery = false;
                  Get.back();
                },
                child: Container(
                  width: isTabletLandscape ? 56.w : 44.w,
                  height: isTabletLandscape ? 56.w : 44.w,
                  padding: EdgeInsets.all(12.w),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: CustomImage(image: IconAsset.arrowLeft),
                ),
              ),
            ),
            if (isTabletLandscape)
              Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: Container(
                      margin: EdgeInsets.fromLTRB(28.w, 86.h, 18.w, 22.h),
                      padding: EdgeInsets.all(38.w),
                      decoration: BoxDecoration(
                        color: const Color(0xFF06152A),
                        borderRadius: BorderRadius.circular(28.r),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 96.w,
                            height: 96.w,
                            padding: EdgeInsets.all(10.w),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: .08),
                              shape: BoxShape.circle,
                            ),
                            child: Image.asset(
                              'assets/vap_driver_logo.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                          22.verticalSpace,
                          CommonText(
                            string: 'Utas felvétele',
                            color: AppColors.whiteColor,
                            fontSize: 34.sp,
                            fontWeight: FontWeight.w800,
                          ),
                          12.verticalSpace,
                          CommonText(
                            string:
                                'A helyes kód után a fuvar elindul, és a belső navigáció az úti célra vált.',
                            color: AppColors.whiteColor.withValues(alpha: .72),
                            fontSize: 18.sp,
                            softWrap: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 5,
                    child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(18.w, 82.h, 30.w, 22.h),
                      child: Center(
                        child: _buildForm(tablet: true),
                      ),
                    ),
                  ),
                ],
              )
            else
              Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(18.w, 88.h, 18.w, 24.h),
                  child: _buildForm(tablet: false),
                ),
              ),
          ],
        ),
      ),
    ),
    );
  }
}
