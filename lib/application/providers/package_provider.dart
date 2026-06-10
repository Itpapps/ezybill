import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/utils/parse_utils.dart';
import '../../data/datasources/remote/package_remote_datasource.dart';
import '../../data/datasources/remote/stb_remote_datasource.dart';
import '../../data/models/stb/deactivation_reason.dart';
import '../../data/models/payment/bill_detail.dart';
import '../../data/models/package/package_model.dart';
import '../../core/config/app_session.dart';
import 'core_providers.dart';
import 'stb_provider.dart';

// ---------------------------------------------------------------------------
// Datasource provider
// ---------------------------------------------------------------------------

final packageRemoteDatasourceProvider =
    Provider<PackageRemoteDatasource>((ref) {
  return PackageRemoteDatasource(dio: ref.watch(dioClientProvider));
});

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

class PackageState {
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;

  // Assigned (active) packages by category
  final List<PackageModel> assignedBase;
  final List<PackageModel> assignedAddon;
  final List<PackageModel> assignedAla;
  final List<PackageModel> assignedBroadcaster;

  // Available packages by category
  final List<PackageModel> availableBase;
  final List<PackageModel> availableAddon;
  final List<PackageModel> availableAla;
  final List<PackageModel> availableBroadcaster;

  // Selection
  final Set<String> selectedIds;

  // Deactivation
  final List<DeactivationReason> deactivationReasons;

  // Bill details
  final BillDetail? billDetail;
  final bool billFetched;

  // Renewal
  final List<PackageModel> renewableServices;

  const PackageState({
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
    this.assignedBase = const [],
    this.assignedAddon = const [],
    this.assignedAla = const [],
    this.assignedBroadcaster = const [],
    this.availableBase = const [],
    this.availableAddon = const [],
    this.availableAla = const [],
    this.availableBroadcaster = const [],
    this.selectedIds = const {},
    this.deactivationReasons = const [],
    this.billDetail,
    this.billFetched = false,
    this.renewableServices = const [],
  });

  /// Convenience: all assigned packages flat.
  List<PackageModel> get allAssigned =>
      [...assignedBase, ...assignedAddon, ...assignedAla, ...assignedBroadcaster];

  /// Convenience: all available packages flat.
  List<PackageModel> get allAvailable =>
      [...availableBase, ...availableAddon, ...availableAla, ...availableBroadcaster];

  /// Filtered deactivation reasons per Android spec (Section 4.4):
  /// Exclude reason ID 17, ID 21, and global_reason == 1.
  List<DeactivationReason> get filteredReasons => deactivationReasons
      .where((r) =>
          r.reasonId != 17 && r.reasonId != 21 && r.globalReason != 1)
      .toList();

  PackageState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
    List<PackageModel>? assignedBase,
    List<PackageModel>? assignedAddon,
    List<PackageModel>? assignedAla,
    List<PackageModel>? assignedBroadcaster,
    List<PackageModel>? availableBase,
    List<PackageModel>? availableAddon,
    List<PackageModel>? availableAla,
    List<PackageModel>? availableBroadcaster,
    Set<String>? selectedIds,
    List<DeactivationReason>? deactivationReasons,
    BillDetail? billDetail,
    bool? billFetched,
    List<PackageModel>? renewableServices,
  }) {
    return PackageState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      successMessage: successMessage,
      assignedBase: assignedBase ?? this.assignedBase,
      assignedAddon: assignedAddon ?? this.assignedAddon,
      assignedAla: assignedAla ?? this.assignedAla,
      assignedBroadcaster: assignedBroadcaster ?? this.assignedBroadcaster,
      availableBase: availableBase ?? this.availableBase,
      availableAddon: availableAddon ?? this.availableAddon,
      availableAla: availableAla ?? this.availableAla,
      availableBroadcaster: availableBroadcaster ?? this.availableBroadcaster,
      selectedIds: selectedIds ?? this.selectedIds,
      deactivationReasons: deactivationReasons ?? this.deactivationReasons,
      billDetail: billDetail ?? this.billDetail,
      billFetched: billFetched ?? this.billFetched,
      renewableServices: renewableServices ?? this.renewableServices,
    );
  }
}

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

class PackageNotifier extends Notifier<PackageState> {
  late PackageRemoteDatasource _pkgDs;
  late StbRemoteDatasource _stbDs;

