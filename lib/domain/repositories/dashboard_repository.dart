import 'package:ezybill/core/utils/result.dart';
import 'package:ezybill/data/models/dashboard/dashboard_response.dart';
import 'package:ezybill/data/models/dashboard/expiry_services_response.dart';
import 'package:ezybill/data/models/dashboard/wallet_response.dart';

/// Abstract interface for dashboard-related data operations.
abstract class DashboardRepository {
  /// Fetch dashboard summary statistics.
  Future<Result<DashboardResponse>> getDashboardDetails({
    String? useLcoDeposits,
    String? lcoBillType,
  });

  /// Get LCO deposit/wallet amount.
  Future<Result<WalletResponse>> getLcoDepositAmount();

  /// Get LCO wallet history with optional date range.
  Future<Result<Map<String, dynamic>>> getLcoWallet({
    required int dealerId,
    String? startDate,
    String? endDate,
  });

  /// Get expiry services count grouped by date.
  Future<Result<ExpiryServicesResponse>> getExpiryServicesDateWiseCount({
    required int dealerId,
  });

  /// Get dashboard customer/STB list filtered by type.
  /// [fromDashboard]: 1=assigned, 2=unassigned, 3=all, 4=active, 5=inactive.
  Future<Result<List<Map<String, dynamic>>>> getDashboardCustomerList({
    required int dealerId,
    required int fromDashboard,
  });
}
