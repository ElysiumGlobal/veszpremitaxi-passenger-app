import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

String source(String relativePath) => File(relativePath).readAsStringSync();

void main() {
  test('destination and BookVehicleScreen use estimate, not booking create', () {
    final controller = source('lib/feature/home/controller/home_controller.dart');
    final screen = source('lib/feature/home/page/bookvehicle_screen.dart');

    expect(controller, contains('HomeService.bookingEstimate('));
    expect(screen, contains('loadEstimate();'));
    expect(screen, isNot(contains('startBooking(')));
    expect(screen, isNot(contains('HomeService.bookingCreate(')));
  });

  test('booking create is only called from finalization with duplicate guard', () {
    final controller = source('lib/feature/home/controller/home_controller.dart');

    expect(controller, contains('if (finalizingBooking.value)'));
    expect(controller, contains('finalizingBooking(true);'));
    expect(controller, contains('HomeService.bookingCreate('));
    expect(controller, contains('status != "searching"'));
  });

  test('Hungarian P0 labels and HUF formatting are present', () {
    final vehicleScreen = source('lib/feature/home/page/bookvehicle_screen.dart');
    final pickupScreen = source('lib/feature/home/page/pickup_point_screen.dart');
    final utils = source('lib/utils/utils.dart');

    expect(vehicleScreen, contains('Tovább a felvételi ponthoz'));
    expect(pickupScreen, contains('Rendelés véglegesítése'));
    expect(utils, contains("symbol: 'Ft'"));
    expect(utils, contains("locale: 'hu_HU'"));
  });
}
