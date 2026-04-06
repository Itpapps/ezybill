import 'package:ezybill/core/utils/result.dart';
import 'package:ezybill/data/models/master_data/city.dart';
import 'package:ezybill/data/models/master_data/country.dart';
import 'package:ezybill/data/models/master_data/customer_type.dart';
import 'package:ezybill/data/models/master_data/district.dart';
import 'package:ezybill/data/models/master_data/group_model.dart';
import 'package:ezybill/data/models/master_data/id_type.dart';
import 'package:ezybill/data/models/master_data/mandal.dart';
import 'package:ezybill/data/models/master_data/state_model.dart';
import 'package:ezybill/data/models/customer/form_validation.dart';

/// Abstract interface for master/reference data operations.
abstract class MasterDataRepository {
  /// Get list of countries.
  Future<Result<List<Country>>> getCountries();

  /// Get states for a given country code.
  Future<Result<List<StateModel>>> getStates({required String countryCode});

  /// Get districts for a given state.
  Future<Result<List<District>>> getDistricts({required String stateId});

  /// Get cities for a given state and district.
  Future<Result<List<City>>> getCities({
    required String stateId,
    required String districtId,
  });

  /// Get mandals for a given district.
  Future<Result<List<Mandal>>> getMandals({required String districtId});

  /// Get locations for a given district.
  Future<Result<List<City>>> getLocationsOfDistrict({
    required String districtId,
  });

  /// Get groups.
  Future<Result<List<GroupModel>>> getGroups();

  /// Get customer types.
  Future<Result<List<CustomerType>>> getCustomerTypes();

  /// Get customer type sub-types for a given customer type.
  Future<Result<List<Map<String, dynamic>>>> getCustomerTypeTypes({
    required String customerTypeId,
  });

  /// Get ID proof types.
  Future<Result<List<IdType>>> getIdTypes();

  /// Get dynamic form validations.
  Future<Result<List<FormValidation>>> getDynamicFormValidations();
}
