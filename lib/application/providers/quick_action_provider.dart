import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/remote/customer_remote_datasource.dart';
import '../../data/datasources/remote/package_remote_datasource.dart';
import '../../data/datasources/remote/stb_remote_datasource.dart';
import 'core_providers.dart';
import 'customer_provider.dart';
import 'package_provider.dart';
import 'stb_provider.dart';

// ---------------------------------------------------------------------------
// Search field enum
// ---------------------------------------------------------------------------

enum QuickSearchField {
  stbNo('STB No'),
  vcNo('VC No'),
  mobile('Mobile'),
  name('Name'),
  accountNo('A/C No');

  final String label;
  const QuickSearchField(this.label);
}

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

class QuickActionState {
  final bool isSearching;
  final String? error;
  final QuickSearchField searchField;

  // Customer info
  final String? customerId;
  final String? customerName;
  final String? mobileNumber;
  final String? accountNumber;

  // STB info
  final String? serialNumber;
  final String? vcNumber;
  final String? boxNumber;
  final String? macAddress;
  final String? stockId;
  final String? deviceId;
  final String? backendSetupId;
  final String? stbStatus; // "ACTIVE", "DE-ACTIVE", "TEMPORARY DE-ACTIVE"
  final String? casName;
  final String? stbType;
  final String? stbModel;
  final String? activationDate;
  final String? lcoName;
  final String? dueDate;
  final String? dueAmount;
  final int isTempDeactivated;

  // Packages
  final List<Map<String, dynamic>> activePackages;
  final List<Map<String, dynamic>> deactivatedPackages;

  // Action state
  final bool isActioning;
  final String? actionResult;
  final bool actionSuccess;

  // Whether we have a loaded result
  bool get hasResult => customerId != null && customerId!.isNotEmpty;

  const QuickActionState({
    this.isSearching = false,
    this.error,
    this.searchField = QuickSearchField.stbNo,
    this.customerId,
    this.customerName,
    this.mobileNumber,
    this.accountNumber,
    this.serialNumber,
    this.vcNumber,
    this.boxNumber,
    this.macAddress,
    this.stockId,
    this.deviceId,
    this.backendSetupId,
    this.stbStatus,
    this.casName,
    this.stbType,
    this.stbModel,
    this.activationDate,
    this.lcoName,
    this.dueDate,
    this.dueAmount,
    this.isTempDeactivated = 0,
    this.activePackages = const [],
    this.deactivatedPackages = const [],
    this.isActioning = false,
    this.actionResult,
    this.actionSuccess = false,
  });

  QuickActionState copyWith({
    bool? isSearching,
    String? error,
    QuickSearchField? searchField,
    String? customerId,
    String? customerName,
    String? mobileNumber,
    String? accountNumber,
    String? serialNumber,
    String? vcNumber,
    String? boxNumber,
    String? macAddress,
    String? stockId,
    String? deviceId,
    String? backendSetupId,
    String? stbStatus,
    String? casName,
    String? stbType,
    String? stbModel,
    String? activationDate,
    String? lcoName,
    String? dueDate,
    int? isTempDeactivated,
    List<Map<String, dynamic>>? activePackages,
    List<Map<String, dynamic>>? deactivatedPackages,
    bool? isActioning,
    String? actionResult,
    bool? actionSuccess,
  }) {
    return QuickActionState(
      isSearching: isSearching ?? this.isSearching,
      error: error,
      searchField: searchField ?? this.searchField,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      accountNumber: accountNumber ?? this.accountNumber,
      serialNumber: serialNumber ?? this.serialNumber,
      vcNumber: vcNumber ?? this.vcNumber,
      boxNumber: boxNumber ?? this.boxNumber,
      macAddress: macAddress ?? this.macAddress,
      stockId: stockId ?? this.stockId,
      deviceId: deviceId ?? this.deviceId,
      backendSetupId: backendSetupId ?? this.backendSetupId,
      stbStatus: stbStatus ?? this.stbStatus,
      casName: casName ?? this.casName,
      stbType: stbType ?? this.stbType,
      stbModel: stbModel ?? this.stbModel,
      activationDate: activationDate ?? this.activationDate,
      lcoName: lcoName ?? this.lcoName,
      dueDate: dueDate ?? this.dueDate,
      dueAmount: dueAmount ?? this.dueAmount,
      isTempDeactivated: isTempDeactivated ?? this.isTempDeactivated,
      activePackages: activePackages ?? this.activePackages,
      deactivatedPackages: deactivatedPackages ?? this.deactivatedPackages,
      isActioning: isActioning ?? this.isActioning,
      actionResult: actionResult,
      actionSuccess: actionSuccess ?? this.actionSuccess,
    );
  }
}

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

