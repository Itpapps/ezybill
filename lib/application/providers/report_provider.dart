import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/remote/report_remote_datasource.dart';
import '../../data/models/report/emp_collection_detail.dart';
import '../../data/models/report/emp_collection_summary.dart';
import '../../data/models/report/mini_day_report_row.dart';
import '../../data/repositories/report_repository_impl.dart';
import '../../domain/repositories/report_repository.dart';
import 'core_providers.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Infrastructure providers
// ─────────────────────────────────────────────────────────────────────────────

final reportRemoteDatasourceProvider = Provider<ReportRemoteDatasource>((ref) {
  return ReportRemoteDatasource(dio: ref.watch(dioClientProvider));
});

final reportRepositoryProvider = Provider<ReportRepository>((ref) {
  return ReportRepositoryImpl(ref.watch(reportRemoteDatasourceProvider));
});

// ─────────────────────────────────────────────────────────────────────────────
// State
// ─────────────────────────────────────────────────────────────────────────────

class ReportState {
  // Mini Day Report
  final bool isDailyLoading;
  final String? dailyError;
  final List<MiniDayReportRow> miniDayReport;

  // Employee Collection Summary
  final bool isCollectionLoading;
  final String? collectionError;
  final List<EmpCollectionSummary> empCollectionSummary;

  // Employee Collection Details
  final bool isDetailLoading;
  final String? detailError;
  final List<EmpCollectionDetail> empCollectionDetails;

  const ReportState({
    this.isDailyLoading = false,
    this.dailyError,
    this.miniDayReport = const [],
    this.isCollectionLoading = false,
    this.collectionError,
    this.empCollectionSummary = const [],
    this.isDetailLoading = false,
    this.detailError,
    this.empCollectionDetails = const [],
  });

  ReportState copyWith({
    bool? isDailyLoading,
    String? dailyError,
    List<MiniDayReportRow>? miniDayReport,
    bool? isCollectionLoading,
    String? collectionError,
    List<EmpCollectionSummary>? empCollectionSummary,
    bool? isDetailLoading,
    String? detailError,
    List<EmpCollectionDetail>? empCollectionDetails,
  }) {
    return ReportState(
      isDailyLoading: isDailyLoading ?? this.isDailyLoading,
      dailyError: dailyError,
      miniDayReport: miniDayReport ?? this.miniDayReport,
      isCollectionLoading: isCollectionLoading ?? this.isCollectionLoading,
      collectionError: collectionError,
      empCollectionSummary: empCollectionSummary ?? this.empCollectionSummary,
      isDetailLoading: isDetailLoading ?? this.isDetailLoading,
      detailError: detailError,
      empCollectionDetails: empCollectionDetails ?? this.empCollectionDetails,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Notifier
// ─────────────────────────────────────────────────────────────────────────────

class ReportNotifier extends Notifier<ReportState> {
  late ReportRepository _repo;

  @override
  ReportState build() {
    _repo = ref.watch(reportRepositoryProvider);
    return const ReportState();
  }

  /// Loads the Mini Day Report for the given [date] (yyyy-MM-dd).
  Future<void> loadDailyReport(String date, {required int dealerId}) async {
    state = state.copyWith(isDailyLoading: true, dailyError: null);
    try {
      final result = await _repo.getDailyReport(
        reportDate: date,
        dealerId: dealerId,
      );
      result.when(
        success: (data) {
          final rawList =
              (data['Dailyreport_details'] as List<dynamic>?) ?? [];
          final rows = rawList
              .map((e) =>
                  MiniDayReportRow.fromJson(e as Map<String, dynamic>))
              .toList();
          state = state.copyWith(isDailyLoading: false, miniDayReport: rows);
        },
        failure: (message, _) {
          state = state.copyWith(isDailyLoading: false, dailyError: message);
        },
      );
    } catch (e) {
      state = state.copyWith(isDailyLoading: false, dailyError: e.toString());
    }
  }

  /// Loads the Employee Collection Summary for the date range.
  /// Param names: fromDate / toDate (camelCase).
  Future<void> loadEmpCollection(
    String fromDate,
    String toDate, {
    required int dealerId,
  }) async {
    state = state.copyWith(isCollectionLoading: true, collectionError: null);
    try {
      final result = await _repo.getEmpCollection(
        fromDate: fromDate,
        toDate: toDate,
        dealerId: dealerId,
      );
      result.when(
        success: (data) {
          final rawList =
              (data['collectionList'] as List<dynamic>?) ?? (data['collResultList'] as List<dynamic>?) ?? [];
          final summaries = rawList
              .map((e) =>
                  EmpCollectionSummary.fromJson(e as Map<String, dynamic>))
              .toList();
          state = state.copyWith(
            isCollectionLoading: false,
            empCollectionSummary: summaries,
          );
        },
        failure: (message, _) {
          state = state.copyWith(
            isCollectionLoading: false,
            collectionError: message,
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        isCollectionLoading: false,
        collectionError: e.toString(),
      );
    }
  }

  /// Loads Employee Collection Details for the date range.
  /// NOTE: employee_id is NOT sent — the server returns all customer
  /// collections for the dealer/date range.
  Future<void> loadEmpCollectionDetails(
    String fromDate,
    String toDate, {
    required int dealerId,
  }) async {
    state = state.copyWith(isDetailLoading: true, detailError: null);
    try {
      final result = await _repo.getEmpCustomerCollection(
        employeeId: '', // not sent per server contract
        fromDate: fromDate,
        toDate: toDate,
        dealerId: dealerId,
      );
      result.when(
        success: (data) {
          final rawList =
              (data['collectionList'] as List<dynamic>?) ?? (data['collResultList'] as List<dynamic>?) ?? [];
          final details = rawList
              .map((e) =>
                  EmpCollectionDetail.fromJson(e as Map<String, dynamic>))
              .toList();
          state = state.copyWith(
            isDetailLoading: false,
            empCollectionDetails: details,
          );
        },
        failure: (message, _) {
          state = state.copyWith(
            isDetailLoading: false,
            detailError: message,
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        isDetailLoading: false,
        detailError: e.toString(),
      );
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────────────────────────────────────

final reportProvider =
    NotifierProvider<ReportNotifier, ReportState>(ReportNotifier.new);
