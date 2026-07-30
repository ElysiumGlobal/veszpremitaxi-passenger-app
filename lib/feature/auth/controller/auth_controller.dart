import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:e_taxi/core/api/exception/app_exception.dart';
import 'package:e_taxi/core/auth/firebase_session.dart';
import 'package:e_taxi/core/debug/passenger_flow_debug.dart';
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
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
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

  firebase_auth.FirebaseAuth get _auth {
    if (!BuildConfig.firebaseEnabled) {
      throw StateError('Firebase Auth is disabled for this build.');
    }
    return firebase_auth.FirebaseAuth.instance;
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

  Future<String> _firebaseIdToken() async {
    return FirebaseSession.idToken();
  }

  String _firebaseErrorMessage(firebase_auth.FirebaseAuthException error) {
    switch (error.code) {
      case 'invalid-email':
        return 'Az e-mail-cím formátuma hibás.';
      case 'weak-password':
        return 'A jelszó legalább 6 karakter legyen.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Hibás e-mail-cím vagy jelszó.';
      case 'user-disabled':
        return 'Ez a felhasználói fiók le van tiltva.';
      case 'too-many-requests':
        return 'Túl sok sikertelen próbálkozás történt. Próbáld újra később.';
      case 'network-request-failed':
        return 'Nincs megfelelő internetkapcsolat.';
      case 'operation-not-allowed':
        return 'Ez a belépési mód még nincs engedélyezve.';
      case 'account-exists-with-different-credential':
        return 'Ehhez az e-mail-címhez már más belépési mód tartozik.';
      default:
        return error.message ?? 'A belépés nem sikerült. Próbáld újra.';
    }
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
        verificationCompleted:
            (firebase_auth.PhoneAuthCredential credential) async {},
        verificationFailed: (firebase_auth.FirebaseAuthException e) {
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
      final firebase_auth.PhoneAuthCredential credential =
          firebase_auth.PhoneAuthProvider.credential(
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
        firebaseIdToken: await _firebaseIdToken(),
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

  Future<Map<String, dynamic>> firbaseEmailLogin({
    required String email,
    required String password,
  }) async {
    final Map<String, dynamic> result = <String, dynamic>{
      'old': true,
      'done': false,
      'verification_sent': false,
    };

    if (!BuildConfig.firebaseEnabled) return result;

    try {
      final firebase_auth.UserCredential credential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      result['done'] = true;
      result['old'] = false;

      try {
        await credential.user?.sendEmailVerification();
        result['verification_sent'] = true;
      } catch (error) {
        LogUtils.printAction('Verification email warning::$error');
      }

      return result;
    } on firebase_auth.FirebaseAuthException catch (error) {
      if (error.code != 'email-already-in-use') {
        AppSnackBar.showErrorSnackBar(
          message: _firebaseErrorMessage(error),
          isError: true,
        );
        return result;
      }

      try {
        await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        result['done'] = true;
        result['old'] = true;
        return result;
      } on firebase_auth.FirebaseAuthException catch (signInError) {
        AppSnackBar.showErrorSnackBar(
          message: _firebaseErrorMessage(signInError),
          isError: true,
        );
        return result;
      }
    }
  }

  String profileImage = "";

  Future<void> emailLogin() async {
    final String email = emailController.text.trim();
    final String password = passwordController.text.trim();

    dynamic emailState;
    try {
      emailState = await AuthService.emailCheck(email: email);
    } catch (error) {
      LogUtils.printAction('Email check warning::$error');
    }

    final dynamic data = emailState is Map ? emailState['data'] : null;
    final String loginDevice = data is Map
        ? (data['login_device'] ?? '').toString().toLowerCase()
        : '';
    final bool backendAccountExists = data is Map && loginDevice.isNotEmpty;

    if (backendAccountExists && loginDevice != 'email') {
      AppSnackBar.showErrorSnackBar(
        message:
            'Ez az e-mail-cím korábban más belépési móddal lett regisztrálva.',
        isError: true,
      );
      return;
    }

    if (!BuildConfig.firebaseEnabled) {
      AppSnackBar.showErrorSnackBar(
        message: 'A biztonságos belépési szolgáltatás nem érhető el.',
        isError: true,
      );
      return;
    }

    handleLoading(true);
    try {
      // A már létező Laravel-fiókokat előbb a régi jelszóval ellenőrizzük.
      // Így hibás jelszóval nem jöhet létre külön Firebase-fiók.
      if (backendAccountExists) {
        await AuthService.emailLogin(
          email: email,
          pass: password,
          fcmToken: '',
          loginType: 'email',
          fUid: '',
        );
      }

      final Map<String, dynamic> firebaseResult = await firbaseEmailLogin(
        email: email,
        password: password,
      );

      if (firebaseResult['done'] != true) return;

      await _ensureFcmToken();
      final UserLoginModel result = await AuthService.emailLogin(
        email: email,
        pass: password,
        fcmToken: FireBaseNotification().fcmToken,
        loginType: 'email',
        fUid: _firebaseUid,
        firebaseIdToken: await _firebaseIdToken(),
      );

      await AppPreference.setBoolean(
        AppPreference.onboardingDone,
        value: true,
      );
      AppConstant().userLoginType = LoginType.email.name;
      phoneController.clear();

      if (firebaseResult['verification_sent'] == true) {
        AppSnackBar.showErrorSnackBar(
          message:
              'A fiók létrejött. Küldtünk egy e-mailes megerősítő linket is.',
          dismisDuration: 5,
        );
      }

      await redirectUser(result, loginType: 'email');
    } on firebase_auth.FirebaseAuthException catch (error) {
      AppSnackBar.showErrorSnackBar(
        message: _firebaseErrorMessage(error),
        isError: true,
      );
    } on AppException catch (error, stack) {
      LogUtils.printError('Laravel email login error::$error\n$stack');
      // A ResponseHandler már megjelenítette a szerver pontos üzenetét.
    } catch (error, stack) {
      LogUtils.printError('Firebase email login error::$error\n$stack');
      AppSnackBar.showErrorSnackBar(
        message: 'A belépés nem sikerült. Próbáld újra.',
        isError: true,
      );
    } finally {
      handleLoading(false);
    }
  }

  static const String _googleWebClientId =
      '938558243123-61g4sf2rcuju7dp7bjht413k57phq916.apps.googleusercontent.com';

  late final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: <String>['email', 'profile'],
    serverClientId: _googleWebClientId,
  );

  String googleEmail = "";

  Future<UserLoginModel?> _googleAuthLogin() async {
    if (!BuildConfig.googleLoginEnabled) {
      throw StateError('Google login is disabled for this build.');
    }

    profileImage = "";

    try {
      await _googleSignIn.signOut();
    } catch (_) {
      // The first login has no previous Google session.
    }

    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null;

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final firebase_auth.AuthCredential credential =
        firebase_auth.GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final firebase_auth.UserCredential userCredential =
        await _auth.signInWithCredential(credential);
    final firebase_auth.User? firebaseUser = userCredential.user;

    googleEmail = firebaseUser?.email ?? googleUser.email;
    profileImage = firebaseUser?.photoURL ?? '';
    final String name =
        firebaseUser?.displayName ?? googleUser.displayName ?? '';

    await _ensureFcmToken();
    return AuthService.googleLogin(
      fUid: firebaseUser?.uid ?? '',
      email: googleEmail,
      fcmToken: FireBaseNotification().fcmToken,
      type: 'google',
      profileImage: profileImage,
      name: name,
      id: googleUser.id,
      firebaseIdToken: await _firebaseIdToken(),
    );
  }

  Future<void> googleLogin() async {
    if (!BuildConfig.googleLoginEnabled) {
      AppSnackBar.showErrorSnackBar(
        message: 'A Google-belépés jelenleg nem érhető el.',
        isError: true,
      );
      return;
    }

    handleLoading(true);
    try {
      final UserLoginModel? data = await _googleAuthLogin();
      if (data == null) return;

      await AppPreference.setBoolean(
        AppPreference.onboardingDone,
        value: true,
      );
      AppConstant().userLoginType = LoginType.google.name;
      phoneController.clear();
      await redirectUser(data, loginType: 'google');
    } on firebase_auth.FirebaseAuthException catch (error) {
      AppSnackBar.showErrorSnackBar(
        message: _firebaseErrorMessage(error),
        isError: true,
      );
    } catch (error, stack) {
      LogUtils.printError('Google login error::$error\n$stack');
      AppSnackBar.showErrorSnackBar(
        message: 'A Google-belépés nem sikerült. Próbáld újra.',
        isError: true,
      );
    } finally {
      handleLoading(false);
    }
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
      firebaseIdToken: await _firebaseIdToken(),
    );
  }

  Future appleLogin() async {
    if (!BuildConfig.appleLoginEnabled) {
      AppSnackBar.showErrorSnackBar(
        message: 'Az Apple-belépés a saját alkalmazásfiók bekötése után aktiválódik.',
        isError: true,
      );
      return;
    }

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
    clearTextField();
    this.loginType = loginType;

    final String token = (data.token ?? '').trim();
    if (token.isEmpty) {
      AppSnackBar.showErrorSnackBar(
        message: 'A szerver nem adott érvényes belépési tokent.',
        isError: true,
      );
      return;
    }

    await AppPreference.setString(AppPreference.userToken, token);
    await AppPreference.setString(
      AppPreference.userId,
      data.user?.id ?? '',
    );

    final bool profilePending = data.user?.isRegister != '1';
    await AppPreference.setBoolean(
      AppPreference.profileCompletionPending,
      value: profilePending,
    );
    await AppPreference.setBoolean(AppPreference.userLogin, value: true);

    PassengerFlowDebug.send(
      'passenger_auth_token_saved',
      data: <String, dynamic>{
        'token_present': true,
        'expected_collector_version':
            PassengerFlowDebug.expectedCollectorVersion,
        'login_type': loginType,
        'profile_completion_pending': profilePending,
      },
    );
    PassengerFlowDebug.kick();

    if (profilePending) {
      AppSnackBar.showErrorSnackBar(
        message:
            'Sikeres belépés. A telefonszámot és a fizetési adatokat az első fizetés előtt kérjük el.',
        dismisDuration: 5,
      );
    }

    Navigation.replaceAll(Routes.dashboardScreen);
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
