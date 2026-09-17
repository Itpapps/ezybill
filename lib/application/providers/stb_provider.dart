import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/parse_utils.dart';
import '../../data/datasources/remote/stb_remote_datasource.dart';
import '../../data/models/stb/deactivation_reason.dart';
import '../../data/models/stb/stb_model.dart';
import 'core_providers.dart';

// ---------------------------------------------------------------------------
// Datasource provider
// ---------------------------------------------------------------------------

final stbRemoteDatasourceProvider = Provider<StbRemoteDatasource>((ref) {
  return StbRemoteDatasource(dio: ref.watch(dioClientProvider));
});

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

class StbState {
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;
  final List<StbModel> stbList;
  final StbModel? selectedStb;
  final List<DeactivationReason> deactivationReasons;
  final bool isTempDeactivated;
  final Map<String, dynamic>? boxDetails;

  const StbState({
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
    this.stbList = const [],
    this.selectedStb,
    this.deactivationReasons = const [],
    this.isTempDeactivated = false,
    this.boxDetails,
  });

  /// Filtered reasons: exclude reasonId == 17 ONLY.
  /// Per Android spec (active code), only ID 17 is excluded.
  /// The commented-out globalReason/disable_for_dpo filtering is NOT active.
  List<DeactivationReason> get filteredReasons =>
      deactivationReasons.where((r) => r.reasonId != 17).toList();

  StbState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
    List<StbModel>? stbList,
    StbModel? selectedStb,
    List<DeactivationReason>? deactivationReasons,
    bool? isTempDeactivated,
    Map<String, dynamic>? boxDetails,
  }) {
    return StbState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      successMessage: successMessage,
      stbList: stbList ?? this.stbList,
      selectedStb: selectedStb ?? this.selectedStb,
      deactivationReasons: deactivationReasons ?? this.deactivationReasons,
      isTempDeactivated: isTempDeactivated ?? this.isTempDeactivated,
      boxDetails: boxDetails ?? this.boxDetails,
    );
  }
}

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

class StbNotifier extends Notifier<StbState> {
  late StbRemoteDatasource _remoteDs;

  @override
  StbState build() {
    _remoteDs = ref.watch(stbRemoteDatasourceProvider);
    return const StbState();
  }

  // -- Helpers ----------------------------------------------------------------

  String get _token => ref.read(appSessionProvider)?.token ?? '';
  int get _dealerId => ref.read(appSessionProvider)?.dealerId ?? 0;

