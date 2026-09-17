import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/remote/master_data_remote_datasource.dart';
import '../../data/models/customer/form_validation.dart';
import '../../data/models/master_data/city.dart';
import '../../data/models/master_data/country.dart';
import '../../data/models/master_data/customer_type.dart';
import '../../data/models/master_data/district.dart';
import '../../data/models/master_data/gender.dart';
import '../../data/models/master_data/group_model.dart';
import '../../data/models/master_data/id_type.dart';
import '../../data/models/master_data/mandal.dart';
import '../../data/models/master_data/state_model.dart';
import 'core_providers.dart';

// ---------------------------------------------------------------------------
// Datasource provider
// ---------------------------------------------------------------------------

final masterDataRemoteDatasourceProvider =
    Provider<MasterDataRemoteDatasource>((ref) {
  return MasterDataRemoteDatasource(dio: ref.watch(dioClientProvider));
});

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

class MasterDataState {
  // Lists
  final List<Country> countries;
  final List<StateModel> states;
  final List<District> districts;
  final List<City> cities;
  final List<Mandal> mandals;
  final List<GroupModel> groups;
  final List<CustomerType> customerTypes;
  final List<IdType> idTypes;
  final List<Gender> genders;
  final List<FormValidation> formValidations;

  // Loading flags
  final bool isLoadingCountries;
  final bool isLoadingStates;
  final bool isLoadingDistricts;
  final bool isLoadingCities;
  final bool isLoadingMandals;
  final bool isLoadingGroups;
  final bool isLoadingCustomerTypes;
  final bool isLoadingIdTypes;
  final bool isLoadingFormValidations;

  // Selected values
  final Country? selectedCountry;
  final StateModel? selectedState;
  final District? selectedDistrict;
  final City? selectedCity;
  final Mandal? selectedMandal;
  final GroupModel? selectedGroup;
  final CustomerType? selectedCustomerType;
  final IdType? selectedIdType;
  final Gender? selectedGender;

  // Error
  final String? errorMessage;

  const MasterDataState({
    this.countries = const [],
    this.states = const [],
    this.districts = const [],
    this.cities = const [],
    this.mandals = const [],
    this.groups = const [],
    this.customerTypes = const [],
    this.idTypes = const [],
    this.genders = const [],
    this.formValidations = const [],
    this.isLoadingCountries = false,
    this.isLoadingStates = false,
    this.isLoadingDistricts = false,
    this.isLoadingCities = false,
    this.isLoadingMandals = false,
    this.isLoadingGroups = false,
    this.isLoadingCustomerTypes = false,
    this.isLoadingIdTypes = false,
    this.isLoadingFormValidations = false,
    this.selectedCountry,
    this.selectedState,
    this.selectedDistrict,
    this.selectedCity,
    this.selectedMandal,
    this.selectedGroup,
    this.selectedCustomerType,
    this.selectedIdType,
    this.selectedGender,
    this.errorMessage,
  });

