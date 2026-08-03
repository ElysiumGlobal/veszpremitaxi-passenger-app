import 'dart:developer';

import 'package:country_phone_validator/country_phone_validator.dart';
import 'package:get/get.dart';

import '../core/api/exception/app_exception.dart';
import 'app_string.dart';

extension Validator on String {
  bool isValidEmail() {
    final RegExp regex = RegExp(
      r'^[a-zA-Z0-9]+(\.[a-zA-Z0-9]+)*@'
      r'[a-zA-Z0-9]+(\.[a-zA-Z0-9]+)+$',
    );

    if (isEmpty) {
      showError(AppString.pleaseEnterYourEmailAddress.tr);
      return false;
    } else if (!regex.hasMatch(this)) {
      showError(AppString.emailAddressIsInvalid.tr);
      return false;
    }
    return true;
  }

  bool isValidPassword() {
    String pattern = r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[^\w\s]).{6,}$';
    RegExp regex = RegExp(pattern);
    log(length.toString());
    if (isEmpty) {
      showError(AppString.pleaseEnterYourPassword.tr);
      return false;
    } else if (length < 6) {
      showError(AppString.passwordLengthMustBeAtLeast6CharacterLong.tr);
      return false;
    } else if (!regex.hasMatch(this)) {
      showError(
        AppString.passwordShouldContainUpperLowerDigitAndSpecialCharacter.tr,
      );
      return false;
    }
    return true;
  }

  bool isValidConfirmPassword(String firstPassword) {
    log(length.toString());
    if (isEmpty) {
      showError(AppString.pleaseEnterYourConfirmPassword.tr);
      return false;
    } else if (firstPassword != this) {
      showError(AppString.passwordDoesNotMatch.tr);
      return false;
    }
    return true;
  }

  bool textDataIsNotValid(String errorMsg) {
    if (isEmpty) {
      showError(errorMsg);
      return true;
    }
    return false;
  }

  bool phoneValid(String phoneNumber, String dialCode) {
    bool valid = CountryUtils.validatePhoneNumber(phoneNumber, dialCode);

    if (valid) {
      return true;
    } else {
      showError(AppString.pleaseEnterValidMobileNumber.tr);
      return false;
    }
  }

  bool isValidIndianVehicle() {
    if (isEmpty) {

      showError(AppString.pleaseEnterValidRegisterNumber.tr);

      return true;
    }
    return false;
  }
}

void showError(String message) {
  AppException(errorCode: 0, message: message).show();
}
