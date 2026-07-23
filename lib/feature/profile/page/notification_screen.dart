import 'package:e_taxi/feature/profile/controller/profile_controller.dart';
import 'package:e_taxi/utils/app_colors.dart';
import 'package:e_taxi/utils/app_string.dart';
import 'package:e_taxi/widgets/appbar.dart';
import 'package:e_taxi/widgets/common_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../utils/assets.dart';
import '../../../utils/utils.dart';
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
    profileController.getNotificaionList();
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 300 &&
          profileController.notiPaginationLoading.value == false &&
          profileController.isMoreNotiDataAvailable) {
        profileController.notiPaginationLoading(true);
        profileController.getNotificaionList(isFirstTime: false);
      }
    });
  }

  ProfileController profileController = Get.find<ProfileController>();

  ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteGrey,
      appBar: CustomAppBar(
        title: AppString.notification.tr,
        centerTitle: false,
      ),
      body: SafeArea(
        bottom: Utils().checkPlatForm,

        child: Obx(
          () => profileController.notificationLoading.value
              ? const LoadingShimmer()
              : profileController.notificationList.isEmpty
              ? NoDataWidget(
                  icon: ImagesAsset.noData,
                  title: AppString.noDataAvailable.tr,
                  subTitle: AppString.weNotFindAnything.tr,
                  onTap: () {
                    profileController.getNotificaionList();
                  },
                )
              : ListView.separated(
                  physics: AlwaysScrollableScrollPhysics(),
                  separatorBuilder: (context, index) => 8.verticalSpace,
                  itemCount: profileController.notificationList.length,
                  itemBuilder: (context, index) {
                    final data = profileController.notificationList[index];
                    return NotiWidget(
                      key: ValueKey(index),
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
