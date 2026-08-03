import 'dart:developer';

import 'package:country_pickers/country.dart';
import 'package:country_pickers/country_pickers.dart';
import 'package:e_taxi/utils/assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../feature/auth/controller/auth_controller.dart';
import 'app_colors.dart';
import 'app_string.dart';

class CountryPickerWidget extends StatelessWidget {
  CountryPickerWidget({
    super.key,
    required this.phoneController,
    required this.country,
  });

  final TextEditingController phoneController;
  final Country country;
  final AuthController _authController = Get.find();

  @override
  Widget build(BuildContext context) {
    return getTextFieldPrefix(context);
  }

  Widget getTextFieldPrefix(BuildContext context) {
    return InkWell(
      onTap: () async {
        _openCountryPickerDialog(context);
      },
      child: Padding(
        padding: EdgeInsets.only(left: 20.w),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: CountryPickerUtils.getDefaultFlagImage(country),
            ),
            4.horizontalSpace,
            Image.asset(IconAsset.arrowDown, height: 16.w, width: 16.w),
            12.horizontalSpace,
            Container(
              width: 2,
              height: 15,
              color: AppColors.textFieldBorderColor,
            ),
          ],
        ),
      ),
    );
  }

  void _openCountryPickerDialog(BuildContext context) => showDialog<void>(
    context: context,
    builder: (context) => CountryPickerDialog(
      titlePadding: const EdgeInsets.all(6.0),
      searchCursorColor: AppColors.textPrimaryColor,
      searchInputDecoration: InputDecoration(
        fillColor: AppColors.whiteColor,
        filled: true,
        disabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: AppColors.whiteColor),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: AppColors.whiteColor),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: AppColors.whiteColor),
        ),
        hintText: AppString.searchCountry.tr,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      ),
      isSearchable: true,
      title: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Text(
          AppString.selectCountry.tr,
          style: TextStyle(
            color: AppColors.textPrimaryColor,
            fontStyle: FontStyle.normal,
            fontWeight: FontWeight.w500,
            fontSize: 14.sp,
          ),
        ),
      ),
      onValuePicked: (Country country) {
        country = country;
        phoneController.text = "+${country.phoneCode}";
        _authController.countryCode("+${country.phoneCode}");
        _authController.selectedDialogCountry.value =
            CountryPickerUtils.getCountryByPhoneCode(country.phoneCode);
        log("selectedDialogCountry ${country.phoneCode}");
      },
      itemBuilder: _buildDialogItem,
    ),
  );

  Widget _buildDialogItem(Country country) => Row(
    children: <Widget>[
      CountryPickerUtils.getDefaultFlagImage(country),
      const SizedBox(width: 8.0),
      Text(
        "+${country.phoneCode}",
        style: TextStyle(
          color: AppColors.textPrimaryColor,
          fontStyle: FontStyle.normal,
          fontWeight: FontWeight.w500,
          fontSize: 12.sp,
        ),
      ),
      const SizedBox(width: 10.0),
      Flexible(
        child: Text(
          country.name,
          style: TextStyle(
            color: AppColors.textPrimaryColor,
            fontStyle: FontStyle.normal,
            fontWeight: FontWeight.w500,
            fontSize: 12.sp,
          ),
        ),
      ),
    ],
  );
}

class CountryPickerWidget1 extends StatelessWidget {
  CountryPickerWidget1({
    super.key,
    required this.phoneController,
    required this.country,
    required this.onTap,
    this.padding,
  });

  final TextEditingController phoneController;
  final Country country;
  final double? padding;

  final Function(dynamic) onTap;

  @override
  Widget build(BuildContext context) {
    return getTextFieldPrefix(context);
  }

  Widget getTextFieldPrefix(BuildContext context) {
    return InkWell(
      onTap: () async {
        _openCountryPickerDialog(context);
      },
      child: Padding(
        padding: EdgeInsets.only(left: padding ?? 20.w),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: CountryPickerUtils.getDefaultFlagImage(country),
            ),
            4.horizontalSpace,
            Image.asset(IconAsset.arrowDown, height: 16.w, width: 16.w),
            12.horizontalSpace,
            Container(
              width: 2,
              height: 15,
              color: AppColors.textFieldBorderColor,
            ),
          ],
        ),
      ),
    );
  }

  void _openCountryPickerDialog(BuildContext context) => showDialog<void>(
    context: context,
    builder: (context) => CountryPickerDialog(
      titlePadding: const EdgeInsets.all(6.0),
      searchCursorColor: AppColors.textPrimaryColor,
      searchInputDecoration: InputDecoration(
        fillColor: AppColors.whiteColor,
        filled: true,
        disabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: AppColors.whiteColor),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: AppColors.whiteColor),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: AppColors.whiteColor),
        ),
        hintText: AppString.searchCountry.tr,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      ),
      isSearchable: true,
      title: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Text(
          AppString.selectCountry.tr,
          style: TextStyle(
            color: AppColors.textPrimaryColor,
            fontStyle: FontStyle.normal,
            fontWeight: FontWeight.w500,
            fontSize: 14.sp,
          ),
        ),
      ),
      onValuePicked: (Country country) {
        country = country;
        phoneController.text = "+${country.phoneCode}";
        onTap(country);
        log("selectedDialogCountry ${country.phoneCode}");
      },
      itemBuilder: _buildDialogItem,
    ),
  );

  Widget _buildDialogItem(Country country) => Row(
    children: <Widget>[
      CountryPickerUtils.getDefaultFlagImage(country),
      const SizedBox(width: 8.0),
      Text(
        "+${country.phoneCode}",
        style: TextStyle(
          color: AppColors.textPrimaryColor,
          fontStyle: FontStyle.normal,
          fontWeight: FontWeight.w500,
          fontSize: 12.sp,
        ),
      ),
      const SizedBox(width: 10.0),
      Flexible(
        child: Text(
          country.name,
          style: TextStyle(
            color: AppColors.textPrimaryColor,
            fontStyle: FontStyle.normal,
            fontWeight: FontWeight.w500,
            fontSize: 12.sp,
          ),
        ),
      ),
    ],
  );
}