class QuickActionNotifier extends Notifier<QuickActionState> {
  late CustomerRemoteDatasource _customerDs;
  late StbRemoteDatasource _stbDs;
  late PackageRemoteDatasource _pkgDs;

  @override
  QuickActionState build() {
    _customerDs = ref.watch(customerRemoteDatasourceProvider);
    _stbDs = ref.watch(stbRemoteDatasourceProvider);
    _pkgDs = ref.watch(packageRemoteDatasourceProvider);
    return const QuickActionState();
  }

  // -- Helpers ----------------------------------------------------------------

  String get _token => ref.read(appSessionProvider)?.token ?? '';

  String _str(dynamic value) {
    if (value == null) return '';
    return value.toString().trim();
  }

  int _int(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }

  /// Update search field without clearing results.
  void setSearchField(QuickSearchField field) {
    state = state.copyWith(searchField: field);
  }

  // -- Search -----------------------------------------------------------------

  /// Chains API calls:
  /// 1. Search customer by field -> get customer_id
  /// 2. Get box details -> get serial_number, vc, status, etc.
  /// 3. Get packages -> active & deactivated lists
  Future<void> search(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;

    // Reset to searching state, keeping searchField
    state = QuickActionState(
      isSearching: true,
      searchField: state.searchField,
    );

    try {
      // ── Step 1: Search customer ──
      final Map<String, dynamic> searchParams = {};
      switch (state.searchField) {
        case QuickSearchField.stbNo:
        case QuickSearchField.vcNo:
          searchParams['boxNumber'] = trimmed;
          break;
        case QuickSearchField.mobile:
          searchParams['mobileNumber'] = trimmed;
          break;
        case QuickSearchField.name:
          searchParams['customerName'] = trimmed;
          break;
        case QuickSearchField.accountNo:
          searchParams['customerNumber'] = trimmed;
          break;
      }

      final customerData = await _customerDs.getCustomerDetails(
        authtoken: _token,
        customerNumber: searchParams['customerNumber'],
        customerName: searchParams['customerName'],
        mobileNumber: searchParams['mobileNumber'],
        boxNumber: searchParams['boxNumber'],
        startValue: 0,
        endValue: 1,
      );

      final customerList = (customerData['customerDetailsList'] ??
              customerData['existCustomerDetails']) as List?;
      if (customerList == null || customerList.isEmpty) {
        state = QuickActionState(
          error: 'No customer found for "$trimmed"',
          searchField: state.searchField,
        );
        return;
      }

      final customer = customerList.first as Map<String, dynamic>;
      final custId = _str(customer['customer_id']);
      final custName = _str(customer['customer_name'] ?? customer['customerName']);
      final mobile = _str(customer['mobile_number'] ?? customer['mobileNumber']);
      final accNo = _str(customer['customer_number'] ?? customer['customerNumber']);
      final custDueDate = _str(customer['due_date'] ?? customer['dueDate']);
      final custDueAmount = _str(customer['pending_amount'] ?? customer['pendingAmount'] ?? '0.00');
      final custLcoName = _str(customer['lco_name'] ?? customer['lcoName']);

      if (custId.isEmpty) {
        state = QuickActionState(
          error: 'Invalid customer data returned',
          searchField: state.searchField,
        );
        return;
      }

      // ── Step 2: Get box details ──
      final boxData = await _stbDs.getCustomerBoxDetails(
        authtoken: _token,
        customerId: custId,
      );

      final boxList = (boxData['customerBoxList'] ?? boxData['data']) as List?;
      if (boxList == null || boxList.isEmpty) {
        // Customer exists but has no boxes (FRESH customer)
        state = QuickActionState(
          searchField: state.searchField,
          customerId: custId,
          customerName: custName,
          mobileNumber: mobile,
          accountNumber: accNo,
          dueDate: custDueDate,
          dueAmount: custDueAmount,
          lcoName: custLcoName,
          stbStatus: 'FRESH',
        );
        return;
      }

      final box = boxList.first as Map<String, dynamic>;
      final serial = _str(box['serial_number'] ?? box['serialNumber']);
      final vc = _str(box['vc_number'] ?? box['vcNumber']);
      final boxNo = _str(box['box_number'] ?? box['boxNumber']);
      final mac = _str(box['mac_address'] ?? box['macAddress']);
      final stockIdVal = _str(box['stock_id'] ?? box['stockId']);
      final deviceIdVal = _str(box['device_id'] ?? box['deviceId']);
      final backendSetupIdVal = _str(box['back_end_setup_id'] ?? box['backEndSetupId']);
      final statusRaw = _str(box['status'] ?? box['stb_status'] ?? box['stbStatus']);
      final casNameVal = _str(box['cas_name'] ?? box['casName']);
      final stbTypeVal = _str(box['stb_type'] ?? box['stbType']);
      final stbModelVal = _str(box['stb_model'] ?? box['stbModel']);
      final actDate = _str(box['activation_date'] ?? box['activationDate']);
      final isTempDeact = _int(box['is_temp_deactivated'] ?? box['isTempDeactivated']);

      // Determine display status
      String displayStatus;
      if (isTempDeact == 1) {
        displayStatus = 'TEMPORARY DE-ACTIVE';
      } else {
        displayStatus = statusRaw.toUpperCase();
        if (displayStatus.contains('DEACT') || displayStatus.contains('INACTIVE')) {
          displayStatus = 'DE-ACTIVE';
        } else if (displayStatus.contains('ACTIVE')) {
          displayStatus = 'ACTIVE';
        }
      }

      // ── Step 3: Get packages ──
      List<Map<String, dynamic>> activePkgs = [];
      List<Map<String, dynamic>> deactivatedPkgs = [];

      try {
        final pkgData = await _pkgDs.getCustomerPackages(
          authtoken: _token,
          customerId: custId,
          stbNo: serial.isNotEmpty ? serial : boxNo,
        );

        // Parse active packages
        final activeLists = [
          pkgData['assignedPackagesList'],
          pkgData['activePackages'],
          pkgData['assigned_packages'],
        ];
        for (final list in activeLists) {
          if (list is List && list.isNotEmpty) {
            activePkgs = list
                .map((e) => e is Map<String, dynamic> ? e : <String, dynamic>{})
                .where((m) => m.isNotEmpty)
                .toList();
            break;
          }
        }

        // Parse deactivated packages
        final deactLists = [
          pkgData['deactivatedPackagesList'],
          pkgData['deactivatedPackages'],
          pkgData['deactivated_packages'],
        ];
        for (final list in deactLists) {
          if (list is List && list.isNotEmpty) {
            deactivatedPkgs = list
                .map((e) => e is Map<String, dynamic> ? e : <String, dynamic>{})
                .where((m) => m.isNotEmpty)
                .toList();
            break;
          }
        }
      } catch (e) {
        debugPrint('[QUICK-ACTION] Package fetch error: $e');
        // Non-fatal — continue with empty packages
      }

      state = QuickActionState(
        searchField: state.searchField,
        customerId: custId,
        customerName: custName,
        mobileNumber: mobile,
        accountNumber: accNo,
        serialNumber: serial,
        vcNumber: vc,
        boxNumber: boxNo,
        macAddress: mac,
        stockId: stockIdVal,
        deviceId: deviceIdVal,
        backendSetupId: backendSetupIdVal,
        stbStatus: displayStatus,
        casName: casNameVal,
        stbType: stbTypeVal,
        stbModel: stbModelVal,
        activationDate: actDate,
        lcoName: custLcoName,
        dueDate: custDueDate,
        dueAmount: custDueAmount,
        isTempDeactivated: isTempDeact,
        activePackages: activePkgs,
        deactivatedPackages: deactivatedPkgs,
      );
    } catch (e) {
      debugPrint('[QUICK-ACTION] Search error: $e');
      state = QuickActionState(
        error: e.toString().replaceAll('ApiException: ', ''),
        searchField: state.searchField,
      );
    }
  }

