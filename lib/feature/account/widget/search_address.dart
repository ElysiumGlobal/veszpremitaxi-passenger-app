import 'dart:async';

import 'package:e_taxi/feature/account/controller/account_controller.dart';
import 'package:e_taxi/feature/account/widget/add_location.dart';
import 'package:e_taxi/feature/account/widget/suggetion_address.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../utils/app_colors.dart';
import '../../../utils/app_string.dart';
import '../../../utils/assets.dart';
import '../../../widgets/appbar.dart';
import '../../../widgets/custom_textfeild.dart';

class SearchAddressScreen extends StatefulWidget {
  const SearchAddressScreen({super.key});

  @override
  State<SearchAddressScreen> createState() => _SearchAddressScreenState();
}

class _SearchAddressScreenState extends State<SearchAddressScreen> {
  final accountController = Get.find<AccountController>();
  TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: AppString.location.tr, centerTitle: false),
      body: SafeArea(
        child: Column(
          children: [
            CustomTextField(
              controller: searchController,
              hintText: "Where are you Going?",
              suffixIcon: IconAsset.search,
              enabled: true,

              onChanged: (search) {
                if ((search).isNotEmpty) {
                  if (accountController.debounce?.isActive ?? false)
                    accountController.debounce?.cancel();
                  accountController.debounce = Timer(
                    const Duration(milliseconds: 400),
                    () {
                      accountController.searchPlace(search);
                    },
                  );
                }
              },
            ),

            16.verticalSpace,

            Expanded(
              child: Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: AppColors.whiteColor,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Obx(
                  () => accountController.searchList.isEmpty
                      ? Center(child: Text("Search Here.."))
                      : ListView.separated(
                          separatorBuilder: (context, index) =>
                              Divider(color: AppColors.textFieldBorderColor),
                          itemCount: accountController.searchList.length,
                          itemBuilder: (context, index) {
                            final data = accountController.searchList[index];
                            return SuggestionAddressWidget(
                              title: (data.terms ?? []).isNotEmpty
                                  ? data.terms?.first.value ?? ""
                                  : "",
                              subTitle: data.description ?? "",
                              onTap: () async {
                                searchController.text =
                                    (data.terms ?? []).isNotEmpty
                                    ? data.terms?.first.value ?? ""
                                    : "";

                                final map = await accountController
                                    .getPlaceDetails(data.placeId ?? "");

                                if (map != null) {
                                  Get.to(
                                    () => AddLocationScreen(
                                      latLng: LatLng(
                                        map['geometry']['location']['lat'],
                                        map['geometry']['location']['lng'],
                                      ),
                                      location: map['formatted_address'],
                                      name: map['name'],
                                    ),
                                  );
                                }
                              },
                            );
                          },
                        ),
                ),
              ),
            ),
          ],
        ).paddingAll(16.w),
      ),
    );
  }
}
