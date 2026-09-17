import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../application/providers/auth_provider.dart';
import '../../application/providers/bms_provider.dart';
import '../../application/providers/core_providers.dart';
import '../../core/constants/app_constants.dart';
import '../common/widgets/app_shell.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/registration_screen.dart';
import '../screens/complaints/complaint_history_screen.dart';
import '../screens/complaints/complaint_screen.dart';
import '../screens/complaints/update_complaint_screen.dart';
import '../../data/models/complaint/complaint_model.dart';
import '../screens/customers/customer_profile_screen.dart';
import '../screens/customers/customer_search_screen.dart';
import '../screens/customers/edit_customer_screen.dart';
import '../screens/customers/new_customer_screen.dart';
import '../screens/employees/employee_list_screen.dart';
import '../screens/employees/employee_tracking_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/lco/lco_payment_screen.dart';
import '../screens/lco/lco_topup_screen.dart';
import '../screens/lco/lco_wallet_history_screen.dart';
import '../screens/packages/package_operations_screen.dart';
import '../screens/packages/package_renewal_screen.dart';
import '../screens/stb/stb_pair_unpair_screen.dart';
import '../screens/stb/stb_replacement_screen.dart';
import '../screens/payments/make_payment_screen.dart';
import '../screens/reports/emp_collection_detail_screen.dart';
import '../screens/reports/emp_collection_filter_screen.dart';
import '../screens/reports/emp_collection_list_screen.dart';
import '../screens/reports/mini_day_report_screen.dart';
import '../screens/reports/reports_screen.dart';
import '../screens/settings/about_screen.dart';
import '../screens/settings/change_password_screen.dart';
import '../screens/settings/debug_console_screen.dart';
import '../screens/settings/privacy_policy_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/stb/stb_operations_screen.dart';
import '../screens/payments/invoice_history_screen.dart';
import '../screens/payments/payment_history_screen.dart';
import '../screens/payments/payment_response_screen.dart';
import '../screens/payments/payment_webview_screen.dart';
import '../screens/payments/pg_transaction_report_screen.dart';
import '../screens/bluetooth/device_discovery_screen.dart';
import '../screens/bluetooth/paired_device_list_screen.dart';
import '../screens/scanner/barcode_scanner_screen.dart';
import '../screens/transactions/transactions_screen.dart';
import 'route_names.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Navigator keys — one per branch so each tab retains its own nav stack.
// ─────────────────────────────────────────────────────────────────────────────

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _homeNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'home');
final _subscribersNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'subscribers');
final _reportsNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'reports');
final _transactionsNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'transactions');
final _settingsNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'settings');

