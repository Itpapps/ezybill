import 'package:ezybill/core/network/api_exception.dart';
import 'package:ezybill/core/network/dio_client.dart';
import 'package:ezybill/core/utils/result.dart';
import 'package:ezybill/data/datasources/remote/stb_remote_datasource.dart';
import 'package:ezybill/domain/repositories/stb_repository.dart';

class StbRepositoryImpl implements StbRepository {
  final StbRemoteDatasource _remoteDatasource;
  final DioClient _dio;

  StbRepositoryImpl(this._remoteDatasource, this._dio);

  String get _authtoken => _dio.authToken ?? '';

  @override
  Future<Result<Map<String, dynamic>>> getCustomerBoxDetails({
    required String customerId,
  }) async {
    try {
      final data = await _remoteDatasource.getCustomerBoxDetails(
        authtoken: _authtoken,
        customerId: customerId,
      );
      return Success(data);
    } on ApiException catch (e) {
      return Failure(e.message, statusCode: e.statusCode);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> getParticularBoxDetails({
    required String customerId,
    required String stockId,
  }) async {
    try {
      final data = await _remoteDatasource.getParticularBoxDetails(
        authtoken: _authtoken,
        customerId: customerId,
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
  Future<Result<Map<String, dynamic>>> deactivateBox({
    required String customerId,
    required String reasonId,
    String? serialNumber,
    String? vcNumber,
    String? boxNumber,
    String? macAddress,
    String? stockId,
    String? deviceId,
    String? backEndSetupId,
    String? remarks,
    int? dealerId,
    int? resellerId,
  }) async {
    try {
      final data = await _remoteDatasource.deactivateBox(
        authtoken: _authtoken,
        customerId: customerId,
        reasonId: reasonId,
        serialNumber: serialNumber,
        vcNumber: vcNumber,
        boxNumber: boxNumber,
        macAddress: macAddress,
        stockId: stockId,
        deviceId: deviceId,
        backEndSetupId: backEndSetupId,
        remarks: remarks,
        dealerId: dealerId,
        resellerId: resellerId,
      );
      return Success(data);
    } on ApiException catch (e) {
      return Failure(e.message, statusCode: e.statusCode);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> reactivateBox({
    String? serialNumber,
    String? boxNumber,
    String? macAddress,
    String? stockId,
    String? deviceId,
    String? backEndSetupId,
  }) async {
    try {
      final data = await _remoteDatasource.reactivateBox(
        authtoken: _authtoken,
        serialNumber: serialNumber,
        boxNumber: boxNumber,
        macAddress: macAddress,
        stockId: stockId,
        deviceId: deviceId,
        backEndSetupId: backEndSetupId,
      );
      return Success(data);
    } on ApiException catch (e) {
      return Failure(e.message, statusCode: e.statusCode);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> getDeactivationReasons() async {
    try {
      final data = await _remoteDatasource.getDeactivationReasons(authtoken: _authtoken);
      return Success(data);
    } on ApiException catch (e) {
      return Failure(e.message, statusCode: e.statusCode);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> temporaryActivation({
    required String customerId,
    required String stockId,
  }) async {
    try {
      final data = await _remoteDatasource.temporaryActivation(
        authtoken: _authtoken,
        customerId: customerId,
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
  Future<Result<Map<String, dynamic>>> validateBoxInfo({
    required String boxNumber,
  }) async {
    try {
      final data = await _remoteDatasource.validateBoxInfo(
        authtoken: _authtoken,
        boxNumber: boxNumber,
      );
      return Success(data);
    } on ApiException catch (e) {
      return Failure(e.message, statusCode: e.statusCode);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> stbPair({
    required String customerId,
    required String stbNo,
    required String vcNo,
  }) async {
    try {
      final data = await _remoteDatasource.stbPair(
        authtoken: _authtoken,
        customerId: customerId,
        stbNo: stbNo,
        vcNo: vcNo,
      );
      return Success(data);
    } on ApiException catch (e) {
      return Failure(e.message, statusCode: e.statusCode);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> stbUnpair({
    required String customerId,
    required String stbNo,
  }) async {
    try {
      final data = await _remoteDatasource.stbUnpair(
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
  Future<Result<Map<String, dynamic>>> stbReplacement({
    required String customerId,
    required String oldStbNo,
    required String newStbNo,
    required String newVcNo,
  }) async {
    try {
      final data = await _remoteDatasource.stbReplacement(
        authtoken: _authtoken,
        customerId: customerId,
        oldStbNo: oldStbNo,
        newStbNo: newStbNo,
        newVcNo: newVcNo,
      );
      return Success(data);
    } on ApiException catch (e) {
      return Failure(e.message, statusCode: e.statusCode);
    } catch (e) {
      return Failure(e.toString());
    }
  }
}
