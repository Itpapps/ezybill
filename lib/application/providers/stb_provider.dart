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
// STB replacement options
// ---------------------------------------------------------------------------

/// One replacement reason, as the server lists it for this user type.
class ReplacementType {
  final String id;
  final String name;
  const ReplacementType(this.id, this.name);

  /// Native switches the form on the reason NAME: a surrender needs no new
  /// box and offers "permanent surrender" (Box_Operations_Fragment.java:519-527).
  bool get isSurrender => name.trim().toUpperCase() == 'SURRENDER';
}

/// What the server allows for STB replacement, from
/// getCustomerParticularBoxDetailsRest (LcoRestServices.php:1846-1880):
/// `show_replacement` (dealer switch SHOW_REPLACEMENT_IN_LCO_MOBILE_APP),
/// `replacement_types` and `stb_replacement_form_validations`.
class ReplacementOptions {
  final bool enabled;
  final List<ReplacementType> types;
  final bool amountMandatory;
  final bool receiptMandatory;

  const ReplacementOptions({
    this.enabled = false,
    this.types = const [],
    this.amountMandatory = false,
    this.receiptMandatory = false,
  });
}

/// Parses the replacement fields the way native does
/// (Customer_STB_Select_Fragment.java:1172-1209): only a status-0 reply
/// counts, and duplicate reason ids are dropped
/// (Box_Operations_Fragment.java:190-199).
ReplacementOptions parseReplacementOptions(Map<String, dynamic> data) {
  int asInt(dynamic v) => int.tryParse(v?.toString().trim() ?? '') ?? 0;

  final code = data['status_code'] ?? data['statusCode'];
  if (code?.toString() != '0') return const ReplacementOptions();

  final seen = <String>{};
  final types = <ReplacementType>[];
  final raw = data['replacement_types'];
  if (raw is List) {
    for (final t in raw.whereType<Map>()) {
      final id = t['replacement_type_id']?.toString().trim() ?? '';
      final name = t['replacement_type']?.toString().trim() ?? '';
      if (id.isEmpty || !seen.add(id)) continue;
      types.add(ReplacementType(id, name));
    }
  }
  final v = data['stb_replacement_form_validations'];
  final validations = v is Map ? v : const {};
  return ReplacementOptions(
    enabled: asInt(data['show_replacement']) == 1,
    types: types,
    amountMandatory: asInt(validations['amount_mandatory']) == 1,
    receiptMandatory: asInt(validations['receipt_number_mandatory']) == 1,
  );
}

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

  /// Null until loaded; callers treat null as "replacement not enabled",
  /// like native's default show_replacement "0".
  final ReplacementOptions? replacementOptions;

  const StbState({
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
    this.stbList = const [],
    this.selectedStb,
    this.deactivationReasons = const [],
    this.isTempDeactivated = false,
    this.boxDetails,
    this.replacementOptions,
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
    ReplacementOptions? replacementOptions,
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
      replacementOptions: replacementOptions ?? this.replacementOptions,
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

  /// Loads the replacement switch, reasons and mandatory flags for a box,
  /// the same call native makes when a box is opened
  /// (Customer_STB_Select_Fragment.java:1138-1209).
  ///
  /// Deliberately silent — no spinner, no error banner — because the STB
  /// Operations screen calls it in the background. Returns null when the
  /// call fails; callers treat that as "not enabled".
  Future<ReplacementOptions?> loadReplacementOptions(
    String customerId,
    String stockId,
  ) async {
    try {
      final data = await _remoteDs.getParticularBoxDetails(
        authtoken: _token,
        customerId: customerId,
        stockId: stockId,
        userType: ref.read(appSessionProvider)?.userType,
      );
      final options = parseReplacementOptions(data);
      state = state.copyWith(
        replacementOptions: options,
        // copyWith clears both messages unless they are passed through.
        errorMessage: state.errorMessage,
        successMessage: state.successMessage,
      );
      return options;
    } catch (_) {
      return null;
    }
  }

  /// Sends a replacement exactly as native does (SurrenderBoxRest,
  /// Box_Operations_Fragment.java:2304-2390) and returns what native shows:
  /// `code` 0 = success, 1 = failure (message from
  /// `response_details.response_message`), >1 = server error (`status_msg`),
  /// -1 = no reply. Shared state is untouched so the STB Operations screen
  /// underneath does not react; the replacement screen shows the result.
  Future<({int code, String message})> replaceStb({
    required String customerId,
    required String serialNumber,
    required String replacementTypeId,
    required String amount,
    required String receiptNumber,
    required String remarks,
    required String replaceSerialNumber,
    required String replaceVcNumber,
    required bool permanentSurrender,
    required bool unpair,
  }) async {
    try {
      final data = await _remoteDs.stbReplacement(
        authtoken: _token,
        customerId: customerId,
        serialNumber: serialNumber,
        replacementTypeId: replacementTypeId,
        amount: amount,
        receiptNumber: receiptNumber,
        remarks: remarks,
        replaceSerialNumber: replaceSerialNumber,
        replaceVcNumber: replaceVcNumber,
        permanentSurrender: permanentSurrender,
        unpair: unpair,
      );
      final code = _statusCode(data);
      final details = data['response_details'];
      final display = details is Map
          ? details['response_message']?.toString()
          : null;
      final message = code > 1
          ? _serverMsg(data, fallback: display ?? '')
          : (display ?? _serverMsg(data));
      return (code: code, message: message);
    } catch (e) {
      return (
        code: -1,
        message: e.toString().replaceAll('ApiException: ', ''),
      );
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
