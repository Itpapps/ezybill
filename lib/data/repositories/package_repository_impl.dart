import 'package:ezybill/core/network/api_exception.dart';
import 'package:ezybill/core/network/dio_client.dart';
import 'package:ezybill/core/utils/result.dart';
import 'package:ezybill/data/datasources/remote/package_remote_datasource.dart';
import 'package:ezybill/domain/repositories/package_repository.dart';

class PackageRepositoryImpl implements PackageRepository {
  final PackageRemoteDatasource _remoteDatasource;
  final DioClient _dio;

  PackageRepositoryImpl(this._remoteDatasource, this._dio);

  String get _authtoken => _dio.authToken ?? '';

  @override
  Future<Result<Map<String, dynamic>>> getCustomerPackages({
    required String customerId,
    required String stbNo,
  }) async {
    try {
      final data = await _remoteDatasource.getCustomerPackages(
        authtoken: _authtoken,
        customerId: customerId,
        stbNo: stbNo,
      );
      return Success(data);
    } on ApiException catch (e) {
      return Failure(e.message, statusCode: e.statusCode);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> getUnassignedPackages({
    required String customerId,
    required String stbNo,
  }) async {
    try {
      final data = await _remoteDatasource.getUnassignedPackages(
        authtoken: _authtoken,
        customerId: customerId,
        stbNo: stbNo,
      );
      return Success(data);
    } on ApiException catch (e) {
      return Failure(e.message, statusCode: e.statusCode);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> getBillDetails({
    required String customerId,
    required String serialNumber,
    required String packageId,
    required String dealerId,
    required String employeeId,
  }) async {
    try {
      final data = await _remoteDatasource.getBillDetails(
        authtoken: _authtoken,
        customerId: customerId,
        serialNumber: serialNumber,
        packageId: packageId,
        dealerId: dealerId,
        employeeId: employeeId,
      );
      return Success(data);
    } on ApiException catch (e) {
      return Failure(e.message, statusCode: e.statusCode);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> activateService({
    required String customerId,
    required String customerDeviceId,
    required String productId,
    required String stockId,
    required String quantity,
    required String dateType,
    required String pricingStructureType,
    required String validityDays,
    required String dealerId,
    required String resellerId,
    required String loginEmployeeId,
  }) async {
    try {
      final data = await _remoteDatasource.activateService(
        authtoken: _authtoken,
        customerId: customerId,
        customerDeviceId: customerDeviceId,
        productId: productId,
        stockId: stockId,
        quantity: quantity,
        dateType: dateType,
        pricingStructureType: pricingStructureType,
        validityDays: validityDays,
        dealerId: dealerId,
        resellerId: resellerId,
        loginEmployeeId: loginEmployeeId,
      );
      return Success(data);
    } on ApiException catch (e) {
      return Failure(e.message, statusCode: e.statusCode);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> deactivateService({
    required String customerId,
    required String serviceId,
    required String reasonId,
    required String remarks,
    required String dealerId,
    required String resellerId,
    required String loginEmployeeId,
    String? stockId,
  }) async {
    try {
      final data = await _remoteDatasource.deactivateService(
        authtoken: _authtoken,
        customerId: customerId,
        serviceId: serviceId,
        reasonId: reasonId,
        remarks: remarks,
        dealerId: dealerId,
        resellerId: resellerId,
        loginEmployeeId: loginEmployeeId,
        stockId: stockId,
      );
      return Success(data);
    } on ApiException catch (e) {
      return Failure(e.message, statusCode: e.statusCode);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> extendService({
    required String customerId,
    required String stbNo,
    required String packageId,
    required String months,
  }) async {
    try {
      final data = await _remoteDatasource.extendService(
        authtoken: _authtoken,
        customerId: customerId,
        stbNo: stbNo,
        packageId: packageId,
        months: months,
      );
      return Success(data);
    } on ApiException catch (e) {
      return Failure(e.message, statusCode: e.statusCode);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> getCasPackages() async {
    try {
      final data = await _remoteDatasource.getCasPackages(authtoken: _authtoken);
      return Success(data);
    } on ApiException catch (e) {
      return Failure(e.message, statusCode: e.statusCode);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> getChannelList({
    required String packageId,
  }) async {
    try {
      final data = await _remoteDatasource.getChannelList(
        authtoken: _authtoken,
        packageId: packageId,
      );
      return Success(data);
    } on ApiException catch (e) {
      return Failure(e.message, statusCode: e.statusCode);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> renewServices({
    required String customerId,
    required String dealerId,
    required String customerServiceIds,
    required String productIds,
  }) async {
    try {
      final data = await _remoteDatasource.renewServices(
        authtoken: _authtoken,
        customerId: customerId,
        dealerId: dealerId,
        customerServiceIds: customerServiceIds,
        productIds: productIds,
      );
      return Success(data);
    } on ApiException catch (e) {
      return Failure(e.message, statusCode: e.statusCode);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> getRenewServices({
    required String customerId,
    required String dealerId,
  }) async {
    try {
      final data = await _remoteDatasource.getRenewServices(
        authtoken: _authtoken,
        customerId: customerId,
        dealerId: dealerId,
      );
      return Success(data);
    } on ApiException catch (e) {
      return Failure(e.message, statusCode: e.statusCode);
    } catch (e) {
      return Failure(e.toString());
    }
  }
}
