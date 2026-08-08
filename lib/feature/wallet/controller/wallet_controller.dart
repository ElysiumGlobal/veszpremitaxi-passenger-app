import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:e_taxi/feature/wallet/model/walllet_model.dart';
import 'package:e_taxi/feature/wallet/service/wallet_service.dart';
import 'package:e_taxi/core/localization/vtaxi_localization_service.dart';
import 'package:e_taxi/utils/app_preferences.dart';
import 'package:e_taxi/utils/common_api_caller.dart';
import 'package:e_taxi/utils/loading_mixin.dart';
import 'package:e_taxi/widgets/app_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';

class WalletController extends GetxController
    with LoadingMixin, LoadingApiMixin {
  @override
  void onInit() {
    super.onInit();
    getWalletData(localLoad: true);
    loadStripeTopupConfig();
  }

  RxBool isLoading = false.obs;
  Rxn<WalletDataModel> walletModel = Rxn<WalletDataModel>();

  final RxBool stripeTopupEnabled = false.obs;
  final RxBool stripeConfigLoading = false.obs;
  final RxBool isTopupLoading = false.obs;
  final RxList<int> allowedTopupAmounts = <int>[].obs;
  final RxString stripeMode = ''.obs;
  final RxString stripeCurrency = 'HUF'.obs;

  String _stripePublishableKey = '';

  Future<void> getWalletData({bool localLoad = false}) async {
    if (localLoad) {
      String dbData = AppPreference.getString(AppPreference.walletData);
      if (dbData.isNotEmpty) {
        walletModel.value = WalletDataModel.fromJson(jsonDecode(dbData));
      }
    }

    if ((walletModel.value?.data?.transactions?.data ?? []).isEmpty) {
      isLoading(true);
    }

    await processApi(
      () => WalletService.getWalletData(),
      result: (data) {
        walletModel.value = data;

        AppPreference.setString(
          AppPreference.walletData,
          jsonEncode(data.toJson()),
        );
      },
    );
    isLoading(false);
  }

  Future<void> loadStripeTopupConfig({bool force = false}) async {
    if (stripeConfigLoading.value) return;
    if (!force && allowedTopupAmounts.isNotEmpty && _stripePublishableKey.isNotEmpty) {
      return;
    }

    stripeConfigLoading(true);
    try {
      final response = await WalletService.getStripeTopupConfig();
      final data = _asMap(response['data']);

      stripeTopupEnabled.value = data['enabled'] == true;
      stripeCurrency.value = (data['currency'] ?? 'HUF').toString().toUpperCase();
      stripeMode.value = (data['mode'] ?? '').toString().toLowerCase();
      _stripePublishableKey = (data['publishable_key'] ?? '').toString().trim();

      final rawAmounts = data['allowed_amounts'];
      final amounts = <int>[];
      if (rawAmounts is List) {
        for (final item in rawAmounts) {
          final parsed = item is num ? item.toInt() : int.tryParse('$item');
          if (parsed != null && parsed > 0 && !amounts.contains(parsed)) {
            amounts.add(parsed);
          }
        }
      }
      amounts.sort();
      allowedTopupAmounts.assignAll(amounts);

      if (_stripePublishableKey.isEmpty || allowedTopupAmounts.isEmpty) {
        stripeTopupEnabled.value = false;
      }
    } catch (_) {
      stripeTopupEnabled.value = false;
    } finally {
      stripeConfigLoading(false);
    }
  }

  Future<bool> startStripeWalletTopup(int amount) async {
    if (isTopupLoading.value) return false;

    isTopupLoading(true);
    try {
      await loadStripeTopupConfig(force: true);

      if (!stripeTopupEnabled.value) {
        AppSnackBar.showErrorSnackBar(
          message: VTaxiLocalizationService.text('vtaxi.wallet.topup_unavailable', 'A bankkártyás egyenlegfeltöltés jelenleg nem érhető el.'),
          isError: true,
        );
        return false;
      }

      if (!allowedTopupAmounts.contains(amount)) {
        AppSnackBar.showErrorSnackBar(
          message: VTaxiLocalizationService.text('vtaxi.wallet.amount_not_allowed', 'Ez a feltöltési összeg jelenleg nem engedélyezett.'),
          isError: true,
        );
        return false;
      }

      final response = await WalletService.createStripeTopup(
        amount: amount,
        clientRequestId: _uuidV4(),
      );
      final data = _asMap(response['data']);

      final topupId = (data['topup_id'] ?? '').toString().trim();
      final clientSecret = (data['client_secret'] ?? '').toString().trim();
      final publishableKey = (data['publishable_key'] ?? _stripePublishableKey)
          .toString()
          .trim();
      final responseMode = (data['mode'] ?? stripeMode.value)
          .toString()
          .toLowerCase();

      if (topupId.isEmpty || clientSecret.isEmpty || publishableKey.isEmpty) {
        throw FormatException(VTaxiLocalizationService.text('vtaxi.wallet.incomplete_stripe_response', 'Hiányos Stripe feltöltési válasz.'));
      }

      Stripe.publishableKey = publishableKey;
      Stripe.urlScheme = 'flutterstripe';
      await Stripe.instance.applySettings();

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'Veszprémi Taxi',
          returnURL: 'flutterstripe://redirect',
          primaryButtonLabel: 'Feltöltés',
          style: ThemeMode.system,
          googlePay: Platform.isAndroid
              ? PaymentSheetGooglePay(
                  merchantCountryCode: 'HU',
                  currencyCode: 'HUF',
                  testEnv: responseMode == 'test',
                )
              : null,
        ),
      );

      await Stripe.instance.presentPaymentSheet();

      final verified = await _waitForServerTopup(topupId);
      if (verified) {
        await getWalletData();
        AppSnackBar.showErrorSnackBar(
          message: '${_formatHuf(amount)} sikeresen jóváírva a tárcádban.',
        );
        return true;
      }

      await getWalletData();
      AppSnackBar.showErrorSnackBar(
        message:
            VTaxiLocalizationService.text('vtaxi.wallet.processing_notice', 'A kártyás fizetés megtörtént, a jóváírás még feldolgozás alatt van. Húzd le a Tárca oldalt frissítéshez.'),
      );
      return false;
    } on StripeException catch (e) {
      if (e.error.code == FailureCode.Canceled) {
        return false;
      }
      AppSnackBar.showErrorSnackBar(
        message: e.error.localizedMessage ??
            e.error.message ??
            'A bankkártyás fizetés nem sikerült.',
        isError: true,
      );
      return false;
    } catch (e) {
      AppSnackBar.showErrorSnackBar(
        message: VTaxiLocalizationService.text('vtaxi.wallet.topup_failed', 'A feltöltés nem sikerült. Kérlek próbáld újra.'),
        isError: true,
      );
      return false;
    } finally {
      isTopupLoading(false);
    }
  }

  Future<bool> _waitForServerTopup(String topupId) async {
    for (var attempt = 0; attempt < 15; attempt++) {
      if (attempt > 0) {
        await Future<void>.delayed(const Duration(seconds: 1));
      }

      try {
        final response = await WalletService.getStripeTopupStatus(topupId);
        final data = _asMap(response['data']);
        final status = (data['status'] ?? '').toString().toLowerCase();

        if (status == 'succeeded') {
          return true;
        }
        if (status == 'failed' ||
            status == 'payment_failed' ||
            status == 'canceled') {
          final message = (data['failure_message'] ?? '').toString().trim();
          if (message.isNotEmpty) {
            AppSnackBar.showErrorSnackBar(message: message, isError: true);
          }
          return false;
        }
      } catch (_) {
        // A Stripe PaymentSheet mar bezarult. Itt nem mondunk sikertelen
        // fizetest pusztan egy atmeneti statusz API hiba miatt; tovabb pollolunk.
      }
    }
    return false;
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return <String, dynamic>{};
  }

  String _uuidV4() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-'
        '${hex.substring(8, 12)}-'
        '${hex.substring(12, 16)}-'
        '${hex.substring(16, 20)}-'
        '${hex.substring(20)}';
  }

  String _formatHuf(int amount) {
    final raw = amount.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < raw.length; i++) {
      if (i > 0 && (raw.length - i) % 3 == 0) {
        buffer.write(' ');
      }
      buffer.write(raw[i]);
    }
    return '${buffer.toString()} Ft';
  }
}
