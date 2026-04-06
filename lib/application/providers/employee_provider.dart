import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/remote/employee_remote_datasource.dart';
import 'core_providers.dart';

final employeeRemoteDatasourceProvider =
    Provider<EmployeeRemoteDatasource>((ref) {
  return EmployeeRemoteDatasource(dio: ref.watch(dioClientProvider));
});

class EmployeeState {
  final bool isLoading;
  final bool isLoadingTrack;
  final String? errorMessage;
  final List<Map<String, dynamic>> employees;
  final List<Map<String, dynamic>> serviceEmployees;
  final List<Map<String, dynamic>> trackPoints;

  const EmployeeState({
    this.isLoading = false,
    this.isLoadingTrack = false,
    this.errorMessage,
    this.employees = const [],
    this.serviceEmployees = const [],
    this.trackPoints = const [],
  });

  EmployeeState copyWith({
    bool? isLoading,
    bool? isLoadingTrack,
    String? errorMessage,
    List<Map<String, dynamic>>? employees,
    List<Map<String, dynamic>>? serviceEmployees,
    List<Map<String, dynamic>>? trackPoints,
    bool clearError = false,
  }) {
    return EmployeeState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingTrack: isLoadingTrack ?? this.isLoadingTrack,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      employees: employees ?? this.employees,
      serviceEmployees: serviceEmployees ?? this.serviceEmployees,
      trackPoints: trackPoints ?? this.trackPoints,
    );
  }
}

class EmployeeNotifier extends Notifier<EmployeeState> {
  late EmployeeRemoteDatasource _remoteDs;

  @override
  EmployeeState build() {
    _remoteDs = ref.watch(employeeRemoteDatasourceProvider);
    return const EmployeeState();
  }

  /// Load LCO employees for the given dealer.
  Future<void> loadEmployees({required int dealerId}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final data = await _remoteDs.getLcoEmployeeList(dealerId: dealerId);
      final list =
          (data['data'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      state = state.copyWith(isLoading: false, employees: list);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  /// Load service employees for the given dealer.
  Future<void> loadServiceEmployees({required int dealerId}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final data =
          await _remoteDs.getServiceEmployeeList(dealerId: dealerId);
      final list =
          (data['data'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      state = state.copyWith(isLoading: false, serviceEmployees: list);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  /// Load employee track (GPS) data for the map.
  ///
  /// The API response is expected to contain a `data` list where each item
  /// has at minimum `latitude`, `longitude`, and optionally `timestamp` and
  /// `address` fields.
  Future<void> loadEmployeeTrack({required String employeeId}) async {
    state = state.copyWith(isLoadingTrack: true, trackPoints: [], clearError: true);
    try {
      final data =
          await _remoteDs.getEmployeeTrackInfo(employeeId: employeeId);
      final list =
          (data['data'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      state = state.copyWith(isLoadingTrack: false, trackPoints: list);
    } catch (e) {
      state = state.copyWith(
        isLoadingTrack: false,
        errorMessage: 'Failed to load track: $e',
      );
    }
  }
}

final employeeProvider =
    NotifierProvider<EmployeeNotifier, EmployeeState>(EmployeeNotifier.new);