  MasterDataState copyWith({
    List<Country>? countries,
    List<StateModel>? states,
    List<District>? districts,
    List<City>? cities,
    List<Mandal>? mandals,
    List<GroupModel>? groups,
    List<CustomerType>? customerTypes,
    List<IdType>? idTypes,
    List<Gender>? genders,
    List<FormValidation>? formValidations,
    bool? isLoadingCountries,
    bool? isLoadingStates,
    bool? isLoadingDistricts,
    bool? isLoadingCities,
    bool? isLoadingMandals,
    bool? isLoadingGroups,
    bool? isLoadingCustomerTypes,
    bool? isLoadingIdTypes,
    bool? isLoadingFormValidations,
    Country? selectedCountry,
    StateModel? selectedState,
    District? selectedDistrict,
    City? selectedCity,
    Mandal? selectedMandal,
    GroupModel? selectedGroup,
    CustomerType? selectedCustomerType,
    IdType? selectedIdType,
    Gender? selectedGender,
    String? errorMessage,
    bool clearSelectedCountry = false,
    bool clearSelectedState = false,
    bool clearSelectedDistrict = false,
    bool clearSelectedCity = false,
    bool clearSelectedMandal = false,
    bool clearSelectedGroup = false,
    bool clearSelectedCustomerType = false,
    bool clearSelectedIdType = false,
    bool clearSelectedGender = false,
    bool clearError = false,
  }) {
    return MasterDataState(
      countries: countries ?? this.countries,
      states: states ?? this.states,
      districts: districts ?? this.districts,
      cities: cities ?? this.cities,
      mandals: mandals ?? this.mandals,
      groups: groups ?? this.groups,
      customerTypes: customerTypes ?? this.customerTypes,
      idTypes: idTypes ?? this.idTypes,
      genders: genders ?? this.genders,
      formValidations: formValidations ?? this.formValidations,
      isLoadingCountries: isLoadingCountries ?? this.isLoadingCountries,
      isLoadingStates: isLoadingStates ?? this.isLoadingStates,
      isLoadingDistricts: isLoadingDistricts ?? this.isLoadingDistricts,
      isLoadingCities: isLoadingCities ?? this.isLoadingCities,
      isLoadingMandals: isLoadingMandals ?? this.isLoadingMandals,
      isLoadingGroups: isLoadingGroups ?? this.isLoadingGroups,
      isLoadingCustomerTypes:
          isLoadingCustomerTypes ?? this.isLoadingCustomerTypes,
      isLoadingIdTypes: isLoadingIdTypes ?? this.isLoadingIdTypes,
      isLoadingFormValidations:
          isLoadingFormValidations ?? this.isLoadingFormValidations,
      selectedCountry: clearSelectedCountry
          ? null
          : (selectedCountry ?? this.selectedCountry),
      selectedState:
          clearSelectedState ? null : (selectedState ?? this.selectedState),
      selectedDistrict: clearSelectedDistrict
          ? null
          : (selectedDistrict ?? this.selectedDistrict),
      selectedCity:
          clearSelectedCity ? null : (selectedCity ?? this.selectedCity),
      selectedMandal:
          clearSelectedMandal ? null : (selectedMandal ?? this.selectedMandal),
      selectedGroup:
          clearSelectedGroup ? null : (selectedGroup ?? this.selectedGroup),
      selectedCustomerType: clearSelectedCustomerType
          ? null
          : (selectedCustomerType ?? this.selectedCustomerType),
      selectedIdType:
          clearSelectedIdType ? null : (selectedIdType ?? this.selectedIdType),
      selectedGender:
          clearSelectedGender ? null : (selectedGender ?? this.selectedGender),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  /// Check whether a field is mandatory based on server-driven form validations.
  bool isFieldMandatory(String columnName) {
    final match = formValidations.where((v) => v.columnName == columnName);
    if (match.isEmpty) return false;
    return match.first.isMandatory == 'Y' || match.first.isMandatory == '1';
  }
}

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

class MasterDataNotifier extends Notifier<MasterDataState> {
  late MasterDataRemoteDatasource _remoteDs;

  // Caches to avoid re-fetching static data
  bool _countriesLoaded = false;
  bool _groupsLoaded = false;
  bool _customerTypesLoaded = false;
  bool _idTypesLoaded = false;

  @override
  MasterDataState build() {
    _remoteDs = ref.watch(masterDataRemoteDatasourceProvider);
    return const MasterDataState(
      genders: [
        Gender(id: 1, name: 'Male'),
        Gender(id: 2, name: 'Female'),
        Gender(id: 3, name: 'Other'),
      ],
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  String _token() {
    final session = ref.read(appSessionProvider);
    return session?.token ?? '';
  }

  int _dealerId() {
    final session = ref.read(appSessionProvider);
    return session?.dealerId ?? 0;
  }

  List<T> _parseList<T>(
    Map<String, dynamic> data,
    T Function(Map<String, dynamic>) fromJson,
    List<String> possibleKeys,
  ) {
    List<T> parseRawList(List raw) {
      final items = <T>[];
      for (final item in raw) {
        if (item is Map) {
          items.add(
            fromJson(
              item.map((k, v) => MapEntry(k.toString(), v)),
            ),
          );
        }
      }
      return items;
    }

    // Also handles PHP-style JSON object: {"0":{...},"1":{...}} from json_encode
    List<T> parseMapAsList(Map raw) {
      final values = raw.values.toList();
      return parseRawList(values);
    }

    for (final key in possibleKeys) {
      final raw = data[key];
      if (raw is List && raw.isNotEmpty) {
        final items = parseRawList(raw);
        if (items.isNotEmpty) return items;
      }
      // PHP json_encode of non-sequential array → JSON object, not array
      if (raw is Map && raw.isNotEmpty) {
        final items = parseMapAsList(raw);
        if (items.isNotEmpty) return items;
      }
    }

    for (final value in data.values) {
      if (value is Map<String, dynamic>) {
        final nested = _parseList(value, fromJson, possibleKeys);
        if (nested.isNotEmpty) return nested;
      } else if (value is Map) {
        final nested = _parseList(
          value.map((k, v) => MapEntry(k.toString(), v)),
          fromJson,
          possibleKeys,
        );
        if (nested.isNotEmpty) return nested;
      } else if (value is List && value.isNotEmpty) {
        final items = parseRawList(value);
        if (items.isNotEmpty) return items;
      }
    }
    return [];
  }

  // ── Countries ────────────────────────────────────────────────────────────

  Future<void> loadCountries() async {
    if (_countriesLoaded && state.countries.isNotEmpty) return;
    state = state.copyWith(isLoadingCountries: true, clearError: true);
    try {
      final data = await _remoteDs.getCountries(authtoken: _token());
      final list = _parseList(
        data,
        Country.fromJson,
        ['countriesList', 'countries', 'data'],
      );
      _countriesLoaded = true;
      state = state.copyWith(isLoadingCountries: false, countries: list);
    } catch (e) {
      state = state.copyWith(
        isLoadingCountries: false,
        errorMessage: e.toString(),
      );
    }
  }

  void selectCountry(Country? country) {
    state = state.copyWith(
      selectedCountry: country,
      // Clear downstream selections
      clearSelectedState: true,
      clearSelectedDistrict: true,
      clearSelectedCity: true,
      clearSelectedMandal: true,
      states: const [],
      districts: const [],
      cities: const [],
      mandals: const [],
    );
    if (country != null) {
      loadStates(country.iso);
    }
  }

  // ── States ───────────────────────────────────────────────────────────────

  Future<void> loadStates(String countryCode) async {
    state = state.copyWith(isLoadingStates: true, clearError: true);
    try {
      final data = await _remoteDs.getStates(
        authtoken: _token(),
        countryCode: countryCode,
      );
      final list = _parseList(
        data,
        StateModel.fromJson,
        ['statesList', 'states', 'data'],
      );
      state = state.copyWith(isLoadingStates: false, states: list);
    } catch (e) {
      state = state.copyWith(
        isLoadingStates: false,
        errorMessage: e.toString(),
      );
    }
  }

  void selectState(StateModel? st) {
    debugPrint('[PROVIDER-DBG] selectState: ${st?.name}, clearing districts/cities/mandals');
    state = state.copyWith(
      selectedState: st,
      clearSelectedDistrict: true,
      clearSelectedCity: true,
      clearSelectedMandal: true,
      districts: const [],
      cities: const [],
      mandals: const [],
    );
    debugPrint('[PROVIDER-DBG] selectState: state updated, starting loadDistricts');
    if (st != null) {
      loadDistricts(st.id.toString());
    }
  }

  // ── Districts ────────────────────────────────────────────────────────────

  Future<void> loadDistricts(String stateId) async {
    debugPrint('[PROVIDER-DBG] loadDistricts: starting for stateId=$stateId');
    state = state.copyWith(isLoadingDistricts: true, clearError: true);
    try {
      final data = await _remoteDs.getDistricts(
        authtoken: _token(),
        stateId: stateId,
      );
      final list = _parseList(
        data,
        District.fromJson,
        ['districtList', 'districtsList', 'districts', 'data'],
      );
      debugPrint('[PROVIDER-DBG] loadDistricts: SUCCESS, ${list.length} districts loaded');
      state = state.copyWith(isLoadingDistricts: false, districts: list);
      debugPrint('[PROVIDER-DBG] loadDistricts: state updated with districts');
    } catch (e) {
      debugPrint('[PROVIDER-DBG] loadDistricts: ERROR $e');
      state = state.copyWith(
        isLoadingDistricts: false,
        errorMessage: e.toString(),
      );
    }
  }

  void selectDistrict(District? district) {
    state = state.copyWith(
      selectedDistrict: district,
      clearSelectedCity: true,
      clearSelectedMandal: true,
      cities: const [],
      mandals: const [],
    );
    if (district != null) {
      final stateId = state.selectedState?.id.toString() ?? '';
      if (stateId.isNotEmpty) {
        loadCities(stateId, district.id.toString());
      }
      loadMandals(district.id.toString());
    }
  }

  // ── Cities ───────────────────────────────────────────────────────────────

  /// Loads LCO-mapped cities via getCitiesRest.
  /// These IDs come from eb_location_lco_mapping → eb_location_locations
  /// and are what the new_customer_validation workflow accepts.
  Future<void> loadCities(
    String stateId,
    String districtId, {
    String boxNumber = '',
  }) async {
    if (stateId.isEmpty || stateId == '0') {
      print('[CITIES] No state — clearing');
      state = state.copyWith(isLoadingCities: false, cities: const []);
      return;
    }
    state = state.copyWith(isLoadingCities: true, clearError: true);
    try {
      final effectiveBox = boxNumber.isNotEmpty ? boxNumber : 'NONE';
      print('[CITIES] getCitiesRest stateId=$stateId boxNumber=$effectiveBox');
      final data = await _remoteDs.getCities(
        authtoken: _token(),
        stateId: stateId,
        districtId: districtId,
        boxNumber: effectiveBox,
      );

      // Log raw response to debug ID mapping
      for (final key in ['citiesList', 'cities', 'data']) {
        if (data.containsKey(key) && data[key] is List && (data[key] as List).isNotEmpty) {
          final first = (data[key] as List).first;
          print('[CITIES-RAW] key=$key, first item keys: ${first is Map ? first.keys.toList() : "not a map"}');
          print('[CITIES-RAW] first item: $first');
          break;
        }
      }

      final cities = (data['status_code'] == 1 || data['status_code'] == '1')
          ? <City>[]
          : _parseList(data, City.fromJson, ['citiesList', 'cities', 'data'])
              .where((c) => c.locationId > 0)
              .toList();

      print('[CITIES-LOADED] ${cities.length} LCO cities: ${cities.map((c) => '${c.locationId}/${c.locationName}').join(', ')}');
      state = state.copyWith(isLoadingCities: false, cities: cities);
    } catch (e) {
      print('[CITIES-ERROR] $e');
      state = state.copyWith(isLoadingCities: false, errorMessage: e.toString());
    }
  }

  void selectCity(City? city) {
    state = state.copyWith(selectedCity: city);
  }

  // ── Mandals ──────────────────────────────────────────────────────────────

  Future<void> loadMandals(
    String districtId, {
    String stateId = '',
    String boxNumber = '',
    String serialNumber = '',
  }) async {
    state = state.copyWith(isLoadingMandals: true, clearError: true);
    try {
      final data = await _remoteDs.getMandals(
        authtoken: _token(),
        districtId: districtId,
        boxNumber: boxNumber,
        serialNumber: serialNumber,
      );
      var list = _parseList(
        data,
        Mandal.fromJson,
        ['mandalList', 'mandalsList', 'mandals', 'data', 'districtLocationsList'],
      );
      // Some deployments return mandals only as part of locations-of-district.
      if (list.isEmpty) {
        final locData = await _remoteDs.getLocationsOfDistrict(
          authtoken: _token(),
          districtId: districtId,
        );
        list = _parseList(
          locData,
          Mandal.fromJson,
          [
            'districtLocationsList',
            'districtlocationsList',
            'district_locations_list',
            'locationList',
            'locationsList',
            'mandalList',
            'mandalsList',
            'mandals',
            'data',
          ],
        );
        if (list.isEmpty) {
          final raw = (locData['districtLocationsList'] as List?) ??
              (locData['locationList'] as List?) ??
              (locData['data'] as List?) ??
              const [];
          final seen = <int>{};
          final derived = <Mandal>[];
          for (final item in raw) {
            if (item is! Map) continue;
            final normalized = item.map((k, v) => MapEntry(k.toString(), v));
            final idRaw =
                normalized['mandal_id'] ??
                normalized['mandalId'] ??
                normalized['mandalid'] ??
                normalized['location_id'] ??
                normalized['locationId'];
            final id = int.tryParse(idRaw?.toString() ?? '') ?? 0;
            if (id <= 0 || seen.contains(id)) continue;
            seen.add(id);
            derived.add(
              Mandal.fromJson({
                'district_id': districtId,
                'mandal_id': id,
                'mandal_name':
                    normalized['mandal_name'] ??
                    normalized['mandalName'] ??
                    normalized['mandal'] ??
                    normalized['location_name'] ??
                    normalized['locationName'] ??
                    normalized['name'] ??
                    '',
              }),
            );
          }
          if (derived.isNotEmpty) list = derived;
        }
      }
      // Some deployments expose locality-style mandals only through city/location data.
      if (list.isEmpty && stateId.trim().isNotEmpty) {
        final cityData = await _remoteDs.getCities(
          authtoken: _token(),
          stateId: stateId,
          districtId: districtId,
          boxNumber: boxNumber,
        );
        final cities = _parseList(
          cityData,
          City.fromJson,
          [
            'districtLocationsList',
            'districtlocationsList',
            'district_locations_list',
            'locationList',
            'locationsList',
            'citiesList',
            'cities',
            'data',
          ],
        );
        if (cities.isNotEmpty) {
          final seen = <int>{};
          list = cities
              .where((city) => city.locationId > 0 && city.locationName.trim().isNotEmpty)
              .where((city) => seen.add(city.locationId))
              .map(
                (city) => Mandal(
                  districtId: int.tryParse(districtId) ?? 0,
                  mandalId: city.locationId,
                  mandalName: city.locationName.trim(),
                ),
              )
              .toList();
        }
      }
      state = state.copyWith(isLoadingMandals: false, mandals: list);
    } catch (e) {
      state = state.copyWith(
        isLoadingMandals: false,
        errorMessage: e.toString(),
      );
    }
  }

  void selectMandal(Mandal? mandal) {
    state = state.copyWith(selectedMandal: mandal);
  }

  /// Loads cities filtered by mandal when one is selected.
  /// - No mandal  → loadCities (getCitiesRest = LCO-mapped cities)
  /// - Mandal set → getLocationsOfDistrictRest filtered by mandal_id (per Java app)
  Future<void> loadCitiesForMandal({
    required String districtId,
    required String mandalId,
    String boxNumber = '',
  }) async {
    final isMandalSelected = mandalId.isNotEmpty && mandalId != '0';
    if (!isMandalSelected) {
      final stateId = state.selectedState?.id.toString() ?? '';
      print('[CITIES-MANDAL] No mandal → loadCities (LCO-mapped cities)');
      await loadCities(stateId, districtId, boxNumber: boxNumber);
      return;
    }

    print('[CITIES-MANDAL] mandal=$mandalId → getLocationsOfDistrictRest filtered');
    state = state.copyWith(isLoadingCities: true, clearError: true);
    try {
      final data = await _remoteDs.getLocationsOfDistrict(
        authtoken: _token(),
        districtId: districtId,
      );

      // Extract raw list so we can filter by mandal_id before conversion.
      List<dynamic> rawItems = [];
      for (final key in ['districtLocationsList', 'locationsList', 'locationList', 'data']) {
        if (!data.containsKey(key)) continue;
        final v = data[key];
        if (v is List) { rawItems = v; break; }
        if (v is Map)  { rawItems = v.values.toList(); break; }
      }
      print('[CITIES-MANDAL] total district locations: ${rawItems.length}');

      // Filter by mandal_id — also include mandal_id=0 (unassigned cities, per Java app logic)
      final filtered = rawItems.where((item) {
        if (item is! Map) return false;
        final mid = (item['mandal_id'] ?? item['mandalId'] ?? item['mandalid'] ?? '').toString().trim();
        return mid == mandalId || mid == '0';
      }).toList();
      print('[CITIES-MANDAL] after mandal_id=$mandalId (incl. 0) filter: ${filtered.length}');

      City fromRaw(dynamic m) =>
          City.fromJson((m as Map).map((k, v) => MapEntry(k.toString(), v)));

      var cities = filtered.map(fromRaw).where((c) => c.locationId > 0).toList();
      if (cities.isEmpty) {
        print('[CITIES-MANDAL] ⚠️ mandal filter empty — showing all district cities');
        cities = rawItems.map(fromRaw).where((c) => c.locationId > 0).toList();
      }

      print('[CITIES-MANDAL-LOADED] ${cities.length} cities');
      state = state.copyWith(isLoadingCities: false, cities: cities);
    } catch (e) {
      print('[CITIES-MANDAL-ERROR] $e');
      state = state.copyWith(isLoadingCities: false, errorMessage: e.toString());
    }
  }

  // ── Groups ───────────────────────────────────────────────────────────────

  Future<void> loadGroups({String serialNumber = ''}) async {
    if (_groupsLoaded && state.groups.isNotEmpty) return;
    state = state.copyWith(isLoadingGroups: true, clearError: true);
    try {
      final data = await _remoteDs.getGroups(
        authtoken: _token(),
        serialNumber: serialNumber,
      );
      final list = _parseList(
        data,
        GroupModel.fromJson,
        ['groupsList', 'groupList', 'groups', 'data'],
      );
      _groupsLoaded = true;
      // Old app behavior: many logins have exactly one group; auto-select it.
      final shouldAutoSelect =
          list.length == 1 && state.selectedGroup == null;
      state = state.copyWith(
        isLoadingGroups: false,
        groups: list,
        selectedGroup: shouldAutoSelect ? list.first : state.selectedGroup,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingGroups: false,
        errorMessage: e.toString(),
      );
    }
  }

  void selectGroup(GroupModel? group) {
    state = state.copyWith(selectedGroup: group);
  }

  // ── Customer Types ───────────────────────────────────────────────────────

  Future<void> loadCustomerTypes() async {
    if (_customerTypesLoaded && state.customerTypes.isNotEmpty) return;
    state = state.copyWith(isLoadingCustomerTypes: true, clearError: true);
    try {
      final data = await _remoteDs.getCustomerTypes(authtoken: _token());
      final list = _parseList(
        data,
        CustomerType.fromJson,
        ['customerTypeList', 'customerTypesList', 'customerTypes', 'data'],
      );
      _customerTypesLoaded = true;
      state = state.copyWith(isLoadingCustomerTypes: false, customerTypes: list);
    } catch (e) {
      state = state.copyWith(
        isLoadingCustomerTypes: false,
        errorMessage: e.toString(),
      );
    }
  }

  void selectCustomerType(CustomerType? ct) {
    state = state.copyWith(selectedCustomerType: ct);
  }

  // ── ID Types ─────────────────────────────────────────────────────────────

  Future<void> loadIdTypes() async {
    if (_idTypesLoaded && state.idTypes.isNotEmpty) return;
    state = state.copyWith(isLoadingIdTypes: true, clearError: true);
    try {
      final data = await _remoteDs.getIdTypes(authtoken: _token());
      final list = _parseList(
        data,
        IdType.fromJson,
        ['idList', 'idTypesList', 'idTypes', 'ids', 'data'],
      );
      _idTypesLoaded = true;
      state = state.copyWith(isLoadingIdTypes: false, idTypes: list);
    } catch (e) {
      state = state.copyWith(
        isLoadingIdTypes: false,
        errorMessage: e.toString(),
      );
    }
  }

  void selectIdType(IdType? idType) {
    state = state.copyWith(selectedIdType: idType);
  }

  // ── Genders ──────────────────────────────────────────────────────────────

  void selectGender(Gender? gender) {
    state = state.copyWith(selectedGender: gender);
  }

  // ── Form Validations ────────────────────────────────────────────────────

  Future<void> loadFormValidations() async {
    state = state.copyWith(isLoadingFormValidations: true, clearError: true);
    try {
      final data = await _remoteDs.getDynamicFormValidations(
        authtoken: _token(),
        // 'customer' — NOT 'customer_details'. This is the table_name the
        // native Android app sends (Edit_Customer_Info.java:6191) and, more
        // importantly, the one the SERVER itself validates against on save
        // (LcoRestServices.php prepare_customer_post_data →
        // getCustomerFormValidation('customer', ...)). Asking for any other
        // name returns no rows, so every server-driven mandatory flag
        // (baid / LCO Customer ID, last_name, email, id_type, id_number,
        // gender, mobile_no, mandal_id) silently reads as optional: no red
        // star, no client-side check, and the server rejects the submit.
        tableName: 'customer',
        dealerId: _dealerId(),
      );
      final list = _parseList(
        data,
        FormValidation.fromJson,
        ['formValidationList', 'dynamicFormValidations', 'data'],
      );
      state = state.copyWith(
        isLoadingFormValidations: false,
        formValidations: list,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingFormValidations: false,
        errorMessage: e.toString(),
      );
    }
  }

  // ── Bulk initialisation ─────────────────────────────────────────────────

  /// Load all one-time data in parallel and pre-select defaults from session.
  Future<void> initialise() async {
    await Future.wait([
      loadCountries(),
      loadGroups(),
      loadCustomerTypes(),
      loadIdTypes(),
      loadFormValidations(),
    ]);

    // Pre-select defaults from session
    final session = ref.read(appSessionProvider);
    if (session == null) return;

    // Default country
    if (session.defaultCountry != null && state.countries.isNotEmpty) {
      final match = state.countries.where(
        (c) => c.iso == session.defaultCountry,
      );
      if (match.isNotEmpty) {
        selectCountry(match.first);
        // Wait for states to load before selecting default state
        await Future.delayed(const Duration(milliseconds: 300));
        await _waitForStates();

        if (session.defaultState != null && state.states.isNotEmpty) {
          final stMatch = state.states.where(
            (s) => s.id == session.defaultState,
          );
          if (stMatch.isNotEmpty) {
            selectState(stMatch.first);
            await Future.delayed(const Duration(milliseconds: 300));
            await _waitForDistricts();

            if (session.defaultDistrict != null &&
                state.districts.isNotEmpty) {
              final dMatch = state.districts.where(
                (d) => d.id == session.defaultDistrict,
              );
              if (dMatch.isNotEmpty) {
                selectDistrict(dMatch.first);
                await Future.delayed(const Duration(milliseconds: 300));
                await _waitForCities();

                // City auto-selection is intentionally disabled.
                // session.defaultCity comes from getLovValue('DEFAULT_CITY', dealerId)
                // which is a dealer-level LOV default (often location_id=1) and is
                // NOT the same as the employee's LCO-mapped city. Auto-selecting it
                // causes 'Invalid City' from saveCustomerRest. User must pick manually.
              }
            }
          }
        }
      }
    }
  }

  Future<void> _waitForStates() async {
    for (int i = 0; i < 20; i++) {
      if (!state.isLoadingStates) return;
      await Future.delayed(const Duration(milliseconds: 150));
    }
  }

  Future<void> _waitForDistricts() async {
    for (int i = 0; i < 20; i++) {
      if (!state.isLoadingDistricts) return;
      await Future.delayed(const Duration(milliseconds: 150));
    }
  }

  Future<void> _waitForCities() async {
    for (int i = 0; i < 20; i++) {
      if (!state.isLoadingCities) return;
      await Future.delayed(const Duration(milliseconds: 150));
    }
  }

  /// Reset all data and caches.
  void reset() {
    _countriesLoaded = false;
    _groupsLoaded = false;
    _customerTypesLoaded = false;
    _idTypesLoaded = false;
    state = const MasterDataState(
      genders: [
        Gender(id: 1, name: 'Male'),
        Gender(id: 2, name: 'Female'),
        Gender(id: 3, name: 'Other'),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

final masterDataProvider =
    NotifierProvider<MasterDataNotifier, MasterDataState>(
  MasterDataNotifier.new,
);
