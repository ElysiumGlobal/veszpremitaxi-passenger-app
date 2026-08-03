import 'package:e_taxi/feature/home/controller/home_controller.dart';
import 'package:e_taxi/utils/app_colors.dart';
import 'package:e_taxi/utils/utils.dart';
import 'package:e_taxi/widgets/appbar.dart';
import 'package:e_taxi/widgets/common_text.dart';
import 'package:e_taxi/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class CashCollectScreen extends StatefulWidget {
  const CashCollectScreen({super.key});

  @override
  State<CashCollectScreen> createState() => _CashCollectScreenState();
}

class _CashCollectScreenState extends State<CashCollectScreen> {
  final HomeController homeController = Get.find<HomeController>();
  final TextEditingController _customTipController = TextEditingController();

  int _selectedTip = 0;
  bool _customTipEnabled = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _customTipController.dispose();
    super.dispose();
  }

  double _number(dynamic value) {
    return double.tryParse(
          (value ?? '0')
              .toString()
              .replaceAll(RegExp(r'[^0-9,.-]'), '')
              .replaceAll(',', '.'),
        ) ??
        0;
  }

  double get _fareAmount {
    final completed = homeController.rideCompleteModel.value;
    return _number(
      completed?.fare?.totalAmount ??
          completed?.booking?.totalAmount ??
          completed?.booking?.finalFare ??
          completed?.booking?.estimatedFare,
    );
  }

  double get _tipAmount {
    if (!_customTipEnabled) return _selectedTip.toDouble();
    return _number(_customTipController.text)
        .clamp(0, 1000000)
        .toDouble();
  }

  String get _bookingId =>
      (homeController.rideCompleteModel.value?.booking?.id ?? '').trim();

  Future<void> _confirmCash() async {
    if (_isSubmitting) return;
    if (_bookingId.isEmpty) {
      Get.snackbar(
        'Fizetés nem rögzíthető',
        'A fuvar azonosítója hiányzik. Nyisd meg újra a lezárt fuvart.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    setState(() => _isSubmitting = true);
    final success = await homeController.confirmPaymentCollected(
      bookingId: _bookingId,
      cashAmount: _fareAmount,
      tipAmount: _tipAmount,
    );
    if (mounted && !success) {
      setState(() => _isSubmitting = false);
    }
  }

  Widget _fareRow(String label, dynamic amount, {bool strong = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 7.h),
      child: Row(
        children: [
          Expanded(
            child: CommonText(
              string: label,
              color: strong ? AppColors.blackColor : AppColors.bodyText,
              fontSize: strong ? 18.sp : 15.sp,
              fontWeight: strong ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
          CommonText(
            string: Utils.formatCurrency((amount ?? '0').toString()),
            color: strong ? AppColors.mainPrimaryColor : AppColors.bodyText,
            fontSize: strong ? 20.sp : 15.sp,
            fontWeight: strong ? FontWeight.w800 : FontWeight.w600,
          ),
        ],
      ),
    );
  }

  Widget _tipButton(int amount) {
    final selected = !_customTipEnabled && _selectedTip == amount;
    return ChoiceChip(
      label: Text(amount == 0 ? 'Nincs' : '${amount.toString()} Ft'),
      selected: selected,
      onSelected: (_) {
        setState(() {
          _customTipEnabled = false;
          _selectedTip = amount;
          _customTipController.clear();
        });
      },
      selectedColor: AppColors.mainPrimaryColor.withValues(alpha: .18),
      side: BorderSide(
        color: selected
            ? AppColors.mainPrimaryColor
            : AppColors.textFieldBorderColor,
      ),
      labelStyle: TextStyle(
        color: AppColors.blackColor,
        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fare = homeController.rideCompleteModel.value?.fare;
    final passenger =
        homeController.rideCompleteModel.value?.booking?.user?.name ?? 'Utas';
    final isLandscape = MediaQuery.sizeOf(context).width >
        MediaQuery.sizeOf(context).height;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: const Color(0xFFF3F5F8),
        appBar: CustomAppBar(
          automaticallyImplyLeading: false,
          title: 'Készpénzes fizetés',
          centerTitle: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(isLandscape ? 24.w : 16.w),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 980),
                child: isLandscape
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _buildFareCard(passenger, fare)),
                          SizedBox(width: 22.w),
                          Expanded(child: _buildPaymentCard()),
                        ],
                      )
                    : Column(
                        children: [
                          _buildFareCard(passenger, fare),
                          SizedBox(height: 18.h),
                          _buildPaymentCard(),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFareCard(String passenger, dynamic fare) {
    return Container(
      padding: EdgeInsets.all(22.w),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .07),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommonText(
            string: 'Fizető utas',
            color: AppColors.textCaptionColor,
            fontSize: 14.sp,
          ),
          CommonText(
            string: passenger,
            fontSize: 24.sp,
            fontWeight: FontWeight.w800,
          ),
          Divider(height: 30.h, color: AppColors.textFieldBorderColor),
          _fareRow('Alapdíj', fare?.baseFare),
          _fareRow('Távolsági díj', fare?.distanceFare),
          _fareRow('Idődíj', fare?.timeFare),
          _fareRow('Várakozási díj', fare?.waitingCharge),
          _fareRow('Éjszakai felár', fare?.nightCharge),
          _fareRow('Egyéb felár', fare?.surgeAmount),
          _fareRow('Kedvezmény', fare?.discountAmount),
          Divider(height: 28.h, color: AppColors.textFieldBorderColor),
          _fareRow('Fizetendő viteldíj', fare?.totalAmount, strong: true),
        ],
      ),
    );
  }

  Widget _buildPaymentCard() {
    final totalWithTip = _fareAmount + _tipAmount;

    return Container(
      padding: EdgeInsets.all(22.w),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .07),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommonText(
            string: 'Készpénzes borravaló',
            fontSize: 21.sp,
            fontWeight: FontWeight.w800,
          ),
          SizedBox(height: 6.h),
          CommonText(
            string: 'Opcionális. A borravalót az utas készpénzben adja át.',
            color: AppColors.textCaptionColor,
            fontSize: 14.sp,
            softWrap: true,
          ),
          SizedBox(height: 16.h),
          Wrap(
            spacing: 10.w,
            runSpacing: 10.h,
            children: [
              _tipButton(0),
              _tipButton(500),
              _tipButton(1000),
              ChoiceChip(
                label: const Text('Egyéb'),
                selected: _customTipEnabled,
                onSelected: (_) {
                  setState(() {
                    _customTipEnabled = true;
                    _selectedTip = 0;
                  });
                },
                selectedColor:
                    AppColors.mainPrimaryColor.withValues(alpha: .18),
                side: BorderSide(
                  color: _customTipEnabled
                      ? AppColors.mainPrimaryColor
                      : AppColors.textFieldBorderColor,
                ),
              ),
            ],
          ),
          if (_customTipEnabled) ...[
            SizedBox(height: 14.h),
            TextField(
              controller: _customTipController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(7),
              ],
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: 'Borravaló összege',
                suffixText: 'Ft',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ],
          Divider(height: 34.h, color: AppColors.textFieldBorderColor),
          _fareRow('Viteldíj', _fareAmount),
          _fareRow('Borravaló', _tipAmount),
          _fareRow('Átvett készpénz összesen', totalWithTip, strong: true),
          SizedBox(height: 18.h),
          CustomButton(
            text: 'Készpénz átvéve',
            isLoader: _isSubmitting,
            onTap: _confirmCash,
          ),
          SizedBox(height: 10.h),
          CommonText(
            string:
                'A gomb a rendelést fizetett állapotba teszi, majd megnyitja az utas értékelését.',
            color: AppColors.textCaptionColor,
            fontSize: 13.sp,
            textAlign: TextAlign.center,
            softWrap: true,
          ),
        ],
      ),
    );
  }
}
