import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;

class ApiConstants {
  ApiConstants._();

  // ═══════════════════════════════════════════════════════════════════════════
  // ENVIRONMENT TOGGLE — Comment/uncomment to switch between LIVE and LOCAL
  // ═══════════════════════════════════════════════════════════════════════════
  //
  // Switch environments by commenting/uncommenting ONE constant: bmsUrl.
  // Everything downstream follows from the BMS response — there is no second
  // flag and no code-level API host to keep in sync.
  //
  //   bmsUrl (LIVE or LOCAL)
  //     -> BMS registration returns ipAddress + version
  //     -> bms_provider derives the API base (strips /wsController for V2)
  //     -> setBaseUrl() -> _overrideBaseUrl -> baseUrl
  //     -> isWsController drives restBase, SOAP/REST login and encryption
  //
  // This mirrors the native Android app, where NAMESPACE_BMS selects which BMS
  // is asked and the operational host always comes from the BMS response.
  //
  // NOTE: switching environments needs a fresh registration state, since the
  // previous BMS-supplied URL persists in login_url/api_base_url.
  // ═══════════════════════════════════════════════════════════════════════════

  // ── BMS URL (device registration + version check) ─────────────────────────
  // THE ONLY ENVIRONMENT SWITCH. Comment/uncomment one of the two below and
  // rebuild — same model as the native Android app's NAMESPACE_BMS.
  // The selected BMS returns `ipAddress` + `version`; bms_provider derives the
  // API base from those and calls setBaseUrl(). Nothing else needs changing.
  // LIVE
  // static const String bmsUrl =
  //     'http://ezybms.itpworld.com/index.php/validateAuthentication';
  //LOCAL
  static const String bmsUrl =
       'http://183.82.159.51:9090/ezybms_m8/app/index.php/validateAuthentication';
  //LOCAL
  // static const String bmsUrl =
  //     'http://192.168.1.98/ezybms_m8/app/index.php/validateAuthentication';

  // ── Fallback API base URL (only used when _overrideBaseUrl is null) ────────
  // Never reached once BMS registration has run — BMS sets _overrideBaseUrl.
  // Kept as an unroutable sentinel so a pre-registration call fails loudly
  // instead of silently reaching a real host. Also backs defaultBaseUrl,
  // which the "Reset to default" affordances read.
  static const String _apiBaseUrl = 'http://0.0.0.0';

  // ── CORS proxy for Flutter Web development only ──
  // LOCAL (web dev)
  static const String _proxyBaseUrl =
      'http://localhost:3199/v2_release_aakshya/index.php';
  // static const String _proxyBaseUrl = 'http://0.0.0.0';

  /// Override base URL set at runtime from SharedPreferences
  static String? _overrideBaseUrl;

  /// Set a custom base URL (persisted via SharedPreferences externally).
  static void setBaseUrl(String url) {
    _overrideBaseUrl = url.trim().isEmpty ? null : url.trim();
  }

  /// Clear the override so the default is used.
  static void clearBaseUrl() {
    _overrideBaseUrl = null;
  }

  /// Base URL — the BMS-supplied override wins, exactly as the native Android
  /// app prefers its persisted `login_url` over any compiled constant.
  /// Falls back to the sentinel only before registration has run.
  static String get baseUrl {
    if (_overrideBaseUrl != null && _overrideBaseUrl!.isNotEmpty) {
      return _overrideBaseUrl!;
    }
    return (kIsWeb && kDebugMode) ? _proxyBaseUrl : _apiBaseUrl;
  }

  /// The hardcoded default URL (for display purposes).
  static String get defaultBaseUrl =>
      (kIsWeb && kDebugMode) ? _proxyBaseUrl : _apiBaseUrl;

  /// Whether the current baseUrl points to a live wsController proxy server.
  /// Live servers route through wsController; local servers use direct controllers.
  static bool get isWsController => baseUrl.endsWith('/wsController');

  /// REST base URL for LCO service calls (Dio-based, NOT login).
  /// Login uses SOAP on live (bypasses Dio) and REST on local.
  /// LOCAL:  baseUrl = .../index.php  → restBase = .../index.php/LcoRestServices
  /// LIVE:   baseUrl = .../index.php/wsController → strip wsController
  ///         → restBase = .../index.php/customerRestservices
  ///         (Android app uses customerRestservices for all REST calls)
  static String get restBase {
    if (isWsController) {
      return '$_strippedBase/customerRestservices';
    }
    return '$baseUrl/LcoRestServices';
  }
  /// Base URL without wsController suffix (for controllers that exist directly).
  static String get _strippedBase =>
      baseUrl.replaceAll('/wsController', '');

