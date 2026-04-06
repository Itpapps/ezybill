import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../application/providers/customer_provider.dart';
import '../../../application/providers/master_data_provider.dart';
import '../../../core/config/app_session.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/validators.dart';
import '../../../data/models/master_data/city.dart';
import '../../../data/models/master_data/country.dart';
import '../../../data/models/master_data/customer_type.dart';
import '../../../data/models/master_data/district.dart';
import '../../../data/models/master_data/gender.dart';
import '../../../data/models/master_data/group_model.dart';
import '../../../data/models/master_data/id_type.dart';
import '../../../data/models/master_data/mandal.dart';
import '../../../data/models/master_data/state_model.dart';
import '../../common/widgets/app_toast.dart';

class EditCustomerScreen extends ConsumerStatefulWidget {
  final String customerId;
  final Map<String, dynamic> customer;

  const EditCustomerScreen({
    super.key,
    required this.customerId,
    required this.customer,
  });

  @override
  ConsumerState<EditCustomerScreen> createState() => _EditCustomerScreenState();
}

class _EditCustomerScreenState extends ConsumerState<EditCustomerScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;
  bool _masterDataLoaded = false;

  // ── Text controllers ──────────────────────────────────────────────────────
  late final TextEditingController _firstNameCtrl;
  late final TextEditingController _lastNameCtrl;
  late final TextEditingController _mobileCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _idNumberCtrl;
  late final TextEditingController _fatherNameCtrl;
  late final TextEditingController _businessNameCtrl;
  late final TextEditingController _accountNumberCtrl;
  late final TextEditingController _remarksCtrl;

  // Billing address
  late final TextEditingController _billingAddress1Ctrl;
  late final TextEditingController _billingAddress2Ctrl;
  late final TextEditingController _billingPinCodeCtrl;

  // Installation address
  late final TextEditingController _installAddress1Ctrl;
  late final TextEditingController _installAddress2Ctrl;
  late final TextEditingController _installPinCodeCtrl;

  // ── Dropdown values ───────────────────────────────────────────────────────
  String? _selectedGenderId;
  String? _selectedCustomerTypeId;
  String? _selectedGroupId;
  String? _selectedIdTypeId;
  String? _selectedBillType;

  // ── Address toggles ───────────────────────────────────────────────────────
  bool _changeAddress = false;
  bool _changeInstallAddress = false;
  bool _sameAsBilling = false;
  bool _uploadDocs = false;

  // ── Cascading address selections (billing) ────────────────────────────────
  Country? _billingCountry;
  StateModel? _billingState;
  District? _billingDistrict;
  City? _billingCity;
  Mandal? _billingMandal;

  // ── Cascading address selections (install) ────────────────────────────────
  Country? _installCountry;
  StateModel? _installState;
  District? _installDistrict;
  City? _installCity;
  Mandal? _installMandal;

  // ── Cascading data lists (install — separate from billing) ────────────────
  List<StateModel> _installStates = [];
  List<District> _installDistricts = [];
  List<City> _installCities = [];
  List<Mandal> _installMandals = [];
  bool _installStatesLoading = false;
  bool _installDistrictsLoading = false;
  bool _installCitiesLoading = false;
  bool _installMandalsLoading = false;

  String _f(String key, [String fallback = '']) =>
      widget.customer[key]?.toString() ?? fallback;

  @override
  void initState() {
    super.initState();

    // Parse name — may be "First Last" or separate fields
    final fullName = _f('customer_name', _f('customerName', ''));
    final parts = fullName.trim().split(RegExp(r'\s+'));
    final firstName = _f('firstName', parts.isNotEmpty ? parts.first : '');
    final lastName = _f('lastName', parts.length > 1 ? parts.sublist(1).join(' ') : '');

    _firstNameCtrl = TextEditingController(text: firstName);
    _lastNameCtrl = TextEditingController(text: lastName);
    _mobileCtrl = TextEditingController(
      text: _f('mobile_no', _f('mobileNumber', _f('mobile_number', ''))),
    );
    _emailCtrl = TextEditingController(text: _f('email', _f('emailId', '')));
    _idNumberCtrl = TextEditingController(text: _f('idNumber', _f('id_number', '')));
    _fatherNameCtrl = TextEditingController(text: _f('fatherName', _f('father_name', '')));
    _businessNameCtrl = TextEditingController(text: _f('businessName', _f('business_name', '')));
    _accountNumberCtrl = TextEditingController(
      text: _f('accountnumber', _f('account_number', _f('accountNumber', ''))),
    );
    _remarksCtrl = TextEditingController(text: _f('remarks', ''));

    _billingAddress1Ctrl = TextEditingController(
      text: _f('billingAddress1', _f('billing_address1', _f('billingAddress', ''))),
    );
    _billingAddress2Ctrl = TextEditingController(
      text: _f('billingAddress2', _f('billing_address2', '')),
    );
    _billingPinCodeCtrl = TextEditingController(
      text: _f('pinCode', _f('pin_code', '')),
    );

    _installAddress1Ctrl = TextEditingController(
      text: _f('installationAddress1', _f('installation_address1', _f('installationAddress', ''))),
    );
    _installAddress2Ctrl = TextEditingController(
      text: _f('installationAddress2', _f('installation_address2', '')),
    );
    _installPinCodeCtrl = TextEditingController(
      text: _f('installPinCode', _f('install_pin_code', '')),
    );

    // Pre-select dropdown values from customer data
    _selectedGenderId = _f('gender', _f('genderId', ''));
    _selectedCustomerTypeId = _f('customerTypeId', _f('customer_type_id', ''));
    _selectedGroupId = _f('groupId', _f('group_id', ''));
    _selectedIdTypeId = _f('idType', _f('id_type', ''));
    _selectedBillType = _f('bill_type', _f('billType', ''));

    // Load master data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMasterData();
    });
  }

  Future<void> _loadMasterData() async {
    final notifier = ref.read(masterDataProvider.notifier);
    await notifier.initialise();
    if (mounted) {
      setState(() => _masterDataLoaded = true);
    }
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _mobileCtrl.dispose();
    _emailCtrl.dispose();
    _idNumberCtrl.dispose();
    _fatherNameCtrl.dispose();
    _businessNameCtrl.dispose();
    _accountNumberCtrl.dispose();
    _remarksCtrl.dispose();
    _billingAddress1Ctrl.dispose();
    _billingAddress2Ctrl.dispose();
    _billingPinCodeCtrl.dispose();
    _installAddress1Ctrl.dispose();
    _installAddress2Ctrl.dispose();
    _installPinCodeCtrl.dispose();
    super.dispose();
  }

  // ── Submit ──────────────────────────────────────────────────────────────

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final session = ref.read(appSessionProvider);
    if (session == null) return;

    setState(() => _isSaving = true);

    try {
      final ds = ref.read(customerRemoteDatasourceProvider);
      final masterState = ref.read(masterDataProvider);

      final data = <String, dynamic>{
        'customerId': widget.customerId,
        'firstName': _firstNameCtrl.text.trim(),
        'mobileNumber': _mobileCtrl.text.trim(),
      };

      if (session.useLastName == 1) {
        data['lastName'] = _lastNameCtrl.text.trim();
      }
      if (_emailCtrl.text.trim().isNotEmpty) {
        data['email'] = _emailCtrl.text.trim();
      }
      if (_selectedGenderId != null && _selectedGenderId!.isNotEmpty) {
        data['gender'] = _selectedGenderId;
      }
      if (_selectedCustomerTypeId != null && _selectedCustomerTypeId!.isNotEmpty) {
        data['customerTypeId'] = _selectedCustomerTypeId;
      }
      if (_selectedGroupId != null && _selectedGroupId!.isNotEmpty) {
        data['groupId'] = _selectedGroupId;
      }
      if (_selectedIdTypeId != null && _selectedIdTypeId!.isNotEmpty) {
        data['idType'] = _selectedIdTypeId;
      }
      if (_idNumberCtrl.text.trim().isNotEmpty) {
        data['idNumber'] = _idNumberCtrl.text.trim();
      }
      if (_fatherNameCtrl.text.trim().isNotEmpty) {
        data['fatherName'] = _fatherNameCtrl.text.trim();
      }
      if (_businessNameCtrl.text.trim().isNotEmpty) {
        data['businessName'] = _businessNameCtrl.text.trim();
      }
      if (session.useAccountNumber > 0 &&
          _accountNumberCtrl.text.trim().isNotEmpty) {
        data['accountNumber'] = _accountNumberCtrl.text.trim();
      }
      if (_selectedBillType != null && _selectedBillType!.isNotEmpty) {
        data['billType'] = _selectedBillType;
      }
      if (_remarksCtrl.text.trim().isNotEmpty) {
        data['remarks'] = _remarksCtrl.text.trim();
      }

      // Address
      data['changeAddress'] = _changeAddress;
      if (_changeAddress) {
        data['billingAddress1'] = _billingAddress1Ctrl.text.trim();
        data['billingAddress2'] = _billingAddress2Ctrl.text.trim();
        data['pinCode'] = _billingPinCodeCtrl.text.trim();
        if (_billingCountry != null) data['countryCode'] = _billingCountry!.iso;
        if (_billingState != null) data['stateId'] = _billingState!.id.toString();
        if (_billingDistrict != null) data['districtId'] = _billingDistrict!.id.toString();
        if (_billingCity != null) data['cityId'] = _billingCity!.locationId.toString();
        if (_billingMandal != null) data['mandalId'] = _billingMandal!.mandalId.toString();
      }

      // Installation address
      data['changeInstallAddress'] = _changeInstallAddress;
      if (_changeInstallAddress) {
        if (_sameAsBilling) {
          data['installationAddress1'] = _billingAddress1Ctrl.text.trim();
          data['installationAddress2'] = _billingAddress2Ctrl.text.trim();
        } else {
          data['installationAddress1'] = _installAddress1Ctrl.text.trim();
          data['installationAddress2'] = _installAddress2Ctrl.text.trim();
        }
      }

      // Upload docs
      data['uploadDocs'] = _uploadDocs;

      await ds.editCustomer(
        authtoken: session.token,
        customerData: data,
      );

      if (mounted) {
        AppToast.show(context, message: 'Customer updated successfully');
        context.pop(true);
      }
    } catch (e) {
      debugPrint('[EDIT] Save error: $e');
      if (mounted) {
        final c = Theme.of(context).extension<AppColors>()!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toString().replaceAll('ApiException: ', ''),
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            backgroundColor: c.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: AppRadius.smBR),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  // ── Install address cascading loaders ─────────────────────────────────

  Future<void> _loadInstallStates(String countryCode) async {
    setState(() => _installStatesLoading = true);
    try {
      final ds = ref.read(masterDataRemoteDatasourceProvider);
      final session = ref.read(appSessionProvider);
      final data = await ds.getStates(
        authtoken: session?.token ?? '',
        countryCode: countryCode,
      );
      final list = _parseModelList(data, StateModel.fromJson,
          ['statesList', 'states', 'data']);
      if (mounted) {
        setState(() {
          _installStates = list;
          _installStatesLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _installStatesLoading = false);
    }
  }

  Future<void> _loadInstallDistricts(String stateId) async {
    setState(() => _installDistrictsLoading = true);
    try {
      final ds = ref.read(masterDataRemoteDatasourceProvider);
      final session = ref.read(appSessionProvider);
      final data = await ds.getDistricts(
        authtoken: session?.token ?? '',
        stateId: stateId,
      );
      final list = _parseModelList(data, District.fromJson,
          ['districtsList', 'districts', 'data']);
      if (mounted) {
        setState(() {
          _installDistricts = list;
          _installDistrictsLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _installDistrictsLoading = false);
    }
  }

  Future<void> _loadInstallCitiesAndMandals(
      String stateId, String districtId) async {
    setState(() {
      _installCitiesLoading = true;
      _installMandalsLoading = true;
    });
    try {
      final ds = ref.read(masterDataRemoteDatasourceProvider);
      final session = ref.read(appSessionProvider);
      final cityData = await ds.getCities(
        authtoken: session?.token ?? '',
        stateId: stateId,
        districtId: districtId,
      );
      final mandalData = await ds.getMandals(
        authtoken: session?.token ?? '',
        districtId: districtId,
      );
      if (mounted) {
        setState(() {
          _installCities = _parseModelList(
              cityData, City.fromJson, ['locationList', 'citiesList', 'cities', 'data']);
          _installMandals = _parseModelList(
              mandalData, Mandal.fromJson, ['mandalsList', 'mandals', 'data']);
          _installCitiesLoading = false;
          _installMandalsLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _installCitiesLoading = false;
          _installMandalsLoading = false;
        });
      }
    }
  }

  List<T> _parseModelList<T>(
    Map<String, dynamic> data,
    T Function(Map<String, dynamic>) fromJson,
    List<String> keys,
  ) {
    for (final key in keys) {
      final raw = data[key];
      if (raw is List && raw.isNotEmpty) {
        return raw.whereType<Map<String, dynamic>>().map(fromJson).toList();
      }
    }
    return [];
  }

  // ── Build ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;
    final tt = Theme.of(context).textTheme;
    final session = ref.watch(appSessionProvider);
    final masterState = ref.watch(masterDataProvider);
    final isFrozen = session?.isCustomerFrozen == true;
    final showLastName = session?.useLastName == 1;
    final showAccountNumber = (session?.useAccountNumber ?? 0) > 0;
    final lockAccountNumber = showAccountNumber;

    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(
        title: Text('Edit Customer', style: tt.titleMedium),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.pop(),
        ),
      ),
      body: !_masterDataLoaded
          ? Center(child: CircularProgressIndicator(color: c.red))
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                children: [
                  // ── Personal Info Section ─────────────────────────────
                  _buildSectionHeader('Personal Information', c),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _firstNameCtrl,
                    label: 'First Name',
                    hint: 'Enter first name',
                    colors: c,
                    readOnly: isFrozen,
                    validator: (v) => validateRequired(v, 'First name'),
                  ),
                  if (showLastName) ...[
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _lastNameCtrl,
                      label: 'Last Name',
                      hint: 'Enter last name',
                      colors: c,
                      readOnly: isFrozen,
                    ),
                  ],
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _mobileCtrl,
                    label: 'Mobile Number',
                    hint: 'Enter 10-digit mobile',
                    colors: c,
                    readOnly: isFrozen,
                    keyboardType: TextInputType.phone,
                    validator: validateMobile,
                    maxLength: 10,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _emailCtrl,
                    label: 'Email',
                    hint: 'Enter email address',
                    colors: c,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return null;
                      return validateEmail(v);
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildDropdown<Gender>(
                    label: 'Gender',
                    value: _findGender(masterState.genders),
                    items: masterState.genders,
                    displayName: (g) => g.name,
                    onChanged: isFrozen
                        ? null
                        : (g) => setState(
                            () => _selectedGenderId = g?.id.toString()),
                    colors: c,
                  ),
                  const SizedBox(height: 12),
                  _buildDropdown<CustomerType>(
                    label: 'Customer Type',
                    value: _findCustomerType(masterState.customerTypes),
                    items: masterState.customerTypes,
                    displayName: (ct) => ct.customerType,
                    isLoading: masterState.isLoadingCustomerTypes,
                    onChanged: (ct) => setState(() =>
                        _selectedCustomerTypeId =
                            ct?.customerTypeId.toString()),
                    colors: c,
                  ),
                  const SizedBox(height: 12),
                  _buildDropdown<GroupModel>(
                    label: 'Group',
                    value: _findGroup(masterState.groups),
                    items: masterState.groups,
                    displayName: (g) => g.groupName,
                    isLoading: masterState.isLoadingGroups,
                    onChanged: (g) => setState(
                        () => _selectedGroupId = g?.groupId.toString()),
                    colors: c,
                  ),
                  const SizedBox(height: 12),
                  _buildDropdown<IdType>(
                    label: 'ID Type',
                    value: _findIdType(masterState.idTypes),
                    items: masterState.idTypes,
                    displayName: (it) => it.name,
                    isLoading: masterState.isLoadingIdTypes,
                    onChanged: (it) => setState(
                        () => _selectedIdTypeId = it?.id.toString()),
                    colors: c,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _idNumberCtrl,
                    label: 'ID Number',
                    hint: 'Enter ID number',
                    colors: c,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _fatherNameCtrl,
                    label: 'Father Name',
                    hint: 'Enter father name',
                    colors: c,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _businessNameCtrl,
                    label: 'Business Name',
                    hint: 'Enter business name',
                    colors: c,
                  ),
                  if (showAccountNumber) ...[
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _accountNumberCtrl,
                      label: 'Account Number',
                      hint: 'Account number',
                      colors: c,
                      readOnly: lockAccountNumber,
                    ),
                  ],
                  const SizedBox(height: 12),
                  _buildDropdown<String>(
                    label: 'Bill Type',
                    value: _selectedBillType != null &&
                            _selectedBillType!.isNotEmpty
                        ? _selectedBillType
                        : null,
                    items: const ['Prepaid', 'Postpaid'],
                    displayName: (s) => s,
                    onChanged: (v) =>
                        setState(() => _selectedBillType = v),
                    colors: c,
                  ),

                  const SizedBox(height: 24),

                  // ── Billing Address Section ───────────────────────────
                  _buildSectionHeader('Billing Address', c),
                  const SizedBox(height: 8),
                  _buildCheckbox(
                    label: 'Change Address',
                    value: _changeAddress,
                    onChanged: (v) =>
                        setState(() => _changeAddress = v ?? false),
                    colors: c,
                  ),
                  if (_changeAddress) ...[
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _billingAddress1Ctrl,
                      label: 'Address Line 1',
                      hint: 'Enter billing address line 1',
                      colors: c,
                      validator: _changeAddress
                          ? (v) => validateRequired(v, 'Address line 1')
                          : null,
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _billingAddress2Ctrl,
                      label: 'Address Line 2',
                      hint: 'Enter billing address line 2',
                      colors: c,
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _billingPinCodeCtrl,
                      label: 'PIN Code',
                      hint: 'Enter 6-digit PIN code',
                      colors: c,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      validator: _changeAddress
                          ? (v) {
                              if (v == null || v.trim().isEmpty) return null;
                              return validatePinCode(v);
                            }
                          : null,
                    ),
                    const SizedBox(height: 12),
                    // Country
                    _buildDropdown<Country>(
                      label: 'Country',
                      value: _billingCountry,
                      items: masterState.countries,
                      displayName: (co) => co.name,
                      isLoading: masterState.isLoadingCountries,
                      onChanged: (co) {
                        setState(() {
                          _billingCountry = co;
                          _billingState = null;
                          _billingDistrict = null;
                          _billingCity = null;
                          _billingMandal = null;
                        });
                        if (co != null) {
                          ref
                              .read(masterDataProvider.notifier)
                              .selectCountry(co);
                        }
                      },
                      colors: c,
                    ),
                    const SizedBox(height: 12),
                    // State
                    _buildDropdown<StateModel>(
                      label: 'State',
                      value: _billingState,
                      items: masterState.states,
                      displayName: (s) => s.name,
                      isLoading: masterState.isLoadingStates,
                      onChanged: (s) {
                        setState(() {
                          _billingState = s;
                          _billingDistrict = null;
                          _billingCity = null;
                          _billingMandal = null;
                        });
                        if (s != null) {
                          ref
                              .read(masterDataProvider.notifier)
                              .selectState(s);
                        }
                      },
                      colors: c,
                    ),
                    const SizedBox(height: 12),
                    // District
                    _buildDropdown<District>(
                      label: 'District',
                      value: _billingDistrict,
                      items: masterState.districts,
                      displayName: (d) => d.name,
                      isLoading: masterState.isLoadingDistricts,
                      onChanged: (d) {
                        setState(() {
                          _billingDistrict = d;
                          _billingCity = null;
                          _billingMandal = null;
                        });
                        if (d != null) {
                          ref
                              .read(masterDataProvider.notifier)
                              .selectDistrict(d);
                        }
                      },
                      colors: c,
                    ),
                    const SizedBox(height: 12),
                    // City
                    _buildDropdown<City>(
                      label: 'City',
                      value: _billingCity,
                      items: masterState.cities,
                      displayName: (ci) => ci.locationName,
                      isLoading: masterState.isLoadingCities,
                      onChanged: (ci) {
                        setState(() => _billingCity = ci);
                      },
                      colors: c,
                    ),
                    const SizedBox(height: 12),
                    // Mandal
                    _buildDropdown<Mandal>(
                      label: 'Mandal',
                      value: _billingMandal,
                      items: masterState.mandals,
                      displayName: (m) => m.mandalName,
                      isLoading: masterState.isLoadingMandals,
                      onChanged: (m) {
                        setState(() => _billingMandal = m);
                      },
                      colors: c,
                    ),
                  ],

                  const SizedBox(height: 24),

                  // ── Installation Address Section ──────────────────────
                  _buildSectionHeader('Installation Address', c),
                  const SizedBox(height: 8),
                  _buildCheckbox(
                    label: 'Change Installation Address',
                    value: _changeInstallAddress,
                    onChanged: (v) =>
                        setState(() => _changeInstallAddress = v ?? false),
                    colors: c,
                  ),
                  if (_changeInstallAddress) ...[
                    _buildCheckbox(
                      label: 'Same as Billing Address',
                      value: _sameAsBilling,
                      onChanged: (v) {
                        setState(() => _sameAsBilling = v ?? false);
                        if (v == true) {
                          _installAddress1Ctrl.text =
                              _billingAddress1Ctrl.text;
                          _installAddress2Ctrl.text =
                              _billingAddress2Ctrl.text;
                          _installPinCodeCtrl.text =
                              _billingPinCodeCtrl.text;
                        }
                      },
                      colors: c,
                    ),
                    if (!_sameAsBilling) ...[
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _installAddress1Ctrl,
                        label: 'Address Line 1',
                        hint: 'Enter installation address line 1',
                        colors: c,
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _installAddress2Ctrl,
                        label: 'Address Line 2',
                        hint: 'Enter installation address line 2',
                        colors: c,
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _installPinCodeCtrl,
                        label: 'PIN Code',
                        hint: 'Enter 6-digit PIN code',
                        colors: c,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return null;
                          return validatePinCode(v);
                        },
                      ),
                      const SizedBox(height: 12),
                      // Install Country
                      _buildDropdown<Country>(
                        label: 'Country',
                        value: _installCountry,
                        items: masterState.countries,
                        displayName: (co) => co.name,
                        isLoading: masterState.isLoadingCountries,
                        onChanged: (co) {
                          setState(() {
                            _installCountry = co;
                            _installState = null;
                            _installDistrict = null;
                            _installCity = null;
                            _installMandal = null;
                            _installStates = [];
                            _installDistricts = [];
                            _installCities = [];
                            _installMandals = [];
                          });
                          if (co != null) {
                            _loadInstallStates(co.iso);
                          }
                        },
                        colors: c,
                      ),
                      const SizedBox(height: 12),
                      _buildDropdown<StateModel>(
                        label: 'State',
                        value: _installState,
                        items: _installStates,
                        displayName: (s) => s.name,
                        isLoading: _installStatesLoading,
                        onChanged: (s) {
                          setState(() {
                            _installState = s;
                            _installDistrict = null;
                            _installCity = null;
                            _installMandal = null;
                            _installDistricts = [];
                            _installCities = [];
                            _installMandals = [];
                          });
                          if (s != null) {
                            _loadInstallDistricts(s.id.toString());
                          }
                        },
                        colors: c,
                      ),
                      const SizedBox(height: 12),
                      _buildDropdown<District>(
                        label: 'District',
                        value: _installDistrict,
                        items: _installDistricts,
                        displayName: (d) => d.name,
                        isLoading: _installDistrictsLoading,
                        onChanged: (d) {
                          setState(() {
                            _installDistrict = d;
                            _installCity = null;
                            _installMandal = null;
                            _installCities = [];
                            _installMandals = [];
                          });
                          if (d != null) {
                            _loadInstallCitiesAndMandals(
                              d.stateId.toString(),
                              d.id.toString(),
                            );
                          }
                        },
                        colors: c,
                      ),
                      const SizedBox(height: 12),
                      _buildDropdown<City>(
                        label: 'City',
                        value: _installCity,
                        items: _installCities,
                        displayName: (ci) => ci.locationName,
                        isLoading: _installCitiesLoading,
                        onChanged: (ci) =>
                            setState(() => _installCity = ci),
                        colors: c,
                      ),
                      const SizedBox(height: 12),
                      _buildDropdown<Mandal>(
                        label: 'Mandal',
                        value: _installMandal,
                        items: _installMandals,
                        displayName: (m) => m.mandalName,
                        isLoading: _installMandalsLoading,
                        onChanged: (m) =>
                            setState(() => _installMandal = m),
                        colors: c,
                      ),
                    ],
                  ],

                  const SizedBox(height: 24),

                  // ── Documents Section ─────────────────────────────────
                  _buildSectionHeader('Documents', c),
                  const SizedBox(height: 8),
                  _buildCheckbox(
                    label: 'Upload Documents',
                    value: _uploadDocs,
                    onChanged: (v) =>
                        setState(() => _uploadDocs = v ?? false),
                    colors: c,
                  ),
                  if (_uploadDocs) ...[
                    const SizedBox(height: 12),
                    _buildUploadPlaceholder(
                      label: 'ID Photo',
                      icon: LucideIcons.creditCard,
                      colors: c,
                    ),
                    const SizedBox(height: 12),
                    _buildUploadPlaceholder(
                      label: 'Customer Photo',
                      icon: LucideIcons.user,
                      colors: c,
                    ),
                  ],

                  const SizedBox(height: 24),

                  // ── Remarks Section ───────────────────────────────────
                  _buildSectionHeader('Remarks', c),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _remarksCtrl,
                    label: 'Remarks',
                    hint: 'Enter remarks (optional)',
                    colors: c,
                    maxLines: 3,
                  ),
                ],
              ),
            ),
      bottomNavigationBar: _masterDataLoaded
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: c.red,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: c.ink20,
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.pillBR,
                      ),
                      elevation: 0,
                    ),
                    child: _isSaving
                        ? SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: c.card,
                            ),
                          )
                        : Text(
                            'Update',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
              ),
            )
          : null,
    );
  }

  // ── Dropdown matching helpers ─────────────────────────────────────────

  Gender? _findGender(List<Gender> genders) {
    if (_selectedGenderId == null || _selectedGenderId!.isEmpty) return null;
    final id = int.tryParse(_selectedGenderId!);
    if (id != null) {
      final match = genders.where((g) => g.id == id);
      if (match.isNotEmpty) return match.first;
    }
    // Try matching by name
    final match = genders.where(
        (g) => g.name.toLowerCase() == _selectedGenderId!.toLowerCase());
    if (match.isNotEmpty) return match.first;
    return null;
  }

  CustomerType? _findCustomerType(List<CustomerType> types) {
    if (_selectedCustomerTypeId == null || _selectedCustomerTypeId!.isEmpty) {
      return null;
    }
    final id = int.tryParse(_selectedCustomerTypeId!);
    if (id != null) {
      final match = types.where((ct) => ct.customerTypeId == id);
      if (match.isNotEmpty) return match.first;
    }
    return null;
  }

  GroupModel? _findGroup(List<GroupModel> groups) {
    if (_selectedGroupId == null || _selectedGroupId!.isEmpty) return null;
    final id = int.tryParse(_selectedGroupId!);
    if (id != null) {
      final match = groups.where((g) => g.groupId == id);
      if (match.isNotEmpty) return match.first;
    }
    return null;
  }

  IdType? _findIdType(List<IdType> types) {
    if (_selectedIdTypeId == null || _selectedIdTypeId!.isEmpty) return null;
    final id = int.tryParse(_selectedIdTypeId!);
    if (id != null) {
      final match = types.where((it) => it.id == id);
      if (match.isNotEmpty) return match.first;
    }
    return null;
  }

  // ── Shared widget builders ────────────────────────────────────────────

  Widget _buildSectionHeader(String title, AppColors c) {
    return Text(
      title,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 15,
        fontWeight: FontWeight.w800,
        color: c.ink,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required AppColors colors,
    bool readOnly = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int? maxLength,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: colors.ink60,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          readOnly: readOnly,
          keyboardType: keyboardType,
          maxLength: maxLength,
          maxLines: maxLines,
          validator: validator,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: readOnly ? colors.ink40 : colors.ink,
          ),
          decoration: InputDecoration(
            hintText: hint,
            counterText: '',
            filled: true,
            fillColor: readOnly ? colors.ink05 : colors.card,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: AppRadius.smBR,
              borderSide: BorderSide(color: colors.ink10, width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppRadius.smBR,
              borderSide: BorderSide(color: colors.ink10, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppRadius.smBR,
              borderSide: BorderSide(color: colors.red, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: AppRadius.smBR,
              borderSide: BorderSide(color: colors.redDot, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: AppRadius.smBR,
              borderSide: BorderSide(color: colors.redDot, width: 1.5),
            ),
            hintStyle: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: colors.ink20,
            ),
            errorStyle: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              color: colors.redDot,
            ),
            suffixIcon: readOnly
                ? Icon(LucideIcons.lock, size: 16, color: colors.ink20)
                : null,
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T? value,
    required List<T> items,
    required String Function(T) displayName,
    required void Function(T?)? onChanged,
    required AppColors colors,
    bool isLoading = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: colors.ink60,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: onChanged == null ? colors.ink05 : colors.card,
            borderRadius: AppRadius.smBR,
            border: Border.all(color: colors.ink10, width: 1.5),
          ),
          child: isLoading
              ? Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colors.ink40,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Loading...',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: colors.ink40,
                        ),
                      ),
                    ],
                  ),
                )
              : DropdownButtonHideUnderline(
                  child: DropdownButton<T>(
                    value: value,
                    isExpanded: true,
                    hint: Text(
                      'Select $label',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: colors.ink20,
                      ),
                    ),
                    icon: Icon(
                      LucideIcons.chevronDown,
                      size: 18,
                      color: colors.ink40,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    borderRadius: AppRadius.smBR,
                    dropdownColor: colors.card,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: colors.ink,
                    ),
                    items: items.map((item) {
                      return DropdownMenuItem<T>(
                        value: item,
                        child: Text(
                          displayName(item),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: colors.ink,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: onChanged,
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildCheckbox({
    required String label,
    required bool value,
    required void Function(bool?)? onChanged,
    required AppColors colors,
  }) {
    return InkWell(
      onTap: () => onChanged?.call(!value),
      borderRadius: AppRadius.smBR,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            SizedBox(
              width: 22,
              height: 22,
              child: Checkbox(
                value: value,
                onChanged: onChanged,
                activeColor: colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                side: BorderSide(color: colors.ink20, width: 1.5),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: colors.ink80,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadPlaceholder({
    required String label,
    required IconData icon,
    required AppColors colors,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: AppRadius.smBR,
        border: Border.all(
          color: colors.ink10,
          width: 1.5,
          strokeAlign: BorderSide.strokeAlignInside,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colors.ink05,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 20, color: colors.ink40),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: colors.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Tap to upload',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: colors.ink40,
                  ),
                ),
              ],
            ),
          ),
          Icon(LucideIcons.upload, size: 18, color: colors.ink40),
        ],
      ),
    );
  }
}
