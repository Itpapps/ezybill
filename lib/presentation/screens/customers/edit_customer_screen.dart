import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../application/providers/customer_provider.dart';
import '../../../application/providers/core_providers.dart';
import '../../../application/providers/master_data_provider.dart';
import '../../../core/config/app_session.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/validators.dart';
import '../../../data/datasources/remote/package_remote_datasource.dart';
import '../../../data/models/master_data/city.dart';
import '../../../data/models/master_data/country.dart';
import '../../../data/models/master_data/customer_type.dart';
import '../../../data/models/master_data/district.dart';
import '../../../data/models/master_data/gender.dart';
import '../../../data/models/master_data/group_model.dart';
import '../../../data/models/master_data/id_type.dart';
import '../../../data/models/master_data/mandal.dart';
import '../../../data/models/master_data/state_model.dart';
import '../../../data/models/package/cas_package.dart';
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
  bool _isLoadingCustomer = false;

  /// Mutable copy of customer data — starts from widget.customer but can be
  /// populated from the API when the GoRouter extra is lost (empty map).
  late Map<String, dynamic> _customerData;
  static final RegExp _androidEmailRegex =
      RegExp(r'[a-zA-Z0-9._-]+@[a-z]+\.+[a-z]+');

  // ── Text controllers ──────────────────────────────────────────────────────
  late final TextEditingController _firstNameCtrl;
  late final TextEditingController _lastNameCtrl;
  late final TextEditingController _mobileCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _idNumberCtrl;
  late final TextEditingController _lcoCustomerIdCtrl;
  late final TextEditingController _cafNumberCtrl;
  late final TextEditingController _groupNameCtrl;
  late final TextEditingController _fatherNameCtrl;
  late final TextEditingController _businessNameCtrl;
  late final TextEditingController _accountNumberCtrl;
  late final TextEditingController _remarksCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _dobCtrl;
  late final TextEditingController _anniversaryCtrl;
  late final TextEditingController _signupDateCtrl;

  // ── Image upload state ──────────────────────────────────────────────────
  File? _customerPhoto;
  File? _idProofPhoto;
  File? _signaturePhoto;
  String? _customerPhotoBase64;
  String? _idProofPhotoBase64;
  String? _signaturePhotoBase64;

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
  int? _selectedBillType;

  // ── Address toggles ───────────────────────────────────────────────────────
  bool _sameAsBilling = false;
  bool _uploadDocs = false;

  // ── Cascading address selections (billing) ────────────────────────────────
  Country? _billingCountry;
  StateModel? _billingState;
  District? _billingDistrict;
  City? _billingCity;
  Mandal? _billingMandal;

  List<CasPackage> _packages = [];
  CasPackage? _selectedPackage;
  bool _packagesLoading = false;
  String? _packagesError;

  String _f(String key, [String fallback = '']) =>
      _customerData[key]?.toString() ?? fallback;

  /// True when this screen is creating a brand-new customer (no existing
  /// customer_id on the server), false when editing an existing one.
  bool get _isNewCustomer =>
      widget.customerId == 'new' ||
      widget.customerId.isEmpty ||
      int.tryParse(widget.customerId) == null;
  String get _boxNumber => _f(
      'boxNumber',
      _f(
        'box_number',
        _f(
          'serialNumber',
          _f(
            'serial_number',
            _f('stbNo', _f('stb_no', _f('stbNumber', _f('boxNo', '')))),
          ),
        ),
      ));
  String get _vcNumber =>
      _f('vcNumber', _f('vcNo', _f('vc_no', _f('vc_number', ''))));
  bool get _hasVc {
    final vc = _vcNumber.trim().toLowerCase();
    return vc.isNotEmpty && vc != 'anytype{}' && vc != 'null' && vc != '0';
  }
  bool get _isVcExplicitlyMissing =>
      _vcNumber.trim().isNotEmpty && !_hasVc;

  List<_BillTypeOption> _billTypeOptions(AppSession? session) {
    switch (session?.customerBilltype) {
      case 0:
        return const [
          _BillTypeOption(value: 1, label: 'Advance Billing'),
          _BillTypeOption(value: 2, label: 'Postpaid'),
        ];
      case 2:
        return const [_BillTypeOption(value: 1, label: 'Advance Billing')];
      case 3:
        return const [_BillTypeOption(value: 2, label: 'Postpaid')];
      default:
        return const [_BillTypeOption(value: 2, label: 'Postpaid')];
    }
  }

  bool _showCafField(AppSession? session) =>
      (session?.useCRF == 1) && (session?.useCAF == 'MANUAL');

  bool _showAccountNumber(AppSession? session) => session?.useAccountNumber == 0;

  String _cafLabel(AppSession? session) =>
      session?.useCRF == 1 ? 'CAF Number' : 'CRF Number';

  @override
  void initState() {
    super.initState();
    _customerData = Map<String, dynamic>.from(widget.customer);

    // Always create controllers (even with empty text) to avoid late init errors
    _initControllers();

    // If customer map is empty (GoRouter extra lost), fetch from API
    if (_customerData.isEmpty && !_isNewCustomer) {
      _isLoadingCustomer = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadCustomerFromApi());
    } else {
      // Load master data
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadMasterData();
      });
    }
  }

  /// Fetch customer details from API when widget.customer is empty.
  Future<void> _loadCustomerFromApi() async {
    try {
      final ds = ref.read(customerRemoteDatasourceProvider);
      final session = ref.read(appSessionProvider);
      final data = await ds.getCustomerDetails(
        authtoken: session?.token ?? '',
        lcoCustomerId: widget.customerId,
        startValue: 0,
        endValue: 1,
      );

      Map<String, dynamic>? found;
      for (final key in [
        'customerDetailsList',
        'existCustomerDetails',
        'customerDetails',
        'data',
      ]) {
        final raw = data[key];
        if (raw is List && raw.isNotEmpty) {
          found = raw[0] as Map<String, dynamic>;
          break;
        }
        // PHP json_encode may return a Map ({"0":{...}}) instead of a List
        // when there is exactly 1 result.
        if (raw is Map && raw.isNotEmpty) {
          final first = raw.values.first;
          if (first is Map<String, dynamic>) {
            found = first;
          } else if (first is Map) {
            found = Map<String, dynamic>.from(first);
          }
          break;
        }
      }

      if (mounted) {
        _customerData = found ?? {'customer_id': widget.customerId};
        _refreshFieldsFromData();
        setState(() => _isLoadingCustomer = false);
        _loadMasterData();
      }
    } catch (e) {
      debugPrint('[EDIT] Failed to load customer from API: $e');
      if (mounted) {
        _customerData = {'customer_id': widget.customerId};
        setState(() => _isLoadingCustomer = false);
        _loadMasterData();
      }
    }
  }

  /// Helper: read a value trying multiple key variants (server uses mixed casing).
  String _fMulti(List<String> keys, [String fallback = '']) {
    for (final k in keys) {
      final v = _customerData[k];
      if (v != null && v.toString().isNotEmpty) return v.toString();
    }
    return fallback;
  }

  /// Create controllers with current _customerData values.
  void _initControllers() {
    final nameInfo = _parseName();

    _firstNameCtrl = TextEditingController(text: nameInfo.$1);
    _lastNameCtrl = TextEditingController(text: nameInfo.$2);
    _mobileCtrl = TextEditingController(
      text: _fMulti(['mobile_no', 'mobileNumber', 'mobile_number']),
    );
    _emailCtrl = TextEditingController(
      text: _fMulti(['email', 'emailId', 'email_id']),
    );
    _idNumberCtrl = TextEditingController(
      text: _fMulti(['idNumber', 'id_number']),
    );
    _lcoCustomerIdCtrl = TextEditingController(
      text: _fMulti(['baid', 'lcoCustomerId', 'lco_customer_id']),
    );
    _cafNumberCtrl = TextEditingController(
      text: _fMulti(['caf_no', 'cafNumber', 'caf_number']),
    );
    _groupNameCtrl = TextEditingController(
      text: _fMulti(['group_name', 'groupName']),
    );
    _fatherNameCtrl = TextEditingController(
      text: _fMulti(['fatherName', 'father_name']),
    );
    _businessNameCtrl = TextEditingController(
      text: _fMulti(['businessName', 'business_name']),
    );
    _accountNumberCtrl = TextEditingController(
      text: _fMulti(['accountnumber', 'account_number', 'accountNumber']),
    );
    _remarksCtrl = TextEditingController(text: _fMulti(['remarks']));
    _phoneCtrl = TextEditingController(
      text: _fMulti(['phone_no', 'phoneNumber', 'phone', 'phone_number']),
    );
    _dobCtrl = TextEditingController(
      text: _fMulti(['dateOfBirth', 'date_of_birth', 'dob'], '0000-00-00'),
    );
    _anniversaryCtrl = TextEditingController(
      text: _fMulti(['anniversaryDate', 'anniversary_date'], '0000-00-00'),
    );
    _signupDateCtrl = TextEditingController(
      text: _fMulti(['signup_date', 'signupDate', 'created_date']),
    );

    _billingAddress1Ctrl = TextEditingController(
      text: _fMulti(['address1', 'billingAddress1', 'billing_address1', 'billingAddress', 'billing_address']),
    );
    _billingAddress2Ctrl = TextEditingController(
      text: _fMulti(['address2', 'billingAddress2', 'billing_address2']),
    );
    _billingPinCodeCtrl = TextEditingController(
      text: _fMulti(['pin_code', 'pinCode', 'pincode']),
    );

    _installAddress1Ctrl = TextEditingController(
      text: _fMulti(['installationAddress1', 'installation_address1', 'installationAddress', 'installation_address']),
    );
    _installAddress2Ctrl = TextEditingController(
      text: _fMulti(['installationAddress2', 'installation_address2']),
    );
    _installPinCodeCtrl = TextEditingController(
      text: _fMulti(['installPinCode', 'install_pin_code']),
    );

    // Pre-select dropdown values from customer data
    _selectedGenderId = _fMulti(['gender', 'genderId', 'gender_id']);
    _selectedCustomerTypeId = _fMulti(['customerTypeId', 'customer_type_id']);
    _selectedGroupId = _fMulti(['groupId', 'group_id']);
    _selectedIdTypeId = _fMulti(['idType', 'id_type']);
    _selectedBillType = int.tryParse(_fMulti(['bill_type', 'billType']));
  }

  /// Parse name from customer data → (firstName, lastName).
  (String, String) _parseName() {
    final fullName = _fMulti(['customer_name', 'customerName']);
    final parts = fullName.trim().split(RegExp(r'\s+'));
    final rawFirst = _fMulti(['firstName', 'first_name'],
        parts.isNotEmpty ? parts.first : '');
    final rawLast = _fMulti(['lastName', 'last_name'],
        parts.length > 1 ? parts.sublist(1).join(' ') : '');

    // For new customers, discard generic placeholder names
    if (_isNewCustomer) {
      return (
        (rawFirst == 'Customer' || rawFirst == 'Unknown') ? '' : rawFirst,
        (rawLast == 'Customer' || rawLast == 'Unknown') ? '' : rawLast,
      );
    }
    return (rawFirst, rawLast);
  }

  /// Update controller text values after _customerData changes (API load).
  void _refreshFieldsFromData() {
    final nameInfo = _parseName();
    _firstNameCtrl.text = nameInfo.$1;
    _lastNameCtrl.text = nameInfo.$2;
    _mobileCtrl.text = _fMulti(['mobile_no', 'mobileNumber', 'mobile_number']);
    _emailCtrl.text = _fMulti(['email', 'emailId', 'email_id']);
    _idNumberCtrl.text = _fMulti(['idNumber', 'id_number']);
    _lcoCustomerIdCtrl.text = _fMulti(['baid', 'lcoCustomerId', 'lco_customer_id']);
    _cafNumberCtrl.text = _fMulti(['caf_no', 'cafNumber', 'caf_number']);
    _groupNameCtrl.text = _fMulti(['group_name', 'groupName']);
    _fatherNameCtrl.text = _fMulti(['fatherName', 'father_name']);
    _businessNameCtrl.text = _fMulti(['businessName', 'business_name']);
    _accountNumberCtrl.text = _fMulti(['accountnumber', 'account_number', 'accountNumber']);
    _remarksCtrl.text = _fMulti(['remarks']);
    _phoneCtrl.text = _fMulti(['phone_no', 'phoneNumber', 'phone', 'phone_number']);
    _dobCtrl.text = _fMulti(['dateOfBirth', 'date_of_birth', 'dob'], '0000-00-00');
    _anniversaryCtrl.text = _fMulti(['anniversaryDate', 'anniversary_date'], '0000-00-00');
    _signupDateCtrl.text = _fMulti(['signup_date', 'signupDate', 'created_date']);
    _billingAddress1Ctrl.text = _fMulti(['address1', 'billingAddress1', 'billing_address1', 'billingAddress', 'billing_address']);
    _billingAddress2Ctrl.text = _fMulti(['address2', 'billingAddress2', 'billing_address2']);
    _billingPinCodeCtrl.text = _fMulti(['pin_code', 'pinCode', 'pincode']);
    _installAddress1Ctrl.text = _fMulti(['installationAddress1', 'installation_address1', 'installationAddress', 'installation_address']);
    _installAddress2Ctrl.text = _fMulti(['installationAddress2', 'installation_address2']);
    _installPinCodeCtrl.text = _fMulti(['installPinCode', 'install_pin_code']);

    setState(() {
      _selectedGenderId = _fMulti(['gender', 'genderId', 'gender_id']);
      _selectedCustomerTypeId = _fMulti(['customerTypeId', 'customer_type_id']);
      _selectedGroupId = _fMulti(['groupId', 'group_id']);
      _selectedIdTypeId = _fMulti(['idType', 'id_type']);
      _selectedBillType = int.tryParse(_fMulti(['bill_type', 'billType']));
    });
  }

  Future<void> _loadMasterData() async {
    try {
      final notifier = ref.read(masterDataProvider.notifier);
      await notifier.initialise();
      await Future.wait([
        notifier.loadCustomerTypes(),
        notifier.loadGroups(serialNumber: _boxNumber),
        notifier.loadIdTypes(),
      ]);
      final md = ref.read(masterDataProvider);
      final selectedGroup =
          _findGroup(md.groups) ?? md.selectedGroup ?? (md.groups.length == 1 ? md.groups.first : null);
      if (selectedGroup != null && selectedGroup.groupName.trim().isNotEmpty) {
        _groupNameCtrl.text = selectedGroup.groupName.trim();
        _selectedGroupId = selectedGroup.groupId.toString();
      }
      // Sync billing address fields from master data defaults for new customers.
      // initialise() auto-selects default country/state/district/city from session
      // but those are in the provider, not the local edit screen state.
      if (_isNewCustomer) {
        final mdSync = ref.read(masterDataProvider);
        if (_billingCountry == null && mdSync.selectedCountry != null) {
          _billingCountry = mdSync.selectedCountry;
        }
        if (_billingState == null && mdSync.selectedState != null) {
          _billingState = mdSync.selectedState;
        }
        if (_billingDistrict == null && mdSync.selectedDistrict != null) {
          _billingDistrict = mdSync.selectedDistrict;
        }
        if (_billingCity == null && mdSync.selectedCity != null) {
          _billingCity = mdSync.selectedCity;
        }
        if (_billingMandal == null && mdSync.selectedMandal != null) {
          _billingMandal = mdSync.selectedMandal;
        }
      }
      if (_boxNumber.trim().isNotEmpty) {
        await _loadPackages();
      }
      if (mounted) {
        setState(() => _masterDataLoaded = true);
      }
    } catch (e) {
      if (mounted) {
        _showApiError(
          'Failed to load customer master data. Please retry.',
          details: e.toString(),
        );
      }
    }
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _mobileCtrl.dispose();
    _emailCtrl.dispose();
    _idNumberCtrl.dispose();
    _lcoCustomerIdCtrl.dispose();
    _cafNumberCtrl.dispose();
    _groupNameCtrl.dispose();
    _fatherNameCtrl.dispose();
    _businessNameCtrl.dispose();
    _accountNumberCtrl.dispose();
    _remarksCtrl.dispose();
    _phoneCtrl.dispose();
    _dobCtrl.dispose();
    _anniversaryCtrl.dispose();
    _signupDateCtrl.dispose();
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
        'mobile': _mobileCtrl.text.trim(),
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
      final selectedGroup = _findGroup(masterState.groups);
      if (selectedGroup != null && selectedGroup.groupId > 0) {
        data['group'] = selectedGroup.groupId.toString();
        data['groupId'] = selectedGroup.groupId.toString();
        if (selectedGroup.groupName.trim().isNotEmpty) {
          data['groupName'] = selectedGroup.groupName.trim();
        }
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
      if (_selectedBillType != null) {
        data['billType'] = _selectedBillType.toString();
      }
      if (_remarksCtrl.text.trim().isNotEmpty) {
        data['remarks'] = _remarksCtrl.text.trim();
      }
      if (_phoneCtrl.text.trim().isNotEmpty) {
        data['phone'] = _phoneCtrl.text.trim();
      }
      if (_dobCtrl.text.trim().isNotEmpty &&
          _dobCtrl.text.trim() != '0000-00-00') {
        data['dateOfBirth'] = _dobCtrl.text.trim();
      }
      if (_anniversaryCtrl.text.trim().isNotEmpty &&
          _anniversaryCtrl.text.trim() != '0000-00-00') {
        data['anniversaryDate'] = _anniversaryCtrl.text.trim();
      }
      if (_customerPhotoBase64 != null) {
        data['customerPhoto'] = _customerPhotoBase64;
      }
      if (_idProofPhotoBase64 != null) {
        data['idProofPhoto'] = _idProofPhotoBase64;
      }
      if (_signaturePhotoBase64 != null) {
        data['signaturePhoto'] = _signaturePhotoBase64;
      }
      if (_selectedPackage != null) {
        data['packageId'] = _selectedPackage!.productId;
      }
      if (_lcoCustomerIdCtrl.text.trim().isNotEmpty) {
        data['lcoCustomerId'] = _lcoCustomerIdCtrl.text.trim();
      }
      if (_showCafField(session) && _cafNumberCtrl.text.trim().isNotEmpty) {
        data['cafNumber'] = _cafNumberCtrl.text.trim();
      }

      // Address (single shared geo set — matches old app layout)
      data['change_addrs'] = '1';
      data['address'] = _billingAddress1Ctrl.text.trim();
      data['address2'] = _billingAddress2Ctrl.text.trim();
      data['pin'] = _billingPinCodeCtrl.text.trim();
      data['pinCode'] = _billingPinCodeCtrl.text.trim();
      data['country'] = _billingCountry?.iso ?? '';
      data['countryCode'] = _billingCountry?.iso ?? '';
      data['state'] = _billingState?.id.toString() ?? '';
      data['stateId'] = _billingState?.id.toString() ?? '';
      data['district'] = _billingDistrict?.id.toString() ?? '';
      data['districtId'] = _billingDistrict?.id.toString() ?? '';
      data['city'] = _billingCity?.locationId.toString() ?? '';
      data['cityId'] = _billingCity?.locationId.toString() ?? '';
      data['mandal'] = _billingMandal?.mandalId.toString() ?? '';
      data['mandalId'] = _billingMandal?.mandalId.toString() ?? '';

      // Installation address
      final installAddr = _sameAsBilling
          ? _billingAddress1Ctrl.text.trim()
          : _installAddress1Ctrl.text.trim();
      data['installationAddress'] = installAddr;
      data['installation_address'] = installAddr;

      // Upload docs
      data['uploadDocs'] = _uploadDocs;

      // ── Required server fields ────────────────────────────────────────────
      // reseller_id: The backend checkCity validation uses this as
      // lcm.employee_id in eb_location_lco_mapping. For NEW customers it MUST
      // be the logged-in employee's ID (not the dealer ID). For EXISTING
      // customers being edited, keep the stored value.
      final resellerId = _isNewCustomer
          ? session.employeeId.toString()
          : _customerData['reseller_id']?.toString().isNotEmpty == true
              ? _customerData['reseller_id'].toString()
              : _customerData['resellerId']?.toString().isNotEmpty == true
                  ? _customerData['resellerId'].toString()
                  : session.employeeId.toString();
      data['reseller_id'] = resellerId;

      // dealer_id and employee_id — belt-and-suspenders for server validation
      if (session.dealerId > 0) {
        data['dealer_id'] = session.dealerId.toString();
      }
      if (session.employeeId > 0) {
        data['employee_id'] = session.employeeId.toString();
      }

      debugPrint('[EDIT_CUSTOMER] dealerId=${session.dealerId} '
          'employeeId=${session.employeeId} '
          'resellerId=$resellerId '
          'customerId=${widget.customerId} '
          'keys=${data.keys.toList()}');

      // ── CRITICAL: Route to correct API endpoint ───────────────────────────
      // customerId == 'new' (or non-numeric) means this is a FRESH STB with no
      // existing customer record. Must call saveCustomerRest, NOT editCustomerRest.
      // editCustomerRest with customerId='new' always returns
      // "Dealer or Employee does not exist (statusCode:1)".
      if (_isNewCustomer) {
        // ── New customer path → saveCustomerRest ──────────────────────────
        // Simplified: send raw UI values directly (matches old app behaviour).
        data.remove('customerId');
        data.remove('change_addrs');
        data.remove('uploadDocs');

        // ── STB serial + VC from the customer map ────────────────────────
        final boxNo = _customerData['box_number']?.toString() ??
            _customerData['serial_no']?.toString() ??
            _customerData['stb_no']?.toString() ??
            _customerData['boxNumber']?.toString() ??
            _customerData['serialNumber']?.toString() ?? '';
        final vcNo = _customerData['vc_number']?.toString() ??
            _customerData['vc_no']?.toString() ??
            _customerData['vcNumber']?.toString() ?? '';
        if (boxNo.isNotEmpty) data['boxNumber'] = boxNo;
        if (vcNo.isNotEmpty) data['vcNumber'] = vcNo;

        data['mobileNumber'] = _mobileCtrl.text.trim();
        if (!data.containsKey('billType')) data['billType'] = '1';
        if (resellerId.isNotEmpty) {
          data['resellerId'] = resellerId;
          data['reseller_id'] = resellerId;
        }

        // ── CRITICAL PAYLOAD DUMP (uses print() — cannot be filtered) ────
        print('========== SAVE_CUSTOMER PAYLOAD ==========');
        print('  country   = ${data["country"]}');
        print('  state     = ${data["state"]}');
        print('  district  = ${data["district"]}');
        print('  mandal    = ${data["mandal"]}');
        print('  city      = ${data["city"]}');
        print('  cityId    = ${data["cityId"]}');
        print('  pin       = ${data["pin"]}');
        print('  address   = ${data["address"]}');
        print('  installationAddress = ${data["installationAddress"]}');
        print('  boxNumber = ${data["boxNumber"]}');
        print('  vcNumber  = ${data["vcNumber"]}');
        print('  firstName = ${data["firstName"]}');
        print('  mobile    = ${data["mobile"]}');
        print('  group     = ${data["group"]}');
        print('  billType  = ${data["billType"]}');
        print('  resellerId= ${data["resellerId"]}');
        print('  _billingCity      = ${_billingCity?.locationId}/${_billingCity?.locationName}');
        print('  _billingMandal    = ${_billingMandal?.mandalId}/${_billingMandal?.mandalName}');
        print('  _billingState     = ${_billingState?.id}/${_billingState?.name}');
        print('  _billingDistrict  = ${_billingDistrict?.id}/${_billingDistrict?.name}');
        print('  ALL KEYS: ${data.keys.toList()}');
        print('============================================');

        await ds.saveCustomer(
          authtoken: session.token,
          customerData: data,
        );

        if (mounted) {
          AppToast.show(context, message: 'Customer created successfully!');
          context.pop(true);
        }
      } else {
        // ── Existing customer path → editCustomerRest ─────────────────────
        await ds.editCustomer(
          authtoken: session.token,
          customerData: data,
        );

        if (mounted) {
          AppToast.show(context, message: 'Customer updated successfully');
          context.pop(true);
        }
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

  // (Install address cascading loaders removed — single shared geo set)

  Future<void> _loadPackages() async {
    final box = _boxNumber.trim();
    if (box.isEmpty) {
      setState(() {
        _packages = [];
        _packagesError = 'STB number not available for package lookup';
      });
      return;
    }
    setState(() {
      _packagesLoading = true;
      _packagesError = null;
    });
    try {
      final session = ref.read(appSessionProvider);
      final ds = PackageRemoteDatasource(dio: ref.read(dioClientProvider));
      final data = await ds.getCasPackages(
        authtoken: session?.token ?? '',
        boxNumber: box,
      );
      final rawList = (data['caspackageList'] as List?) ??
          (data['casPackagesList'] as List?) ??
          (data['data'] as List?) ??
          const [];
      final list = rawList
          .whereType<Map<String, dynamic>>()
          .map(CasPackage.fromJson)
          .toList();
      if (mounted) {
        setState(() {
          _packages = list;
          _selectedPackage = _selectedPackage != null
              ? list.where((p) => p.productId == _selectedPackage!.productId).firstOrNull
              : null;
          _packagesLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _packagesLoading = false;
          _packagesError = e.toString().replaceAll('ApiException: ', '');
        });
      }
    }
  }

  Future<void> _ensureCustomerTypesLoaded() async {
    final notifier = ref.read(masterDataProvider.notifier);
    if (ref.read(masterDataProvider).customerTypes.isEmpty) {
      await notifier.loadCustomerTypes();
    }
  }

  Future<void> _ensureGroupsLoaded() async {
    final notifier = ref.read(masterDataProvider.notifier);
    if (ref.read(masterDataProvider).groups.isEmpty) {
      await notifier.loadGroups(serialNumber: _boxNumber);
    }
    final groups = ref.read(masterDataProvider).groups;
    final selectedGroup =
        _findGroup(groups) ?? (groups.length == 1 ? groups.first : null);
    if (selectedGroup != null && mounted) {
      setState(() {
        _selectedGroupId = selectedGroup.groupId.toString();
        _groupNameCtrl.text = selectedGroup.groupName;
      });
    }
  }

  Future<void> _ensureIdTypesLoaded() async {
    final notifier = ref.read(masterDataProvider.notifier);
    if (ref.read(masterDataProvider).idTypes.isEmpty) {
      await notifier.loadIdTypes();
    }
  }

  Future<void> _ensureBillingDistrictsLoaded() async {
    if (_billingState == null) {
      _showApiError('Please select state first');
      return;
    }
    final notifier = ref.read(masterDataProvider.notifier);
    final md = ref.read(masterDataProvider);
    if (md.districts.isEmpty || md.selectedState?.id != _billingState!.id) {
      await notifier.loadDistricts(_billingState!.id.toString());
    }
  }

  Future<void> _ensureBillingCitiesLoaded() async {
    if (_billingDistrict == null) {
      _showApiError('Please select district first');
      return;
    }
    final notifier = ref.read(masterDataProvider.notifier);
    // loadCitiesForMandal uses getLocationsOfDistrictRest, filtered by mandal_id when mandal is set.
    final mandalId = _billingMandal?.mandalId.toString() ?? '0';
    await notifier.loadCitiesForMandal(
      districtId: _billingDistrict!.id.toString(),
      mandalId: mandalId,
      boxNumber: _boxNumber,
    );
  }

  Future<void> _ensureBillingMandalsLoaded() async {
    if (_billingDistrict == null) {
      _showApiError('Please select district first');
      return;
    }
    final notifier = ref.read(masterDataProvider.notifier);
    final md = ref.read(masterDataProvider);
    if (md.mandals.isEmpty || md.selectedDistrict?.id != _billingDistrict!.id) {
      await notifier.loadMandals(
        _billingDistrict!.id.toString(),
        stateId: _billingState?.id.toString() ?? '',
        boxNumber: _boxNumber,
        serialNumber: _boxNumber,
      );
    }
  }

  Future<T?> _openSelectionDialog<T>({
    required String title,
    required List<T> items,
    required String Function(T) displayName,
    bool enableSearch = true,
  }) async {
    return showDialog<T>(
      context: context,
      builder: (ctx) {
        return _SelectionDialogContent<T>(
          title: title,
          items: items,
          displayName: displayName,
          enableSearch: enableSearch,
        );
      },
    );
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

  void _showApiError(String fallback, {String? details}) {
    final c = Theme.of(context).extension<AppColors>()!;
    final raw = (details ?? '').replaceAll('ApiException: ', '').trim();
    final message = raw.isNotEmpty ? raw : fallback;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
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

  // ── Build ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;
    final tt = Theme.of(context).textTheme;
    final session = ref.watch(appSessionProvider);
    final masterState = ref.watch(masterDataProvider);
    final isFrozen = session?.isCustomerFrozen == true;
    final showLastName = session?.useLastName == 1;
    final showAccountNumber = true;
    final lockAccountNumber = (session?.useAccountNumber ?? 0) > 0;
    final showCaf = _showCafField(session);
    final billTypeOptions = _billTypeOptions(session);
    final isLastNameMandatory = masterState.isFieldMandatory('last_name');
    final isEmailMandatory = masterState.isFieldMandatory('email');
    final isIdTypeMandatory = masterState.isFieldMandatory('id_type');
    final isIdNumberMandatory = masterState.isFieldMandatory('id_number');
    final isMobileMandatory = masterState.isFieldMandatory('mobile_no');
    final isBaidMandatory = masterState.isFieldMandatory('baid');
    final isMandalMandatory = masterState.isFieldMandatory('mandal_id');

    final lcoIdMandatory = (session?.useCAF == 'MANUAL') || isBaidMandatory;
    if (_selectedBillType == null && billTypeOptions.isNotEmpty) {
      _selectedBillType = billTypeOptions.first.value;
    }

    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(
        title: Text(_isNewCustomer ? 'Create Customer' : 'Edit Customer', style: tt.titleMedium),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.pop(),
        ),
      ),
      body: (_isLoadingCustomer || !_masterDataLoaded)
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
                    required: true,
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
                      required: isLastNameMandatory,
                      readOnly: isFrozen,
                      validator: isLastNameMandatory
                          ? (v) => validateRequired(v, 'Last name')
                          : null,
                    ),
                  ],
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _mobileCtrl,
                    label: 'Mobile Number',
                    hint: 'Enter 10-digit mobile',
                    colors: c,
                    required: true,
                    readOnly: isFrozen,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                    validator: (v) {
                      final mobileErr = validateMobile(v);
                      if (mobileErr != null) return mobileErr;
                      if (isMobileMandatory &&
                          (v == null || v.trim().length < 10)) {
                        return 'Mobile number should not be less than 10 digits';
                      }
                      return null;
                    },
                    maxLength: 10,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _emailCtrl,
                    label: 'Email',
                    hint: 'Enter email address',
                    colors: c,
                    required: isEmailMandatory,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return null;
                      if (isEmailMandatory &&
                          !_androidEmailRegex.hasMatch(v.trim())) {
                        return 'Email Id pattern is Invalid';
                      }
                      return validateEmail(v);
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _phoneCtrl,
                    label: 'Phone',
                    hint: 'Enter phone number',
                    colors: c,
                    keyboardType: TextInputType.phone,
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
                  _buildDialogSelector<CustomerType>(
                    label: 'Customer Type',
                    required: true,
                    value: _findCustomerType(masterState.customerTypes),
                    items: masterState.customerTypes,
                    displayName: (ct) => ct.customerType,
                    isLoading: masterState.isLoadingCustomerTypes,
                    onBeforeOpen: _ensureCustomerTypesLoaded,
                    onSelected: (ct) => setState(
                      () => _selectedCustomerTypeId = ct.customerTypeId.toString(),
                    ),
                    colors: c,
                  ),
                  const SizedBox(height: 12),
                  _buildDialogSelector<GroupModel>(
                    label: 'Group',
                    required: true,
                    value: _findGroup(masterState.groups),
                    items: masterState.groups,
                    latestItems: () => ref.read(masterDataProvider).groups,
                    displayName: (g) => g.groupName,
                    isLoading: masterState.isLoadingGroups,
                    onBeforeOpen: _ensureGroupsLoaded,
                    enableSearch: false,
                    onSelected: (g) => setState(() {
                      _selectedGroupId = g.groupId.toString();
                      _groupNameCtrl.text = g.groupName;
                    }),
                    colors: c,
                    validator: (g) => g == null ? 'Please select Group' : null,
                  ),
                  const SizedBox(height: 12),
                  _buildDialogSelector<IdType>(
                    label: 'ID Type',
                    required: isIdTypeMandatory,
                    value: _findIdType(masterState.idTypes),
                    items: masterState.idTypes,
                    displayName: (it) => it.name,
                    isLoading: masterState.isLoadingIdTypes,
                    onBeforeOpen: _ensureIdTypesLoaded,
                    onSelected: (it) => setState(
                      () => _selectedIdTypeId = it.id.toString(),
                    ),
                    colors: c,
                    validator: isIdTypeMandatory
                        ? (it) => it == null ? 'Please select ID Type' : null
                        : null,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _idNumberCtrl,
                    label: 'ID Number',
                    hint: 'Enter ID number',
                    colors: c,
                    required: isIdNumberMandatory,
                    validator: isIdNumberMandatory
                        ? (v) => validateRequired(v, 'ID number')
                        : null,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _lcoCustomerIdCtrl,
                    label: session?.baidLabel ?? 'LCO Customer ID',
                    hint: 'Enter ${session?.baidLabel ?? 'LCO customer ID'}',
                    colors: c,
                    required: lcoIdMandatory,
                    validator: lcoIdMandatory
                        ? (v) => (v == null || v.trim().length < 2)
                            ? 'Lco customer id shouldnot be empty'
                            : null
                        : null,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _fatherNameCtrl,
                    label: 'Father Name',
                    hint: 'Enter father name',
                    colors: c,
                  ),
                  if (showCaf) ...[
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _cafNumberCtrl,
                      label: _cafLabel(session),
                      hint: 'Enter ${_cafLabel(session)}',
                      colors: c,
                      required: true,
                      validator: (v) {
                        if (v == null || v.trim().length < 2) {
                          return '${_cafLabel(session)} shouldnot be empty';
                        }
                        return null;
                      },
                    ),
                  ],
                  if (_signupDateCtrl.text.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _signupDateCtrl,
                      label: 'Signup Date (YYYY-MM-DD HH:MM:SS)',
                      hint: '',
                      colors: c,
                      readOnly: true,
                    ),
                  ],
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
                      required: (session?.useAccountNumber ?? 0) == 0,
                      readOnly: lockAccountNumber,
                      validator: (session?.useAccountNumber ?? 0) == 0
                          ? (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Account number shouldnot be empty';
                              }
                              return null;
                            }
                          : null,
                    ),
                  ],
                  const SizedBox(height: 12),
                  _buildDropdown<_BillTypeOption>(
                    label: 'Bill Type',
                    value: billTypeOptions
                        .where((o) => o.value == _selectedBillType)
                        .firstOrNull,
                    items: billTypeOptions,
                    displayName: (o) => o.label,
                    onChanged: (o) =>
                        setState(() => _selectedBillType = o?.value),
                    colors: c,
                  ),

                  const SizedBox(height: 24),

                  // ── Address Section (old-app layout: single geo set) ──
                  _buildSectionHeader('Address', c),
                  const SizedBox(height: 8),
                  // Address 1 *
                  _buildTextField(
                    controller: _billingAddress1Ctrl,
                    label: 'Address 1',
                    hint: 'Enter address line 1',
                    colors: c,
                    required: true,
                    validator: (v) => validateRequired(v, 'Address line 1'),
                  ),
                  const SizedBox(height: 12),
                  // Address 2
                  _buildTextField(
                    controller: _billingAddress2Ctrl,
                    label: 'Address 2',
                    hint: 'Enter address line 2',
                    colors: c,
                  ),
                  const SizedBox(height: 12),
                  // Change Installation Address
                  _buildCheckbox(
                    label: 'Change Installation Address',
                    value: !_sameAsBilling,
                    onChanged: (v) {
                      setState(() => _sameAsBilling = !(v ?? false));
                      if (!(v ?? false)) {
                        _installAddress1Ctrl.text =
                            _billingAddress1Ctrl.text;
                        _installAddress2Ctrl.text =
                            _billingAddress2Ctrl.text;
                      }
                    },
                    colors: c,
                  ),
                  const SizedBox(height: 12),
                  // Installation Add 1 *
                  _buildTextField(
                    controller: _installAddress1Ctrl,
                    label: 'Installation Add 1',
                    hint: 'Enter installation address',
                    colors: c,
                    required: true,
                    readOnly: _sameAsBilling,
                    validator: (v) {
                      if (_sameAsBilling) return null;
                      return validateRequired(v, 'Installation address');
                    },
                  ),
                  const SizedBox(height: 12),
                  // Installation Add 2
                  _buildTextField(
                    controller: _installAddress2Ctrl,
                    label: 'Installation Add 2',
                    hint: 'Enter installation address line 2',
                    colors: c,
                    readOnly: _sameAsBilling,
                  ),
                  const SizedBox(height: 12),
                  // Country *
                  _buildDialogSelector<Country>(
                    label: 'Country',
                    required: true,
                    value: _billingCountry,
                    items: masterState.countries,
                    latestItems: () =>
                        ref.read(masterDataProvider).countries,
                    displayName: (co) => co.name,
                    isLoading: masterState.isLoadingCountries,
                    onSelected: (co) {
                      setState(() {
                        _billingCountry = co;
                        _billingState = null;
                        _billingDistrict = null;
                        _billingCity = null;
                        _billingMandal = null;
                      });
                      ref
                          .read(masterDataProvider.notifier)
                          .selectCountry(co);
                    },
                    colors: c,
                  ),
                  const SizedBox(height: 12),
                  // State *
                  _buildDialogSelector<StateModel>(
                    label: 'State',
                    required: true,
                    value: _billingState,
                    items: masterState.states,
                    latestItems: () =>
                        ref.read(masterDataProvider).states,
                    displayName: (s) => s.name,
                    isLoading: masterState.isLoadingStates,
                    onSelected: (s) {
                      setState(() {
                        _billingState = s;
                        _billingDistrict = null;
                        _billingCity = null;
                        _billingMandal = null;
                      });
                      ref
                          .read(masterDataProvider.notifier)
                          .selectState(s);
                    },
                    colors: c,
                  ),
                  const SizedBox(height: 12),
                  // District *
                  _buildDialogSelector<District>(
                    label: 'District',
                    required: true,
                    value: _billingDistrict,
                    items: masterState.districts,
                    latestItems: () =>
                        ref.read(masterDataProvider).districts,
                    displayName: (d) => d.name,
                    isLoading: masterState.isLoadingDistricts,
                    onBeforeOpen: _ensureBillingDistrictsLoaded,
                    enableSearch: false,
                    onSelected: (d) {
                      setState(() {
                        _billingDistrict = d;
                        _billingCity = null;
                        _billingMandal = null;
                      });
                      ref.read(masterDataProvider.notifier).selectDistrict(d);
                    },
                    colors: c,
                  ),
                  const SizedBox(height: 12),
                  // Mandal (optional — if not selected, City shows all)
                  _buildDialogSelector<Mandal>(
                    label: 'Mandal',
                    required: isMandalMandatory,
                    value: _billingMandal,
                    items: masterState.mandals,
                    latestItems: () => ref.read(masterDataProvider).mandals,
                    displayName: (m) => m.mandalName,
                    isLoading: masterState.isLoadingMandals,
                    onBeforeOpen: _ensureBillingMandalsLoaded,
                    enableSearch: false,
                    onSelected: (m) async {
                      setState(() {
                        _billingMandal = m;
                        _billingCity = null;
                      });
                      ref.read(masterDataProvider.notifier).selectMandal(m);
                      await ref.read(masterDataProvider.notifier).loadCitiesForMandal(
                            districtId: _billingDistrict!.id.toString(),
                            mandalId: m.mandalId.toString(),
                            boxNumber: _boxNumber,
                          );
                    },
                    colors: c,
                    validator: isMandalMandatory
                        ? (m) => m == null ? 'Please select mandal' : null
                        : null,
                  ),
                  const SizedBox(height: 12),
                  // City *
                  _buildDialogSelector<City>(
                    label: 'City',
                    required: true,
                    value: _billingCity,
                    items: masterState.cities,
                    latestItems: () => ref.read(masterDataProvider).cities,
                    displayName: (ci) => ci.locationName,
                    isLoading: masterState.isLoadingCities,
                    onBeforeOpen: _ensureBillingCitiesLoaded,
                    enableSearch: false,
                    onSelected: (ci) => setState(() => _billingCity = ci),
                    colors: c,
                  ),
                  const SizedBox(height: 12),
                  // PIN Code *
                  _buildTextField(
                    controller: _billingPinCodeCtrl,
                    label: 'PIN Code',
                    hint: 'Enter 6-digit PIN code',
                    colors: c,
                    required: true,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'PIN code is required';
                      }
                      return validatePinCode(v);
                    },
                  ),

                  const SizedBox(height: 24),

                  // ── Packages Section ──────────────────────────────────
                  _buildSectionHeader('Packages', c),
                  const SizedBox(height: 12),
                  if (_isVcExplicitlyMissing)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: c.amberSoft,
                        borderRadius: AppRadius.smBR,
                        border: Border.all(color: c.amber.withValues(alpha: 0.25)),
                      ),
                      child: Text(
                        'VC number is invalid for this STB. Customer update is allowed, package selection is disabled.',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: c.ink80,
                        ),
                      ),
                    )
                  else if (_packagesLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: LinearProgressIndicator(),
                    )
                  else if (_packagesError != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _packagesError!,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: c.red,
                          ),
                        ),
                        const SizedBox(height: 8),
                        OutlinedButton.icon(
                          onPressed: _loadPackages,
                          icon: const Icon(LucideIcons.refreshCw, size: 16),
                          label: const Text('Retry Packages'),
                        ),
                      ],
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                                    if (_packages.isEmpty && !_packagesLoading) {
                                      await _loadPackages();
                                    }
                                    if (!mounted) return;
                                    if (_packagesLoading) return;
                                    if (_packages.isEmpty) {
                                      _showApiError(
                                        'No packages available for this STB',
                                        details: _packagesError,
                                      );
                                      return;
                                    }
                                    final selected =
                                        await _openSelectionDialog<CasPackage>(
                                      title: 'SELECT BASE PACKAGE',
                                      items: _packages,
                                      displayName: (p) => p.productName,
                                    );
                                    if (selected != null && mounted) {
                                      setState(() => _selectedPackage = selected);
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: c.blue,
                              foregroundColor: c.card,
                              shape: RoundedRectangleBorder(
                                borderRadius: AppRadius.smBR,
                              ),
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: Text(
                              _selectedPackage?.productName ?? 'Select Package',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        if (_selectedPackage != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Selected: ${_selectedPackage!.productName}',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: c.ink60,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  const SizedBox(height: 24),

                  // ── Documents Section ─────────────────────────────────
                  _buildCheckbox(
                    label: 'Upload Photo, ID Proof and Signature',
                    value: _uploadDocs,
                    onChanged: (v) =>
                        setState(() => _uploadDocs = v ?? false),
                    colors: c,
                  ),
                  if (_uploadDocs) ...[
                    const SizedBox(height: 12),
                    _buildImageUploadTile(
                      label: 'Upload Photo',
                      icon: LucideIcons.camera,
                      file: _customerPhoto,
                      onPick: () => _pickImage((f, b64) {
                        setState(() {
                          _customerPhoto = f;
                          _customerPhotoBase64 = b64;
                        });
                      }),
                      colors: c,
                    ),
                    const SizedBox(height: 12),
                    _buildImageUploadTile(
                      label: 'Upload ID Proof',
                      icon: LucideIcons.creditCard,
                      file: _idProofPhoto,
                      onPick: () => _pickImage((f, b64) {
                        setState(() {
                          _idProofPhoto = f;
                          _idProofPhotoBase64 = b64;
                        });
                      }),
                      colors: c,
                    ),
                    const SizedBox(height: 12),
                    _buildImageUploadTile(
                      label: 'Signature',
                      icon: LucideIcons.penTool,
                      file: _signaturePhoto,
                      onPick: () => _pickImage((f, b64) {
                        setState(() {
                          _signaturePhoto = f;
                          _signaturePhotoBase64 = b64;
                        });
                      }),
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
                            _isNewCustomer ? 'Create' : 'Update',
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
    final byName = types.where(
      (ct) => ct.customerType.toLowerCase() == _selectedCustomerTypeId!.toLowerCase(),
    );
    if (byName.isNotEmpty) return byName.first;
    return null;
  }

  GroupModel? _findGroup(List<GroupModel> groups) {
    final selectedId = _selectedGroupId?.trim() ?? '';
    if (selectedId.isNotEmpty) {
      final id = int.tryParse(selectedId);
      if (id != null) {
        final match = groups.where((g) => g.groupId == id);
        if (match.isNotEmpty) return match.first;
      }
      final byName = groups.where(
        (g) => g.groupName.toLowerCase() == selectedId.toLowerCase(),
      );
      if (byName.isNotEmpty) return byName.first;
    }
    final typedName = _groupNameCtrl.text.trim();
    if (typedName.isNotEmpty) {
      final byTypedName = groups.where(
        (g) => g.groupName.toLowerCase() == typedName.toLowerCase(),
      );
      if (byTypedName.isNotEmpty) return byTypedName.first;
    }
    if (groups.length == 1) return groups.first;
    return null;
  }

  IdType? _findIdType(List<IdType> types) {
    if (_selectedIdTypeId == null || _selectedIdTypeId!.isEmpty) return null;
    final id = int.tryParse(_selectedIdTypeId!);
    if (id != null) {
      final match = types.where((it) => it.id == id);
      if (match.isNotEmpty) return match.first;
    }
    final byName = types.where(
      (it) => it.name.toLowerCase() == _selectedIdTypeId!.toLowerCase(),
    );
    if (byName.isNotEmpty) return byName.first;
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
    bool required = false,
    bool readOnly = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    List<TextInputFormatter>? inputFormatters,
    int? maxLength,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          required ? '$label *' : label,
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
          inputFormatters: inputFormatters,
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
    bool required = false,
    String? Function(T?)? validator,
    bool isLoading = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          required ? '$label *' : label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: colors.ink60,
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<T>(
          value: value != null && items.contains(value) ? value : null,
          isExpanded: true,
          icon: Icon(
            LucideIcons.chevronDown,
            size: 18,
            color: colors.ink40,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: onChanged == null ? colors.ink05 : colors.card,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
            hintText: isLoading ? 'Loading...' : 'Select $label',
            hintStyle: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: colors.ink20,
            ),
            errorStyle: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              color: colors.redDot,
            ),
          ),
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: colors.ink,
          ),
          items: isLoading
              ? const []
              : items.map((item) {
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
          onChanged: isLoading ? null : onChanged,
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildDialogSelector<T>({
    required String label,
    required T? value,
    required List<T> items,
    required String Function(T) displayName,
    required void Function(T) onSelected,
    required AppColors colors,
    List<T> Function()? latestItems,
    Future<void> Function()? onBeforeOpen,
    bool enableSearch = true,
    bool required = false,
    bool isLoading = false,
    String? Function(T?)? validator,
  }) {
    return FormField<T>(
      initialValue: value,
      validator: (_) => validator?.call(value),
      builder: (state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              required ? '$label *' : label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: colors.ink60,
              ),
            ),
            const SizedBox(height: 6),
            InkWell(
              onTap: isLoading
                  ? null
                  : () async {
                      if (onBeforeOpen != null) {
                        await onBeforeOpen();
                        if (!mounted) return;
                      }
                      final dialogItems = latestItems?.call() ?? items;
                      if (dialogItems.isEmpty) {
                        _showApiError('No data available for $label');
                        return;
                      }
                      final selected = await _openSelectionDialog<T>(
                        title: 'SELECT ${label.toUpperCase()}',
                        items: dialogItems,
                        displayName: displayName,
                        enableSearch: enableSearch,
                      );
                      if (selected != null) {
                        onSelected(selected);
                        state.didChange(selected);
                      }
                    },
              borderRadius: AppRadius.smBR,
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: isLoading ? colors.ink05 : colors.card,
                  borderRadius: AppRadius.smBR,
                  border: Border.all(
                    color: state.hasError ? colors.redDot : colors.ink10,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        isLoading
                            ? 'Loading...'
                            : (value != null ? displayName(value) : 'Select'),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: value != null ? colors.ink : colors.ink20,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(
                      LucideIcons.chevronDown,
                      size: 18,
                      color: colors.ink40,
                    ),
                  ],
                ),
              ),
            ),
            if (state.hasError)
              Padding(
                padding: const EdgeInsets.only(top: 6, left: 2),
                child: Text(
                  state.errorText ?? '',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: colors.redDot,
                  ),
                ),
              ),
          ],
        );
      },
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

  Future<void> _pickImage(void Function(File file, String base64) onPicked) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 70,
    );
    if (picked == null) return;
    final file = File(picked.path);
    final bytes = await file.readAsBytes();
    final b64 = base64Encode(bytes);
    onPicked(file, b64);
  }

  Widget _buildImageUploadTile({
    required String label,
    required IconData icon,
    required File? file,
    required VoidCallback onPick,
    required AppColors colors,
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
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onPick,
          child: file != null
              ? ClipRRect(
                  borderRadius: AppRadius.smBR,
                  child: Image.file(
                    file,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                )
              : Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: colors.ink05,
                    borderRadius: AppRadius.smBR,
                    border: Border.all(color: colors.ink10, width: 1.5),
                  ),
                  alignment: Alignment.center,
                  child: Icon(icon, size: 36, color: colors.green),
                ),
        ),
      ],
    );
  }
}