  static String get selfcareBase => '$_strippedBase/selfcare_rest_mobileapp';
  static String get paymentGatewayBase => '$_strippedBase/paymentgateway';

  // Auth
  static const String validateLogin = '/validateLogin';
  static const String getAccessControl = '/getaccesscontrollRest';

  // Dashboard
  static const String dashboardDetails = '/dashBoardDetailsRest';
  static const String lcoDepositAmount = '/lco_deposit_amountRest';
  static const String lcoWallet = '/getlcowalletRest';
  static const String dashboardList = '/getdashboardlist';
  static const String expiryServicesCount = '/getExpiryServicesDateWiseCount';

  // Customer
  static const String customerDetailsCount = '/getCustomerDetailsCountRest';
  static const String customerDetails = '/getCustomerDetailsRest';
  static const String existingCustomer = '/existingCustomerRest';
  static const String saveCustomer = '/saveCustomerRest';
  static const String editCustomer = '/editCustomerRest';
  static const String updateCustomerLocation = '/updateCustomerLocation';

  // Payments
  static const String pendingAmount = '/getPendingAmountRest';
  static const String makePayment = '/makePaymentsRest';
  static const String paymentModes = '/getPaymentModesRest';
  static const String receiptRanges = '/getReceiptRanges';
  static const String billDetails = '/getbilldetailsRest';
  static const String pgTransactionLogs = '/pgTransactionLogs';
  static const String paymentHistory = '/PaymentServiceRest';
  static const String customerTransaction = '/customer_transaction_reponseRest';

  // Complaints
  static const String complaintList = '/getComplaintList';
  static const String totalComplaintsList = '/gettotalcomplaintslist';
  static const String customerComplaintList = '/getCustomerComplaintListRest';
  static const String complaintCategories = '/complaintCategoriesRest';
  static const String complaintSubCategories = '/getComplaintsubCategory';
  static const String createComplaint = '/createComplaintRest';
  static const String complaintTypes = '/complaintTypesRest';
  static const String closeComplaint = '/closeComplaintRest';
  static const String complaintHistory = '/ComplaintHistoryRest';

  // STB / Box
  static const String customerBoxDetails = '/getCustomerBoxDetailsRest';
  static const String particularBoxDetails =
      '/getCustomerParticularBoxDetailsRest';
  static const String deactivateBox = '/deactivateBoxRest';
  static const String reactivateBox = '/reactivateBoxRest';
  static const String deactivationReasons = '/getDeactiveReasonsRest';
  static const String temporaryActivation = '/temporaryActivationRest';
  static const String validateBoxInfo = '/validateBoxInfoRest';
  static const String stbPair = '/stbPairRest';
  static const String stbUnpair = '/stbUnpairRest';
  static const String stbReplacement = '/stb_replacement';

  // Packages / Services
  static const String customerPackages = '/getCustomerPackages_splitRest';
  static const String unassignedPackages = '/getUnassignedPackages_splitRest';
  static const String activateService = '/activateServiceRest';
  static const String deactivateService = '/deactivateServiceRest';
  static const String extendService = '/extendCustomerServices';
  static const String casPackages = '/getCasPackagesRest';
  static const String channelList = '/channel_listRest';
  static const String renewServices = '/renewServicesList';
  static const String getRenewServices = '/getRenewServicesList';

  // Reports
  static const String dailyReport = '/DailyreportRest';
  static const String empCollection = '/empCollectionRest';
  static const String empCustomerCollection =
      '/empCustomerCollectionDetailsRest';
  static const String invoiceHistory = '/InvoiceServiceRest';

  // Employees
  static const String lcoEmployeeList = '/getLcoEmployeeList';
  static const String serviceEmployeeList = '/getServiceEmployeeList';
  static const String employeeTrackInfo = '/getEmployeeTrackInfo';

  // Master Data
  static const String countries = '/getCountriesRest';
  static const String states = '/getStatesRest';
  static const String districts = '/getdistrictsRest';
  static const String cities = '/getCitiesRest';
  static const String mandals = '/getmandalsRest';
  static const String locationsOfDistrict = '/getLocationsOfDistrictRest';
  static const String groups = '/getGroupsRest';
  static const String customerTypes = '/getCustomerTypesRest';
  static const String customerTypeTypes = '/getcustomerTypeTypesRest';
  static const String idTypes = '/getIdsRest';
  static const String dynamicFormValidations = '/dynamicformvalidationsRest';

  // Password
  static const String changePassword = '/changePasswordRest';
}
