import '../../../core/constants/api_constants.dart';
import '../../../core/network/dio_client.dart';

class DashboardRemoteDatasource {
  final DioClient _dio;

  DashboardRemoteDatasource({required DioClient dio}) : _dio = dio;

  /// Dashboard Details - POST /LcoRestServices/dashBoardDetailsRest
  Future<Map<String, dynamic>> getDashboardDetails({
    required String authtoken,
    String? useLcoDeposits,
    String? lcoBillType,
  }) async {
    final response = await _dio.post(
      ApiConstants.dashboardDetails,
      data: {
        'authtoken': authtoken,
        if (useLcoDeposits != null) 'use_lco_deposits': useLcoDeposits,
        if (lcoBillType != null) 'lco_billtype': lcoBillType,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  /// LCO Deposit Amount
  Future<Map<String, dynamic>> getLcoDepositAmount({
    required String authtoken,
  }) async {
    final response = await _dio.post(
      ApiConstants.lcoDepositAmount,
      data: {
        'authtoken': authtoken,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  /// LCO Wallet
  Future<Map<String, dynamic>> getLcoWallet({
    required String authtoken,
    required int dealerId,
    String? startDate,
    String? endDate,
  }) async {
    final response = await _dio.post(
      ApiConstants.lcoWallet,
      data: {
        'authtoken': authtoken,
        'dealer_id': dealerId,
        if (startDate != null) 'start_date': startDate,
        if (endDate != null) 'end_date': endDate,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  /// Get expiry services count by date
  Future<Map<String, dynamic>> getExpiryServicesDateWiseCount({
    required String authtoken,
    required int dealerId,
  }) async {
    final response = await _dio.post(
      ApiConstants.expiryServicesCount,
      data: {
        'authtoken': authtoken,
        'dealer_id': dealerId,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  /// Dashboard List - returns customers/STBs filtered by type
  /// from_dashboard: 1=assigned, 2=unassigned, 3=all, 4=active, 5=inactive
  Future<Map<String, dynamic>> getDashboardCustomerList({
    required String authtoken,
    required int dealerId,
    required int fromDashboard,
  }) async {
    final response = await _dio.post(
      ApiConstants.dashboardList,
      data: {
        'authtoken': authtoken,
        'dealer_id': dealerId,
        'from_dashboard': fromDashboard,
      },
    );
    return response.data as Map<String, dynamic>;
  }
}