// ── Selection dialog content (StatefulWidget — owns its own TextEditingController lifecycle) ──

class _SelectionDialogContent<T> extends StatefulWidget {
  final String title;
  final List<T> items;
  final String Function(T) displayName;
  final bool enableSearch;

  const _SelectionDialogContent({
    required this.title,
    required this.items,
    required this.displayName,
    this.enableSearch = true,
  });

  @override
  State<_SelectionDialogContent<T>> createState() =>
      _SelectionDialogContentState<T>();
}

class _SelectionDialogContentState<T>
    extends State<_SelectionDialogContent<T>> {
  late TextEditingController _queryCtrl;
  late List<T> _filtered;

  @override
  void initState() {
    super.initState();
    _queryCtrl = TextEditingController();
    _filtered = List<T>.from(widget.items);
  }

  @override
  void dispose() {
    _queryCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.cardBR),
      titlePadding: EdgeInsets.zero,
      contentPadding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      title: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: colors.blueSoft,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(12)),
        ),
        child: Center(
          child: Text(
            widget.title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.enableSearch) ...[
              TextField(
                controller: _queryCtrl,
                onChanged: (q) {
                  final s = q.trim().toLowerCase();
                  setState(() {
                    _filtered = widget.items
                        .where((item) => widget.displayName(item)
                            .toLowerCase()
                            .contains(s))
                        .toList();
                  });
                },
                decoration: const InputDecoration(
                  hintText: 'Search',
                  border: UnderlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
            ],
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: _filtered.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, i) {
                  final item = _filtered[i];
                  return ListTile(
                    dense: true,
                    title: Text(
                      widget.displayName(item),
                      style: GoogleFonts.plusJakartaSans(fontSize: 14),
                    ),
                    onTap: () => Navigator.of(context).pop(item),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BillTypeOption {
  final int value;
  final String label;
  const _BillTypeOption({required this.value, required this.label});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _BillTypeOption &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;
}
