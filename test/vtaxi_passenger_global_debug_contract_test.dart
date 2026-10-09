import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('passenger pilot debug is globally backend-connected', () {
    final debug =
        File('lib/core/debug/passenger_flow_debug.dart').readAsStringSync();
    final api =
        File('lib/core/api/api.dart').readAsStringSync();
    final auth =
        File('lib/feature/auth/controller/auth_controller.dart').readAsStringSync();
    final pubspec = File('pubspec.yaml').readAsStringSync();

    expect(pubspec, contains('version: 1.0.45+55'));
    expect(debug, contains("appVersion = '1.0.45+55'"));
    expect(debug, contains('vtaxi_passenger_instance_id_v1'));
    expect(debug, contains('passenger_presence_heartbeat'));
    expect(debug, contains("client_role': 'passenger'"));
    expect(debug, contains("'user_id':"));
    expect(debug, contains('Duration(seconds: 30)'));
    expect(debug, contains('ApiConstants.flowDebugEvent'));
    expect(debug, contains('updateLifecycle(state.name)'));
    expect(api, contains('PassengerFlowDebug.apiRequest'));
    expect(api, contains('PassengerFlowDebug.apiResponse'));
    expect(api, contains('PassengerFlowDebug.apiError'));
    expect(auth, contains('PassengerFlowDebug.kick()'));
  });
}
