// TEMPORARY REPRODUCTION HARNESS — investigation only, delete after use.
//
// Mounts the real PackageOperationsScreen inside a StatefulShellRoute shaped
// like app_router.dart (root navigator + home branch; `/`, `/customer/:id`
// and `/package-operations` as siblings under `/`) and drives the deactivate
// dialog through the scenarios the user asked for, recording for each:
//   - is PackageOperationsScreen still mounted?
//   - is the dialog still open?
//   - which navigator stacks look like what?
//   - did any exception surface?

import 'dart:async';

import 'package:ezybill/application/providers/package_provider.dart';
import 'package:ezybill/application/providers/stb_provider.dart';
import 'package:ezybill/core/config/app_session.dart';
import 'package:ezybill/core/network/dio_client.dart';
import 'package:ezybill/data/datasources/remote/package_remote_datasource.dart';
import 'package:ezybill/data/datasources/remote/stb_remote_datasource.dart';
import 'package:ezybill/l10n/app_localizations.dart';
import 'package:ezybill/presentation/screens/packages/package_operations_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

// ── Fakes ────────────────────────────────────────────────────────────────────

class _FakePkgDs extends PackageRemoteDatasource {
  _FakePkgDs() : super(dio: DioClient());

  Completer<Map<String, dynamic>>? deactivateCompleter;
  final deactivateCalls = <Map<String, dynamic>>[];

  @override
  Future<Map<String, dynamic>> getCustomerPackages({
    required String authtoken,
    required String customerId,
    required String stbNo,
  }) async {
    return {
      'status_code': '0',
      'status_msg': 'Success',
      'packageList_base': [
        {
          'product_id': '2281',
          'product_name': 'KA-BASIC TIER',
          'base_price': '130.00',
          'customer_service_id': '4210334',
          'is_base_package': '1',
          'alacarte': '0',
          'is_broadcaster_package': '0',
          'validity': 'Month(s)',
          'validity_days': '1',
          'sd_channels_count': '153',
          'hd_channels_count': '0',
        },
      ],
      'packageList_addon': [],
      'packageList_ala': [],
      'packageList_broadcaster': [],
    };
  }

  @override
  Future<Map<String, dynamic>> getUnassignedPackages({
    required String authtoken,
    required String customerId,
    required String stbNo,
  }) async {
    return {
      'status_code': '0',
      'packageList_base': [],
      'packageList_addon': [],
      'packageList_ala': [],
      'packageList_broadcaster': [],
    };
  }

  @override
  Future<Map<String, dynamic>> deactivateService({
    required String authtoken,
    required String customerId,
    required String serviceId,
    required String reasonId,
    required String remarks,
    required String dealerId,
    required String resellerId,
    required String loginEmployeeId,
    String? stockId,
  }) {
    deactivateCalls.add({
      'customerId': customerId,
      'serviceId': serviceId,
      'reasonId': reasonId,
      'remarks': remarks,
      'stockId': stockId,
      'resellerId': resellerId,
    });
    deactivateCompleter = Completer<Map<String, dynamic>>();
    return deactivateCompleter!.future;
  }
}

class _FakeStbDs extends StbRemoteDatasource {
  _FakeStbDs() : super(dio: DioClient());

  @override
  Future<Map<String, dynamic>> getCustomerBoxDetails({
    required String authtoken,
    required String customerId,
  }) async {
    return {
      'status_code': '0',
      'customerBoxList': [
        {
          'serial_number': 'STB1',
          'vc_number': 'VC1',
          'stock_id': '155014',
          'device_id': '240524',
        },
      ],
    };
  }

  @override
  Future<Map<String, dynamic>> getDeactivationReasons({
    required String authtoken,
    String? stockId,
    String? customerId,
  }) async {
    return {
      'status_code': '0',
      'reasonList': [
        {'reasonId': '5', 'reasonName': 'Customer Request', 'global_reason': '0'},
        {'reasonId': '6', 'reasonName': 'Moved Away', 'global_reason': '0'},
      ],
    };
  }
}

class _TestSession extends AppSessionNotifier {
  @override
  AppSession? build() => AppSession.empty(); // intStbDeactivation defaults to 1
}

