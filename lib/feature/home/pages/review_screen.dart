import 'package:e_taxi/feature/home/controller/home_controller.dart';
import 'package:e_taxi/utils/app_colors.dart';
import 'package:e_taxi/widgets/cacheNetworkImage.dart';
import 'package:e_taxi/widgets/common_text.dart';
import 'package:e_taxi/widgets/custom_button.dart';
import 'package:e_taxi/widgets/custom_textfeild.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class ReviewScreen extends StatefulWidget {
  const ReviewScreen({super.key});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  final HomeController homeController = Get.find<HomeController>();
  final TextEditingController _commentController = TextEditingController();

  double _rating = 0;
  bool _submitting = false;
  final Set<String> _selectedTags = <String>{};

  final List<String> _ratingTags = const [
    '🕐 Pontos',
    '🤝 Barátságos',
    '🧹 Nem volt tiszta',
    '💰 Fizetési probléma',
    '😡 Udvariatlan',
  ];

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  int get _bookingId => int.tryParse(
        homeController.rideCompleteModel.value?.booking?.id ?? '',
      ) ??
      0;

  String get _passengerName =>
      homeController.rideCompleteModel.value?.booking?.user?.name ?? 'Utas';

  String get _passengerPhoto =>
      homeController.rideCompleteModel.value?.booking?.user?.profilePhoto ?? '';

  Future<void> _submitReview() async {
    if (_submitting) return;
    if (_bookingId <= 0) {
      Get.snackbar(
        'Értékelés nem menthető',
        'A lezárt fuvar azonosítója hiányzik.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    if (_rating <= 0) {
      Get.snackbar(
        'Válassz csillagot',
        'Az értékeléshez adj 1–5 csillagot, vagy nyomd meg a Kihagyom gombot.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final parts = <String>[..._selectedTags];
    final typedComment = _commentController.text.trim();
    if (typedComment.isNotEmpty) parts.add(typedComment);

    setState(() => _submitting = true);
    final success = await homeController.driverReviewAdd(
      bookingId: _bookingId,
      rating: _rating,
      comment: parts.join(', '),
    );
    if (mounted && !success) {
      setState(() => _submitting = false);
    }
  }

  void _skipReview() {
    homeController.finishPostRideFlow(reason: 'customer_review_skipped');
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape = MediaQuery.sizeOf(context).width >
        MediaQuery.sizeOf(context).height;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: const Color(0xFFF3F5F8),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(isLandscape ? 24.w : 16.w),
            child: Center(
              child: Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxWidth: 860),
                padding: EdgeInsets.all(isLandscape ? 28.w : 20.w),
                decoration: BoxDecoration(
                  color: AppColors.whiteColor,
                  borderRadius: BorderRadius.circular(24.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: .08),
                      blurRadius: 28,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(14.w),
                      decoration: BoxDecoration(
                        color: AppColors.sucessContainer,
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      child: CommonText(
                        string: 'A készpénzes fizetés rögzítve. A fuvar lezárult.',
                        color: AppColors.successColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 16.sp,
                        textAlign: TextAlign.center,
                        softWrap: true,
                      ),
                    ),
                    SizedBox(height: 24.h),
                    CommonText(
                      string: 'Értékeld az utast',
                      fontSize: 28.sp,
                      fontWeight: FontWeight.w800,
                    ),
                    SizedBox(height: 8.h),
                    CommonText(
                      string: _passengerName,
                      color: AppColors.bodyText,
                      fontSize: 18.sp,
                    ),
                    SizedBox(height: 14.h),
                    NetworkImageWidget(
                      image: _passengerPhoto,
                      ht: 72.h,
                      wt: 72.h,
                      radius: 50.r,
                    ),
                    SizedBox(height: 18.h),
                    RatingBar.builder(
                      direction: Axis.horizontal,
                      allowHalfRating: false,
                      itemCount: 5,
                      initialRating: _rating,
                      itemPadding: EdgeInsets.symmetric(horizontal: 8.w),
                      itemBuilder: (context, _) => const Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      onRatingUpdate: (rating) {
                        setState(() => _rating = rating);
                      },
                    ),
                    SizedBox(height: 22.h),
                    Wrap(
                      spacing: 10.w,
                      runSpacing: 10.h,
                      alignment: WrapAlignment.center,
                      children: _ratingTags.map((tag) {
                        final selected = _selectedTags.contains(tag);
                        return FilterChip(
                          label: Text(tag),
                          selected: selected,
                          onSelected: (_) {
                            setState(() {
                              selected
                                  ? _selectedTags.remove(tag)
                                  : _selectedTags.add(tag);
                            });
                          },
                          selectedColor:
                              AppColors.mainPrimaryColor.withValues(alpha: .18),
                          side: BorderSide(
                            color: selected
                                ? AppColors.mainPrimaryColor
                                : AppColors.textFieldBorderColor,
                          ),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 22.h),
                    CustomTextField(
                      textfielHeight: 110.h,
                      controller: _commentController,
                      minLine: 4,
                      maxLine: 5,
                      hintText: 'Megjegyzés az utasról (opcionális)',
                    ),
                    SizedBox(height: 22.h),
                    Row(
                      children: [
                        Expanded(
                          child: CustomButton(
                            text: 'Kihagyom',
                            buttonColor: AppColors.transparent,
                            borderColor: AppColors.mainPrimaryColor,
                            onTap: _submitting ? null : _skipReview,
                          ),
                        ),
                        SizedBox(width: 14.w),
                        Expanded(
                          child: CustomButton(
                            text: 'Értékelés mentése',
                            isLoader: _submitting,
                            onTap: _submitReview,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
