import 'package:e_taxi/feature/trip/controller/trip_controller.dart';
import 'package:e_taxi/feature/trip/widget/trip_card_widget.dart';
import 'package:e_taxi/utils/app_colors.dart';
import 'package:e_taxi/utils/app_string.dart';
import 'package:e_taxi/utils/assets.dart';
import 'package:e_taxi/widgets/appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../../utils/navigation_utils/navigation.dart';
import '../../../utils/navigation_utils/routes.dart';
import '../../../widgets/no_data_widget.dart';

class TripScreen extends StatefulWidget {
  const TripScreen({super.key});

  @override
  State<TripScreen> createState() => _TripScreenState();
}

class _TripScreenState extends State<TripScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    scrollController.addListener(() {
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 300 &&
          tripController.moreAvailable &&
          tripController.isPagination.value == false) {
        tripController.isPagination(true);
        tripController.getTripHistory(isFirst: false);
      }
    });
  }

  ScrollController scrollController = ScrollController();

  final tripController = Get.find<TripController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteGrey,
      appBar: CustomAppBar(
        title: AppString.myTrip.tr,
        centerTitle: false,
        leading: SizedBox(width: 16.w),
        leadingSize: 16.w,
      ),
      body: Padding(
        padding: EdgeInsetsGeometry.symmetric(horizontal: 16.w),
        child: Obx(
          () => tripController.loading.value
              ? Skeletonizer(
                  enabled: true,
                  child: ListView.separated(
                    separatorBuilder: (context, index) => 16.verticalSpace,
                    itemCount: 3,
                    itemBuilder: (context, index) {
                      return TripCardWidgetShimmer();
                    },
                  ),
                )
              : tripController.tripHistoryList.isEmpty
              ? RefreshIndicator(
                  onRefresh: () async {
                    await tripController.getTripHistory();
                  },
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        physics: AlwaysScrollableScrollPhysics(),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: IntrinsicHeight(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Spacer(),
                                NoDataWidget(
                                  icon: ImagesAsset.noData,
                                  title: AppString.noDataAvailable.tr,
                                  subTitle: AppString.weNotFindAnything.tr,
                                  onTap: () {},
                                ),
                                Spacer(),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    await tripController.getTripHistory();
                  },
                  child: ListView.separated(
                    physics: AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.only(top: 16.h, bottom: 16.h),
                    controller: scrollController,
                    separatorBuilder: (context, index) => 16.verticalSpace,
                    itemCount: tripController.isPagination.value
                        ? (1 + tripController.tripHistoryList.length)
                        : tripController.tripHistoryList.length,
                    itemBuilder: (context, index) {
                      if (index == tripController.tripHistoryList.length) {
                        return Center(
                          child: CircularProgressIndicator(),
                        ).paddingSymmetric(vertical: 4.h);
                      }

                      final data = tripController.tripHistoryList[index];

                      return GestureDetector(
                        onTap: () {
                          Navigation.pushNamed(
                            Routes.rideDetailsScreen,
                            arg: data,
                            params: {'index': "$index"},
                          );
                        },
                        child: TripCardWidget(tripHistory: data),
                      );
                    },
                  ),
                ),
        ),
      ),
    );
  }
}
