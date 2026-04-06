import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Typed session object that merges the login response and access control
/// response into a single immutable config. Every screen reads config flags
/// through this class via [appSessionProvider].
class AppSession {
  // ── Identity ──────────────────────────────────────────────────────────────
  final String token;
  final int dealerId;
  final int employeeId;
  final String userType;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String lcoCode;
  final String businessName;
  final String lcoLocation;
  final String employeeParentType;
  final String employeeParentId;

  // ── Config flags from validateLogin (36 flags) ────────────────────────────
  final int useCRF;
  final String useCAF;
  final int useLastName;
  final int useDiscount;
  final int useDataFromMasterTable;
  final int useMandatoryForHotel;
  final int useAccountNumber;
  final int freezecustomerparamsinapp;
  final int blockpayment;
  final int lcoBilltype;
  final int useLcoDeposit;
  final int customerBilltype;
  final int autoReceiptNumber;
  final String currencyCode;
  final int allowTopUp;
  final int showCafMobileValidation;
  final int stbPairing;
  final int stbUnpairing;
  final int showMiaAgreementUpload;
  final int acceptTermsConditions;
  final int agreementDetailsCount;
  final int accessDistributorWise;
  final int isDirectLco;
  final int isUnpaidlco;
  final String appMenuFormat;
  final int invoicePaymentSearchLimit;
  final String lcoMobileNo;
  final String patchInformation;
  final int recurringServiceEdit;
  final int showLcoComplaint;
  final double depositAmount;
  final int showSerialVc;
  final int showServiceExtension;
  final int editQuantity;
  final int enableBoxWisePayment;
  final String? baidLabel;
  final String? defaultCountry;
  final int? defaultState;
  final int? defaultDistrict;
  final int? defaultCity;
  final int appTheme;
  final int appDashboard;
  final int enableAadhaar;
  final int lcoPaymentFlag;

  // ── Access Control flags from getaccesscontrollRest (8 flags) ─────────────
  final int intBulkPayment;
  final int invoicePageAccess;
  final int paymentHistPageAccess;
  final int accessForComplaints;
  final int intStbActivation;
  final int intStbDeactivation;
  final int intStbReactivation;
  final int pgTransaction;
  final int pgTransactionReportAccess;

  const AppSession({
    required this.token,
    required this.dealerId,
    required this.employeeId,
    required this.userType,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.lcoCode,
    required this.businessName,
    this.lcoLocation = '',
    this.employeeParentType = '',
    this.employeeParentId = '',
    this.useCRF = 0,
    this.useCAF = 'MANUAL',
    this.useLastName = 1,
    this.useDiscount = 0,
    this.useDataFromMasterTable = 0,
    this.useMandatoryForHotel = 0,
    this.useAccountNumber = 0,
    this.freezecustomerparamsinapp = 0,
    this.blockpayment = 0,
    this.lcoBilltype = 0,
    this.useLcoDeposit = 0,
    this.customerBilltype = 0,
    this.autoReceiptNumber = 1,
    this.currencyCode = 'INR',
    this.allowTopUp = 0,
    this.showCafMobileValidation = 0,
    this.stbPairing = 0,
    this.stbUnpairing = 0,
    this.showMiaAgreementUpload = 0,
    this.acceptTermsConditions = 0,
    this.agreementDetailsCount = 0,
    this.accessDistributorWise = 0,
    this.isDirectLco = 0,
    this.isUnpaidlco = 0,
    this.appMenuFormat = 'DEFAULT',
    this.invoicePaymentSearchLimit = 0,
    this.lcoMobileNo = '',
    this.patchInformation = '',
    this.recurringServiceEdit = 0,
    this.showLcoComplaint = 0,
    this.depositAmount = 0.0,
    this.showSerialVc = 1,
    this.showServiceExtension = 0,
    this.editQuantity = 0,
    this.enableBoxWisePayment = 0,
    this.baidLabel,
    this.defaultCountry,
    this.defaultState,
    this.defaultDistrict,
    this.defaultCity,
    this.appTheme = 1,
    this.appDashboard = 1,
    this.enableAadhaar = 0,
    this.lcoPaymentFlag = 0,
    this.intBulkPayment = 1,
    this.invoicePageAccess = 1,
    this.paymentHistPageAccess = 1,
    this.accessForComplaints = 1,
    this.intStbActivation = 1,
    this.intStbDeactivation = 1,
    this.intStbReactivation = 1,
    this.pgTransaction = 0,
    this.pgTransactionReportAccess = 0,
  });