  bool _isSuccess(Map<String, dynamic> resp) {
    final code = resp['status_code'] ?? resp['statusCode'];
    return code?.toString() == '0';
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

  // -- Load boxes -------------------------------------------------------------

  Future<void> loadBoxes(String customerId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final data = await _remoteDs.getCustomerBoxDetails(
        authtoken: _token,
        customerId: customerId,
      );
      final boxes = parseList<StbModel>(
        data['customerBoxList'] ?? data['data'],
        StbModel.fromJson,
      );
      state = state.copyWith(isLoading: false, stbList: boxes);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  // -- Load box details (for replacement) ------------------------------------

  Future<void> loadBoxDetails(String customerId, String stockId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final data = await _remoteDs.getParticularBoxDetails(
        authtoken: _token,
        customerId: customerId,
        stockId: stockId,
      );
      final boxData = data['data'] as Map<String, dynamic>?;
      final stb = boxData != null ? StbModel.fromJson(boxData) : null;
      state = state.copyWith(
        isLoading: false,
        selectedStb: stb,
        boxDetails: boxData,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  // -- Deactivation reasons ---------------------------------------------------

  Future<void> loadDeactivationReasons() async {
    try {
      final data = await _remoteDs.getDeactivationReasons(authtoken: _token);
      final reasons = parseList<DeactivationReason>(
        data['reasonList'] ?? data['data'],
        DeactivationReason.fromJson,
      );
      state = state.copyWith(deactivationReasons: reasons);
    } catch (_) {}
  }

  // -- Deactivate box ---------------------------------------------------------
  //
  // Spec params: authtoken, customerId, serialNumber, vcNumber, boxNumber,
  //   macAddress, stockId, deviceId, backEndSetupId, reasonId, remarks (with
  //   suffix), from_mobileapp: 1, dealer_id, reseller_id.
  //
  // Remarks suffix: empty -> "Box Deactivation from Flutter app"
  //                  text  -> "{text}. Box Deactivation from Flutter app"
  //
  // Response: status_code == 0 -> success, parse is_temp_deactivated.
  //           status_code == 1 -> "{msg}. Please contact our support team."
  //           status_code >= 2 -> "{msg}. Please contact our support team."

  Future<bool> deactivateBox(
    String customerId,
    String reasonId, {
    String? remarks,
    String? serialNumber,
    String? vcNumber,
    String? boxNumber,
    String? macAddress,
    String? stockId,
    String? deviceId,
    String? backEndSetupId,
    int? resellerId,
  }) async {
    state = state.copyWith(
        isLoading: true, errorMessage: null, successMessage: null);
    try {
      // Append suffix to remarks per Android spec
      final fullRemarks = remarks != null && remarks.isNotEmpty
          ? '$remarks. Box Deactivation from Flutter app'
          : 'Box Deactivation from Flutter app';

      final data = await _remoteDs.deactivateBox(
        authtoken: _token,
        customerId: customerId,
        reasonId: reasonId,
        serialNumber: serialNumber,
        vcNumber: vcNumber,
        boxNumber: boxNumber,
        macAddress: macAddress,
        stockId: stockId,
        deviceId: deviceId,
        backEndSetupId: backEndSetupId,
        remarks: fullRemarks,
        dealerId: _dealerId,
        // Server marks resellerId isRequired; Android sends the customer's
        // reseller id from its box bundle (Box_Operations_Fragment:1021).
        resellerId: resellerId,
      );

      final code = _statusCode(data);
      if (code == 0) {
        // Track is_temp_deactivated from response
        final isTempDeact =
            data['is_temp_deactivated']?.toString() == '1' ||
                data['isTempDeactivated']?.toString() == '1';
        state = state.copyWith(
          isLoading: false,
          successMessage:
              _serverMsg(data, fallback: 'STB deactivated successfully'),
          isTempDeactivated: isTempDeact,
        );
        return true;
      } else {
        // status_code 1 or >= 2: append support message
        final msg =
            '${_serverMsg(data, fallback: 'Deactivation failed')}. Please contact our support team.';
        state = state.copyWith(isLoading: false, errorMessage: msg);
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  // -- Reactivate box ---------------------------------------------------------
  //
  // Spec params: authtoken, serialNumber, boxNumber, macAddress, stockId,
  //   deviceId, backEndSetupId, reinitialize: 1.
  // NOTE: vcNumber, customer_id, dealer_id, reseller_id NOT sent per spec.
  //
  // Response: status_code == 0 -> success
  //           status_code >= 1 -> "{msg}. Please contact our support team."

  Future<bool> reactivateBox({
    String? serialNumber,
    String? boxNumber,
    String? macAddress,
    String? stockId,
    String? deviceId,
    String? backEndSetupId,
  }) async {
    state = state.copyWith(
        isLoading: true, errorMessage: null, successMessage: null);
    try {
      final data = await _remoteDs.reactivateBox(
        authtoken: _token,
        serialNumber: serialNumber,
        boxNumber: boxNumber,
        macAddress: macAddress,
        stockId: stockId,
        deviceId: deviceId,
        backEndSetupId: backEndSetupId,
      );

      final code = _statusCode(data);
      if (code == 0) {
        state = state.copyWith(
          isLoading: false,
          successMessage:
              _serverMsg(data, fallback: 'STB reactivated successfully'),
          isTempDeactivated: false,
        );
        return true;
      } else {
        final msg =
            '${_serverMsg(data, fallback: 'Reactivation failed')}. Please contact our support team.';
        state = state.copyWith(isLoading: false, errorMessage: msg);
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  // -- Temporary Activation ---------------------------------------------------
  //
  // Spec: only customerId and stockId are meaningful params.
  // NO confirmation dialog -- fires immediately on tap.
  //
  // Response: status_code == 0 -> "STB activated successfully"
  //           status_code >= 1 -> "{msg}" titled "Activation aborted!"

  Future<bool> temporaryActivate(
      String customerId, String stockId) async {
    state = state.copyWith(
        isLoading: true, errorMessage: null, successMessage: null);
    try {
      final data = await _remoteDs.temporaryActivation(
        authtoken: _token,
        customerId: customerId,
        stockId: stockId,
      );

      final code = _statusCode(data);
      if (code == 0) {
        state = state.copyWith(
          isLoading: false,
          successMessage:
              _serverMsg(data, fallback: 'STB activated successfully'),
          isTempDeactivated: false,
        );
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage:
              _serverMsg(data, fallback: 'Activation aborted!'),
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  // -- Pair STB ---------------------------------------------------------------

  Future<bool> pairStb(
      String customerId, String serialNumber, String vcNumber) async {
    state = state.copyWith(
        isLoading: true, errorMessage: null, successMessage: null);
    try {
      final data = await _remoteDs.stbPair(
        authtoken: _token,
        customerId: customerId,
        stbNo: serialNumber,
        vcNo: vcNumber,
      );

      if (_isSuccess(data)) {
        state = state.copyWith(
          isLoading: false,
          successMessage: _serverMsg(data, fallback: 'STB paired successfully'),
        );
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: _serverMsg(data, fallback: 'Pairing failed'),
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  // -- Unpair STB -------------------------------------------------------------

  Future<bool> unpairStb(String customerId, String serialNumber) async {
    state = state.copyWith(
        isLoading: true, errorMessage: null, successMessage: null);
    try {
      final data = await _remoteDs.stbUnpair(
        authtoken: _token,
        customerId: customerId,
        stbNo: serialNumber,
      );

      if (_isSuccess(data)) {
        state = state.copyWith(
          isLoading: false,
          successMessage:
              _serverMsg(data, fallback: 'STB unpaired successfully'),
        );
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: _serverMsg(data, fallback: 'Unpairing failed'),
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  // -- STB Replacement --------------------------------------------------------

  Future<bool> replaceStb(
    String customerId,
    String oldStbNo,
    String newStbNo,
    String newVcNo,
  ) async {
    state = state.copyWith(
        isLoading: true, errorMessage: null, successMessage: null);
    try {
      final data = await _remoteDs.stbReplacement(
        authtoken: _token,
        customerId: customerId,
        oldStbNo: oldStbNo,
        newStbNo: newStbNo,
        newVcNo: newVcNo,
      );

      if (_isSuccess(data)) {
        state = state.copyWith(
          isLoading: false,
          successMessage:
              _serverMsg(data, fallback: 'STB replaced successfully'),
        );
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: _serverMsg(data, fallback: 'Replacement failed'),
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  // -- Clear messages ---------------------------------------------------------

  void clearMessages() {
    state = state.copyWith(errorMessage: null, successMessage: null);
  }

  /// Alias kept for backward-compat with existing screen code.
  Future<void> loadCustomerBoxes(String customerId) => loadBoxes(customerId);
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

final stbProvider = NotifierProvider<StbNotifier, StbState>(StbNotifier.new);
