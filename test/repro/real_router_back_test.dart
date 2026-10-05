// TEMPORARY REPRODUCTION — real routerProvider + real EzyBillApp/AppShell,
// deactivate dialog open, hardware back. Investigation only; delete after use.

import 'dart:async';

import 'package:ezybill/application/providers/auth_provider.dart';
import 'package:ezybill/application/providers/core_providers.dart';
import 'package:ezybill/application/providers/package_provider.dart';
import 'package:ezybill/application/providers/stb_provider.dart';
import 'package:ezybill/core/config/app_session.dart';
import 'package:ezybill/core/network/dio_client.dart';
import 'package:ezybill/data/datasources/remote/package_remote_datasource.dart';
import 'package:ezybill/data/datasources/remote/stb_remote_datasource.dart';
import 'package:ezybill/main.dart';
import 'package:ezybill/presentation/router/app_router.dart';
import 'package:ezybill/presentation/screens/packages/package_operations_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakePkgDs extends PackageRemoteDatasource {
  _FakePkgDs() : super(dio: DioClient());
  @override
  Future<Map<String, dynamic>> getCustomerPackages(
          {required String authtoken,
          required String customerId,
          required String stbNo}) async =>
      {
        'status_code': '0',
        'packageList_base': [
          {
            'product_id': '2281',
            'product_name': 'Base_BEE',
            'base_price': '66.00',
            'customer_service_id': '4210334',
            'is_base_package': '1',
          }
        ],
        'packageList_addon': [],
        'packageList_ala': [],
        'packageList_broadcaster': [],
      };
  @override
  Future<Map<String, dynamic>> getUnassignedPackages(
          {required String authtoken,
          required String customerId,
          required String stbNo}) async =>
      {
        'status_code': '0',
        'packageList_base': [],
        'packageList_addon': [],
        'packageList_ala': [],
        'packageList_broadcaster': []
      };
  @override
  Future<Map<String, dynamic>> deactivateService(
      {required String authtoken,
      required String customerId,
      required String serviceId,
      required String reasonId,
      required String remarks,
      required String dealerId,
      required String resellerId,
      required String loginEmployeeId,
      String? stockId}) async {
    return Completer<Map<String, dynamic>>().future;
  }
}

class _FakeStbDs extends StbRemoteDatasource {
  _FakeStbDs() : super(dio: DioClient());
  @override
  Future<Map<String, dynamic>> getCustomerBoxDetails(
          {required String authtoken, required String customerId}) async =>
      {
        'status_code': '0',
        'customerBoxList': [
          {'serial_number': 'STB1', 'stock_id': '155014', 'device_id': '1'}
        ],
      };
  @override
  Future<Map<String, dynamic>> getDeactivationReasons(
          {required String authtoken,
          String? stockId,
          String? customerId}) async =>
      {
        'status_code': '0',
        'reasonList': [
          {'reasonId': '5', 'reasonName': 'Others', 'global_reason': '0'},
        ],
      };
}

class _AuthedAuth extends AuthNotifier {
  @override
  AuthState build() => const AuthState(status: AuthStatus.authenticated);
}

class _TestSession extends AppSessionNotifier {
  @override
  AppSession? build() => AppSession.empty();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('REAL router: dialog open, hardware back', (tester) async {
    SharedPreferences.setMockInitialValues({
      'smsKey': 'ABCDtest',
      'login_url': 'http://127.0.0.1:1/index.php',
      'api_base_url': 'http://127.0.0.1:1/index.php',
      'bms_version': 'V2',
    });
    final prefs = await SharedPreferences.getInstance();
    late GoRouterHolder holder;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          authProvider.overrideWith(_AuthedAuth.new),
          appSessionProvider.overrideWith(_TestSession.new),
          packageRemoteDatasourceProvider.overrideWithValue(_FakePkgDs()),
          stbRemoteDatasourceProvider.overrideWithValue(_FakeStbDs()),
        ],
        child: Consumer(builder: (context, ref, _) {
          holder = GoRouterHolder(ref);
          return const EzyBillApp();
        }),
      ),
    );
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

    final router = holder.router;
    // ignore: avoid_print
    print('[REAL] start location=${router.routerDelegate.currentConfiguration.uri}');

    router.push('/package-operations', extra: {
      'customerId': '123',
      'customerName': 'Sonu Testing Tt',
    });
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    // ignore: avoid_print
    print('[REAL] pkgops mounted=${find.byType(PackageOperationsScreen).evaluate().isNotEmpty} '
        'location=${router.routerDelegate.currentConfiguration.uri}');

    await tester.tap(find.text('Deactivate').first);
    await tester.pump(const Duration(milliseconds: 500));
    await tester.tap(find.text('Base_BEE'));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.tap(find.text('Deactivate Selected'));
    await tester.pump(const Duration(seconds: 1));
    // ignore: avoid_print
    print('[REAL] dialog open=${find.byType(AlertDialog).evaluate().isNotEmpty}');
    // ignore: avoid_print
    print('[REAL] matches.last=${router.routerDelegate.currentConfiguration.matches.last.runtimeType} '
        'all=${router.routerDelegate.currentConfiguration.matches.map((m) => m.runtimeType).toList()}');

    if (const bool.fromEnvironment('GESTURE', defaultValue: true)) {
      // Android predictive-back swipe as delivered by the engine on a
      // gesture-navigation device (startBackGesture ... commitBackGesture).
      await _sendBackGesture(tester, 'startBackGesture', {
        'touchOffset': [2.0, 400.0],
        'progress': 0.0,
        'swipeEdge': 0,
      });
      await tester.pump(const Duration(milliseconds: 100));
      await _sendBackGesture(tester, 'updateBackGestureProgress', {
        'touchOffset': [80.0, 400.0],
        'progress': 0.6,
        'swipeEdge': 0,
      });
      await tester.pump(const Duration(milliseconds: 100));
      await _sendBackGesture(tester, 'commitBackGesture', null);
    } else {
      await tester.binding.handlePopRoute(); // 3-button back
    }
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    final err = tester.takeException();
    // ignore: avoid_print
    print('[REAL] after back: dialog open=${find.byType(AlertDialog, skipOffstage: false).evaluate().isNotEmpty} '
        'pkgops mounted=${find.byType(PackageOperationsScreen, skipOffstage: false).evaluate().isNotEmpty} '
        'location=${router.routerDelegate.currentConfiguration.uri} exception=${err?.toString().split('\n').first}');

    // Now interact with the surviving dialog like the user did.
    if (find.byType(DropdownButtonFormField<int>).evaluate().isNotEmpty) {
      await tester.tap(find.byType(DropdownButtonFormField<int>));
      await tester.pump(const Duration(seconds: 1));
      await tester.tap(find.text('Others').last, warnIfMissed: false);
      await tester.pump(const Duration(seconds: 1));
      final err2 = tester.takeException();
      // ignore: avoid_print
      print('[REAL] after selecting reason in surviving dialog: exception=${err2?.toString().split('\n').first}');
    }
  });
}

Future<void> _sendBackGesture(
    WidgetTester tester, String method, Map<String, Object?>? args) async {
  final data = const StandardMethodCodec()
      .encodeMethodCall(MethodCall(method, args));
  await tester.binding.defaultBinaryMessenger
      .handlePlatformMessage('flutter/backgesture', data, (_) {});
}

class GoRouterHolder {
  final WidgetRef ref;
  GoRouterHolder(this.ref);
  get router => ref.read(routerProvider);
}