  // ── Convenience getters ───────────────────────────────────────────────────

  String get displayName => '$firstName $lastName'.trim();

  String get currencySymbol => currencyCode == 'INR' ? '\u20B9' : currencyCode;

  bool get isDistributor =>
      userType == 'DISTRIBUTOR' ||
      userType == 'SUBDISTRIBUTOR' ||
      employeeParentType == 'DISTRIBUTOR' ||
      employeeParentType == 'SUBDISTRIBUTOR';

  bool get isReseller => userType == 'RESELLER';
  bool get isEmployee => userType == 'EMPLOYEE';
  bool get isTeamLead => userType == 'TEAMLEAD';

  bool get canAccessComplaints => accessForComplaints == 1;
  bool get canActivateStb => intStbActivation == 1;
  bool get canDeactivateStb => intStbDeactivation == 1;
  bool get canReactivateStb => intStbReactivation == 1;
  bool get canBulkPay => intBulkPayment == 1;
  bool get canAccessInvoices => invoicePageAccess == 1;
  bool get canAccessPaymentHistory => paymentHistPageAccess == 1;
  bool get canPgTransaction => pgTransaction == 1;

  bool get showWallet =>
      !isDistributor &&
      userType != 'DEALER' &&
      userType != 'ADMIN' &&
      userType != 'SERVICE' &&
      isDirectLco == 0;

  bool get showLcoTopUp =>
      isReseller && allowTopUp == 1 && isDirectLco == 0;

  bool get isPaymentBlocked => blockpayment == 1;
  bool get isCustomerFrozen => freezecustomerparamsinapp == 1;
  bool get useAutoReceipt => autoReceiptNumber == 1;

  // ── Factory: parse login response ─────────────────────────────────────────

