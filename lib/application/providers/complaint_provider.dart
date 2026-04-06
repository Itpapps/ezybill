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

  const ComplaintState({
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
    this.complaints = const [],
    this.categories = const [],
    this.subcategories = const [],
    this.closerTypes = const [],
    this.employees = const [],
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

  Future<void> loadComplaints({
    int serviceEmployeeId = 0,
    String loginUsersType = 'RESELLER',
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final result = await _repo.getComplaintList(
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

  Future<void> loadEmployees(int dealerId) async {
    try {
      final ds = ref.read(complaintRemoteDatasourceProvider);
      final data = await ds.getLcoEmployeeList(dealerId: dealerId);
      final list =
          (data['data'] as List?)?.cast<Map<String, dynamic>>() ??
          (data['lcoEmployeelist'] as List?)?.cast<Map<String, dynamic>>() ??
          [];
      state = state.copyWith(employees: list);
    } catch (_) {}
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

      final result = await _repo.closeComplaint(
        complaintId: complaintId,
        remarks: commentWithSuffix,
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