// ─────────────────────────────────────────────────────────────────────────────
// Router provider
// ─────────────────────────────────────────────────────────────────────────────

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: RouteNames.home,
    // Route logging to the system console — debug/profile only, so release
    // builds do not write every navigation (with params) to logcat.
    debugLogDiagnostics: kDevToolsEnabled,

    // ── Auth redirect ──────────────────────────────────────────────────────
    redirect: (context, state) {
      final isLoggedIn = authState.status == AuthStatus.authenticated;
      final isLoggingIn = state.matchedLocation == RouteNames.login;
      final isRegistering = state.matchedLocation == RouteNames.registration;

      // Check if device is registered with BMS
      final prefs = ref.read(sharedPreferencesProvider);
      final smsKey = prefs.getString(kSmsKey);
      final hasRegistration = smsKey != null && smsKey.length > 1;

      // On web, skip registration check — go straight to login.
      // Registration uses BMS SOAP which needs separate network setup.
      if (kIsWeb && !hasRegistration && !isRegistering) {
        if (!isLoggedIn && !isLoggingIn) return RouteNames.login;
      }

      // If not registered with BMS, go to registration (unless already there)
      if (!kIsWeb && !hasRegistration && !isRegistering) {
        return RouteNames.registration;
      }

      // If registered with BMS but not logged in, go to login
      if (hasRegistration && !isLoggedIn && !isLoggingIn && !isRegistering) {
        return RouteNames.login;
      }

      // If logged in and on login/registration page, go to home
      if (isLoggedIn && (isLoggingIn || isRegistering)) return RouteNames.home;

      return null;
    },

    routes: [
      // ── Registration (no shell, full-screen) ───────────────────────────
      GoRoute(
        path: RouteNames.registration,
        name: RouteNames.registrationName,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const RegistrationScreen(),
      ),

      // ── Login (no shell, full-screen) ─────────────────────────────────
      GoRoute(
        path: RouteNames.login,
        name: RouteNames.loginName,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const LoginScreen(),
      ),

      // ── Bottom-nav shell with IndexedStack for tab persistence ─────────
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(navigationShell: navigationShell);
        },
        branches: [
          // ────────────────────────────────────────────────────────────────
          // Branch 0 — Home
          // All general sub-pages are nested here so the bottom nav stays
          // visible. GoRouter resolves relative paths against the parent,
          // so "customer/:id" becomes "/customer/:id", etc.
          // ────────────────────────────────────────────────────────────────
          StatefulShellBranch(
            navigatorKey: _homeNavigatorKey,
            routes: [
              GoRoute(
                path: RouteNames.home,
                name: RouteNames.homeName,
                builder: (context, state) => const HomeScreen(),
                routes: [
                  // ── Customer sub-routes ──────────────────────────────
                  // "customer/new" must come before "customer/:id" so the
                  // literal path is matched first.
                  GoRoute(
                    path: 'customer/new',
                    builder: (context, state) {
                      final extra = state.extra as Map<String, dynamic>?;
                      return NewCustomerScreen(
                        prefilledSerial: extra?['serialNumber']?.toString(),
                        prefilledVc: extra?['vcNumber']?.toString(),
                        prefilledStbCode: extra?['stbCode']?.toString(),
                      );
                    },
                  ),
                  GoRoute(
                    path: 'customer/:id/edit',
                    name: RouteNames.editCustomerName,
                    builder: (context, state) {
                      final id = state.pathParameters['id'] ?? '';
                      final extra = state.extra as Map<String, dynamic>?;
                      return EditCustomerScreen(
                        customerId: id,
                        customer:
                            extra?['customer'] as Map<String, dynamic>? ?? {},
                      );
                    },
                  ),
                  GoRoute(
                    path: 'customer/:id',
                    name: RouteNames.customerProfileName,
                    builder: (context, state) {
                      final id = state.pathParameters['id'] ?? '';
                      final extra = state.extra as Map<String, dynamic>?;
                      return CustomerProfileScreen(
                        customerId: id,
                        customerName: extra?['customerName']?.toString(),
                        initialData: extra,
                      );
                    },
                  ),

                  // ── Payment routes ──────────────────────────────────
                  GoRoute(
                    path: 'make-payment',
                    name: RouteNames.makePaymentName,
                    builder: (context, state) {
                      final extra = state.extra as Map<String, dynamic>?;
                      return MakePaymentScreen(
                        customerId: extra?['customerId']?.toString(),
                        customerName: extra?['customerName']?.toString(),
                        initialPendingAmount: (extra?['pendingAmount'] is num) ? 
                        (extra!['pendingAmount'] as num).toDouble() : null,
                      );
                    },
                  ),
                  GoRoute(
                    path: 'payment-history/:customerId',
                    name: RouteNames.paymentHistoryName,
                    builder: (context, state) {
                      final customerId =
                          state.pathParameters['customerId'] ?? '';
                      return PaymentHistoryScreen(customerId: customerId);
                    },
                  ),
                  GoRoute(
                    path: 'invoice-history/:customerId',
                    name: RouteNames.invoiceHistoryName,
                    builder: (context, state) {
                      final customerId =
                          state.pathParameters['customerId'] ?? '';
                      return InvoiceHistoryScreen(customerId: customerId);
                    },
                  ),
                  GoRoute(
                    path: 'pg-transactions',
                    name: RouteNames.pgTransactionsName,
                    builder: (context, state) =>
                        const PgTransactionReportScreen(),
                  ),

                  // ── Complaint routes ────────────────────────────────
                  GoRoute(
                    path: 'complaints',
                    name: RouteNames.complaintsName,
                    builder: (context, state) {
                      final extra = state.extra as Map<String, dynamic>?;
                      // Callers (customer profile, customer search) send
                      // `customerId` / `customerName` / `resellerId`; the
                      // short `custId` / `custName` forms are accepted too.
                      final resellerRaw =
                          extra?['resellerId'] ?? extra?['reseller_id'];
                      return ComplaintScreen(
                        custId: (extra?['custId'] ?? extra?['customerId'])
                            ?.toString(),
                        custName: (extra?['custName'] ?? extra?['customerName'])
                            ?.toString(),
                        resellerId: int.tryParse(resellerRaw?.toString() ?? ''),
                      );
                    },
                  ),
                  GoRoute(
                    path: 'complaint-history/:customerId',
                    name: RouteNames.complaintHistoryName,
                    builder: (context, state) {
                      final customerId =
                          state.pathParameters['customerId'] ?? '';
                      return ComplaintHistoryScreen(customerId: customerId);
                    },
                  ),
                  GoRoute(
                    path: 'complaint-update',
                    name: RouteNames.updateComplaintName,
                    builder: (context, state) {
                      final extra =
                          state.extra as Map<String, dynamic>? ?? {};
                      final complaint = extra['complaint'] as ComplaintModel;
                      return UpdateComplaintScreen(complaint: complaint);
                    },
                  ),

                  // ── STB routes ──────────────────────────────────────
                  GoRoute(
                    path: 'stb-operations',
                    name: RouteNames.stbOperationsName,
                    builder: (context, state) {
                      final extra = state.extra as Map<String, dynamic>?;
                      return StbOperationsScreen(
                        customerId: extra?['customerId']?.toString(),
                        customerName: extra?['customerName']?.toString(),
                        // Customer's reseller id — required by deactivateBoxRest.
                        resellerId: int.tryParse(
                          extra?['resellerId']?.toString() ?? '',
                        ),
                      );
                    },
                  ),
                  GoRoute(
                    path: 'stb-pair-unpair',
                    name: RouteNames.stbPairUnpairName,
                    builder: (context, state) {
                      final extra = state.extra as Map<String, dynamic>?;
                      return StbPairUnpairScreen(
                        customerId: extra?['customerId']?.toString(),
                      );
                    },
                  ),
                  GoRoute(
                    path: 'stb-replacement',
                    name: RouteNames.stbReplacementName,
                    builder: (context, state) {
                      final extra = state.extra as Map<String, dynamic>?;
                      return StbReplacementScreen(
                        customerId: extra?['customerId']?.toString(),
                        stbNo: extra?['stbNo']?.toString(),
                        customerName: extra?['customerName']?.toString(),
                      );
                    },
                  ),

                  // ── Package routes ──────────────────────────────────
                  GoRoute(
                    path: 'package-operations',
                    name: RouteNames.packageOperationsName,
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
                  GoRoute(
                    path: 'package-renewal',
                    name: RouteNames.packageRenewalName,
                    builder: (context, state) {
                      final extra = state.extra as Map<String, dynamic>?;
                      return PackageRenewalScreen(
                        customerId: extra?['customerId']?.toString(),
                        stbNo: extra?['stbNo']?.toString(),
                      );
                    },
                  ),

                  // ── Employee routes ─────────────────────────────────
                  GoRoute(
                    path: 'employees',
                    name: RouteNames.employeeListName,
                    builder: (context, state) => const EmployeeListScreen(),
                    routes: [
                      GoRoute(
                        path: 'tracking',
                        name: RouteNames.employeeTrackingName,
                        builder: (context, state) =>
                            const EmployeeTrackingScreen(),
                      ),
                    ],
                  ),

                  // ── LCO Operations ──────────────────────────────────
                  GoRoute(
                    path: 'lco-payment',
                    name: RouteNames.lcoPaymentName,
                    builder: (context, state) => const LcoPaymentScreen(),
                  ),
                  GoRoute(
                    path: 'lco-topup',
                    name: RouteNames.lcoTopupName,
                    builder: (context, state) => const LcoTopupScreen(),
                  ),
                  GoRoute(
                    path: 'lco-wallet-history',
                    name: RouteNames.lcoWalletHistoryName,
                    builder: (context, state) =>
                        const LcoWalletHistoryScreen(),
                  ),

                  // ── Hardware integration routes ─────────────────────
                  GoRoute(
                    path: 'bluetooth/printer',
                    name: RouteNames.bluetoothPrinterName,
                    builder: (context, state) =>
                        const PairedDeviceListScreen(),
                  ),
                  GoRoute(
                    path: 'bluetooth/discovery',
                    name: RouteNames.bluetoothDiscoveryName,
                    builder: (context, state) =>
                        const DeviceDiscoveryScreen(),
                  ),
                  GoRoute(
                    path: 'scanner/barcode',
                    name: RouteNames.barcodeScannerName,
                    builder: (context, state) {
                      final extra = state.extra as Map<String, dynamic>?;
                      return BarcodeScannerScreen(
                        hintLabel: extra?['hintLabel']?.toString(),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),

          // ────────────────────────────────────────────────────────────────
          // Branch 1 — Subscribers
          // ────────────────────────────────────────────────────────────────
          StatefulShellBranch(
            navigatorKey: _subscribersNavigatorKey,
            routes: [
              GoRoute(
                path: RouteNames.subscribers,
                name: RouteNames.subscribersName,
                builder: (context, state) => const CustomerSearchScreen(),
              ),
            ],
          ),

          // ────────────────────────────────────────────────────────────────
          // Branch 2 — Reports
          // Report sub-pages are nested so the bottom nav stays visible.
          // ────────────────────────────────────────────────────────────────
          StatefulShellBranch(
            navigatorKey: _reportsNavigatorKey,
            routes: [
              GoRoute(
                path: RouteNames.reports,
                name: RouteNames.reportsName,
                builder: (context, state) => const ReportsScreen(),
                routes: [
                  GoRoute(
                    path: 'mini-day',
                    name: RouteNames.miniDayReportName,
                    builder: (context, state) =>
                        const MiniDayReportScreen(),
                  ),
                  GoRoute(
                    path: 'emp-collection/filter',
                    name: RouteNames.empCollectionFilterName,
                    builder: (context, state) =>
                        const EmpCollectionFilterScreen(),
                  ),
                  GoRoute(
                    path: 'emp-collection/list',
                    name: RouteNames.empCollectionListName,
                    builder: (context, state) {
                      final extra =
                          state.extra as Map<String, dynamic>? ?? {};
                      return EmpCollectionListScreen(
                        fromDate: extra['fromDate']?.toString() ?? '',
                        toDate: extra['toDate']?.toString() ?? '',
                      );
                    },
                  ),
                  GoRoute(
                    path: 'emp-collection/detail',
                    name: RouteNames.empCollectionDetailName,
                    builder: (context, state) {
                      final extra =
                          state.extra as Map<String, dynamic>? ?? {};
                      return EmpCollectionDetailScreen(
                        employeeName:
                            extra['employeeName']?.toString() ?? '',
                      );
                    },
                  ),
                ],
              ),
            ],
          ),

          // ────────────────────────────────────────────────────────────────
          // Branch 3 — Transactions
          // ────────────────────────────────────────────────────────────────
          StatefulShellBranch(
            navigatorKey: _transactionsNavigatorKey,
            routes: [
              GoRoute(
                path: RouteNames.transactions,
                name: RouteNames.transactionsName,
                builder: (context, state) => const TransactionsScreen(),
              ),
            ],
          ),

          // ────────────────────────────────────────────────────────────────
          // Branch 4 — Settings
          // Settings sub-pages are nested so the bottom nav stays visible.
          // ────────────────────────────────────────────────────────────────
          StatefulShellBranch(
            navigatorKey: _settingsNavigatorKey,
            routes: [
              GoRoute(
                path: RouteNames.settings,
                name: RouteNames.settingsName,
                builder: (context, state) => const SettingsScreen(),
                routes: [
                  GoRoute(
                    path: 'change-password',
                    name: RouteNames.changePasswordName,
                    builder: (context, state) =>
                        const ChangePasswordScreen(),
                  ),
                  GoRoute(
                    path: 'about',
                    name: RouteNames.aboutName,
                    builder: (context, state) => const AboutScreen(),
                  ),
                  GoRoute(
                    path: 'privacy-policy',
                    name: RouteNames.privacyPolicyName,
                    builder: (context, state) =>
                        const PrivacyPolicyScreen(),
                  ),
                  // Debug/profile builds only. Gating the ROUTE (not just the
                  // Settings tile) means the console cannot be reached by deep
                  // link in release either — the screen is tree-shaken out.
                  if (kDevToolsEnabled)
                    GoRoute(
                      path: 'debug-console',
                      name: RouteNames.debugConsoleName,
                      builder: (context, state) =>
                          const DebugConsoleScreen(),
                    ),
                ],
              ),
            ],
          ),
        ],
      ),

      // ── Standalone routes (full-screen, NO bottom nav) ─────────────────
      // These use _rootNavigatorKey so they push above the shell.

      // New Customer wizard — full-screen
      GoRoute(
        path: RouteNames.newCustomer,
        name: RouteNames.newCustomerName,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return NewCustomerScreen(
            prefilledSerial: extra?['serialNumber']?.toString(),
            prefilledVc: extra?['vcNumber']?.toString(),
            prefilledStbCode: extra?['stbCode']?.toString(),
          );
        },
      ),

      // Payment webview — full-screen
      GoRoute(
        path: RouteNames.paymentWebview,
        name: RouteNames.paymentWebviewName,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return PaymentWebviewScreen(
            customerId: extra['customerId']?.toString() ?? '',
            amount: extra['amount']?.toString() ?? '',
            authKey: extra['authKey']?.toString() ?? '',
            employeeId: extra['employeeId']?.toString() ?? '',
            dealerId: extra['dealerId']?.toString() ?? '',
          );
        },
      ),

      // Payment response — full-screen
      GoRoute(
        path: RouteNames.paymentResponse,
        name: RouteNames.paymentResponseName,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return PaymentResponseScreen(
            customerId: extra['customerId']?.toString() ?? '',
            customerName: extra['customerName']?.toString(),
          );
        },
      ),
    ],
  );
});
