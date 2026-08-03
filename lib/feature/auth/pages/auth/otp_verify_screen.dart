import 'package:e_taxi/feature/auth/controller/auth_controller.dart';
import 'package:e_taxi/utils/app_colors.dart';
import 'package:e_taxi/utils/app_string.dart';
import 'package:e_taxi/utils/assets.dart';
import 'package:e_taxi/widgets/common_text.dart';
import 'package:e_taxi/widgets/custome_img.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:sms_autofill/sms_autofill.dart';

import '../../../../utils/navigation_utils/navigation.dart';
import '../../../../widgets/app_snackbar.dart';
import '../../../../widgets/custom_button.dart';

class OtpVerifyScreen extends StatefulWidget {
  const OtpVerifyScreen({super.key});

  @override
  State<OtpVerifyScreen> createState() => _OtpVerifyScreenState();
}

class _OtpVerifyScreenState extends State<OtpVerifyScreen> with CodeAutoFill {
  String otpenter = "";
  final _authController = Get.find<AuthController>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.microtask(() {
      _authController.startTimer();
      listenOtp();
    });
  }

  Future<void> listenOtp() async {
    await SmsAutoFill().unregisterListener();
    await SmsAutoFill().listenForCode();
  }

  @override
  void dispose() {
    SmsAutoFill().unregisterListener();
    super.dispose();
  }

  Rx<OtpFieldController> controller = OtpFieldController().obs;
  Rx<TextEditingController> _otpController = TextEditingController().obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteGrey,
      body: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,

            children: [
              PinFieldAutoFill(
                currentCode: otpenter,
                codeLength: 6,
                decoration: BoxLooseDecoration(
                  strokeColorBuilder: FixedColorBuilder(
                    AppColors.textFieldBorderColor,
                  ),
                  bgColorBuilder: FixedColorBuilder(AppColors.whiteColor),
                  textStyle: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.titleTextColor,
                  ),
                ),
                cursor: Cursor(
                  color: AppColors.mainPrimaryColor,
                  width: 2,
                  enabled: true,
                ),
                onCodeChanged: (code) {
                  print("onCodeChanged $code");


                  otpenter = code.toString();

                  if (otpenter.length == 6) {
                    try {
                      controller.value.set(otpenter.split("").toList());
                      _otpController.value.text = otpenter;
                    } catch (e) {
                      debugPrint("Asdads:::$e");
                    }
                  }

                },
                onCodeSubmitted: (val) {
                  print("onCodeSubmitted $val");
                },
              ),
            ],
          ),
          Positioned.fill(
            child: SafeArea(
              child: ColoredBox(
                color: AppColors.whiteGrey,
                child: Padding(
                  padding: EdgeInsetsGeometry.symmetric(horizontal: 16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigation.pop();
                        },
                        child: Container(
                          margin: EdgeInsetsGeometry.symmetric(vertical: 16.h),
                          height: 40.h,
                          width: 40.h,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.whiteColor,
                          ),
                          alignment: Alignment.center,
                          child: CustomImage(
                            image: IconAsset.arrowLeft,
                            ht: 24.h,
                            wt: 24.h,
                          ),
                        ),
                      ),
                      34.verticalSpace,
                      CommonText(
                        string: AppString.otpVerification.tr,
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w500,
                      ),
                      8.verticalSpace,
                      CommonText(
                        string:
                            "${AppString.digitCodeSend.tr} ${_authController.countryCode.value} ${_authController.phoneController.text.trim()}",
                        softWrap: true,
                        fontWeight: FontWeight.w500,
                        fontSize: 16.sp,
                        color: AppColors.textCaptionColor,
                      ),
                      32.verticalSpace,

                      Obx(
                        () => PinCodeTextField(
                          appContext: context,
                          length: 6,
                          controller: _otpController.value,
                          keyboardType: TextInputType.number,
                          autoDismissKeyboard: true,
                          enableActiveFill: true,
                          animationType: AnimationType.fade,
                          animationDuration: const Duration(milliseconds: 200),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          pinTheme: PinTheme(
                            shape: PinCodeFieldShape.box,
                            borderRadius: BorderRadius.circular(8),
                            fieldHeight: 55,
                            fieldWidth: 45,
                            activeFillColor: AppColors.whiteColor,
                            inactiveFillColor: AppColors.whiteColor,
                            selectedFillColor: AppColors.whiteColor,
                            inactiveColor: AppColors.textFieldBorderColor,
                            selectedColor: AppColors.mainPrimaryColor,
                            activeColor: AppColors.textFieldBorderColor,
                          ),
                          onChanged: (value) {
                            otpenter = value;
                          },
                          onCompleted: (value) {
                            debugPrint("OTP Completed: $value");
                          },
                        ),
                      ),

                      32.verticalSpace,

                      CustomButton(
                        text: AppString.verify.tr,
                        onTap: () async {
                          if (otpenter.length != 6) {
                            AppSnackBar.showErrorSnackBar(
                              message: "Enter the Otp",
                            );
                            return;
                          }
                          _authController.firebaseOtpVerify(otpenter);

                        },
                      ),

                      32.verticalSpace,

                      Obx(
                        () => Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () {
                                if (_authController.timeSec.value == 0) {
                                  listenOtp();
                                  _authController.firebaseOtpSend(
                                    isResend: true,
                                  );
                                }
                              },
                              child: CommonText(
                                string: _authController.timeSec.value == 0
                                    ? AppString.resendCode.tr
                                    : AppString.resendCodeIn.tr,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                                color: AppColors.titleTextColor,
                              ),
                            ),
                            Obx(
                              () => _authController.timeSec.value == 0
                                  ? SizedBox.shrink()
                                  : CommonText(
                                      string:
                                          " ${timeString(time: _authController.timeSec.value)} " +
                                          AppString.min.tr,
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.mainPrimaryColor,
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String timeString({required int time}) {
    final minute = (time ~/ 60);
    final second = (time % 60);
    String sec = second.toString();
    if (second < 10) {
      sec = "0$sec";
    }

    return "0$minute:$sec";
  }

  @override
  void codeUpdated() {
    // TODO: implement codeUpdated
  }
}

class OTPField extends StatefulWidget {
  final int length;
  final void Function(String) onCompleted;

  const OTPField({super.key, required this.length, required this.onCompleted});

  @override
  State<OTPField> createState() => _OTPFieldState();
}

class _OTPFieldState extends State<OTPField> {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;
  final FocusNode _keyboardFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.length, (_) => TextEditingController());
    _focusNodes = List.generate(widget.length, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (var c in _controllers) c.dispose();
    for (var f in _focusNodes) f.dispose();
    _keyboardFocus.dispose();
    super.dispose();
  }

  void _onChanged(String value, int index) {
    if (value.isNotEmpty && RegExp(r'^\d$').hasMatch(value)) {
      if (index < widget.length - 1) {
        _focusNodes[index + 1].requestFocus();
        _onCompleted();
      } else {
        _focusNodes[index].unfocus();
        _onCompleted();
      }
    }
  }

  void _onKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace) {
      int lastFilled = -1;
      for (int i = widget.length - 1; i >= 0; i--) {
        if (_controllers[i].text.isNotEmpty) {
          lastFilled = i;
          break;
        }
      }
      if (lastFilled == -1) return;

      _controllers[lastFilled].clear();

      final newFocusIndex = lastFilled > 0 ? lastFilled - 1 : 0;
      _focusNodes[newFocusIndex].requestFocus();
    }
  }

  void _onCompleted() {
    final otp = _controllers.map((c) => c.text).join();

    if (otp.length == widget.length) {
      widget.onCompleted(otp);
    }
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: _keyboardFocus,
      autofocus: true,
      onKeyEvent: _onKeyEvent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 16.w,
            children: List.generate(widget.length, (index) {
              return Flexible(
                child: CustomTextFieldss(
                  hintText: "",
                  title: "",
                  controller: _controllers[index],
                  focusNode: _focusNodes[index],
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  maxLength: 1,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(1),
                  ],
                  onChanged: (value) => _onChanged(value, index),
                  autoFocus: index == 0,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class CustomTextFieldss extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final String title;
  final bool obscureText;
  final String? Function(String?)? formValidator;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final int? maxLength;
  final TextInputFormatter? formatter;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;
  final TextAlign? textAlign;
  final bool? autoFocus;
  final ValueChanged<String>? onChanged;

  const CustomTextFieldss({
    super.key,
    required this.controller,
    required this.hintText,
    required this.title,
    this.obscureText = false,
    this.formValidator,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType,
    this.maxLength,
    this.formatter,
    this.inputFormatters,
    this.focusNode,
    this.textAlign,
    this.onChanged,
    this.autoFocus,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      autofocus: autoFocus ?? false,
      controller: controller,
      focusNode: focusNode,
      obscureText: obscureText,
      validator: formValidator,
      textAlign: textAlign ?? TextAlign.start,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      keyboardType: keyboardType,
      maxLength: maxLength,
      onChanged: onChanged,
      cursorColor: AppColors.mainPrimaryColor,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(vertical: 16),
        fillColor: AppColors.whiteColor,
        filled: true,
        isDense: true,
        hintText: hintText,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        counterText: "",
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: AppColors.textFieldBorderColor,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(8.r),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.mainPrimaryColor, width: 1),
          borderRadius: BorderRadius.circular(8.r),
        ),
      ),
      style: TextStyle(fontSize: 14.sp, color: AppColors.titleTextColor),
      inputFormatters:
          inputFormatters ??
          (keyboardType != TextInputType.number
              ? const []
              : [
                  if (formatter != null)
                    formatter!
                  else
                    FilteringTextInputFormatter.digitsOnly,
                ]),
    );
  }
}
