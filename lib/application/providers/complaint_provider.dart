import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/result.dart';
import '../../core/utils/string_extensions.dart';
import '../../data/datasources/remote/complaint_remote_datasource.dart';
import '../../data/models/complaint/complaint_category.dart';
import '../../data/models/complaint/complaint_model.dart';
import '../../data/models/complaint/complaint_subcategory.dart';
import '../../data/repositories/complaint_repository_impl.dart';
import '../../domain/repositories/complaint_repository.dart';
import 'core_providers.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Datasource & Repository providers
// ─────────────────────────────────────────────────────────────────────────────

final complaintRemoteDatasourceProvider =
    Provider<ComplaintRemoteDatasource>((ref) {
  return ComplaintRemoteDatasource(dio: ref.watch(dioClientProvider));
});

final complaintRepositoryProvider = Provider<ComplaintRepository>((ref) {
  return ComplaintRepositoryImpl(ref.watch(complaintRemoteDatasourceProvider));
});

// ─────────────────────────────────────────────────────────────────────────────
// patch_information version gating helper
// ─────────────────────────────────────────────────────────────────────────────

/// The set of `patch_information` values that enable subcategory spinner and
/// employee assignment in the create-complaint flow.
const _gatedPatchVersions = {'1.4.13.2', '1.4.13.3', '1.4.13.4'};

/// Returns `true` when [patchInfo] matches one of the gated patch versions.
bool isPatchGated(String patchInfo) => _gatedPatchVersions.contains(patchInfo);

/// Returns `true` when the employee field should be visible.
/// Employee field is gated to patch "1.4.13.3" only.
bool isEmployeePatchGated(String patchInfo) => patchInfo == '1.4.13.3';

// ─────────────────────────────────────────────────────────────────────────────
// State
// ─────────────────────────────────────────────────────────────────────────────

class ComplaintState {
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;
  final List<ComplaintModel> complaints;
  final List<ComplaintCategory> categories;
  final List<ComplaintSubcategory> subcategories;
  final List<Map<String, dynamic>> closerTypes;
  final List<Map<String, dynamic>> employees;

  /// Service employees for the update screen (getServiceEmployeeList) —
  /// a different list from [employees], which create-complaint uses.
  final List<Map<String, dynamic>> serviceEmployees;

  const ComplaintState({
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
    this.complaints = const [],
    this.categories = const [],
    this.subcategories = const [],
    this.closerTypes = const [],
    this.employees = const [],
    this.serviceEmployees = const [],
  });

  ComplaintState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
    List<ComplaintModel>? complaints,
    List<ComplaintCategory>? categories,
    List<ComplaintSubcategory>? subcategories,
    List<Map<String, dynamic>>? closerTypes,
    List<Map<String, dynamic>>? employees,
    List<Map<String, dynamic>>? serviceEmployees,
  }) {
    return ComplaintState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      successMessage: successMessage,
      complaints: complaints ?? this.complaints,
      categories: categories ?? this.categories,
      subcategories: subcategories ?? this.subcategories,
      closerTypes: closerTypes ?? this.closerTypes,
      employees: employees ?? this.employees,
      serviceEmployees: serviceEmployees ?? this.serviceEmployees,
    );
  }

  /// Open complaints (anything not closed).
  List<ComplaintModel> get openComplaints =>
      complaints.where((c) => c.status.toUpperCase() != 'CLOSED').toList();

  /// All complaints.
  List<ComplaintModel> get allComplaints => complaints;
}

// ─────────────────────────────────────────────────────────────────────────────
// Notifier
// ─────────────────────────────────────────────────────────────────────────────

class ComplaintNotifier extends Notifier<ComplaintState> {
  late ComplaintRepository _repo;

  @override
  ComplaintState build() {
    _repo = ref.watch(complaintRepositoryProvider);
    return const ComplaintState();
  }

  // ── Load complaints ──────────────────────────────────────────────────────

  /// Customer whose complaints the list shows; null = all of the dealer's.
  String? _listCustomerId;
  String _listUsersType = 'RESELLER';