  /// Constructs an [AppSession] from the raw `validateLogin` JSON response.
  /// All fields are parsed defensively — missing or null values fall back to
  /// safe defaults so the app never crashes on a partial response.
  factory AppSession.fromLoginResponse(Map<String, dynamic> json) {
    return AppSession(
      token: _str(json['authToken']),
      dealerId: _int(json['dealerId']),
      employeeId: _int(json['employeeId']),
      userType: _str(json['userType']),
      firstName: _str(json['firstName']),
      lastName: _str(json['lastName']),
      email: _str(json['emailId'] ?? json['email']),
      phone: _str(json['phone'] ?? json['mobileNo']),
      lcoCode: _str(json['lcoCode']),
      businessName: _str(json['businessName']),
      lcoLocation: _str(json['lcoLocation']),
      employeeParentType: _str(json['employeeParentType']),
      employeeParentId: _str(json['employeeParentId']),

      // Config flags
      useCRF: _int(json['useCRF']),
      useCAF: _str(json['useCAF'], fallback: 'MANUAL'),
      useLastName: _int(json['useLastName'], fallback: 1),
      useDiscount: _int(json['useDiscount']),
      useDataFromMasterTable: _int(json['useDataFromMasterTable']),
      useMandatoryForHotel: _int(json['useMandatoryForHotel']),
      useAccountNumber: _int(json['useAccountNumber']),
      freezecustomerparamsinapp: _int(json['freezecustomerparamsinapp']),
      blockpayment: _int(json['blockpayment'] ?? json['hidemakepayment']),
      lcoBilltype: _int(json['lco_billtype'] ?? json['lcoBilltype']),
      useLcoDeposit: _int(json['useLcoDeposit'] ?? json['use_lco_deposits']),
      customerBilltype: _int(json['customerBilltype'] ?? json['customer_billtype']),
      autoReceiptNumber: _int(json['autoReceiptNumber'] ?? json['AUTO_RECEIPT_NUMBER'], fallback: 1),
      currencyCode: _str(json['currencyCode'] ?? json['CURRENCY_CODE'], fallback: 'INR'),
      allowTopUp: _int(json['allowTopUp']),
      showCafMobileValidation: _int(json['showCafMobileValidation']),
      stbPairing: _int(json['stbPairing']),
      stbUnpairing: _int(json['stbUnpairing']),
      showMiaAgreementUpload: _int(json['showMiaAgreementUpload']),
      acceptTermsConditions: _int(json['acceptTermsConditions']),
      agreementDetailsCount: _int(json['agreementDetailsCount']),
      accessDistributorWise: _int(json['access_distributor_wise'] ?? json['accessDistributorWise']),
      isDirectLco: _int(json['is_direct_lco'] ?? json['isDirectLco']),
      isUnpaidlco: _int(json['is_unpaidlco'] ?? json['isUnpaidlco']),
      appMenuFormat: _str(json['appMenuFormat'] ?? json['menuType'], fallback: 'DEFAULT'),
      invoicePaymentSearchLimit: _int(json['invoicepaymentsearchlimit'] ?? json['invoicePaymentSearchLimit']),
      lcoMobileNo: _str(json['lcoMobileNo']),
      patchInformation: _str(json['patchInformation']),
      recurringServiceEdit: _int(json['recurringServiceEdit']),
      showLcoComplaint: _int(json['showLcoComplaint']),
      depositAmount: _double(json['depositAmount']),
      showSerialVc: _int(json['showSerialVc'], fallback: 1),
      showServiceExtension: _int(json['showServiceExtension']),
      editQuantity: _int(json['editQuantity']),
      enableBoxWisePayment: _int(json['enableBoxWisePayment']),
      baidLabel: json['baidLabel']?.toString(),
      defaultCountry: json['defaultCountry']?.toString(),
      defaultState: _intOrNull(json['defaultState'] ?? json['defaultstate']),
      defaultDistrict: _intOrNull(json['defaultDistrict'] ?? json['defaultdistrict']),
      defaultCity: _intOrNull(json['defaultCity'] ?? json['defaultcity']),
      appTheme: _int(json['appTheme'], fallback: 1),
      appDashboard: _int(json['appDashboard'], fallback: 1),
      enableAadhaar: _int(json['enableAadhaar']),
      lcoPaymentFlag: _int(json['lcoPaymentFlag']),
    );
  }

  /// Returns a copy with access-control flags merged from the
  /// `getaccesscontrollRest` response.
  AppSession copyWithAccessControl(Map<String, dynamic> json) {
    return AppSession(
      // Identity — carried over
      token: token,
      dealerId: dealerId,
      employeeId: employeeId,
      userType: userType,
      firstName: firstName,
      lastName: lastName,
      email: email,
      phone: phone,
      lcoCode: lcoCode,
      businessName: businessName,
      lcoLocation: lcoLocation,
      employeeParentType: employeeParentType,
      employeeParentId: employeeParentId,

      // Config flags — carried over
      useCRF: useCRF,
      useCAF: useCAF,
      useLastName: useLastName,
      useDiscount: useDiscount,
      useDataFromMasterTable: useDataFromMasterTable,
      useMandatoryForHotel: useMandatoryForHotel,
      useAccountNumber: useAccountNumber,
      freezecustomerparamsinapp: freezecustomerparamsinapp,
      blockpayment: blockpayment,
      lcoBilltype: lcoBilltype,
      useLcoDeposit: useLcoDeposit,
      customerBilltype: customerBilltype,
      autoReceiptNumber: autoReceiptNumber,
      currencyCode: currencyCode,
      allowTopUp: allowTopUp,
      showCafMobileValidation: showCafMobileValidation,
      stbPairing: stbPairing,
      stbUnpairing: stbUnpairing,
      showMiaAgreementUpload: showMiaAgreementUpload,
      acceptTermsConditions: acceptTermsConditions,
      agreementDetailsCount: agreementDetailsCount,
      accessDistributorWise: accessDistributorWise,
      isDirectLco: isDirectLco,
      isUnpaidlco: isUnpaidlco,
      appMenuFormat: appMenuFormat,
      invoicePaymentSearchLimit: invoicePaymentSearchLimit,
      lcoMobileNo: lcoMobileNo,
      patchInformation: patchInformation,
      recurringServiceEdit: recurringServiceEdit,
      showLcoComplaint: showLcoComplaint,
      depositAmount: depositAmount,
      showSerialVc: showSerialVc,
      showServiceExtension: showServiceExtension,
      editQuantity: editQuantity,
      enableBoxWisePayment: enableBoxWisePayment,
      baidLabel: baidLabel,
      defaultCountry: defaultCountry,
      defaultState: defaultState,
      defaultDistrict: defaultDistrict,
      defaultCity: defaultCity,
      appTheme: appTheme,
      appDashboard: appDashboard,
      enableAadhaar: enableAadhaar,
      lcoPaymentFlag: lcoPaymentFlag,

      // Access control — updated from response
      intBulkPayment: _int(json['int_bulk_payment'] ?? json['intBulkPayment'], fallback: intBulkPayment),
      invoicePageAccess: _int(json['invoice_page_access'] ?? json['invoicePageAccess'], fallback: invoicePageAccess),
      paymentHistPageAccess: _int(json['payment_hist_page_access'] ?? json['paymentHistPageAccess'], fallback: paymentHistPageAccess),
      accessForComplaints: _int(json['access_for_complaints'] ?? json['accessForComplaints'], fallback: accessForComplaints),
      intStbActivation: _int(json['int_stb_activation'] ?? json['intStbActivation'], fallback: intStbActivation),
      intStbDeactivation: _int(json['int_stb_deactivation'] ?? json['intStbDeactivation'], fallback: intStbDeactivation),
      intStbReactivation: _int(json['int_stb_reactivation'] ?? json['intStbReactivation'], fallback: intStbReactivation),
      pgTransaction: _int(json['pgtransaction'] ?? json['pgTransaction'], fallback: pgTransaction),
      pgTransactionReportAccess: _int(json['int_payment_transaction_report_access'] ?? json['pgTransactionReportAccess'], fallback: pgTransactionReportAccess),
    );
  }

