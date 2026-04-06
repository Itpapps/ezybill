/// Centralised route path and name constants for GoRouter.
///
/// Path constants are used in [GoRoute.path], while name constants are used
/// with [GoRouterState.namedLocation] and [context.goNamed].
class RouteNames {
  RouteNames._();

  // ── Tab shell paths ──────────────────────────────────────────────────────
  static const String home = '/';
  static const String subscribers = '/subscribers';
  static const String reports = '/reports';
  static const String transactions = '/transactions';
  static const String settings = '/settings';

  // ── Auth ──────────────────────────────────────────────────────────────────
  static const String login = '/login';
  static const String registration = '/registration';

  // ── Customer sub-routes ──────────────────────────────────────────────────
  static const String customerProfile = '/customer/:id';
  static const String editCustomer = '/customer/:id/edit';
  static const String newCustomer = '/customer/new';

  // ── Feature routes (no shell) ────────────────────────────────────────────
  static const String complaints = '/complaints';
  static const String complaintHistory = '/complaint-history/:customerId';
  static const String updateComplaint = '/complaint-update';
  static const String makePayment = '/make-payment';
  static const String stbOperations = '/stb-operations';
  static const String packageOperations = '/package-operations';
  static const String packageRenewal = '/package-renewal';
  static const String stbPairUnpair = '/stb-pair-unpair';
  static const String stbReplacement = '/stb-replacement';
  static const String employeeList = '/employees';
  static const String employeeTracking = '/employees/tracking';

  // ── Payment / Transaction routes ─────────────────────────────────────────
  static const String paymentHistory = '/payment-history/:customerId';
  static const String invoiceHistory = '/invoice-history/:customerId';
  static const String pgTransactions = '/pg-transactions';
  static const String paymentWebview = '/payment-webview';
  static const String paymentResponse = '/payment-response';

  // ── Report sub-routes ───────────────────────────────────────────────────
  static const String miniDayReport = '/reports/mini-day';
  static const String empCollectionFilter = '/reports/emp-collection/filter';
  static const String empCollectionList = '/reports/emp-collection/list';
  static const String empCollectionDetail = '/reports/emp-collection/detail';

  // ── Hardware integration routes ─────────────────────────────────────────
  static const String bluetoothPrinter = '/bluetooth/printer';
  static const String bluetoothDiscovery = '/bluetooth/discovery';
  static const String barcodeScanner = '/scanner/barcode';

  // ── LCO Operations ─────────────────────────────────────────────────────
  static const String lcoPayment = '/lco-payment';
  static const String lcoTopup = '/lco-topup';
  static const String lcoWalletHistory = '/lco-wallet-history';

  // ── Route names (used with goNamed / namedLocation) ──────────────────────
  static const String homeName = 'home';
  static const String subscribersName = 'subscribers';
  static const String reportsName = 'reports';
  static const String transactionsName = 'transactions';
  static const String settingsName = 'settings';
  static const String loginName = 'login';
  static const String registrationName = 'registration';
  static const String customerProfileName = 'customer-profile';
  static const String editCustomerName = 'edit-customer';
  static const String newCustomerName = 'new-customer';
  static const String complaintsName = 'complaints';
  static const String complaintHistoryName = 'complaint-history';
  static const String updateComplaintName = 'complaint-update';
  static const String makePaymentName = 'make-payment';
  static const String stbOperationsName = 'stb-operations';
  static const String packageOperationsName = 'package-operations';
  static const String packageRenewalName = 'package-renewal';
  static const String stbPairUnpairName = 'stb-pair-unpair';
  static const String stbReplacementName = 'stb-replacement';
  static const String employeeListName = 'employee-list';
  static const String employeeTrackingName = 'employee-tracking';
  static const String paymentHistoryName = 'payment-history';
  static const String invoiceHistoryName = 'invoice-history';
  static const String pgTransactionsName = 'pg-transactions';
  static const String paymentWebviewName = 'payment-webview';
  static const String paymentResponseName = 'payment-response';
  static const String miniDayReportName = 'mini-day-report';
  static const String empCollectionFilterName = 'emp-collection-filter';
  static const String empCollectionListName = 'emp-collection-list';
  static const String empCollectionDetailName = 'emp-collection-detail';
  static const String bluetoothPrinterName = 'bluetooth-printer';
  static const String bluetoothDiscoveryName = 'bluetooth-discovery';
  static const String barcodeScannerName = 'barcode-scanner';
  static const String lcoPaymentName = 'lco-payment';
  static const String lcoTopupName = 'lco-topup';
  static const String lcoWalletHistoryName = 'lco-wallet-history';

  // ── Settings sub-routes ───────────────────────────────────────────────
  static const String changePassword = '/settings/change-password';
  static const String about = '/settings/about';
  static const String privacyPolicy = '/settings/privacy-policy';

  static const String debugConsole = '/settings/debug-console';

  static const String changePasswordName = 'change-password';
  static const String aboutName = 'about';
  static const String privacyPolicyName = 'privacy-policy';
  static const String debugConsoleName = 'debug-console';
}