  /// Loads the complaints list. With a [customerId] it loads only that
  /// customer's complaints, like native's customer flow
  /// (Complaint_Operations_Fragment → getCustomerComplaintListRest);
  /// without one, the dealer-wide list. [reloadComplaints] repeats the same
  /// choice, so a refresh never swaps a customer's list for everyone's.
  Future<void> loadComplaints({
    int serviceEmployeeId = 0,
    String loginUsersType = 'RESELLER',
    String? customerId,
  }) async {
    final forCustomer =
        (customerId != null && customerId.trim().isNotEmpty) ? customerId : null;
    _listCustomerId = forCustomer;
    _listUsersType = loginUsersType;
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final result = forCustomer != null
          ? await _repo.getCustomerComplaintList(customerId: forCustomer)
          : await _repo.getComplaintList(
              serviceEmployeeId: serviceEmployeeId,
              loginUsersType: loginUsersType,
            );

      switch (result) {
        case Success(:final data):
          final list = _extractComplaintModels(data);
          state = state.copyWith(isLoading: false, complaints: list);
        case Failure(:final message):
          state = state.copyWith(isLoading: false, errorMessage: message);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('ApiException: ', ''),
      );
    }
  }

  /// Repeats the last [loadComplaints] (same customer or dealer-wide).
  Future<void> reloadComplaints() => loadComplaints(
        loginUsersType: _listUsersType,
        customerId: _listCustomerId,
      );

  // ── Load categories ──────────────────────────────────────────────────────

  Future<void> loadCategories() async {
    try {
      final result = await _repo.getComplaintCategories();
      switch (result) {
        case Success(:final data):
          state = state.copyWith(categories: data);
        case Failure():
          break;
      }
    } catch (_) {}
  }

  // ── Load subcategories ───────────────────────────────────────────────────

  Future<void> loadSubcategories(String categoryId) async {
    state = state.copyWith(subcategories: []);
    try {
      final result =
          await _repo.getComplaintSubCategories(categoryId: categoryId);
      switch (result) {
        case Success(:final data):
          state = state.copyWith(subcategories: data);
        case Failure():
          break;
      }
    } catch (_) {}
  }

  // ── Load closer types (complaint statuses) ───────────────────────────────

  Future<void> loadCloserTypes() async {
    try {
      final result = await _repo.getComplaintTypes();
      switch (result) {
        case Success(:final data):
          state = state.copyWith(closerTypes: data);
        case Failure():
          break;
      }
    } catch (_) {}
  }

  // ── Load employees ───────────────────────────────────────────────────────

  Future<void> loadEmployees(int dealerId, {int? resellerId}) async {
    try {
      final ds = ref.read(complaintRemoteDatasourceProvider);
      // Android passes the customer's reseller id as `employee_id` and the
      // server filters the list on it; pass it through when the caller has it.
      final data = await ds.getLcoEmployeeList(
        dealerId: dealerId,
        employeeId: resellerId,
      );
      final list =
          (data['data'] as List?)?.cast<Map<String, dynamic>>() ??
          (data['lcoEmployeelist'] as List?)?.cast<Map<String, dynamic>>() ??
          [];
      state = state.copyWith(employees: list);
    } catch (_) {}
  }

  /// Loads the service employees for the update screen, like native's
  /// GetServiceemployeelistRest (ComplaintHistory_Other_Fragment.java:1081-1170).
  Future<void> loadServiceEmployees(int dealerId) async {
    // copyWith clears both messages unless they are passed through.
    state = state.copyWith(
      serviceEmployees: const [],
      errorMessage: state.errorMessage,
      successMessage: state.successMessage,
    );
    try {
      final ds = ref.read(complaintRemoteDatasourceProvider);
      final data = await ds.getServiceEmployeeList(dealerId: dealerId);
      final raw = data['getServiceEmployeeList'];
      state = state.copyWith(
        serviceEmployees:
            raw is List ? raw.whereType<Map<String, dynamic>>().toList() : [],
        errorMessage: state.errorMessage,
        successMessage: state.successMessage,
      );
    } catch (_) {
      // Unknown, not "none": native keeps its -1 default in this case.
    }
  }

  // ── Create complaint ─────────────────────────────────────────────────────

  /// Creates a complaint, appending the Flutter suffix to description.
  /// [category] should be the subcategory ID if one was selected, else the
  /// parent category ID — the caller is responsible for this selection.
  /// [assignedTo] is the employee ID (0 or null means none).
  /// [error] defaults to "0" per the Android spec.
  /// Returns the ticket number on success, or null on failure.
  Future<String?> createComplaint({
    required String customerId,
    required String complaint,
    required int category,
    String? error,
    int? assignedTo,
  }) async {
    state = state.copyWith(
        isLoading: true, errorMessage: null, successMessage: null);
    try {
      // Append the standard Flutter creation suffix.
      final descriptionWithSuffix =
          complaint.appendComplaintSuffix(true);

      final result = await _repo.createComplaint(
        customerId: customerId,
        complaint: descriptionWithSuffix,
        category: category,
        error: error ?? '0',
        assignedTo: assignedTo,
      );

      switch (result) {
        case Success(:final data):
          final ticketNumber =
              data['tkt_number']?.toString() ??
              data['ticket_number']?.toString() ??
              data['ticketNumber']?.toString();
          final msg = data['status_msg']?.toString() ??
              'Complaint created successfully';
          state = state.copyWith(
            isLoading: false,
            successMessage: msg,
          );
          return ticketNumber;
        case Failure(:final message):
          state = state.copyWith(isLoading: false, errorMessage: message);
          return null;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('ApiException: ', ''),
      );
      return null;
    }
  }

  // ── Close / update complaint ─────────────────────────────────────────────

  /// Updates a complaint status, appending the status-change suffix to comment.
  ///
  /// Business rules from Android spec:
  /// - [comment] is mandatory and gets `.Complaint Status Change From Flutter app`
  ///   appended.
  /// - [status] comes from `complaintTypesRest` (ticket_closer_categories).
  /// - [assignedEmployeeId] is MANDATORY for TEAMLEAD, optional for others.
  /// - [closerTicketTypeId] and [closerReasonId] are sent when available.
  Future<bool> closeComplaint({
    required String complaintId,
    required String ticketNumber,
    required String comment,
    required String status,
    String? assignedEmployeeId,
    String? closerTicketTypeId,
    String? closerReasonId,
  }) async {
    state = state.copyWith(
        isLoading: true, errorMessage: null, successMessage: null);
    try {
      final commentWithSuffix =
          '$comment.Complaint Status Change From Flutter app';

      // Native sends the picked service employee, else -1. Its code means to
      // fall back to the logged-in employee when the dealer has no service
      // employees (ComplaintHistory_Other_Fragment.java:1169), but the line
      // before it throws (:1168, NullPointerException — seen in logcat), so
      // in practice it always sends -1 (updatecomp log: assignedemp=-1).
      // The own-id value is what the server rejects: Flutter's
      // assignedemp=98 came back "Complaint update failed.".
      final assignedEmp = assignedEmployeeId ?? '-1';

      final result = await _repo.closeComplaint(
        complaintId: complaintId,
        ticketNumber: ticketNumber,
        comment: commentWithSuffix,
        status: status,
        assignedEmp: assignedEmp,
        closerTicketTypeId: closerTicketTypeId,
        closerReasonId: closerReasonId,
      );

      switch (result) {
        case Success(:final data):
          state = state.copyWith(
            isLoading: false,
            successMessage:
                data['status_msg']?.toString() ?? 'Complaint updated',
          );
          return true;
        case Failure(:final message):
          state = state.copyWith(isLoading: false, errorMessage: message);
          return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('ApiException: ', ''),
      );
      return false;
    }
  }

  // ── Load complaint history for a customer ────────────────────────────────

  Future<List<ComplaintModel>> loadHistory(String customerId) async {
    try {
      final result =
          await _repo.getCustomerComplaintList(customerId: customerId);
      switch (result) {
        case Success(:final data):
          return _extractComplaintModels(data);
        case Failure():
          return [];
      }
    } catch (_) {
      return [];
    }
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  List<ComplaintModel> _extractComplaintModels(Map<String, dynamic> data) {
    for (final key in [
      'lcoComplaintlist',
      'complaintList',
      'customerComplaintList',
      'data',
    ]) {
      final list = data[key];
      if (list is List && list.isNotEmpty) {
        return list
            .cast<Map<String, dynamic>>()
            .map((e) => ComplaintModel.fromJson(e))
            // With no complaints the server still sends one blank placeholder
            // row (getCustomerComplaintListRest "No records found."); native
            // never shows it.
            .where((c) => c.complaintId.trim().isNotEmpty)
            .toList();
      }
    }
    return [];
  }

  void clearMessages() {
    state = state.copyWith(errorMessage: null, successMessage: null);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────────────────────────────────────

final complaintProvider =
    NotifierProvider<ComplaintNotifier, ComplaintState>(ComplaintNotifier.new);