  /// Constructs a combined session from login + access control in one call.
  factory AppSession.fromLoginAndAccessControl(
    Map<String, dynamic> loginData,
    Map<String, dynamic>? accessControlData,
  ) {
    final session = AppSession.fromLoginResponse(loginData);
    if (accessControlData == null) return session;
    return session.copyWithAccessControl(accessControlData);
  }

  // ── JSON serialisation ────────────────────────────────────────────────────

  Map<String, dynamic> toJson() => {
        'authToken': token,
        'dealerId': dealerId,
        'employeeId': employeeId,
        'userType': userType,
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'phone': phone,
        'lcoCode': lcoCode,
        'businessName': businessName,
        'lcoLocation': lcoLocation,
        'employeeParentType': employeeParentType,
        'employeeParentId': employeeParentId,
        'useCRF': useCRF,
        'useCAF': useCAF,
        'useLastName': useLastName,
        'useDiscount': useDiscount,
        'useDataFromMasterTable': useDataFromMasterTable,
        'useMandatoryForHotel': useMandatoryForHotel,
        'useAccountNumber': useAccountNumber,
        'freezecustomerparamsinapp': freezecustomerparamsinapp,
        'blockpayment': blockpayment,
        'lcoBilltype': lcoBilltype,
        'useLcoDeposit': useLcoDeposit,
        'customerBilltype': customerBilltype,
        'autoReceiptNumber': autoReceiptNumber,
        'currencyCode': currencyCode,
        'allowTopUp': allowTopUp,
        'showCafMobileValidation': showCafMobileValidation,
        'stbPairing': stbPairing,
        'stbUnpairing': stbUnpairing,
        'showMiaAgreementUpload': showMiaAgreementUpload,
        'acceptTermsConditions': acceptTermsConditions,
        'agreementDetailsCount': agreementDetailsCount,
        'accessDistributorWise': accessDistributorWise,
        'isDirectLco': isDirectLco,
        'isUnpaidlco': isUnpaidlco,
        'appMenuFormat': appMenuFormat,
        'invoicePaymentSearchLimit': invoicePaymentSearchLimit,
        'lcoMobileNo': lcoMobileNo,
        'patchInformation': patchInformation,
        'recurringServiceEdit': recurringServiceEdit,
        'showLcoComplaint': showLcoComplaint,
        'depositAmount': depositAmount,
        'showSerialVc': showSerialVc,
        'showServiceExtension': showServiceExtension,
        'editQuantity': editQuantity,
        'enableBoxWisePayment': enableBoxWisePayment,
        'baidLabel': baidLabel,
        'defaultCountry': defaultCountry,
        'defaultState': defaultState,
        'defaultDistrict': defaultDistrict,
        'defaultCity': defaultCity,
        'appTheme': appTheme,
        'appDashboard': appDashboard,
        'enableAadhaar': enableAadhaar,
        'lcoPaymentFlag': lcoPaymentFlag,
        'intBulkPayment': intBulkPayment,
        'invoicePageAccess': invoicePageAccess,
        'paymentHistPageAccess': paymentHistPageAccess,
        'accessForComplaints': accessForComplaints,
        'intStbActivation': intStbActivation,
        'intStbDeactivation': intStbDeactivation,
        'intStbReactivation': intStbReactivation,
        'pgTransaction': pgTransaction,
        'pgTransactionReportAccess': pgTransactionReportAccess,
      };

