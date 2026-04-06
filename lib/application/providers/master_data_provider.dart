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
    for (final key in possibleKeys) {
      final raw = data[key];
      if (raw is List && raw.isNotEmpty) {
        return raw
            .whereType<Map<String, dynamic>>()
            .map((e) => fromJson(e))
            .toList();
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
    state = state.copyWith(
      selectedState: st,
      clearSelectedDistrict: true,
      clearSelectedCity: true,
      clearSelectedMandal: true,
      districts: const [],
      cities: const [],
      mandals: const [],
    );
    if (st != null) {
      loadDistricts(st.id.toString());
    }
  }

  // ── Districts ────────────────────────────────────────────────────────────

  Future<void> loadDistricts(String stateId) async {
    state = state.copyWith(isLoadingDistricts: true, clearError: true);
    try {
      final data = await _remoteDs.getDistricts(
        authtoken: _token(),
        stateId: stateId,
      );
      final list = _parseList(
        data,
        District.fromJson,
        ['districtsList', 'districts', 'data'],
      );
      state = state.copyWith(isLoadingDistricts: false, districts: list);
    } catch (e) {
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
      // Load cities and mandals in parallel
      loadCities(district.stateId.toString(), district.id.toString());
      loadMandals(district.id.toString());
    }
  }

  // ── Cities ───────────────────────────────────────────────────────────────

  Future<void> loadCities(String stateId, String districtId) async {
    state = state.copyWith(isLoadingCities: true, clearError: true);
    try {
      final data = await _remoteDs.getCities(
        authtoken: _token(),
        stateId: stateId,
        districtId: districtId,
      );
      final list = _parseList(
        data,
        City.fromJson,
        ['locationList', 'citiesList', 'cities', 'data'],
      );
      state = state.copyWith(isLoadingCities: false, cities: list);
    } catch (e) {
      state = state.copyWith(
        isLoadingCities: false,
        errorMessage: e.toString(),
      );
    }
  }

  void selectCity(City? city) {
    state = state.copyWith(selectedCity: city);
  }

  // ── Mandals ──────────────────────────────────────────────────────────────

  Future<void> loadMandals(String districtId) async {
    state = state.copyWith(isLoadingMandals: true, clearError: true);
    try {
      final data = await _remoteDs.getMandals(
        authtoken: _token(),
        districtId: districtId,
      );
      final list = _parseList(
        data,
        Mandal.fromJson,
        ['mandalsList', 'mandals', 'data'],
      );
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

  // ── Groups ───────────────────────────────────────────────────────────────

  Future<void> loadGroups() async {
    if (_groupsLoaded && state.groups.isNotEmpty) return;
    state = state.copyWith(isLoadingGroups: true, clearError: true);
    try {
      final data = await _remoteDs.getGroups(authtoken: _token());
      final list = _parseList(
        data,
        GroupModel.fromJson,
        ['groupsList', 'groups', 'data'],
      );
      _groupsLoaded = true;
      state = state.copyWith(isLoadingGroups: false, groups: list);
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
        ['customerTypesList', 'customerTypes', 'data'],
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
        ['idTypesList', 'idTypes', 'ids', 'data'],
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
        tableName: 'customer_details',
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

                if (session.defaultCity != null && state.cities.isNotEmpty) {
                  final cMatch = state.cities.where(
                    (c) => c.locationId == session.defaultCity,
                  );
                  if (cMatch.isNotEmpty) {
                    selectCity(cMatch.first);
                  }
                }
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
