import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;

class ApiConstants {
  ApiConstants._();

  /// BMS (Business Management System) SOAP server URL for device registration.
  static const String bmsUrl =
      'http://183.83.216.66:9090/ezybms_m8/app/index.php/validateAuthentication';

  /// Direct API server URL (used by mobile apps & production web)
  static const String _apiBaseUrl =
      'http://192.168.1.143/v2_release_aakshya/index.php';

  /// CORS proxy URL for Flutter Web development
  /// Run: node cors_proxy.js (from project root)
  static const String _proxyBaseUrl =
      'http://localhost:3199/v2_release_aakshya/index.php';

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

  /// Base URL - checks override first, then uses CORS proxy on web debug,
  /// direct on mobile/production.
  static String get baseUrl {
    if (_overrideBaseUrl != null && _overrideBaseUrl!.isNotEmpty) {
      return _overrideBaseUrl!;
    }
    return (kIsWeb && kDebugMode) ? _proxyBaseUrl : _apiBaseUrl;
  }

  /// The hardcoded default URL (for display purposes).
  static String get defaultBaseUrl =>
      (kIsWeb && kDebugMode) ? _proxyBaseUrl : _apiBaseUrl;

  static String get restBase => '$baseUrl/LcoRestServices';
  static String get selfcareBase => '$baseUrl/selfcare_rest_mobileapp';
  static String get paymentGatewayBase => '$baseUrl/paymentgateway';

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
