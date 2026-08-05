import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

String source(String relativePath) => File(relativePath).readAsStringSync();

String between(String value, String start, String end) {
  final startIndex = value.indexOf(start);
  expect(startIndex, greaterThanOrEqualTo(0), reason: start);
  final endIndex = value.indexOf(end, startIndex + start.length);
  expect(endIndex, greaterThan(startIndex), reason: end);
  return value.substring(startIndex, endIndex);
}

void main() {
  test(
    'completed cash waits for driver confirmation without payment navigation',
    () {
      final controller = source(
        'lib/feature/home/controller/home_controller.dart',
      );
      final socketData = between(
        controller,
        'Future<void> socketData({bool isFirstTime = false}) async {',
        'Future<void> _openCompletedRidePaymentSelection(',
      );

      expect(socketData, contains("if (status == 'completed')"));
      expect(socketData, contains('final awaitsCashConfirmation ='));
      expect(socketData, contains("status == 'completed' &&"));
      expect(socketData, contains('if (awaitsCashConfirmation)'));
      expect(
        socketData,
        contains('completed_cash_waiting_for_driver_confirmation'),
      );
      expect(socketData, contains('await _finalizeCompletedRide('));
      expect(
        socketData,
        isNot(contains('_openCompletedRidePaymentSelection(')),
      );
      expect(socketData, isNot(contains('Routes.paymentSelectScreen')));
      expect(socketData, isNot(contains('CashCollectScreen')));
    },
  );

  test('profile restores exact completed cash task only while unpaid', () {
    final profile = source(
      'lib/feature/profile/controller/profile_controller.dart',
    );

    expect(profile, contains("status == 'completed'"));
    expect(profile, contains("paymentMethod == 'cash'"));
    expect(profile, contains("paymentStatus != 'paid'"));
    expect(
      profile,
      contains('!activeStatuses.contains(status) && !awaitsCashConfirmation'),
    );
    expect(profile, isNot(contains('bookingTooOld')));
    expect(profile, isNot(contains('Duration(minutes: 90)')));
    expect(profile, isNot(contains('Duration(hours: 12)')));

    final controller = source(
      'lib/feature/home/controller/home_controller.dart',
    );
    final socketData = between(
      controller,
      'Future<void> socketData({bool isFirstTime = false}) async {',
      'Future<void> _openCompletedRidePaymentSelection(',
    );
    expect(
      socketData,
      contains('(activeStatuses.contains(status) || awaitsCashConfirmation)'),
    );
  });

  test('cash release requires two exact empty profile responses', () {
    final searchDriver = source('lib/feature/home/page/search_driver.dart');

    expect(
      searchDriver,
      contains(
        'currentBooking == null &&\n'
        '            serverCurrentBookingId.isEmpty &&\n'
        '            responseBookingId.isEmpty',
      ),
    );
    expect(searchDriver, contains('_consecutiveExactServerReleasePolls++'));
    expect(searchDriver, contains('_consecutiveExactServerReleasePolls >= 2'));
    expect(searchDriver, contains('completed_cash_released_by_server'));
    expect(searchDriver, contains("paymentStatus = 'paid';"));
    expect(searchDriver, contains('_bookingStatusPollingTimer?.cancel();'));
  });
}
