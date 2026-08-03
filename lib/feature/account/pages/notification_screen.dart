import 'package:e_taxi/feature/account/controller/account_controller.dart';
import 'package:e_taxi/utils/app_colors.dart';
import 'package:e_taxi/utils/app_string.dart';
import 'package:e_taxi/utils/utils.dart';
import 'package:e_taxi/widgets/appbar.dart';
import 'package:e_taxi/widgets/common_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../utils/assets.dart';
import '../../../widgets/no_data_widget.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _accountController.getNotificaionList();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 300 &&
          _accountController.notiPaginationLoading.value == false &&
          _accountController.isMoreNotiDataAvailable) {
        _accountController.notiPaginationLoading(true);
        _accountController.getNotificaionList(isFirstTime: false);
      }
    });
  }

  AccountController _accountController = Get.find<AccountController>();

  ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: AppString.notification.tr,
        centerTitle: false,
      ),
      body: SafeArea(
        bottom: Utils().checkPlatForm,

        child: Obx(
          () => _accountController.notificationLoading.value
              ? const LoadingShimmer()
              : _accountController.notificationList.isEmpty
              ? NoDataWidget(
                  icon: ImagesAsset.noData,
                  title: AppString.noDataAvailable.tr,
                  subTitle: AppString.weNotFindAnything.tr,
                  onTap: () {
                    _accountController.getNotificaionList();
                  },
                )
              : ListView.separated(
                  physics: AlwaysScrollableScrollPhysics(),
                  separatorBuilder: (context, index) => 8.verticalSpace,
                  itemCount: _accountController.notificationList.length,
                  itemBuilder: (context, index) {
                    final data = _accountController.notificationList[index];
                    return NotiWidget(
                      title: data.title ?? "",
                      subTitle: data.body ?? "",
                      time: Utils().getdateTimeDateWise(
                        date: data.sentAt ?? "",
                      ),
                    );
                  },
                ),
        ).paddingAll(16.w),
      ),
    );
  }
}

class NotiWidget extends StatelessWidget {
  const NotiWidget({
    required this.title,
    required this.subTitle,
    required this.time,
    super.key,
  });

  final String title;
  final String subTitle;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.textFieldBorderColor),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommonText(
            string: title,
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
          4.verticalSpace,
          CommonText(
            string: subTitle,
            color: AppColors.textCaptionColor,
            softWrap: true,
          ),
          4.verticalSpace,
          CommonText(
            string: time,
            color: AppColors.hintTextColor,
            fontSize: 12.sp,
          ),
        ],
      ),
    );
  }
}

class LoadingShimmer extends StatelessWidget {
  const LoadingShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: AlwaysScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return Skeletonizer(
          child: Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.textFieldBorderColor),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonText(
                  string: "title",
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
                4.verticalSpace,
                CommonText(
                  string: "subTitle",
                  color: AppColors.textCaptionColor,
                  softWrap: true,
                ),
                4.verticalSpace,
                CommonText(
                  string: "title",
                  color: AppColors.hintTextColor,
                  fontSize: 12.sp,
                ),
              ],
            ),
          ),
        );
      },
      separatorBuilder: (context, index) => 8.verticalSpace,
      itemCount: 4,
    );
  }
}
