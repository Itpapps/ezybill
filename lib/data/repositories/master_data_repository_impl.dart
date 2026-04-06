import 'package:ezybill/core/network/api_exception.dart';
import 'package:ezybill/core/network/dio_client.dart';
import 'package:ezybill/core/utils/result.dart';
import 'package:ezybill/data/datasources/remote/master_data_remote_datasource.dart';
import 'package:ezybill/data/models/customer/form_validation.dart';
import 'package:ezybill/data/models/master_data/city.dart';
import 'package:ezybill/data/models/master_data/country.dart';
import 'package:ezybill/data/models/master_data/customer_type.dart';
import 'package:ezybill/data/models/master_data/district.dart';
import 'package:ezybill/data/models/master_data/group_model.dart';
import 'package:ezybill/data/models/master_data/id_type.dart';
import 'package:ezybill/data/models/master_data/mandal.dart';
import 'package:ezybill/data/models/master_data/state_model.dart';
import 'package:ezybill/domain/repositories/master_data_repository.dart';

class MasterDataRepositoryImpl implements MasterDataRepository {
  final MasterDataRemoteDatasource _remoteDatasource;
  final DioClient _dio;

  MasterDataRepositoryImpl(this._remoteDatasource, this._dio);

  String get _authtoken => _dio.authToken ?? '';

  /// Extract list from response map. Tries common keys used by the server.
  List<Map<String, dynamic>> _extractList(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final value = data[key];
      if (value is List) {
        return value.cast<Map<String, dynamic>>();
      }
    }
    // Fallback: if data itself looks like it wraps a single list
    return [];
  }

  @override
  Future<Result<List<Country>>> getCountries() async {
    try {
      final data = await _remoteDatasource.getCountries(authtoken: _authtoken);
      final list = _extractList(data, ['countries', 'countryList', 'data']);
      final countries = list.map((e) => Country.fromJson(e)).toList();
      return Success(countries);
    } on ApiException catch (e) {
      return Failure(e.message, statusCode: e.statusCode);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  @override
  Future<Result<List<StateModel>>> getStates({
    required String countryCode,
  }) async {
    try {
      final data = await _remoteDatasource.getStates(
        authtoken: _authtoken,
        countryCode: countryCode,
      );
      final list = _extractList(data, ['states', 'stateList', 'data']);
      final states = list.map((e) => StateModel.fromJson(e)).toList();
      return Success(states);
    } on ApiException catch (e) {
      return Failure(e.message, statusCode: e.statusCode);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  @override
  Future<Result<List<District>>> getDistricts({
    required String stateId,
  }) async {
    try {
      final data = await _remoteDatasource.getDistricts(authtoken: _authtoken, stateId: stateId);
      final list = _extractList(data, ['districts', 'districtList', 'data']);
      final districts = list.map((e) => District.fromJson(e)).toList();
      return Success(districts);
    } on ApiException catch (e) {
      return Failure(e.message, statusCode: e.statusCode);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  @override
  Future<Result<List<City>>> getCities({
    required String stateId,
    required String districtId,
  }) async {
    try {
      final data = await _remoteDatasource.getCities(
        authtoken: _authtoken,
        stateId: stateId,
        districtId: districtId,
      );
      final list = _extractList(data, ['cities', 'cityList', 'locations', 'data']);
      final cities = list.map((e) => City.fromJson(e)).toList();
      return Success(cities);
    } on ApiException catch (e) {
      return Failure(e.message, statusCode: e.statusCode);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  @override
  Future<Result<List<Mandal>>> getMandals({
    required String districtId,
  }) async {
    try {
      final data = await _remoteDatasource.getMandals(
        authtoken: _authtoken,
        districtId: districtId,
      );
      final list = _extractList(data, ['mandals', 'mandalList', 'data']);
      final mandals = list.map((e) => Mandal.fromJson(e)).toList();
      return Success(mandals);
    } on ApiException catch (e) {
      return Failure(e.message, statusCode: e.statusCode);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  @override
  Future<Result<List<City>>> getLocationsOfDistrict({
    required String districtId,
  }) async {
    try {
      final data = await _remoteDatasource.getLocationsOfDistrict(
        authtoken: _authtoken,
        districtId: districtId,
      );
      final list = _extractList(data, ['locations', 'locationList', 'cities', 'data']);
      final locations = list.map((e) => City.fromJson(e)).toList();
      return Success(locations);
    } on ApiException catch (e) {
      return Failure(e.message, statusCode: e.statusCode);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  @override
  Future<Result<List<GroupModel>>> getGroups() async {
    try {
      final data = await _remoteDatasource.getGroups(authtoken: _authtoken);
      final list = _extractList(data, ['groups', 'groupList', 'data']);
      final groups = list.map((e) => GroupModel.fromJson(e)).toList();
      return Success(groups);
    } on ApiException catch (e) {
      return Failure(e.message, statusCode: e.statusCode);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  @override
  Future<Result<List<CustomerType>>> getCustomerTypes() async {
    try {
      final data = await _remoteDatasource.getCustomerTypes(authtoken: _authtoken);
      final list = _extractList(data, ['customerTypes', 'customerTypeList', 'data']);
      final types = list.map((e) => CustomerType.fromJson(e)).toList();
      return Success(types);
    } on ApiException catch (e) {
      return Failure(e.message, statusCode: e.statusCode);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  @override
  Future<Result<List<Map<String, dynamic>>>> getCustomerTypeTypes({
    required String customerTypeId,
  }) async {
    try {
      final data = await _remoteDatasource.getCustomerTypeTypes(
        authtoken: _authtoken,
        customerTypeId: customerTypeId,
      );
      final list = _extractList(data, ['customerTypeTypes', 'data']);
      return Success(list);
    } on ApiException catch (e) {
      return Failure(e.message, statusCode: e.statusCode);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  @override
  Future<Result<List<IdType>>> getIdTypes() async {
    try {
      final data = await _remoteDatasource.getIdTypes(authtoken: _authtoken);
      final list = _extractList(data, ['idTypes', 'idTypeList', 'data']);
      final types = list.map((e) => IdType.fromJson(e)).toList();
      return Success(types);
    } on ApiException catch (e) {
      return Failure(e.message, statusCode: e.statusCode);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  @override
  Future<Result<List<FormValidation>>> getDynamicFormValidations() async {
    try {
      final data = await _remoteDatasource.getDynamicFormValidations(
        authtoken: _authtoken,
        tableName: 'customer',
        dealerId: 0,
      );
      final list = data['dynamicFormValidations'];
      if (list is List) {
        final validations = list
            .cast<Map<String, dynamic>>()
            .map((e) => FormValidation.fromJson(e))
            .toList();
        return Success(validations);
      }
      return const Success([]);
    } on ApiException catch (e) {
      return Failure(e.message, statusCode: e.statusCode);
    } catch (e) {
      return Failure(e.toString());
    }
  }
}
