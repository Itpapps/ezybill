import '../../../core/constants/api_constants.dart';
import '../../../core/network/dio_client.dart';

class MasterDataRemoteDatasource {
  final DioClient _dio;

  MasterDataRemoteDatasource({required DioClient dio}) : _dio = dio;

  /// Generic helper to POST and return raw response map.
  /// Response parsing (list extraction, status checks) is the repository's job.
  Future<Map<String, dynamic>> _fetch(
    String path, {
    Map<String, dynamic>? data,
  }) async {
    final response = await _dio.post(path, data: data ?? {});
    return response.data as Map<String, dynamic>;
  }

  /// Get countries list
  Future<Map<String, dynamic>> getCountries({
    required String authtoken,
  }) async {
    return _fetch(ApiConstants.countries, data: {
      'authtoken': authtoken,
    });
  }

  /// Get states list
  Future<Map<String, dynamic>> getStates({
    required String authtoken,
    required String countryCode,
  }) async {
    return _fetch(ApiConstants.states, data: {
      'authtoken': authtoken,
      'countryCode': countryCode,
    });
  }

  /// Get districts list
  Future<Map<String, dynamic>> getDistricts({
    required String authtoken,
    required String stateId,
  }) async {
    return _fetch(ApiConstants.districts, data: {
      'authtoken': authtoken,
      'stateId': stateId,
    });
  }

  /// Get cities list
  Future<Map<String, dynamic>> getCities({
    required String authtoken,
    required String stateId,
    required String districtId,
    String boxNumber = '',
  }) async {
    return _fetch(ApiConstants.cities, data: {
      'authtoken': authtoken,
      'stateId': stateId,
      'districtId': districtId,
      'boxNumber': boxNumber,
    });
  }

  /// Get mandals list
  Future<Map<String, dynamic>> getMandals({
    required String authtoken,
    required String districtId,
    String boxNumber = '',
    String serialNumber = '',
  }) async {
    return _fetch(ApiConstants.mandals, data: {
      'authtoken': authtoken,
      'districtId': districtId,
      'boxNumber': boxNumber,
      'serialNumber': serialNumber,
    });
  }

  /// Get locations of district
  Future<Map<String, dynamic>> getLocationsOfDistrict({
    required String authtoken,
    required String districtId,
  }) async {
    return _fetch(ApiConstants.locationsOfDistrict, data: {
      'authtoken': authtoken,
      'districtId': districtId,
    });
  }

  /// Get groups list
  Future<Map<String, dynamic>> getGroups({
    required String authtoken,
    String serialNumber = '',
  }) async {
    return _fetch(ApiConstants.groups, data: {
      'authtoken': authtoken,
      'serialNumber': serialNumber,
    });
  }

  /// Get customer types list
  Future<Map<String, dynamic>> getCustomerTypes({
    required String authtoken,
  }) async {
    return _fetch(ApiConstants.customerTypes, data: {
      'authtoken': authtoken,
    });
  }

  /// Get customer type types list
  Future<Map<String, dynamic>> getCustomerTypeTypes({
    required String authtoken,
    required String customerTypeId,
  }) async {
    return _fetch(ApiConstants.customerTypeTypes, data: {
      'authtoken': authtoken,
      'customerTypeId': customerTypeId,
    });
  }

  /// Get ID types list
  Future<Map<String, dynamic>> getIdTypes({
    required String authtoken,
  }) async {
    return _fetch(ApiConstants.idTypes, data: {
      'authtoken': authtoken,
    });
  }

  /// Get dynamic form validations
  /// Requires table_name and dealerId per spec
  Future<Map<String, dynamic>> getDynamicFormValidations({
    required String authtoken,
    required String tableName,
    required int dealerId,
  }) async {
    return _fetch(ApiConstants.dynamicFormValidations, data: {
      'authtoken': authtoken,
      'table_name': tableName,
      'dealerId': dealerId,
    });
  }
}
