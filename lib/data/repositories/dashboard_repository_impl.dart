import 'package:ezybill/core/network/api_exception.dart';
import 'package:ezybill/core/network/dio_client.dart';
import 'package:ezybill/core/utils/result.dart';
import 'package:ezybill/data/datasources/remote/dashboard_remote_datasource.dart';
import 'package:ezybill/data/models/dashboard/dashboard_response.dart';
import 'package:ezybill/data/models/dashboard/expiry_services_response.dart';
import 'package:ezybill/data/models/dashboard/wallet_response.dart';
import 'package:ezybill/domain/repositories/dashboard_repository.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDatasource _remoteDatasource;
  final DioClient _dioClient;

  DashboardRepositoryImpl(this._remoteDatasource, this._dioClient);

  String get _authToken => _dioClient.authToken ?? '';

  @override
  Future<Result<DashboardResponse>> getDashboardDetails({
    String? useLcoDeposits,
    String? lcoBillType,
  }) async {
    try {
      final data = await _remoteDatasource.getDashboardDetails(
        authtoken: _authToken,
        useLcoDeposits: useLcoDeposits,
        lcoBillType: lcoBillType,
      );
      final response = DashboardResponse.fromJson(data);

      // status_code == 0 means success for this endpoint
      if (response.statusCode == 0) {
        return Success(response);
      }
      return Failure(response.statusMsg.isNotEmpty
          ? response.statusMsg
          : 'Failed to load dashboard');
    } on ApiException catch (e) {
      return Failure(e.message, statusCode: e.statusCode);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  @override
  Future<Result<WalletResponse>> getLcoDepositAmount({required int dealerId}) async {
    try {
      final data = await _remoteDatasource.getLcoDepositAmount(
        authtoken: _authToken,
        dealerId: dealerId,
      );
      final response = WalletResponse.fromJson(data);
      return Success(response);
    } on ApiException catch (e) {
      return Failure(e.message, statusCode: e.statusCode);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> getLcoWallet({
    required int dealerId,
    String? startDate,
    String? endDate,
  }) async {
    try {
      final data = await _remoteDatasource.getLcoWallet(
        authtoken: _authToken,
        dealerId: dealerId,
        startDate: startDate,
        endDate: endDate,
      );
      return Success(data);
    } on ApiException catch (e) {
      return Failure(e.message, statusCode: e.statusCode);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  @override
  Future<Result<ExpiryServicesResponse>> getExpiryServicesDateWiseCount({
    required int dealerId,
  }) async {
    try {
      final data = await _remoteDatasource.getExpiryServicesDateWiseCount(
        authtoken: _authToken,
        dealerId: dealerId,
      );
      final response = ExpiryServicesResponse.fromJson(data);
      return Success(response);
    } on ApiException catch (e) {
      return Failure(e.message, statusCode: e.statusCode);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  @override
  Future<Result<List<Map<String, dynamic>>>> getDashboardCustomerList({
    required int dealerId,
    required int fromDashboard,
  }) async {
    try {
      final data = await _remoteDatasource.getDashboardCustomerList(
        authtoken: _authToken,
        dealerId: dealerId,
        fromDashboard: fromDashboard,
      );
      // The datasource returns Map<String, dynamic>, extract the list
      final list = <Map<String, dynamic>>[];
      for (final key in [
        'dashboardCustomerList',
        'customerDetailsList',
        'data',
      ]) {
        final items = data[key];
        if (items is List && items.isNotEmpty) {
          list.addAll(items.cast<Map<String, dynamic>>());
          break;
        }
      }
      return Success(list);
    } on ApiException catch (e) {
      return Failure(e.message, statusCode: e.statusCode);
    } catch (e) {
      return Failure(e.toString());
    }
  }
}
