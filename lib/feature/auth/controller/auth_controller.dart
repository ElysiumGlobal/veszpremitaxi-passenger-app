import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io' show Platform;
import 'package:country_pickers/country.dart';
import 'package:country_pickers/utils/utils.dart';
import 'package:e_taxi/feature/auth/model/uer_login_model.dart';
import 'package:e_taxi/feature/auth/service/auth_service.dart';
import 'package:e_taxi/utils/app_preferences.dart';
import 'package:e_taxi/utils/app_string.dart';
import 'package:e_taxi/utils/build_config.dart';
import 'package:e_taxi/utils/common_api_caller.dart';
import 'package:e_taxi/utils/constants.dart';
import 'package:e_taxi/utils/enum.dart';
import 'package:e_taxi/utils/loading_mixin.dart';
import 'package:e_taxi/utils/log_utils.dart';
import 'package:e_taxi/widgets/app_snackbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:sms_autofill/sms_autofill.dart';

import '../../../core/helper/notification_service/firebase_notification_service.dart';
import '../../../utils/navigation_utils/navigation.dart';
import '../../../utils/navigation_utils/routes.dart';
import '../model/email_password.dart';

class AuthController extends GetxController with LoadingMixin, LoadingApiMixin {
  final RxString countryCode = "+36".obs;

  final Rx<Country> selectedDialogCountry =
      CountryPickerUtils.getCountryByPhoneCode("36").obs;

  TextEditingController phoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController rEmailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  Future<void> listenForCode() async {
    await SmsAutoFill().unregisterListener(); // avoid duplicates
    await SmsAutoFill().listenForCode(); // start listening
  }

  @override
  void onClose() {
    // TODO: implement onClose

    super.onClose();
  }

  Timer? timer;
  RxInt timeSec = 60.obs;

  void startTimer() async {
    if (timer?.isActive ?? false) timer?.cancel();
    timeSec.value = 60;
    timer = Timer.periodic(Duration(seconds: 1), (timers) {
      if (timeSec.value > 0) {
        timeSec.value--;
      } else {
        timeSec.value = 0;
        timers.cancel();
      }
    });
  }

  Future<void> sendOtp({bool resend = false}) async {
    await processApi(
      () => AuthService.sendOtp(phoneController.text.trim(), countryCode.value),
      result: (result) {
        LogUtils.showLogs(message: "boddy:::$result");
        startTimer();
        if (!resend) {
          Navigation.pushNamed(Routes.otpVerifyScreen);
        }
      },
      error: (error, stack) {},
      loading: handleLoading,
    );
  }

  FirebaseAuth get _auth {
    if (!BuildConfig.firebaseEnabled) {
      throw StateError('Firebase Auth is disabled for this build.');
    }
    return FirebaseAuth.instance;
  }

  Future<void> _ensureFcmToken() async {
    if (!BuildConfig.firebaseEnabled ||
        FireBaseNotification().fcmToken.isNotEmpty) {
      return;
    }

    try {
      FireBaseNotification().fcmToken =
          (await FirebaseMessaging.instance.getToken()) ?? "";
    } catch (e) {
      LogUtils.printAction("Firebase token not get::$e");
    }
  }

  String get _firebaseUid {
    if (!BuildConfig.firebaseEnabled) return "";
    return _auth.currentUser?.uid ?? "";
  }

  String? _verificationId;

  Future<void> firebaseOtpSend({bool isResend = false}) async {
    if (!BuildConfig.firebaseEnabled) return;

    handleLoading(true);
    try {
      String phone = "${countryCode.value}${phoneController.text.trim()}";
      // print(">>>>>>$phone");
      await _auth.verifyPhoneNumber(
        phoneNumber: phone,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {},
        verificationFailed: (FirebaseAuthException e) {
          handleLoading(false);
          log("VERIFICTION ERROR ::$e");
          AppSnackBar.showErrorSnackBar(message: "${e.code}", isError: true);
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          startTimer();
          handleLoading(false);
          if (isResend == false) {
            Navigation.pushNamed(Routes.otpVerifyScreen);
          }
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
          handleLoading(false);
        },
      );
    } catch (e) {
      handleLoading(false);
    }
  }