  factory AppSession.fromJson(Map<String, dynamic> json) =>
      AppSession.fromLoginResponse(json).copyWithAccessControl(json);

  /// An empty session useful as a fallback for providers that need a
  /// non-null default before the user has logged in.
  factory AppSession.empty() => const AppSession(
        token: '',
        dealerId: 0,
        employeeId: 0,
        userType: '',
        firstName: '',
        lastName: '',
        email: '',
        phone: '',
        lcoCode: '',
        businessName: '',
      );

  // ── Private parse helpers ─────────────────────────────────────────────────

  static int _int(dynamic value, {int fallback = 0}) {
    if (value == null) return fallback;
    if (value is int) return value;
    if (value is double) return value.toInt();
    final s = value.toString().trim();
    if (s.isEmpty) return fallback;
    return int.tryParse(s) ?? fallback;
  }

  static int? _intOrNull(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    final s = value.toString().trim();
    if (s.isEmpty) return null;
    return int.tryParse(s);
  }

  static double _double(dynamic value, {double fallback = 0.0}) {
    if (value == null) return fallback;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    final s = value.toString().trim();
    if (s.isEmpty) return fallback;
    return double.tryParse(s) ?? fallback;
  }

  static String _str(dynamic value, {String fallback = ''}) {
    if (value == null) return fallback;
    final s = value.toString().trim();
    return s.isEmpty ? fallback : s;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppSession &&
          runtimeType == other.runtimeType &&
          token == other.token &&
          dealerId == other.dealerId &&
          employeeId == other.employeeId;

  @override
  int get hashCode => Object.hash(token, dealerId, employeeId);

  @override
  String toString() =>
      'AppSession(dealer=$dealerId, employee=$employeeId, type=$userType, name=$displayName)';
}

// ─────────────────────────────────────────────────────────────────────────────
// StateNotifier + Provider
// ─────────────────────────────────────────────────────────────────────────────

class AppSessionNotifier extends Notifier<AppSession?> {
  @override
  AppSession? build() => null;

  /// Set the session after a successful login + access control call.
  void setSession(AppSession session) {
    state = session;
  }

  /// Build and set the session from raw login and access-control JSON maps.
  void fromLoginResponse(
    Map<String, dynamic> loginData, {
    Map<String, dynamic>? accessControlData,
  }) {
    state = AppSession.fromLoginAndAccessControl(loginData, accessControlData);
  }

  /// Merge updated access-control flags into the existing session.
  void updateAccessControl(Map<String, dynamic> accessControlData) {
    if (state == null) return;
    state = state!.copyWithAccessControl(accessControlData);
  }

  /// Restore a previously persisted session from JSON.
  void restoreFromJson(Map<String, dynamic> json) {
    state = AppSession.fromJson(json);
  }

  /// Clear the session on logout.
  void clear() {
    state = null;
  }
}

/// Global Riverpod provider for the current user session.
///
/// Usage:
/// ```dart
/// final session = ref.watch(appSessionProvider);
/// if (session?.canAccessComplaints == true) { ... }
/// ```
final appSessionProvider =
    NotifierProvider<AppSessionNotifier, AppSession?>(
  AppSessionNotifier.new,
);