// ── Router mirroring app_router.dart ─────────────────────────────────────────

class _Stub extends StatelessWidget {
  final String label;
  final VoidCallback? onNext;
  const _Stub(this.label, {this.onNext});
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(label)),
        body: Center(
          child: onNext == null
              ? Text('$label body')
              : TextButton(onPressed: onNext, child: Text('go from $label')),
        ),
      );
}

GoRouter _buildRouter(GlobalKey<NavigatorState> rootKey,
    GlobalKey<NavigatorState> branchKey) {
  return GoRouter(
    navigatorKey: rootKey,
    initialLocation: '/',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => Scaffold(
          body: shell,
          bottomNavigationBar: const SizedBox(height: 56),
        ),
        branches: [
          StatefulShellBranch(
            navigatorKey: branchKey,
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => _Stub('HOME',
                    onNext: () => context.push('/customer/123',
                        extra: {'customerName': 'Chinni Reddy'})),
                routes: [
                  GoRoute(
                    path: 'customer/:id',
                    builder: (context, state) => _Stub('PROFILE',
                        onNext: () => context.push('/package-operations',
                            extra: {
                              'customerId': '123',
                              'customerName': 'Chinni Reddy',
                            })),
                  ),
                  GoRoute(
                    path: 'package-operations',
                    builder: (context, state) {
                      final extra = state.extra as Map<String, dynamic>?;
                      return PackageOperationsScreen(
                        customerId: extra?['customerId']?.toString(),
                        stbNo: extra?['serialNumber']?.toString() ??
                            extra?['stbNo']?.toString(),
                        customerName: extra?['customerName']?.toString(),
                        customerStockId: extra?['stockId']?.toString(),
                        customerDeviceId: extra?['deviceId']?.toString(),
                        resellerId: extra?['resellerId']?.toString(),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

// ── Harness ──────────────────────────────────────────────────────────────────

class _Harness {
  final WidgetTester tester;
  final rootKey = GlobalKey<NavigatorState>(debugLabel: 'root');
  final branchKey = GlobalKey<NavigatorState>(debugLabel: 'home');
  final pkgDs = _FakePkgDs();
  final stbDs = _FakeStbDs();
  late GoRouter router;

  _Harness(this.tester);

  Future<void> pumpApp({PageTransitionsTheme? transitions}) async {
    router = _buildRouter(rootKey, branchKey);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          packageRemoteDatasourceProvider.overrideWithValue(pkgDs),
          stbRemoteDatasourceProvider.overrideWithValue(stbDs),
          appSessionProvider.overrideWith(_TestSession.new),
        ],
        child: MaterialApp.router(
          routerConfig: router,
          theme: transitions == null ? null : ThemeData(pageTransitionsTheme: transitions),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> openPackageOpsFromProfile() async {
    await tester.tap(find.text('go from HOME'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('go from PROFILE'));
    await tester.pumpAndSettle();
    expect(find.byType(PackageOperationsScreen), findsOneWidget);
  }

  Future<void> openDeactivateDialog() async {
    // Mode chip "Deactivate" then the assigned package card, then bottom bar.
    await tester.tap(find.text('Deactivate').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('KA-BASIC TIER'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Deactivate Selected'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text('Reason *'), findsOneWidget);
  }

  Future<void> backSwipe() async {
    Future<void> send(String m, Map<String, Object?>? a) => tester.binding
        .defaultBinaryMessenger
        .handlePlatformMessage('flutter/backgesture',
            const StandardMethodCodec().encodeMethodCall(MethodCall(m, a)),
            (_) {});
    await send('startBackGesture', {'touchOffset': [2.0, 400.0], 'progress': 0.0, 'swipeEdge': 0});
    await tester.pump(const Duration(milliseconds: 100));
    await send('updateBackGestureProgress', {'touchOffset': [80.0, 400.0], 'progress': 0.6, 'swipeEdge': 0});
    await tester.pump(const Duration(milliseconds: 100));
    await send('commitBackGesture', null);
  }

  Future<void> hardwareBack() async {
    // Same entry point Android uses: WidgetsBinding.handlePopRoute →
    // WidgetsApp → Router → GoRouterDelegate.popRoute.
    await tester.binding.handlePopRoute();
  }

  Future<void> selectReason(String name) async {
    await tester.tap(find.byType(DropdownButtonFormField<int>));
    await tester.pumpAndSettle();
    await tester.tap(find.text(name).last);
    await tester.pumpAndSettle();
  }

  Future<void> enterRemarks(String text) async {
    await tester.enterText(
        find.widgetWithText(TextField, 'Remarks *').first, text);
    await tester.pumpAndSettle();
  }

  bool get screenMounted =>
      find.byType(PackageOperationsScreen, skipOffstage: false)
          .evaluate()
          .isNotEmpty;
  bool get dialogOpen =>
      find.byType(AlertDialog, skipOffstage: false).evaluate().isNotEmpty;

  String describeStacks() {
    String routes(NavigatorState? nav) {
      if (nav == null) return '<none>';
      final names = <String>[];
      nav.widget.pages.map((p) => p.name ?? p.key.toString()).forEach(names.add);
      return names.join(' > ');
    }

    return 'root pages=[${routes(rootKey.currentState)}] '
        'branch pages=[${routes(branchKey.currentState)}] '
        'root.canPop=${rootKey.currentState?.canPop()} '
        'branch.canPop=${branchKey.currentState?.canPop()} '
        'location=${router.routerDelegate.currentConfiguration.uri}';
  }

  void report(String scenario) {
    // Exceptions thrown during a pump are captured by the tester; surface them.
    final err = tester.takeException();
    // ignore: avoid_print
    print('[$scenario] screenMounted=$screenMounted dialogOpen=$dialogOpen '
        'exception=${err == null ? 'none' : err.toString().split('\n').first} '
        '| ${describeStacks()}');
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('S3 hardware back once with dialog open', (tester) async {
    final h = _Harness(tester);
    await h.pumpApp();
    await h.openPackageOpsFromProfile();
    await h.openDeactivateDialog();
    h.report('S3 before');
    await h.hardwareBack();
    await tester.pumpAndSettle();
    h.report('S3 after back x1');
  });

  testWidgets('S4 hardware back twice quickly with dialog open',
      (tester) async {
    final h = _Harness(tester);
    await h.pumpApp();
    await h.openPackageOpsFromProfile();
    await h.openDeactivateDialog();
    await h.hardwareBack();
    await tester.pump(const Duration(milliseconds: 16)); // one frame between
    await h.hardwareBack();
    await tester.pump();
    h.report('S4 immediately after back x2');
    await tester.pumpAndSettle();
    h.report('S4 settled after back x2');
  });

  testWidgets('S4b hardware back twice with no frame between', (tester) async {
    final h = _Harness(tester);
    await h.pumpApp();
    await h.openPackageOpsFromProfile();
    await h.openDeactivateDialog();
    final f1 = h.hardwareBack();
    final f2 = h.hardwareBack();
    await f1;
    await f2;
    await tester.pump();
    h.report('S4b immediately');
    await tester.pumpAndSettle();
    h.report('S4b settled');
  });

  testWidgets('S5 tap outside dialog (barrier)', (tester) async {
    final h = _Harness(tester);
    await h.pumpApp();
    await h.openPackageOpsFromProfile();
    await h.openDeactivateDialog();
    await tester.tapAt(const Offset(8, 8));
    await tester.pumpAndSettle();
    h.report('S5 after barrier tap');
  });

  testWidgets('S6-S8 reason, remarks, Deactivate -> Yes, success',
      (tester) async {
    final h = _Harness(tester);
    await h.pumpApp();
    await h.openPackageOpsFromProfile();
    await h.openDeactivateDialog();
    await h.selectReason('Customer Request');
    h.report('S6 after reason');
    await h.enterRemarks('test remarks');
    h.report('S7 after remarks');
    // Button state
    final btn = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Deactivate'));
    // ignore: avoid_print
    print('[S7] Deactivate button enabled=${btn.onPressed != null}');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Deactivate'));
    await tester.pumpAndSettle();
    h.report('S8 after Deactivate (confirm dialog expected)');
    await tester.tap(find.text('Yes'));
    await tester.pump();
    h.report('S8 after Yes (request in flight)');
    h.pkgDs.deactivateCompleter!
        .complete({'status_code': '0', 'status_msg': 'Service De-Activated Successfully.'});
    await tester.pumpAndSettle();
    h.report('S8 after success response');
    // ignore: avoid_print
    print('[S8] request payload seen by datasource: ${h.pkgDs.deactivateCalls}');
  });

  testWidgets('S8x Deactivate -> Yes then hardware back while in flight',
      (tester) async {
    final h = _Harness(tester);
    await h.pumpApp();
    await h.openPackageOpsFromProfile();
    await h.openDeactivateDialog();
    await h.selectReason('Customer Request');
    await h.enterRemarks('test remarks');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Deactivate'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Yes'));
    await tester.pump();
    await h.hardwareBack();
    await tester.pumpAndSettle();
    h.report('S8x after back while request in flight');
    h.pkgDs.deactivateCompleter!
        .complete({'status_code': '0', 'status_msg': 'Service De-Activated Successfully.'});
    await tester.pumpAndSettle();
    h.report('S8x after late success response');
  });

  testWidgets('MECH page popped under open dialog, then select reason',
      (tester) async {
    final h = _Harness(tester);
    await h.pumpApp();
    await h.openPackageOpsFromProfile();
    await h.openDeactivateDialog();
    // Force the branch navigator to pop the page beneath the root dialog.
    h.branchKey.currentState!.pop();
    await tester.pumpAndSettle();
    h.report('MECH after branch pop');
    await h.selectReason('Customer Request');
    h.report('MECH after selecting reason');
  });

  testWidgets('S9 router recreated (authProvider change) with dialog open',
      (tester) async {
    final h = _Harness(tester);
    await h.pumpApp();
    await h.openPackageOpsFromProfile();
    await h.openDeactivateDialog();
    // main.dart:83 rebuilds MaterialApp.router with a brand-new GoRouter when
    // authProvider changes. Emulate exactly that with the same navigator keys.
    h.router = _buildRouter(h.rootKey, h.branchKey);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          packageRemoteDatasourceProvider.overrideWithValue(h.pkgDs),
          stbRemoteDatasourceProvider.overrideWithValue(h.stbDs),
          appSessionProvider.overrideWith(_TestSession.new),
        ],
        child: MaterialApp.router(
          routerConfig: h.router,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
    await tester.pumpAndSettle();
    h.report('S9 after router recreation');
    if (h.dialogOpen) {
      await h.selectReason('Customer Request');
      h.report('S9 after selecting reason');
    }
  });

  testWidgets('S3b hardware back while reason dropdown menu is open',
      (tester) async {
    final h = _Harness(tester);
    await h.pumpApp();
    await h.openPackageOpsFromProfile();
    await h.openDeactivateDialog();
    await tester.tap(find.byType(DropdownButtonFormField<int>));
    await tester.pumpAndSettle();
    h.report('S3b dropdown open');
    await h.hardwareBack();
    await tester.pumpAndSettle();
    h.report('S3b after back x1 (menu should close)');
    await h.hardwareBack();
    await tester.pumpAndSettle();
    h.report('S3b after back x2 (dialog should close)');
    await h.hardwareBack();
    await tester.pumpAndSettle();
    h.report('S3b after back x3 (page should pop)');
  });

  testWidgets('U1 reason tap while remarks focused only dismisses keyboard',
      (tester) async {
    final h = _Harness(tester);
    await h.pumpApp();
    await h.openPackageOpsFromProfile();
    await h.openDeactivateDialog();
    // Focus remarks (keyboard up), then tap the Reason field once.
    await tester.tap(find.widgetWithText(TextField, 'Remarks *').first);
    await tester.pumpAndSettle();
    await tester.tap(find.byType(DropdownButtonFormField<int>),
        warnIfMissed: false);
    await tester.pumpAndSettle();
    final menuOpenAfterFirstTap =
        find.text('Customer Request').evaluate().length > 1;
    // Second tap (keyboard now dismissed) opens the menu.
    await tester.tap(find.byType(DropdownButtonFormField<int>));
    await tester.pumpAndSettle();
    final menuOpenAfterSecondTap =
        find.text('Customer Request').evaluate().length > 1 ||
            find.text('Moved Away').evaluate().isNotEmpty;
    // ignore: avoid_print
    print('[U1] menu after 1st tap (remarks focused)=$menuOpenAfterFirstTap, '
        'after 2nd tap=$menuOpenAfterSecondTap');
    await tester.tap(find.text('Moved Away').last);
    await tester.pumpAndSettle();
    h.report('U1 after selecting reason via second tap');
  });

  testWidgets('G1 predictive-back SWIPE, default Android transition', (tester) async {
    final h = _Harness(tester);
    await h.pumpApp();
    await h.openPackageOpsFromProfile();
    await h.openDeactivateDialog();
    await h.backSwipe();
    await tester.pumpAndSettle();
    h.report('G1 after swipe (default = PredictiveBackPageTransitionsBuilder)');
  });

  testWidgets('G2 predictive-back SWIPE, Zoom transition on Android', (tester) async {
    final h = _Harness(tester);
    await h.pumpApp(transitions: const PageTransitionsTheme(builders: {
      TargetPlatform.android: ZoomPageTransitionsBuilder(),
    }));
    await h.openPackageOpsFromProfile();
    await h.openDeactivateDialog();
    await h.backSwipe();
    await tester.pumpAndSettle();
    h.report('G2 after swipe (ZoomPageTransitionsBuilder)');
  });

  testWidgets('S8f Deactivate -> Yes, server failure response',
      (tester) async {
    final h = _Harness(tester);
    await h.pumpApp();
    await h.openPackageOpsFromProfile();
    await h.openDeactivateDialog();
    await h.selectReason('Customer Request');
    await h.enterRemarks('test remarks');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Deactivate'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Yes'));
    await tester.pump();
    h.pkgDs.deactivateCompleter!.complete(
        {'status_code': '1', 'status_msg': 'Mandatory fields are missing.'});
    await tester.pumpAndSettle();
    h.report('S8f after failure response');
    final dialogTitle = find.text('Failed to deactivate Packages');
    final dialogMsg = find.text('Mandatory fields are missing.!');
    final snack = find.byType(SnackBar);
    // ignore: avoid_print
    print('[S8f] failure dialog title=${dialogTitle.evaluate().isNotEmpty} '
        'message=${dialogMsg.evaluate().isNotEmpty} snackbar=${snack.evaluate().isNotEmpty}');
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    h.report('S8f after OK (screen must remain, dialog closed)');
    // ignore: avoid_print
    print('[S8f] selection retained=${h.pkgDs.deactivateCalls.length == 1 && find.text('1 package selected').evaluate().isNotEmpty}');
  });

  testWidgets('S8g Deactivate -> Yes, status_code 2 -> Connectivity Error title',
      (tester) async {
    final h = _Harness(tester);
    await h.pumpApp();
    await h.openPackageOpsFromProfile();
    await h.openDeactivateDialog();
    await h.selectReason('Customer Request');
    await h.enterRemarks('test remarks');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Deactivate'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Yes'));
    await tester.pump();
    h.pkgDs.deactivateCompleter!
        .complete({'status_code': '2', 'status_msg': 'Some server error'});
    await tester.pumpAndSettle();
    // ignore: avoid_print
    print('[S8g] title=${find.text('Connectivity Error').evaluate().isNotEmpty} '
        'msg=${find.text('Some server error!').evaluate().isNotEmpty}');
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    h.report('S8g after OK');
  });

  testWidgets('S8h load error still uses SnackBar (other errors untouched)',
      (tester) async {
    final h = _Harness(tester);
    await h.pumpApp();
    await h.openPackageOpsFromProfile();
    // Force a generic provider error through the existing path.
    final container = ProviderScope.containerOf(
        tester.element(find.byType(PackageOperationsScreen)));
    container.read(packageProvider.notifier).loadBillDetails(
        customerId: '123', boxNumber: 'STB1', productIds: '2281');
    await tester.pumpAndSettle();
    // ignore: avoid_print
    print('[S8h] snackbar shown=${find.byType(SnackBar).evaluate().isNotEmpty} '
        'dialog shown=${find.byType(AlertDialog).evaluate().isNotEmpty}');
  });
}
