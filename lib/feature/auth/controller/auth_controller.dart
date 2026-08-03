import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:country_pickers/country.dart';
import 'package:country_pickers/utils/utils.dart';
import 'package:e_taxi/utils/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../../core/service/firebase_notification_new.dart';
import '../../../utils/app_preferences.dart';
import '../../../utils/app_string.dart';
import '../../../utils/common_api_caller.dart';
import '../../../utils/enum.dart';
import '../../../utils/loading_mixin.dart';
import '../../../utils/log_utils.dart';
import '../../../utils/navigation_utils/navigation.dart';
import '../../../utils/navigation_utils/routes.dart';
import '../../../widgets/app_snackbar.dart';
import '../model/user_login_model.dart';
import '../service/auth_service.dart';

class AuthController extends GetxController with LoadingMixin, LoadingApiMixin {
  final RxString countryCode = "+91".obs;

  final Rx<Country> selectedDialogCountry =
      CountryPickerUtils.getCountryByPhoneCode("91").obs;

  String email = "";
  String password = "";

  TextEditingController phoneController = TextEditingController();

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
        print(">>>>>>>>>$result");
        startTimer();
        if (resend == false) {
          Navigation.pushNamed(Routes.otpVerifyScreen);
        }
      },
      error: (error, stack) {
        handleLoading(false);
      },
      loading: handleLoading,
    );
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _verificationId;

  Future<void> firebaseOtpSend({bool isResend = false}) async {
    handleLoading(true);
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: "${countryCode.value}${phoneController.text.trim()}",
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {},
        verificationFailed: (FirebaseAuthException e) {
          log("Fail::::::::$e");
          handleLoading(false);
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
          log("RETRIVE::::::::");
          handleLoading(false);
        },
      );
    } catch (e) {
      log("ERRROR :::$e ");
      handleLoading(false);
    }
  }

  Future<void> firebaseOtpVerify(String otp) async {
    handleLoading(true);
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otp,
      );

      await _auth.signInWithCredential(credential);
      if (FireBaseNotification().FcmToken.isEmpty) {
        try {
          FireBaseNotification().FcmToken =
              (await FirebaseMessaging.instance.getToken()) ?? "";
        } catch (e) {}
      }
      final result = await AuthService.FirebaseVerifyOtp(
        phone: phoneController.text.trim(),
        fcm: FireBaseNotification().FcmToken,
        countryCode: countryCode.value,
        fUid: FirebaseAuth.instance.currentUser?.uid ?? "",
      );
      AppPreference.setBoolean(
        AppPreference.onboardingDone,
        value: true,
      );
      AppPreference.setString(AppPreference.userToken, result.token ?? "");

      Constants.userLoginType = LoginType.phone.name;

      redirectUser(result, isOtp: true);
    } catch (e, st) {
      handleLoading(false);
      LogUtils.printError("ERROR ::::::$e, $st");
      AppSnackBar.showErrorSnackBar(
        message: "Enter the correct verification code",
        isError: true,
      );
    } finally {
      handleLoading(false);
    }
  }

  void redirectUser(UserLoginModel? result, {isOtp = false}) {
    if (result != null) {
      AppPreference.setString(AppPreference.userId, result.driver?.id ?? "");
      if ((result.driver?.isRegister ?? "0") == "0") {
        Map data = {
          "phone": result.driver?.phone ?? "",
          "countryCode": result.driver?.countryCode ?? "+91",
          "email": result.driver?.email ?? "",
          "name": result.driver?.name ?? "",
        };
        handleLoading(false);
        AppPreference.setString(AppPreference.userInitData, jsonEncode(data));

        if (result.driver?.step0 == "0") {
          if (isOtp) {
            Navigation.replace(Routes.locationSetScreen, arguments: data);
          } else {
            Navigation.pushNamed(Routes.locationSetScreen, arg: data);
          }
        } else if (result.driver?.step1 == "0") {
          AppPreference.setInt(AppPreference.userStep, 1);
          if (isOtp) {
            Navigation.replace(Routes.profileSetUpScreen, arguments: data);
          } else {
            Navigation.pushNamed(Routes.profileSetUpScreen, arg: data);
          }
        } else if (result.driver?.step2 == "0") {
          AppPreference.setInt(AppPreference.userStep, 2);

          if (isOtp) {
            Navigation.replace(Routes.vehicleSetupScreen);
          } else {
            Navigation.pushNamed(Routes.vehicleSetupScreen);
          }
        } else if (result.driver?.step3 == "0") {
          AppPreference.setInt(AppPreference.userStep, 3);
          Navigation.replace(Routes.documentScreen);
          if (isOtp) {
            Navigation.replace(Routes.documentScreen);
          } else {
            Navigation.pushNamed(Routes.documentScreen);
          }
        } else if (result.driver?.isVerified == "1") {
          AppPreference.setBoolean(AppPreference.profileApprove, value: true);
          AppPreference.setInt(AppPreference.userStep, 4);

          Navigation.replaceAll(Routes.homeScreen);
        } else {
          AppPreference.setInt(AppPreference.userStep, 4);
          Navigation.replaceAll(Routes.accountDeActiveScreen);
        }
      } else {
        AppPreference.setInt(AppPreference.userStep, 4);
        if (result.driver?.isVerified == "1") {
          log(">><<<${result.driver?.toJson()}");
          AppPreference.setBoolean(AppPreference.profileApprove, value: true);
          Navigation.replaceAll(Routes.homeScreen);
        } else {
          Navigation.replaceAll(Routes.accountDeActiveScreen);
        }
      }
    }
  }

  Future<Map> firbaseEmailLogin({
    required String email,
    required String password,
    required bool isAdmin,
  }) async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    Map res = {'old': true, "done": false};

    try {
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      print("✅ Logged in as ${userCredential.user!.email}");

      res['done'] = true;
      res['old'] = false;
      if (isAdmin == false) {
        AppSnackBar.showErrorSnackBar(
          message: "${AppString.emailVeriflinkSend} $email",
          dismisDuration: 10,
          isError: true,
        );
        FirebaseAuth.instance.currentUser?.sendEmailVerification();
      }

      return res;
    } on FirebaseAuthException catch (e) {
      print("ECODE::::::${e.code}");
      if (e.code == 'email-already-in-use') {
        print("👤 User not found, creating new account...");
        try {
          UserCredential newUser = await auth.signInWithEmailAndPassword(
            email: email,
            password: password,
          );
          print("✅ New account created for ${newUser.user!.email}");

          res['done'] = true;
          return res;
        } on FirebaseAuthException catch (createError) {
          print("❌ Error creating user: ${createError.message}");
          handleLoading(false);
          AppSnackBar.showErrorSnackBar(
            message: "${createError.code}",
            isError: true,
          );

          return res;
        }
      } else if (e.code == 'wrong-password') {
        print("❌ Wrong password for this account");
        handleLoading(false);
        AppSnackBar.showErrorSnackBar(
          message: AppString.wrongPassword.tr,
          isError: true,
        );
        return res;
      } else {
        print(
          "❌ Auth error: ${e.message}:: email:$email >>password::  $password",
        );
        handleLoading(false);
        AppSnackBar.showErrorSnackBar(message: "Try Again", isError: true);
        return res;
      }
    }
  }

  Future<dynamic> emailLogin() async {
    var data;
    handleLoading(true);
    try {
      data = await AuthService.emailCheck(email: email);
    } catch (e) {}

    if (data['data']['is_register'] == 1 &&
        data['data']['login_device'] != "email") {
      handleLoading(false);
      AppSnackBar.showErrorSnackBar(
        message: AppString.emailAlreadyRegister.tr,
        isError: true,
      );
      return;
    } else {
      Map result = await firbaseEmailLogin(
        email: email,
        password: password,
        isAdmin: (data['data']['is_demo'] ?? 0) == 1,
      );
      if (result['done']) {
        FirebaseAuth.instance.currentUser?.reload();
        if (FirebaseAuth.instance.currentUser?.emailVerified == false &&
            data['data']['is_demo'] == 0) {
          if (result['old']) {
            FirebaseAuth.instance.currentUser?.sendEmailVerification();
            AppSnackBar.showErrorSnackBar(
              message: AppString.emailnotVerified,
              dismisDuration: 10,
              isError: true,
            );
          }
          handleLoading(false);
          return;
        }

        if (FireBaseNotification().FcmToken.isEmpty) {
          try {
            FireBaseNotification().FcmToken =
                (await FirebaseMessaging.instance.getToken()) ?? "";
          } catch (e) {}
        }
        await processApi(
          () => AuthService.emailLogin(
            email: email,
            pass: password,
            fcmToken: FireBaseNotification().FcmToken,
            loginType: "email",
            fUid: FirebaseAuth.instance.currentUser?.uid ?? "",
          ),
          result: (data) {
            AppPreference.setBoolean(AppPreference.onboardingDone, value: true);

            AppPreference.setString(AppPreference.userToken, data.token ?? "");
            Constants.userLoginType = LoginType.email.name;

            redirectUser(data);
          },
          error: (error, stack) {
            handleLoading(false);
          },
          loading: handleLoading,
        );
      }
    }
  }


  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<UserLoginModel> _googleAuthLogin() async {
    try {
      if (FirebaseAuth.instance.currentUser != null) {
        await GoogleSignIn().signOut();
      }
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
      final UserCredential userCredential = await FirebaseAuth.instance
          .signInWithCredential(credential);

      email = userCredential.user?.email ?? "";

      if (FireBaseNotification().FcmToken.isEmpty) {
        try {
          FireBaseNotification().FcmToken =
              (await FirebaseMessaging.instance.getToken()) ?? "";
        } catch (e) {}
      }

      return await AuthService.googleLogin(
        email: userCredential.user?.email ?? "",
        fcmToken: FireBaseNotification().FcmToken,
        type: "google",
        name: userCredential.user?.displayName ?? "",
        profileImage: userCredential.user?.photoURL ?? "",
        fUid: FirebaseAuth.instance.currentUser?.uid ?? "",
      );
    } catch (e, st) {
      print("ERROR:::$e\n\n$st");
      if (e == "User are close" ||
          e.toString() ==
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
        AppPreference.setString(AppPreference.userToken, data.token ?? "");

        Constants.userLoginType = LoginType.google.name;

        redirectUser(data);
      },
      error: (error, stack) {
        handleLoading(false);
      },
      loading: handleLoading,
    );
  }


  Future<UserLoginModel> _appleUserLogin() async {
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      String appleToken = appleCredential.identityToken ?? "";
      Map<String, dynamic> decodedToken = JwtDecoder.decode(appleToken);

      String userEmail = decodedToken["email"];
      email = userEmail;
      String userId = decodedToken["sub"];
      String userName = "${appleCredential.givenName ?? ""}";

      if (FireBaseNotification().FcmToken.isEmpty) {
        try {
          FireBaseNotification().FcmToken =
              (await FirebaseMessaging.instance.getToken()) ?? "";
        } catch (e) {}
      }
      return await AuthService.googleLogin(
        email: email,
        fcmToken: FireBaseNotification().FcmToken,
        type: "apple",
        id: userId,
        name: userName,
        fUid: FirebaseAuth.instance.currentUser?.uid ?? "",
      );
    } catch (e) {
      rethrow;
    }
  }

  Future appleLogin() async {
    processApi(
      () => _appleUserLogin(),
      result: (data) {
        AppPreference.setBoolean(AppPreference.onboardingDone, value: true);
        AppPreference.setString(AppPreference.userToken, data.token ?? "");
        Constants.userLoginType = LoginType.apple.name;
        redirectUser(data);
      },
      error: (error, stack) {
        handleLoading(false);
      },
      loading: handleLoading,
    );
  }
}