  @override
  PackageState build() {
    _pkgDs = ref.watch(packageRemoteDatasourceProvider);
    _stbDs = ref.watch(stbRemoteDatasourceProvider);
    return const PackageState();
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  AppSession? get _session => ref.read(appSessionProvider);
  String get _token => _session?.token ?? '';
  int get _dealerId => _session?.dealerId ?? 0;
  int get _employeeId => _session?.employeeId ?? 0;

  bool _isSuccess(Map<String, dynamic> resp) {
    final code = resp['status_code'] ?? resp['statusCode'];
    return code?.toString() == '0';
  }

  int _deriveDateType(PackageModel pkg) {
    final validity = pkg.validity.toLowerCase();
    if (validity.contains('year')) return 2;
    if (validity.contains('day')) return 3;
    return 1; // month/default
  }

  int _statusCode(Map<String, dynamic> resp) {
    final code = resp['status_code'] ?? resp['statusCode'];
    return int.tryParse(code?.toString() ?? '') ?? -1;
  }

  String _serverMsg(Map<String, dynamic> resp, {String fallback = ''}) {
    return resp['status_msg']?.toString() ??
        resp['statusMsg']?.toString() ??
        resp['statusMessage']?.toString() ??
        fallback;
  }

  /// Strip HTML tags from server response messages per Android spec (Section 3.7).
  String _stripHtml(String text) {
    return text
        .replaceAll(RegExp(r'<b>|</b>|<br>|</br>|<br/>|<br />'), '')
        .trim();
  }

  List<PackageModel> _parsePackages(dynamic raw) =>
      parseList<PackageModel>(raw, PackageModel.fromJson);

  // ── Validity/Date Computation (Section 3.4) ─────────────────────────────
  //
  // CRITICAL BUSINESS RULE: The validity string's LENGTH determines the
  // date unit used for end-date calculation.
  //
  //  | validity.length | Unit    | Example string |
  //  |-----------------|---------|----------------|
  //  | 7               | YEAR    | "Year(s)"      |
  //  | 8               | MONTH   | "Month(s)"     |
  //  | other           | DATE    | days           |
  //
  // After adding the period, subtract 1 day so a 1-month package starting
  // Jan 1 ends Jan 31.

  /// Compute the service end date for a package based on its validity string
  /// and validityDays.  Returns a formatted date string (dd-MM-yyyy).
  static String computeEndDate(PackageModel pkg) {
    final now = DateTime.now();
    final validityStr = pkg.validity; // e.g. "Year(s)", "Month(s)", or numeric
    final days = pkg.validityDays;

    DateTime endDate;
    if (validityStr.length == 7) {
      // YEAR — add N years
      endDate = DateTime(now.year + days, now.month, now.day);
    } else if (validityStr.length == 8) {
      // MONTH — add N months
      endDate = DateTime(now.year, now.month + days, now.day);
    } else {
      // DATE — add N days
      endDate = now.add(Duration(days: days));
    }

    // Subtract 1 day per Android spec
    endDate = endDate.subtract(const Duration(days: 1));

    return DateFormat('dd-MM-yyyy').format(endDate);
  }

  /// Start date is always today.
  static String computeStartDate() {
    return DateFormat('dd-MM-yyyy').format(DateTime.now());
  }

  // ── Load assigned packages ───────────────────────────────────────────────

  Future<void> loadAssigned(String customerId, String boxNumber) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final data = await _pkgDs.getCustomerPackages(
        authtoken: _token,
        customerId: customerId,
        stbNo: boxNumber,
      );

      state = state.copyWith(
        isLoading: false,
        assignedBase: _parsePackages(data['packageList_base']),
        assignedAddon: _parsePackages(data['packageList_addon']),
        assignedAla: _parsePackages(data['packageList_ala']),
        assignedBroadcaster: _parsePackages(data['packageList_broadcaster']),
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  // ── Load available packages ──────────────────────────────────────────────

  Future<void> loadAvailable(String customerId, String boxNumber) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final data = await _pkgDs.getUnassignedPackages(
        authtoken: _token,
        customerId: customerId,
        stbNo: boxNumber,
      );

      state = state.copyWith(
        isLoading: false,
        availableBase: _parsePackages(data['packageList_base']),
        availableAddon: _parsePackages(data['packageList_addon']),
        availableAla: _parsePackages(data['packageList_ala']),
        availableBroadcaster: _parsePackages(data['packageList_broadcaster']),
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  // ── Combined load (assigned + available) ─────────────────────────────────

  Future<void> loadCustomerPackages(String customerId, String stbNo) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await Future.wait([
        loadAssigned(customerId, stbNo),
        loadAvailable(customerId, stbNo),
      ]);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  // ── Selection ────────────────────────────────────────────────────────────

  void toggleSelection(String packageId) {
    final current = Set<String>.from(state.selectedIds);
    if (current.contains(packageId)) {
      current.remove(packageId);
    } else {
      current.add(packageId);
    }
    state = state.copyWith(selectedIds: current, billFetched: false, billDetail: null);
  }

  void clearSelection() {
    state = state.copyWith(
        selectedIds: const {}, billFetched: false, billDetail: null);
  }

  // ── Bill details (Section 3.5) ──────────────────────────────────────────
  //
  // REST endpoint: /getbilldetailsRest
  // Params: authtoken, dealer_id, employee_id, customer_id,
  //         package_id (comma-separated), serial_number
  //
  // Response contains "basePrice" object with lco_share, mso_share,
  // ncf_total_amount, encf_total_amount, total_amount, etc.
  // NCF row hidden if ncf_total_amount <= 0
  // ENCF row hidden if encf_total_amount <= 0

  Future<bool> loadBillDetails({
    required String customerId,
    required String boxNumber,
    required String productIds,
    String? resellerId,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final data = await _pkgDs.getBillDetails(
        authtoken: _token,
        dealerId: _dealerId.toString(),
        employeeId: resellerId ?? _employeeId.toString(),
        customerId: customerId,
        packageId: productIds,
        serialNumber: boxNumber,
      );

      if (_isSuccess(data)) {
        // Parse the "basePrice" nested object from the response
        final basePriceData = data['basePrice'] as Map<String, dynamic>?;
        if (basePriceData != null) {
          final bill = BillDetail.fromJson(basePriceData);
          state = state.copyWith(
            isLoading: false,
            billDetail: bill,
            billFetched: true,
          );
          return true;
        }

        // Fallback: try parsing the root level
        final bill = BillDetail.fromJson(data);
        state = state.copyWith(
          isLoading: false,
          billDetail: bill,
          billFetched: true,
        );
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: _serverMsg(data, fallback: 'Failed to get bill details'),
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  // ── Activate service (Section 3.7) ──────────────────────────────────────
  //
  // CRITICAL params per Android spec:
  //   customerId, customerDeviceId, productId (comma-separated),
  //   quantity=1, dateType=0, pricingStructureType=1, validityDays=1,
  //   stockId, fromMobileApp=1, login_employee_id, reseller_id, dealer_id
  //
  // Response codes:
  //   0 = success, 1 = failure dialog, 2 = "Contact Support", >2 = failure

  Future<bool> activateService({
    required String customerId,
    required String customerDeviceId,
    required String productIds,
    required String stockId,
    String? resellerId,
  }) async {
    state = state.copyWith(
        isLoading: true, errorMessage: null, successMessage: null);
    try {
      final selectedPkg = state.allAvailable
          .where((p) => state.selectedIds.contains(p.packageId))
          .firstOrNull;
      final qty = 1;
      final pricingType =
          int.tryParse(selectedPkg?.pricingStructureType ?? '') ?? 1;
      final validity = (selectedPkg?.validityDays ?? 0) > 0
          ? selectedPkg!.validityDays
          : 1;
      final dateType = selectedPkg != null ? _deriveDateType(selectedPkg) : 1;

      final data = await _pkgDs.activateService(
        authtoken: _token,
        customerId: customerId,
        customerDeviceId: customerDeviceId,
        productId: productIds,
        stockId: stockId,
        quantity: qty.toString(),
        dateType: dateType.toString(),
        pricingStructureType: pricingType.toString(),
        validityDays: validity.toString(),
        dealerId: _dealerId.toString(),
        resellerId: resellerId ?? _employeeId.toString(),
        loginEmployeeId: _employeeId.toString(),
      );

      final code = _statusCode(data);
      final rawMsg = _serverMsg(data, fallback: '');

      if (code == 0) {
        // Strip HTML tags from response messages per spec
        final cleanMsg = _stripHtml(rawMsg.isNotEmpty
            ? rawMsg
            : 'Service activated successfully');
        state = state.copyWith(
          isLoading: false,
          successMessage: cleanMsg,
          selectedIds: const {},
          billFetched: false,
          billDetail: null,
        );
        return true;
      } else if (code == 1) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Activation Failed! ${_stripHtml(rawMsg)}',
        );
        return false;
      } else if (code == 2) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Contact Support',
        );
        return false;
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Activation Failed!',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  // ── Deactivate service (Section 4.6) ────────────────────────────────────
  //
  // CRITICAL: Uses customer_service_id (comma-separated) NOT product_id.
  //
  // Params: authToken, customerId, serviceId, fromMobileApp=1, reasonId,
  //         remarks (with suffix), stock_id, dealer_id, reseller_id,
  //         login_employee_id
  //
  // Remarks suffix: ". Deactivation From Flutter App"
  //
  // Response codes:
  //   0 = success, 1 = failure with message, >=2 = failure with details

  Future<bool> deactivateService({
    required String customerId,
    required String serviceIds,
    required String reasonId,
    required String remarks,
    String? stockId,
    String? resellerId,
  }) async {
    state = state.copyWith(
        isLoading: true, errorMessage: null, successMessage: null);
    try {
      // Validate remarks per spec (Section 4.5): must NOT be empty
      if (remarks.trim().isEmpty) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Remarks should not be empty.',
        );
        return false;
      }

      // Append suffix per Android spec (Section 4.6):
      // remarks = userText + ". Deactivation From Flutter App"
      final fullRemarks = '${remarks.trim()}. Deactivation From Flutter App';

      final data = await _pkgDs.deactivateService(
        authtoken: _token,
        customerId: customerId,
        serviceId: serviceIds,
        reasonId: reasonId,
        remarks: fullRemarks,
        dealerId: _dealerId.toString(),
        resellerId: resellerId ?? _employeeId.toString(),
        loginEmployeeId: _employeeId.toString(),
        stockId: stockId,
      );

      final code = _statusCode(data);
      final rawMsg = _serverMsg(data, fallback: '');

      if (code == 0) {
        state = state.copyWith(
          isLoading: false,
          successMessage: 'Product deactivated successfully',
          selectedIds: const {},
        );
        return true;
      } else if (code == 1) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: '$rawMsg Package deactivation failed',
        );
        return false;
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage:
              '$rawMsg. Package deactivation failed. Please check and enter valid details',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  // ── Deactivation reasons (Section 4.4) ──────────────────────────────────
  //
  // Filtering is done in PackageState.filteredReasons getter:
  // Exclude reasonId == 17, reasonId == 21, global_reason == 1

  Future<void> loadDeactivationReasons() async {
    try {
      final data = await _stbDs.getDeactivationReasons(authtoken: _token);
      final reasons = parseList<DeactivationReason>(
        data['reasonList'] ?? data['data'],
        DeactivationReason.fromJson,
      );
      state = state.copyWith(deactivationReasons: reasons);
    } catch (e) {
      debugPrint('Failed to load deactivation reasons: $e');
    }
  }

  // ── Renewable services (Section 5.1) ────────────────────────────────────
  //
  // REST endpoint: /getRenewServicesList
  // Params: authtoken, dealer_id, customer_id
  //
  // Response: status_code == 0, getRenewServices: [ { customer_service_id,
  //           product_id, base_price, pname } ]

  Future<void> loadRenewable(String customerId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final data = await _pkgDs.getRenewServices(
        authtoken: _token,
        customerId: customerId,
        dealerId: _dealerId.toString(),
      );

      if (_isSuccess(data)) {
        final services = parseList<PackageModel>(
          data['getRenewServices'] ?? data['data'],
          PackageModel.fromJson,
        );
        state = state.copyWith(isLoading: false, renewableServices: services);
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: _serverMsg(data, fallback: 'Failed to load renewable services'),
        );
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  // ── Submit renewal (Section 5.3) ────────────────────────────────────────
  //
  // REST endpoint: /renewServicesList
  // CRITICAL: Sends BOTH customer_service_id AND product_ids as separate
  // comma-separated params.
  //
  // Response: status_code == 0 = success, 1 = failure

  Future<bool> submitRenewal(String customerId) async {
    state = state.copyWith(
        isLoading: true, errorMessage: null, successMessage: null);
    try {
      // Build comma-separated customer_service_ids and product_ids
      // from selected renewable services.
      final customerServiceIds = <String>[];
      final productIds = <String>[];

      for (final id in state.selectedIds) {
        final svc = state.renewableServices
            .where((s) => s.packageId == id)
            .firstOrNull;
        if (svc != null) {
          // customer_service_id for renewal
          if (svc.customerServiceId != null &&
              svc.customerServiceId!.isNotEmpty) {
            customerServiceIds.add(svc.customerServiceId!);
          }
          // product_id
          productIds.add(svc.packageId);
        }
      }

      if (customerServiceIds.isEmpty || productIds.isEmpty) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'No valid services selected for renewal',
        );
        return false;
      }

      final data = await _pkgDs.renewServices(
        authtoken: _token,
        customerId: customerId,
        dealerId: _dealerId.toString(),
        customerServiceIds: customerServiceIds.join(','),
        productIds: productIds.join(','),
      );

      final code = _statusCode(data);

      if (code == 0) {
        state = state.copyWith(
          isLoading: false,
          successMessage:
              _serverMsg(data, fallback: 'Renewal submitted successfully'),
          selectedIds: const {},
        );
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: _serverMsg(data, fallback: 'Renewal failed'),
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  // ── Clear messages ───────────────────────────────────────────────────────

  void clearMessages() {
    state = state.copyWith(errorMessage: null, successMessage: null);
  }
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

final packageProvider =
    NotifierProvider<PackageNotifier, PackageState>(PackageNotifier.new);