  // -- Deactivate box ---------------------------------------------------------

  Future<bool> deactivate(String reasonId, String? remarks) async {
    if (state.customerId == null) return false;

    state = state.copyWith(isActioning: true, actionResult: null);
    try {
      final fullRemarks = remarks != null && remarks.isNotEmpty
          ? '$remarks. Box Deactivation from Flutter app'
          : 'Box Deactivation from Flutter app';

      final session = ref.read(appSessionProvider)!;
      final data = await _stbDs.deactivateBox(
        authtoken: _token,
        customerId: state.customerId!,
        reasonId: reasonId,
        serialNumber: state.serialNumber,
        vcNumber: state.vcNumber,
        boxNumber: state.boxNumber,
        macAddress: state.macAddress,
        stockId: state.stockId,
        deviceId: state.deviceId,
        backEndSetupId: state.backendSetupId,
        remarks: fullRemarks,
        dealerId: session.dealerId,
      );

      final code = (data['status_code'] ?? data['statusCode'])?.toString();
      if (code == '0') {
        final isTempDeact = _int(data['is_temp_deactivated'] ?? data['isTempDeactivated']);
        final msg = _str(data['status_msg'] ?? data['statusMsg'] ?? data['statusMessage']);
        state = state.copyWith(
          isActioning: false,
          actionResult: msg.isNotEmpty ? msg : 'STB deactivated successfully',
          actionSuccess: true,
          stbStatus: isTempDeact == 1 ? 'TEMPORARY DE-ACTIVE' : 'DE-ACTIVE',
          isTempDeactivated: isTempDeact,
        );
        return true;
      } else {
        final msg = _str(data['status_msg'] ?? data['statusMsg'] ?? data['statusMessage']);
        state = state.copyWith(
          isActioning: false,
          actionResult: '$msg. Please contact our support team.',
          actionSuccess: false,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isActioning: false,
        actionResult: e.toString().replaceAll('ApiException: ', ''),
        actionSuccess: false,
      );
      return false;
    }
  }

  // -- Activate (reactivate) --------------------------------------------------

  Future<bool> activate() async {
    state = state.copyWith(isActioning: true, actionResult: null);
    try {
      final data = await _stbDs.reactivateBox(
        authtoken: _token,
        serialNumber: state.serialNumber,
        boxNumber: state.boxNumber,
        macAddress: state.macAddress,
        stockId: state.stockId,
        deviceId: state.deviceId,
        backEndSetupId: state.backendSetupId,
      );

      final code = (data['status_code'] ?? data['statusCode'])?.toString();
      if (code == '0') {
        final msg = _str(data['status_msg'] ?? data['statusMsg'] ?? data['statusMessage']);
        state = state.copyWith(
          isActioning: false,
          actionResult: msg.isNotEmpty ? msg : 'STB reactivated successfully',
          actionSuccess: true,
          stbStatus: 'ACTIVE',
          isTempDeactivated: 0,
        );
        return true;
      } else {
        final msg = _str(data['status_msg'] ?? data['statusMsg'] ?? data['statusMessage']);
        state = state.copyWith(
          isActioning: false,
          actionResult: '$msg. Please contact our support team.',
          actionSuccess: false,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isActioning: false,
        actionResult: e.toString().replaceAll('ApiException: ', ''),
        actionSuccess: false,
      );
      return false;
    }
  }

  // -- Temporary Activate -----------------------------------------------------

  Future<bool> temporaryActivate() async {
    if (state.customerId == null || state.stockId == null) return false;

    state = state.copyWith(isActioning: true, actionResult: null);
    try {
      final data = await _stbDs.temporaryActivation(
        authtoken: _token,
        customerId: state.customerId!,
        stockId: state.stockId!,
      );

      final code = (data['status_code'] ?? data['statusCode'])?.toString();
      if (code == '0') {
        final msg = _str(data['status_msg'] ?? data['statusMsg'] ?? data['statusMessage']);
        state = state.copyWith(
          isActioning: false,
          actionResult: msg.isNotEmpty ? msg : 'STB activated successfully',
          actionSuccess: true,
          stbStatus: 'ACTIVE',
          isTempDeactivated: 0,
        );
        return true;
      } else {
        final msg = _str(data['status_msg'] ?? data['statusMsg'] ?? data['statusMessage']);
        state = state.copyWith(
          isActioning: false,
          actionResult: msg.isNotEmpty ? msg : 'Activation aborted!',
          actionSuccess: false,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isActioning: false,
        actionResult: e.toString().replaceAll('ApiException: ', ''),
        actionSuccess: false,
      );
      return false;
    }
  }

  // -- Refresh (placeholder) --------------------------------------------------

  void refresh() {
    if (state.hasResult && state.serialNumber != null) {
      final query = state.serialNumber!;
      final savedField = state.searchField;
      state = QuickActionState(searchField: QuickSearchField.stbNo);
      search(query).then((_) {
        // Restore the original search field preference
        state = state.copyWith(searchField: savedField);
      });
    }
  }

  // -- Clear ------------------------------------------------------------------

  void clear() {
    state = QuickActionState(searchField: state.searchField);
  }

  /// Clear just the action result message.
  void clearActionResult() {
    state = state.copyWith(actionResult: null);
  }
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

final quickActionProvider =
    NotifierProvider<QuickActionNotifier, QuickActionState>(
  QuickActionNotifier.new,
);