  Future<void> firebaseOtpVerify(String otp) async {
    if (!BuildConfig.firebaseEnabled) return;

    handleLoading(true);
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otp,
      );

      await _auth.signInWithCredential(credential);
      await _ensureFcmToken();
      final result = await AuthService.firebasePhone(
        phone: phoneController.text.trim(),
        fcm: FireBaseNotification().fcmToken,
        countryCode: countryCode.value,
        fUid: _firebaseUid,
      );

      AppPreference.setBoolean(AppPreference.onboardingDone, value: true);
      AppConstant().userLoginType = LoginType.otp.name;

      AppSnackBar.showErrorSnackBar(message: result.message ?? "");
      emailController.text = "";
      loginType = "otp";
      redirectUser(result, isOtp: true, loginType: "phone");
    } catch (e, st) {
      handleLoading(false);
      LogUtils.printError("ERROR ::::::$e, $st");
      AppSnackBar.showErrorSnackBar(
        message: "Enter the correct verification code",
        isError: true,
      );
    }
  }

  clearTextField() {
    fullNameController.clear();
    emailController.clear();
    phoneController.clear();
    referralController.clear();
    passwordController.clear();
  }

  Future<void> verifyOtp(String otp) async {
    await _ensureFcmToken();

    await processApi(
      () => AuthService.verifyOtp(
        otp: otp,
        phone: phoneController.text.trim(),
        fcm: FireBaseNotification().fcmToken,
        countryCode: countryCode.value,
      ),
      result: (result) {
        AppPreference.setBoolean(AppPreference.onboardingDone, value: true);
        AppConstant().userLoginType = LoginType.otp.name;
        LogUtils.showLogs(message: "boddy:::$result");
        AppSnackBar.showErrorSnackBar(message: result.message ?? "");
        emailController.text = "";
        loginType = "otp";
        redirectUser(result, isOtp: true, loginType: "phone");
      },
      loading: handleLoading,
      error: (error, stack) {},
    );
  }

  Future<Map> firbaseEmailLogin({
    required String email,
    required String password,
  }) async {
    Map res = {'old': true, "done": false};
    if (!BuildConfig.firebaseEnabled) return res;

    final FirebaseAuth auth = _auth;
    try {
      // 🔹 Try signing in first
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      LogUtils.printWhite("✅ Logged in as ${userCredential.user!.email}");
      AppSnackBar.showErrorSnackBar(
        message: "${AppString.emailVeriflinkSend} $email",
        dismisDuration: 10,
        isError: true,
      );
      res['done'] = true;
      res['old'] = false;
      _auth.currentUser?.sendEmailVerification();
      return res;
    } on FirebaseAuthException catch (e) {
      LogUtils.printWhite("ECODE::::::${e.code}");
      if (e.code == 'email-already-in-use') {
        // 🔹 No user found → create new account
        LogUtils.printWhite("👤 User already register Sign in ...");
        try {
          UserCredential newUser = await auth.signInWithEmailAndPassword(
            email: email,
            password: password,
          );
          LogUtils.printWhite(
            "✅ New account created for ${newUser.user!.email}",
          );

          res['done'] = true;
          return res;
        } on FirebaseAuthException catch (createError) {
          LogUtils.printWhite(
            "❌ sign  in  user: ${createError.code}::${createError.message}",
          );
          handleLoading(false);
          AppSnackBar.showErrorSnackBar(
            message: createError.code,
            isError: true,
          );

          return res;
        }
      } else if (e.code == 'wrong-password') {
        LogUtils.printWhite("❌ Wrong password for this account");
        handleLoading(false);
        AppSnackBar.showErrorSnackBar(
          message: AppString.wrongPassword.tr,
          isError: true,
        );
        return res;
      } else {
        LogUtils.printWhite(
          "❌ Auth error: ${e.message}:: email:$email >>password::  $password",
        );
        handleLoading(false);
        AppSnackBar.showErrorSnackBar(message: "Try Again", isError: true);
        return res;
      }
    }
  }

  String profileImage = "";

  Future<dynamic> emailLogin() async {
    dynamic data;
    handleLoading(true);

    try {
      data = await AuthService.emailCheck(email: emailController.text.trim());
      log(">>>>>>>>$data");
      LogUtils.printSuccess(data.toString());
    } catch (e) {
      LogUtils.printAction("Email check error ::$e");
    }

    if (data['data']['is_register'] == 1 &&
        data['data']['login_device'] != "email") {
      handleLoading(false);
      AppSnackBar.showErrorSnackBar(
        message: AppString.emailAlreadyRegister.tr,
        isError: true,
      );
      debugPrint("DATA::::$data");
      return;
    } else {
      Map result = await firbaseEmailLogin(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (result['done']) {
        _auth.currentUser?.reload();
        if (_auth.currentUser?.emailVerified == false) {
          if (result['old']) {
            _auth.currentUser?.sendEmailVerification();
            AppSnackBar.showErrorSnackBar(
              message: AppString.emailnotVerified,
              dismisDuration: 10,
              isError: true,
            );
          }
          handleLoading(false);
          return;
        }

        await _ensureFcmToken();
        await processApi(
          () => AuthService.emailLogin(
            email: emailController.text.trim(),
            pass: passwordController.text.trim(),
            fcmToken: FireBaseNotification().fcmToken,
            loginType: "email",
            fUid: _firebaseUid,
          ),
          result: (data) {
            LogUtils.showLogs(message: "boddy:::${data.toJson()}");
            AppPreference.setBoolean(AppPreference.onboardingDone, value: true);
            AppConstant().userLoginType = LoginType.email.name;
            phoneController.text = "";
            redirectUser(data, loginType: "email");
          },
          loading: handleLoading,
        );
      }

      handleLoading(false);
    }
  }

  static const _googleWebClientId =
      '59887336692-hlpf5ohel9i5misjild4ahb42hjt5c9c.apps.googleusercontent.com';

  GoogleSignIn _createGoogleSignIn() => GoogleSignIn(
    scopes: ['email'],
    serverClientId: Platform.isIOS ? _googleWebClientId : null,
  );

  GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email'],
    serverClientId: Platform.isIOS ? _googleWebClientId : null,
  );

  String googleEmail = "";

  Future<UserLoginModel> _googleAuthLogin() async {
    try {
      if (!BuildConfig.firebaseEnabled) {
        throw StateError('Firebase Auth is disabled for this build.');
      }

      profileImage = "";
      if (_auth.currentUser != null) {
        try {
          await _createGoogleSignIn().signOut();
        } catch (_) {}
        await _auth.signOut();
      }

      final UserCredential userCredential;
      if (Platform.isAndroid) {
        final GoogleAuthProvider provider = GoogleAuthProvider();
        provider.addScope('email');
        userCredential = await _auth.signInWithProvider(provider);
      } else {
        _googleSignIn = _createGoogleSignIn();
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
        if (googleUser == null) {
          throw "User are close";
        }
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        userCredential = await _auth.signInWithCredential(credential);
      }

      googleEmail = userCredential.user?.email ?? "";
      profileImage = userCredential.user?.photoURL ?? "";
      String name = userCredential.user?.displayName ?? "";

      // print(">>>>>>>${userCredential.user?.photoURL??""}");

      await _ensureFcmToken();
      return await AuthService.googleLogin(
        fUid: _firebaseUid,
        email: userCredential.user?.email ?? "",
        fcmToken: FireBaseNotification().fcmToken,
        type: "google",
        profileImage: profileImage,
        name: name,
      );
    } catch (e, st) {
      LogUtils.printWhite("ERROR:::$e\n\n$st");
      log(">>>>>>>>>>>>>>>>$e, $st");
      if (e == "User are close") {
      } else if (e.toString() ==
          "PlatformException(sign_in_failed, com.google.GIDSignIn, access_denied, null)") {
      } else {
        AppSnackBar.showErrorSnackBar(message: e.toString(), isError: true);
      }

      rethrow;
    }
  }

  Future googleLogin() async {
    processApi(
      () => _googleAuthLogin(),
      result: (data) {
        LogUtils.showLogs(message: "boddy:::$data");
        AppPreference.setBoolean(AppPreference.onboardingDone, value: true);
        AppConstant().userLoginType = LoginType.google.name;

        phoneController.text = "";

        redirectUser(data, loginType: "google");
      },
      loading: handleLoading,
    );
  }

  Future<UserLoginModel> _appleUserLogin() async {
    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );

    String appleToken = appleCredential.identityToken ?? "";
    Map<String, dynamic> decodedToken = JwtDecoder.decode(appleToken);

    log(">>>>>>>${decodedToken}");

    String userEmail = decodedToken["email"];
    googleEmail = userEmail;
    String userId = decodedToken["sub"];
    String userName = appleCredential.givenName ?? "";

    await _ensureFcmToken();

    return await AuthService.googleLogin(
      email: googleEmail,
      fcmToken: FireBaseNotification().fcmToken,
      type: "apple",
      name: userName,
      id: userId,
      fUid: _firebaseUid,
    );
  }

  Future appleLogin() async {
    processApi(
      () => _appleUserLogin(),
      result: (data) {
        AppPreference.setBoolean(AppPreference.onboardingDone, value: true);
        AppConstant().userLoginType = LoginType.google.name;
        phoneController.text = "";

        redirectUser(data, loginType: "apple");
      },
      loading: handleLoading,
    );
  }

  String loginType = "";

  Future<void> redirectUser(
    UserLoginModel data, {
    bool isOtp = false,
    required String loginType,
  }) async {
    print(">>>>>>redirect    asdasd${data.toJson()}");
    clearTextField();
    this.loginType = loginType;
    AppPreference.setString(AppPreference.userToken, data.token ?? "");
    AppPreference.setString(AppPreference.userId, data.user?.id ?? "");
    if (data.user?.isRegister == "1") {
      AppPreference.setBoolean(AppPreference.userLogin, value: true);
      Navigation.replaceAll(Routes.dashboardScreen);
    } else {
      handleLoading(false);
      try {
        rEmailController.text = data.user?.email ?? "";
        phoneController.text = data.user?.phone ?? "";
        fullNameController.text = data.user?.name ?? "";
        String countryCodes = (data.user?.countryCode ?? "").isEmpty
            ? "+36"
            : data.user?.countryCode ?? "";

        print(">>>>${data.user?.email}:::::${rEmailController.text}");
        String code = countryCodes.split("+").last;

        countryCode.value = countryCodes;
        selectedDialogCountry.value = CountryPickerUtils.getCountryByPhoneCode(
          code,
        );

        AuthPhoneEmailModel model = AuthPhoneEmailModel(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
          countryCode: data.user?.countryCode ?? "+36",
          phone: data.user?.phone ?? "",
        );
        if (isOtp) {
          Navigation.replace(Routes.registerScreen, arguments: model);
        } else {
          Navigation.pushNamed(Routes.registerScreen, arg: model);
        }
        AppPreference.setString(
          AppPreference.userLoginDetailsModel,
          jsonEncode(model.toJson()),
        );
      } catch (e, st) {
        LogUtils.printWhite("ERROR:::$e, $st");
      }
    }
  }

  // todo: SinUp

  TextEditingController fullNameController = TextEditingController();
  TextEditingController referralController = TextEditingController();
  RxString gender = "Male".obs;

  Future<void> userRegister() async {
    await _ensureFcmToken();

    processApi(
      () => AuthService.registerUser(
        gender: gender.value,
        phone: phoneController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        fcmToken: FireBaseNotification().fcmToken,
        fullName: fullNameController.text.trim(),
        referral: referralController.text.trim(),
        countryCode: countryCode.value,
      ),
      result: (result) {
        AppPreference.setUserModel(result.user);

        // AppPreference.setString(AppPreference.userToken, result.token ?? "");   // api response not give the token
        LogUtils.printSuccess(result.toString());
        AppPreference.setBoolean(AppPreference.userLogin, value: true);
        Navigation.pushNamed(Routes.termServiceScreen);
      },
      loading: handleLoading,
    );
  }
}
