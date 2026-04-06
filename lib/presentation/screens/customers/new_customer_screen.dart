import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../application/providers/core_providers.dart';
import '../../../application/providers/master_data_provider.dart';
import '../../../core/config/app_session.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../data/datasources/remote/customer_remote_datasource.dart';
import '../../../data/datasources/remote/package_remote_datasource.dart';
import '../../../data/datasources/remote/stb_remote_datasource.dart';
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
import 'new_customer_confirm_screen.dart';
import 'new_customer_package_screen.dart';

// ─── Regex patterns from Android business logic ─────────────────────────────
final _androidEmailRegex = RegExp(r'[a-zA-Z0-9._-]+@[a-z]+\.+[a-z]+');
final _accountNumberRegex = RegExp(r'((?=.*\d)(?=.*[a-z]).{3,30})');

// =============================================================================
// New Customer 4-Step Wizard
// =============================================================================

class NewCustomerScreen extends ConsumerStatefulWidget {
  final String? prefilledSerial;
  final String? prefilledVc;
  final String? prefilledStbCode;

  const NewCustomerScreen({
    super.key,
    this.prefilledSerial,
    this.prefilledVc,
    this.prefilledStbCode,
  });

  @override
  ConsumerState<NewCustomerScreen> createState() => _NewCustomerScreenState();
}

class _NewCustomerScreenState extends ConsumerState<NewCustomerScreen> {
  final _pageController = PageController();
  int _currentStep = 0;

  // ── Step 1: STB ────────────────────────────────────────────────────────────
  final _stbController = TextEditingController();
  final _vcController = TextEditingController();
  bool _stbVerified = false;
  bool _stbVerifying = false;
  String? _stbError;
  Map<String, dynamic>? _stbInfo;

  // ── Step 2: Customer Form ──────────────────────────────────────────────────
  final _formKey = GlobalKey<FormState>();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _fatherNameCtrl = TextEditingController();
  final _mobileCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _idNumberCtrl = TextEditingController();
  final _businessNameCtrl = TextEditingController();
  final _accountNumberCtrl = TextEditingController();
  final _address1Ctrl = TextEditingController();
  final _address2Ctrl = TextEditingController();
  final _pinCodeCtrl = TextEditingController();
  final _instAddress1Ctrl = TextEditingController();
  final _instAddress2Ctrl = TextEditingController();
  final _instPinCodeCtrl = TextEditingController();
  final _cafNumberCtrl = TextEditingController();
  final _lcoCustomerIdCtrl = TextEditingController();
  final _remarksCtrl = TextEditingController();
  final _latCtrl = TextEditingController();
  final _lonCtrl = TextEditingController();
  final _discountCtrl = TextEditingController();
  DateTime? _dob;
  bool _sameAsBilling = true;
  int _billType = 1; // 1 = Advance Billing, 2 = Postpaid

  // CustomerTypeTypes sub-selection for useMandatoryForHotel
  String? _selectedCustTypeTypes;
  final List<String> _custTypeTypesList = [];

  // ── Step 3: Package ────────────────────────────────────────────────────────
  CasPackage? _selectedPackage;
  int _cycle = 2; // 1=Year, 2=Month, 3=Day
  int _quantity = 1;
  int _validityDays = 30;

  // ── Step 4: Confirm ────────────────────────────────────────────────────────
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(masterDataProvider.notifier).initialise();
      _applyRouteParams();
      _applyDefaultBillType();
    });
  }

  /// Pre-fill fields from widget params (passed via GoRouter extra).
  void _applyRouteParams() {
    // From GoRouter widget params (Fresh box tap)
    if (widget.prefilledSerial != null && widget.prefilledSerial!.isNotEmpty) {
      _stbController.text = widget.prefilledSerial!;
      _stbVerified = true; // Skip verification for pre-filled fresh boxes
    }
    if (widget.prefilledVc != null && widget.prefilledVc!.isNotEmpty) {
      _vcController.text = widget.prefilledVc!;
    }

    // Fallback: old ModalRoute style
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args == null) return;
    if (args.containsKey('stbNo') && _stbController.text.isEmpty) {
      _stbController.text = args['stbNo'].toString();
    }
    if (args.containsKey('mobile')) {
      _mobileCtrl.text = args['mobile'].toString();
    }
  }

  /// Set the default bill type based on session config.
  void _applyDefaultBillType() {
    final session = ref.read(appSessionProvider);
    if (session == null) return;
    switch (session.customerBilltype) {
      case 0:
        _billType = 1; // default to Advance Billing when both shown
        break;
      case 2:
        _billType = 1; // Advance Billing only
        break;
      case 3:
        _billType = 2; // Postpaid only
        break;
      default:
        _billType = 2; // Postpaid only
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _stbController.dispose();
    _vcController.dispose();
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _fatherNameCtrl.dispose();
    _mobileCtrl.dispose();
    _emailCtrl.dispose();
    _idNumberCtrl.dispose();
    _businessNameCtrl.dispose();
    _accountNumberCtrl.dispose();
    _address1Ctrl.dispose();
    _address2Ctrl.dispose();
    _pinCodeCtrl.dispose();
    _instAddress1Ctrl.dispose();
    _instAddress2Ctrl.dispose();
    _instPinCodeCtrl.dispose();
    _cafNumberCtrl.dispose();
    _lcoCustomerIdCtrl.dispose();
    _remarksCtrl.dispose();
    _latCtrl.dispose();
    _lonCtrl.dispose();
    _discountCtrl.dispose();
    super.dispose();
  }

  // ── Navigation ─────────────────────────────────────────────────────────────

  void _goToStep(int step) {
    setState(() => _currentStep = step);
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _next() {
    if (_currentStep < 3) _goToStep(_currentStep + 1);
  }

  void _back() {
    if (_currentStep > 0) {
      _goToStep(_currentStep - 1);
    } else {
      Navigator.of(context).pop();
    }
  }

  // ── Step 1: Verify STB ────────────────────────────────────────────────────

  Future<void> _verifyStb() async {
    final stbNo = _stbController.text.trim();
    final vcNo = _vcController.text.trim();
    if (stbNo.isEmpty) {
      setState(() => _stbError = 'Please enter an STB serial number');
      return;
    }
    if (vcNo.isEmpty) {
      setState(() => _stbError = 'Please enter a VC number');
      return;
    }

    setState(() {
      _stbVerifying = true;
      _stbError = null;
    });

    try {
      final session = ref.read(appSessionProvider);
      final ds = StbRemoteDatasource(dio: ref.read(dioClientProvider));
      final result = await ds.validateBoxInfo(
        authtoken: session?.token ?? '',
        stbNo: stbNo,
        vcNo: vcNo,
      );

      final statusCode = result['statusCode'] ?? result['status_code'];
      if (statusCode == 0 || statusCode == '0') {
        setState(() {
          _stbVerified = true;
          _stbVerifying = false;
          _stbInfo = result;
        });
      } else {
        setState(() {
          _stbVerified = false;
          _stbVerifying = false;
          _stbError = result['statusMessage']?.toString() ??
              result['status_msg']?.toString() ??
              'STB not found or already assigned';
        });
      }
    } catch (e) {
      setState(() {
        _stbVerified = false;
        _stbVerifying = false;
        _stbError = e.toString().replaceAll('ApiException: ', '');
      });
    }
  }

  void _openScanner() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _BarcodeScannerSheet(
        onScanned: (code) {
          Navigator.pop(ctx);
          setState(() {
            _stbController.text = code;
            _stbVerified = false;
            _stbError = null;
          });
        },
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // VALIDATION: 20-rule sequential chain (first failure stops)
  // ══════════════════════════════════════════════════════════════════════════

  /// Returns an error message string on validation failure, or null if valid.
  /// Implements the exact 20-rule sequential if/else chain from the Android
  /// NewCustCreation_Fragment business logic (lines 993-1393).
  String? _validate() {
    final session = ref.read(appSessionProvider);
    final md = ref.read(masterDataProvider);
    if (session == null) return 'Session not available';

    // Convenience accessors for dynamic form validation flags
    bool isDynMandatory(String col) => md.isFieldMandatory(col);

    // ── Rule 1: Customer Type must be selected (always mandatory) ──────────
    if (md.selectedCustomerType == null) {
      return 'Please select a Customer Type!';
    }

    // ── Rule 2: useMandatoryForHotel sub-type required ─────────────────────
    if (session.useMandatoryForHotel == 1 &&
        (_selectedCustTypeTypes == null ||
            _selectedCustTypeTypes == 'Select' ||
            _selectedCustTypeTypes!.isEmpty)) {
      return 'Please select a Customer Type!';
    }

    // ── Rule 3: CAF Number mandatory when useCRF==1 && useCAF=="MANUAL" ───
    if (session.useCRF == 1 &&
        session.useCAF == 'MANUAL' &&
        _cafNumberCtrl.text.trim().isEmpty) {
      return 'CAF Number should not be empty';
    }

    // ── Rule 4: LCO Customer Id mandatory when useCAF=="MANUAL" ───────────
    if (session.useCAF == 'MANUAL' &&
        _lcoCustomerIdCtrl.text.trim().isEmpty) {
      return 'LCO Customer Id should not be empty';
    }

    // ── Rule 5: LCO Customer Id mandatory when baid dynamic flag set ──────
    if (isDynMandatory('baid') &&
        _lcoCustomerIdCtrl.text.trim().isEmpty) {
      return 'LCO Customer Id should not be empty';
    }

    // ── Rule 6: First Name (always mandatory) ─────────────────────────────
    if (_firstNameCtrl.text.trim().isEmpty) {
      return 'First Name should not be empty';
    }

    // ── Rule 7: Last Name (dynamic form validation) ───────────────────────
    if (isDynMandatory('last_name') &&
        _lastNameCtrl.text.trim().isEmpty) {
      return 'Last Name should not be empty';
    }

    // ── Rule 8: Account Number empty check (useAccountNumber==0) ──────────
    if (session.useAccountNumber == 0 &&
        _accountNumberCtrl.text.trim().isEmpty) {
      return 'Account Number should not be empty';
    }

    // ── Rule 9: Account Number alphanumeric check (useAccountNumber==0) ───
    if (session.useAccountNumber == 0 &&
        _accountNumberCtrl.text.trim().isNotEmpty &&
        !_accountNumberRegex.hasMatch(
            _accountNumberCtrl.text.trim().toLowerCase())) {
      return 'Account Number should contain at least 1 numeric and 1 alphabet and min length 3';
    }

    // ── Rule 10: Address must not be empty ─────────────────────────────────
    if (_address1Ctrl.text.trim().isEmpty) {
      return 'Address should not be empty';
    }
    if (!_sameAsBilling && _instAddress1Ctrl.text.trim().isEmpty) {
      return 'Address should not be empty';
    }

    // ── Rule 11: Mobile number >= 10 digits (dynamic) ─────────────────────
    if (isDynMandatory('mobile_no') &&
        _mobileCtrl.text.trim().length < 10) {
      return 'Mobile number should not be less than 10 digits';
    }

    // ── Rule 12: PIN code >= 6 digits (always) ────────────────────────────
    if (_pinCodeCtrl.text.trim().isNotEmpty &&
        _pinCodeCtrl.text.trim().length < 6) {
      return 'Pincode should not be less than 6 digits';
    }

    // ── Rule 13: Email pattern check (dynamic) ────────────────────────────
    if (_emailCtrl.text.trim().isNotEmpty &&
        isDynMandatory('email') &&
        !_androidEmailRegex.hasMatch(_emailCtrl.text.trim())) {
      return 'Email Id pattern is Invalid';
    }

    // ── Rule 14: Package must be selected (always mandatory) ──────────────
    if (_selectedPackage == null) {
      // Package is selected on Step 3 — will be checked when moving to Step 4
      // At Step 2 validation time, skip this; re-check before save.
    }

    // ── Rule 15: Group must be selected (always mandatory) ────────────────
    if (md.selectedGroup == null) {
      return 'Please select a Group';
    }

    // ── Rule 16: ID Type (dynamic) ────────────────────────────────────────
    if (isDynMandatory('id_type') && md.selectedIdType == null) {
      return 'Please select ID Type';
    }

    // ── Rule 17: ID Number (dynamic) ──────────────────────────────────────
    if (isDynMandatory('id_number') &&
        _idNumberCtrl.text.trim().isEmpty) {
      return 'Please enter an ID Number';
    }

    // ── Rule 18: Mandal (dynamic) ─────────────────────────────────────────
    if (isDynMandatory('mandal_id') && md.selectedMandal == null) {
      return 'Please select mandal';
    }

    // ── Rule 19: City must be selected (always mandatory) ─────────────────
    if (md.selectedCity == null) {
      return 'Please select city';
    }

    return null; // all validations passed
  }

  /// Full validation including package (called before save on Step 4).
  String? _validateAll() {
    final formError = _validate();
    if (formError != null) return formError;

    // Rule 14: Package must be selected
    if (_selectedPackage == null) {
      return 'Package should not be empty';
    }

    return null;
  }

  /// Validate Step 2 form and show error via snackbar if validation fails.
  bool _validateForm() {
    // First run Flutter's built-in TextFormField validators
    final formValid = _formKey.currentState?.validate() ?? false;
    if (!formValid) return false;

    // Then run the 20-rule sequential validation chain
    final error = _validate();
    if (error != null) {
      _showValidationError(error);
      return false;
    }
    return true;
  }

  void _showValidationError(String message) {
    final colors = Theme.of(context).extension<AppColors>()!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontFamily: 'Plus Jakarta Sans'),
        ),
        backgroundColor: colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  // ── "Same as Billing Address" checkbox handler ────────────────────────────

  void _onSameAsBillingChanged(bool? value) {
    setState(() {
      _sameAsBilling = value ?? true;
      if (_sameAsBilling) {
        // Copy billing address fields to installation address
        _instAddress1Ctrl.text = _address1Ctrl.text;
        _instAddress2Ctrl.text = _address2Ctrl.text;
        _instPinCodeCtrl.text = _pinCodeCtrl.text;
      } else {
        // Clear installation address fields
        _instAddress1Ctrl.clear();
        _instAddress2Ctrl.clear();
        _instPinCodeCtrl.clear();
      }
    });
  }

  // ── Config-based visibility helpers ───────────────────────────────────────

  /// CAF label: useCRF==0 -> "CRF Number"; useCRF==1 -> "CAF Number"
  String _cafLabel(AppSession session) =>
      session.useCRF == 1 ? 'CAF Number' : 'CRF Number';

  /// Whether to show the CAF/CRF input field.
  /// useCRF==1 && useCAF=="AUTO" -> hide; useCRF==1 && useCAF=="MANUAL" -> show
  /// useCRF==0 -> hide
  bool _showCafField(AppSession session) =>
      session.useCRF == 1 && session.useCAF == 'MANUAL';

  /// Whether CAF field is mandatory (shown + MANUAL mode).
  bool _isCafMandatory(AppSession session) => _showCafField(session);

  /// Whether to show Last Name row.
  /// useLastName==1 -> show; useLastName==0 -> hide
  bool _showLastName(AppSession session) => session.useLastName == 1;

  /// First name label: useLastName==0 -> "Customer Name"; ==1 -> "First Name"
  String _firstNameLabel(AppSession session) =>
      session.useLastName == 1 ? 'First Name' : 'Customer Name';

  /// Whether to show Account Number field.
  /// useAccountNumber==0 -> show (mandatory); >0 -> hide
  bool _showAccountNumber(AppSession session) => session.useAccountNumber == 0;

  /// Whether to show the discount field.
  bool _showDiscount(AppSession session) {
    if (session.useDiscount == 0) return false;
    if (session.useDiscount == 1) {
      return session.userType == 'DEALER' ||
          session.userType == 'ADMIN' ||
          session.userType == 'EMPLOYEE';
    }
    if (session.useDiscount == 2) return true;
    return false;
  }

  /// Bill type options based on customerBilltype config.
  List<_BillTypeOption> _billTypeOptions(AppSession session) {
    switch (session.customerBilltype) {
      case 0:
        return [
          const _BillTypeOption(value: 1, label: 'Advance Billing'),
          const _BillTypeOption(value: 2, label: 'Postpaid'),
        ];
      case 2:
        return [const _BillTypeOption(value: 1, label: 'Advance Billing')];
      case 3:
        return [const _BillTypeOption(value: 2, label: 'Postpaid')];
      default:
        return [const _BillTypeOption(value: 2, label: 'Postpaid')];
    }
  }

  // ── Step 4: Save Customer ─────────────────────────────────────────────────

  Future<void> _saveCustomer() async {
    // Run full validation before save
    final error = _validateAll();
    if (error != null) {
      _showValidationError(error);
      return;
    }

    setState(() => _isSaving = true);

    try {
      final session = ref.read(appSessionProvider);
      final md = ref.read(masterDataProvider);
      final ds = CustomerRemoteDatasource(dio: ref.read(dioClientProvider));

      final customerData = <String, dynamic>{
        'firstName': _firstNameCtrl.text.trim(),
        if (_lastNameCtrl.text.trim().isNotEmpty)
          'lastName': _lastNameCtrl.text.trim(),
        'mobileNumber': _mobileCtrl.text.trim(),
        if (_emailCtrl.text.trim().isNotEmpty) 'email': _emailCtrl.text.trim(),
        if (_fatherNameCtrl.text.trim().isNotEmpty)
          'fatherName': _fatherNameCtrl.text.trim(),
        if (md.selectedGender != null) 'gender': md.selectedGender!.name,
        if (_dob != null)
          'dob':
              '${_dob!.year}-${_dob!.month.toString().padLeft(2, '0')}-${_dob!.day.toString().padLeft(2, '0')}',
        if (md.selectedCustomerType != null)
          'customerTypeId': md.selectedCustomerType!.customerTypeId.toString(),
        if (_selectedCustTypeTypes != null &&
            _selectedCustTypeTypes!.isNotEmpty &&
            _selectedCustTypeTypes != 'Select')
          'customerTypeTypes': _selectedCustTypeTypes,
        if (md.selectedIdType != null)
          'idType': md.selectedIdType!.id.toString(),
        if (_idNumberCtrl.text.trim().isNotEmpty)
          'idNumber': _idNumberCtrl.text.trim(),
        if (_businessNameCtrl.text.trim().isNotEmpty)
          'businessName': _businessNameCtrl.text.trim(),
        if (_accountNumberCtrl.text.trim().isNotEmpty)
          'accountNumber': _accountNumberCtrl.text.trim(),
        'billingAddress1': _address1Ctrl.text.trim(),
        if (_address2Ctrl.text.trim().isNotEmpty)
          'billingAddress2': _address2Ctrl.text.trim(),
        if (_pinCodeCtrl.text.trim().isNotEmpty)
          'pinCode': _pinCodeCtrl.text.trim(),
        if (md.selectedCountry != null) 'countryCode': md.selectedCountry!.iso,
        if (md.selectedState != null)
          'stateId': md.selectedState!.id.toString(),
        if (md.selectedDistrict != null)
          'districtId': md.selectedDistrict!.id.toString(),
        if (md.selectedCity != null)
          'cityId': md.selectedCity!.locationId.toString(),
        if (md.selectedMandal != null)
          'mandalId': md.selectedMandal!.mandalId.toString(),
        'installationAddress1': _sameAsBilling
            ? _address1Ctrl.text.trim()
            : _instAddress1Ctrl.text.trim(),
        if (_sameAsBilling
            ? _address2Ctrl.text.trim().isNotEmpty
            : _instAddress2Ctrl.text.trim().isNotEmpty)
          'installationAddress2': _sameAsBilling
              ? _address2Ctrl.text.trim()
              : _instAddress2Ctrl.text.trim(),
        if (md.selectedGroup != null)
          'groupId': md.selectedGroup!.groupId.toString(),
        if (_cafNumberCtrl.text.trim().isNotEmpty)
          'cafNumber': _cafNumberCtrl.text.trim(),
        if (_lcoCustomerIdCtrl.text.trim().isNotEmpty)
          'lcoCustomerId': _lcoCustomerIdCtrl.text.trim(),
        if (_remarksCtrl.text.trim().isNotEmpty)
          'remarks': _remarksCtrl.text.trim(),
        if (_latCtrl.text.trim().isNotEmpty)
          'latitude': double.tryParse(_latCtrl.text.trim()),
        if (_lonCtrl.text.trim().isNotEmpty)
          'longitude': double.tryParse(_lonCtrl.text.trim()),
        'stbSerialNumber': _stbController.text.trim(),
        'stbVcNumber': _vcController.text.trim(),
        'billType': _billType,
        if (_discountCtrl.text.trim().isNotEmpty)
          'discount': int.tryParse(_discountCtrl.text.trim()) ?? 0,
        if (_selectedPackage != null) ...{
          'packageId': _selectedPackage!.productId,
          'packageName': _selectedPackage!.productName,
          'pricingStructureType': _selectedPackage!.pricingStructureType,
          'cycle': _cycle,
          'quantity': _quantity,
          if (_cycle == 3) 'validityDays': _validityDays,
        },
        'dealerId': session?.dealerId ?? 0,
        'employeeId': session?.employeeId ?? 0,
      };

      final result = await ds.saveCustomer(
        authtoken: session?.token ?? '',
        customerData: customerData,
      );

      if (!mounted) return;
      setState(() => _isSaving = false);

      final customerId = result['customerId']?.toString() ??
          result['customer_id']?.toString() ??
          '';

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) {
          final colors = Theme.of(ctx).extension<AppColors>()!;
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(LucideIcons.checkCircle, color: colors.green, size: 24),
                const SizedBox(width: 8),
                const Text(
                  'Success',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            content: Text(
              customerId.isNotEmpty
                  ? 'Customer created successfully!\nCustomer ID: $customerId'
                  : 'Customer created successfully!',
              style: const TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 14,
              ),
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Theme.of(ctx).extension<AppColors>()!.red,
                  foregroundColor:
                      Theme.of(ctx).extension<AppColors>()!.card,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'OK',
                  style: TextStyle(fontFamily: 'Plus Jakarta Sans'),
                ),
              ),
            ],
          );
        },
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceAll('ApiException: ', ''),
          ),
          backgroundColor: Theme.of(context).extension<AppColors>()!.red,
        ),
      );
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final session = ref.watch(appSessionProvider);

    return PopScope(
      canPop: _currentStep == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _back();
      },
      child: Scaffold(
        backgroundColor: colors.bg,
        appBar: AppBar(
          title: const Text(
            'New Customer',
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          backgroundColor: colors.card,
          foregroundColor: colors.ink,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(LucideIcons.arrowLeft),
            onPressed: _back,
          ),
        ),
        body: Column(
          children: [
            // ── Step indicator ──────────────────────────────────────
            _StepIndicator(
              currentStep: _currentStep,
              colors: colors,
            ),

            // ── Pages ──────────────────────────────────────────────
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _currentStep = i),
                children: [
                  _buildStep1Stb(colors),
                  _buildStep2Form(colors, session),
                  NewCustomerPackageScreen(
                    stbNumber: _stbController.text.trim(),
                    selectedPackage: _selectedPackage,
                    cycle: _cycle,
                    quantity: _quantity,
                    validityDays: _validityDays,
                    onPackageSelected: (pkg, cycle, qty, days) {
                      setState(() {
                        _selectedPackage = pkg;
                        _cycle = cycle;
                        _quantity = qty;
                        _validityDays = days;
                      });
                    },
                    onNext: _next,
                    onBack: _back,
                  ),
                  NewCustomerConfirmScreen(
                    stbNumber: _stbController.text.trim(),
                    vcNumber: _vcController.text.trim(),
                    firstName: _firstNameCtrl.text.trim(),
                    lastName: _lastNameCtrl.text.trim(),
                    fatherName: _fatherNameCtrl.text.trim(),
                    mobile: _mobileCtrl.text.trim(),
                    email: _emailCtrl.text.trim(),
                    dob: _dob,
                    idNumber: _idNumberCtrl.text.trim(),
                    businessName: _businessNameCtrl.text.trim(),
                    accountNumber: _accountNumberCtrl.text.trim(),
                    address1: _address1Ctrl.text.trim(),
                    address2: _address2Ctrl.text.trim(),
                    pinCode: _pinCodeCtrl.text.trim(),
                    instAddress1: _sameAsBilling
                        ? _address1Ctrl.text.trim()
                        : _instAddress1Ctrl.text.trim(),
                    instAddress2: _sameAsBilling
                        ? _address2Ctrl.text.trim()
                        : _instAddress2Ctrl.text.trim(),
                    cafNumber: _cafNumberCtrl.text.trim(),
                    lcoCustomerId: _lcoCustomerIdCtrl.text.trim(),
                    remarks: _remarksCtrl.text.trim(),
                    selectedPackage: _selectedPackage,
                    cycle: _cycle,
                    quantity: _quantity,
                    validityDays: _validityDays,
                    isSaving: _isSaving,
                    onConfirm: _saveCustomer,
                    onBack: _back,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Step 1: STB Scan / Verify
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildStep1Stb(AppColors colors) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Scan button
          GestureDetector(
            onTap: _stbVerified ? null : _openScanner,
            child: Container(
              height: 160,
              decoration: BoxDecoration(
                color: colors.blueSoft,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _stbVerified ? colors.green : colors.blue,
                  width: 2,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _stbVerified ? LucideIcons.checkCircle : LucideIcons.scan,
                    size: 48,
                    color: _stbVerified ? colors.green : colors.blue,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _stbVerified ? 'STB Verified' : 'Tap to Scan STB Barcode',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _stbVerified ? colors.green : colors.blue,
                    ),
                  ),
                  if (!_stbVerified)
                    Text(
                      'or enter manually below',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 13,
                        color: colors.ink40,
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // STB Serial Number
          _WizardTextField(
            controller: _stbController,
            label: 'STB Serial Number',
            colors: colors,
            enabled: !_stbVerified,
            prefixIcon: LucideIcons.monitor,
            suffixIcon: _stbVerified
                ? Icon(LucideIcons.checkCircle, color: colors.green, size: 20)
                : null,
          ),
          const SizedBox(height: 12),

          // VC Number
          _WizardTextField(
            controller: _vcController,
            label: 'VC Number',
            colors: colors,
            enabled: !_stbVerified,
            prefixIcon: LucideIcons.creditCard,
            suffixIcon: _stbVerified
                ? Icon(LucideIcons.checkCircle, color: colors.green, size: 20)
                : null,
          ),
          const SizedBox(height: 16),

          // Error
          if (_stbError != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colors.redSoft,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(LucideIcons.alertCircle, color: colors.red, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _stbError!,
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 13,
                          color: colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Verify / Reset button
          if (!_stbVerified)
            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _stbVerifying ? null : _verifyStb,
                icon: _stbVerifying
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          color: colors.card,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(LucideIcons.shieldCheck, size: 18),
                label: Text(
                  _stbVerifying ? 'Verifying...' : 'Verify STB',
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.red,
                  foregroundColor: colors.card,
                  disabledBackgroundColor: colors.red.withAlpha(128),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            )
          else
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        _stbVerified = false;
                        _stbError = null;
                        _stbInfo = null;
                        _stbController.clear();
                        _vcController.clear();
                      });
                    },
                    icon: const Icon(LucideIcons.refreshCw, size: 16),
                    label: const Text(
                      'Reset',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colors.ink60,
                      side: BorderSide(color: colors.ink20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      minimumSize: const Size(0, 50),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: _next,
                    icon: const Icon(LucideIcons.arrowRight, size: 18),
                    label: const Text(
                      'Next: Customer Details',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.red,
                      foregroundColor: colors.card,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                      minimumSize: const Size(0, 50),
                    ),
                  ),
                ),
              ],
            ),

          // STB Info card
          if (_stbInfo != null && _stbVerified) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.greenSoft,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colors.green.withAlpha(60)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'STB Information',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: colors.ink,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _InfoRow(
                    label: 'Serial',
                    value: _stbController.text.trim(),
                    colors: colors,
                  ),
                  _InfoRow(
                    label: 'VC Number',
                    value: _vcController.text.trim(),
                    colors: colors,
                  ),
                  if (_stbInfo!['stb_type'] != null)
                    _InfoRow(
                      label: 'Type',
                      value: _stbInfo!['stb_type'].toString(),
                      colors: colors,
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Step 2: Customer Form
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildStep2Form(AppColors colors, dynamic session) {
    final md = ref.watch(masterDataProvider);
    final sess = session as AppSession?;
    if (sess == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final showLastName = _showLastName(sess);
    final showCaf = _showCafField(sess);
    final cafMandatory = _isCafMandatory(sess);
    final showAcctNum = _showAccountNumber(sess);
    final showDiscountField = _showDiscount(sess);
    final hotelMode = sess.useMandatoryForHotel == 1;
    final billTypeOpts = _billTypeOptions(sess);

    // Dynamic form validation flags for mandatory indicators
    final isLastNameMandatory = md.isFieldMandatory('last_name');
    final isEmailMandatory = md.isFieldMandatory('email');
    final isIdTypeMandatory = md.isFieldMandatory('id_type');
    final isIdNumberMandatory = md.isFieldMandatory('id_number');
    final isGenderMandatory = md.isFieldMandatory('gender');
    final isMobileMandatory = md.isFieldMandatory('mobile_no');
    final isBaidMandatory = md.isFieldMandatory('baid');
    final isMandalMandatory = md.isFieldMandatory('mandal_id');

    // LCO Customer ID is mandatory if useCAF==MANUAL OR baid dynamic flag
    final lcoIdMandatory =
        sess.useCAF == 'MANUAL' || isBaidMandatory;

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Identity / Type ──────────────────────────────────────
            _SectionHeader(title: 'Customer Type', colors: colors),
            const SizedBox(height: 12),
            _SectionCard(
              colors: colors,
              children: [
                _WizardDropdown<CustomerType>(
                  label: 'Customer Type *',
                  colors: colors,
                  value: md.selectedCustomerType,
                  items: md.customerTypes,
                  isLoading: md.isLoadingCustomerTypes,
                  displayName: (ct) => ct.customerType,
                  onChanged: (ct) => ref
                      .read(masterDataProvider.notifier)
                      .selectCustomerType(ct),
                  prefixIcon: LucideIcons.tag,
                ),
                if (hotelMode) ...[
                  const SizedBox(height: 12),
                  _WizardDropdown<String>(
                    label: 'Customer Sub-Type *',
                    colors: colors,
                    value: _selectedCustTypeTypes,
                    items: _custTypeTypesList.isNotEmpty
                        ? _custTypeTypesList
                        : const ['Select'],
                    displayName: (s) => s,
                    onChanged: (val) =>
                        setState(() => _selectedCustTypeTypes = val),
                    prefixIcon: LucideIcons.tag,
                  ),
                ],
              ],
            ),
            const SizedBox(height: 20),

            // ── CAF / LCO Customer ID ────────────────────────────────
            if (showCaf || lcoIdMandatory) ...[
              _SectionHeader(title: 'Reference Numbers', colors: colors),
              const SizedBox(height: 12),
              _SectionCard(
                colors: colors,
                children: [
                  if (showCaf)
                    _WizardTextField(
                      controller: _cafNumberCtrl,
                      label: _cafLabel(sess),
                      colors: colors,
                      required: cafMandatory,
                      prefixIcon: LucideIcons.fileText,
                      validator: cafMandatory
                          ? (v) {
                              if (v == null || v.trim().isEmpty) {
                                return '${_cafLabel(sess)} should not be empty';
                              }
                              return null;
                            }
                          : null,
                    ),
                  if (showCaf && lcoIdMandatory) const SizedBox(height: 12),
                  _WizardTextField(
                    controller: _lcoCustomerIdCtrl,
                    label: sess.baidLabel ?? 'LCO Customer ID',
                    colors: colors,
                    required: lcoIdMandatory,
                    prefixIcon: LucideIcons.hash,
                    validator: lcoIdMandatory
                        ? (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'LCO Customer Id should not be empty';
                            }
                            return null;
                          }
                        : null,
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],

            // ── Personal Information ─────────────────────────────────
            _SectionHeader(title: 'Personal Information', colors: colors),
            const SizedBox(height: 12),
            _SectionCard(
              colors: colors,
              children: [
                _WizardTextField(
                  controller: _firstNameCtrl,
                  label: _firstNameLabel(sess),
                  colors: colors,
                  required: true,
                  prefixIcon: LucideIcons.user,
                  validator: (v) => validateRequired(v, _firstNameLabel(sess)),
                ),
                if (showLastName) ...[
                  const SizedBox(height: 12),
                  _WizardTextField(
                    controller: _lastNameCtrl,
                    label: 'Last Name',
                    colors: colors,
                    required: isLastNameMandatory,
                    prefixIcon: LucideIcons.user,
                    validator: isLastNameMandatory
                        ? (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Last Name should not be empty';
                            }
                            return null;
                          }
                        : null,
                  ),
                ],
                const SizedBox(height: 12),
                _WizardTextField(
                  controller: _fatherNameCtrl,
                  label: 'Father\'s Name',
                  colors: colors,
                  prefixIcon: LucideIcons.users,
                ),
                const SizedBox(height: 12),
                // Gender dropdown
                _WizardDropdown<Gender>(
                  label: isGenderMandatory ? 'Gender *' : 'Gender',
                  colors: colors,
                  value: md.selectedGender,
                  items: md.genders,
                  displayName: (g) => g.name,
                  onChanged: (g) =>
                      ref.read(masterDataProvider.notifier).selectGender(g),
                  prefixIcon: LucideIcons.user,
                ),
                const SizedBox(height: 12),
                // Date of birth
                _DatePickerField(
                  label: 'Date of Birth',
                  colors: colors,
                  value: _dob,
                  onChanged: (d) => setState(() => _dob = d),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ── Contact Information ──────────────────────────────────
            _SectionHeader(title: 'Contact Information', colors: colors),
            const SizedBox(height: 12),
            _SectionCard(
              colors: colors,
              children: [
                _WizardTextField(
                  controller: _mobileCtrl,
                  label: isMobileMandatory ? 'Mobile Number *' : 'Mobile Number',
                  colors: colors,
                  required: isMobileMandatory,
                  prefixIcon: LucideIcons.phone,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  validator: isMobileMandatory
                      ? (v) {
                          if (v == null || v.trim().length < 10) {
                            return 'Mobile number should not be less than 10 digits';
                          }
                          return null;
                        }
                      : null,
                ),
                const SizedBox(height: 12),
                _WizardTextField(
                  controller: _emailCtrl,
                  label: isEmailMandatory ? 'Email *' : 'Email',
                  colors: colors,
                  required: isEmailMandatory,
                  prefixIcon: LucideIcons.mail,
                  keyboardType: TextInputType.emailAddress,
                  validator: isEmailMandatory
                      ? (v) {
                          if (v != null &&
                              v.trim().isNotEmpty &&
                              !_androidEmailRegex.hasMatch(v.trim())) {
                            return 'Email Id pattern is Invalid';
                          }
                          return null;
                        }
                      : null,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ── Identity Documents ───────────────────────────────────
            _SectionHeader(title: 'Identity', colors: colors),
            const SizedBox(height: 12),
            _SectionCard(
              colors: colors,
              children: [
                _WizardDropdown<IdType>(
                  label: isIdTypeMandatory ? 'ID Type *' : 'ID Type',
                  colors: colors,
                  value: md.selectedIdType,
                  items: md.idTypes,
                  isLoading: md.isLoadingIdTypes,
                  displayName: (it) => it.name,
                  onChanged: (it) =>
                      ref.read(masterDataProvider.notifier).selectIdType(it),
                  prefixIcon: LucideIcons.fingerprint,
                ),
                const SizedBox(height: 12),
                _WizardTextField(
                  controller: _idNumberCtrl,
                  label: isIdNumberMandatory ? 'ID Number *' : 'ID Number',
                  colors: colors,
                  required: isIdNumberMandatory,
                  enabled: md.selectedIdType != null,
                  prefixIcon: LucideIcons.hash,
                  validator: isIdNumberMandatory
                      ? (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Please enter an ID Number';
                          }
                          return null;
                        }
                      : null,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ── Account Number (conditional: useAccountNumber==0) ────
            if (showAcctNum) ...[
              _SectionHeader(title: 'Account', colors: colors),
              const SizedBox(height: 12),
              _SectionCard(
                colors: colors,
                children: [
                  _WizardTextField(
                    controller: _accountNumberCtrl,
                    label: 'Account Number *',
                    colors: colors,
                    required: true,
                    prefixIcon: LucideIcons.wallet,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Account Number should not be empty';
                      }
                      if (!_accountNumberRegex
                          .hasMatch(v.trim().toLowerCase())) {
                        return 'Account Number should contain at least 1 numeric and 1 alphabet and min length 3';
                      }
                      return null;
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],

            // ── Billing Address ──────────────────────────────────────
            _SectionHeader(title: 'Billing Address', colors: colors),
            const SizedBox(height: 12),
            _SectionCard(
              colors: colors,
              children: [
                _WizardTextField(
                  controller: _address1Ctrl,
                  label: 'Address Line 1 *',
                  colors: colors,
                  required: true,
                  prefixIcon: LucideIcons.mapPin,
                  validator: (v) => validateRequired(v, 'Address'),
                ),
                const SizedBox(height: 12),
                _WizardTextField(
                  controller: _address2Ctrl,
                  label: 'Address Line 2',
                  colors: colors,
                  prefixIcon: LucideIcons.mapPin,
                ),
                const SizedBox(height: 12),
                _WizardTextField(
                  controller: _pinCodeCtrl,
                  label: 'PIN Code',
                  colors: colors,
                  prefixIcon: LucideIcons.mapPin,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(6),
                  ],
                  validator: (v) {
                    if (v != null &&
                        v.trim().isNotEmpty &&
                        v.trim().length < 6) {
                      return 'Pincode should not be less than 6 digits';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                // Country
                _WizardDropdown<Country>(
                  label: 'Country',
                  colors: colors,
                  value: md.selectedCountry,
                  items: md.countries,
                  isLoading: md.isLoadingCountries,
                  displayName: (c) => c.name,
                  onChanged: (c) =>
                      ref.read(masterDataProvider.notifier).selectCountry(c),
                  prefixIcon: LucideIcons.globe,
                ),
                const SizedBox(height: 12),

                // State
                _WizardDropdown<StateModel>(
                  label: 'State',
                  colors: colors,
                  value: md.selectedState,
                  items: md.states,
                  isLoading: md.isLoadingStates,
                  displayName: (s) => s.name,
                  onChanged: (s) =>
                      ref.read(masterDataProvider.notifier).selectState(s),
                  prefixIcon: LucideIcons.map,
                ),
                const SizedBox(height: 12),

                // District
                _WizardDropdown<District>(
                  label: 'District',
                  colors: colors,
                  value: md.selectedDistrict,
                  items: md.districts,
                  isLoading: md.isLoadingDistricts,
                  displayName: (d) => d.name,
                  onChanged: (d) =>
                      ref.read(masterDataProvider.notifier).selectDistrict(d),
                  prefixIcon: LucideIcons.mapPin,
                ),
                const SizedBox(height: 12),

                // City (always mandatory per rule 19)
                _WizardDropdown<City>(
                  label: 'City *',
                  colors: colors,
                  value: md.selectedCity,
                  items: md.cities,
                  isLoading: md.isLoadingCities,
                  displayName: (c) => c.locationName,
                  onChanged: (c) =>
                      ref.read(masterDataProvider.notifier).selectCity(c),
                  prefixIcon: LucideIcons.building,
                ),
                const SizedBox(height: 12),

                // Mandal
                _WizardDropdown<Mandal>(
                  label: isMandalMandatory ? 'Mandal *' : 'Mandal',
                  colors: colors,
                  value: md.selectedMandal,
                  items: md.mandals,
                  isLoading: md.isLoadingMandals,
                  displayName: (m) => m.mandalName,
                  onChanged: (m) =>
                      ref.read(masterDataProvider.notifier).selectMandal(m),
                  prefixIcon: LucideIcons.landmark,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ── Installation Address ─────────────────────────────────
            _SectionHeader(title: 'Installation Address', colors: colors),
            const SizedBox(height: 12),
            _SectionCard(
              colors: colors,
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Checkbox(
                        value: _sameAsBilling,
                        onChanged: _address1Ctrl.text.trim().isNotEmpty
                            ? _onSameAsBillingChanged
                            : null,
                        activeColor: colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Same as billing address',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 14,
                        color: colors.ink80,
                      ),
                    ),
                  ],
                ),
                if (!_sameAsBilling) ...[
                  const SizedBox(height: 12),
                  _WizardTextField(
                    controller: _instAddress1Ctrl,
                    label: 'Address Line 1 *',
                    colors: colors,
                    required: true,
                    prefixIcon: LucideIcons.mapPin,
                    validator: (v) =>
                        validateRequired(v, 'Installation Address'),
                  ),
                  const SizedBox(height: 12),
                  _WizardTextField(
                    controller: _instAddress2Ctrl,
                    label: 'Address Line 2',
                    colors: colors,
                    prefixIcon: LucideIcons.mapPin,
                  ),
                  const SizedBox(height: 12),
                  _WizardTextField(
                    controller: _instPinCodeCtrl,
                    label: 'PIN Code',
                    colors: colors,
                    prefixIcon: LucideIcons.mapPin,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(6),
                    ],
                  ),
                ],
              ],
            ),
            const SizedBox(height: 20),

            // ── Group / Billing / Discount ────────────────────────────
            _SectionHeader(title: 'Group & Billing', colors: colors),
            const SizedBox(height: 12),
            _SectionCard(
              colors: colors,
              children: [
                _WizardDropdown<GroupModel>(
                  label: 'Group *',
                  colors: colors,
                  value: md.selectedGroup,
                  items: md.groups,
                  isLoading: md.isLoadingGroups,
                  displayName: (g) => g.groupName,
                  onChanged: (g) =>
                      ref.read(masterDataProvider.notifier).selectGroup(g),
                  prefixIcon: LucideIcons.users,
                ),
                if (billTypeOpts.length > 1) ...[
                  const SizedBox(height: 12),
                  _WizardDropdown<_BillTypeOption>(
                    label: 'Bill Type',
                    colors: colors,
                    value: billTypeOpts
                        .where((o) => o.value == _billType)
                        .firstOrNull,
                    items: billTypeOpts,
                    displayName: (o) => o.label,
                    onChanged: (o) {
                      if (o != null) setState(() => _billType = o.value);
                    },
                    prefixIcon: LucideIcons.receipt,
                  ),
                ],
                if (showDiscountField) ...[
                  const SizedBox(height: 12),
                  _WizardTextField(
                    controller: _discountCtrl,
                    label: 'Discount (%)',
                    colors: colors,
                    prefixIcon: LucideIcons.percent,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(3),
                    ],
                  ),
                ],
              ],
            ),
            const SizedBox(height: 20),

            // ── Other ────────────────────────────────────────────────
            if (!showCaf && !lcoIdMandatory) ...[
              // Show LCO ID and CAF in Other section if not shown above
            ],
            _SectionHeader(title: 'Other', colors: colors),
            const SizedBox(height: 12),
            _SectionCard(
              colors: colors,
              children: [
                if (!showCaf && !lcoIdMandatory) ...[
                  _WizardTextField(
                    controller: _lcoCustomerIdCtrl,
                    label: sess.baidLabel ?? 'LCO Customer ID',
                    colors: colors,
                    prefixIcon: LucideIcons.hash,
                  ),
                  const SizedBox(height: 12),
                ],
                _WizardTextField(
                  controller: _businessNameCtrl,
                  label: 'Business Name',
                  colors: colors,
                  prefixIcon: LucideIcons.building2,
                ),
                const SizedBox(height: 12),
                _WizardTextField(
                  controller: _remarksCtrl,
                  label: 'Remarks',
                  colors: colors,
                  maxLines: 3,
                  prefixIcon: LucideIcons.messageSquare,
                ),
                const SizedBox(height: 12),
                // GPS coordinates
                Row(
                  children: [
                    Expanded(
                      child: _WizardTextField(
                        controller: _latCtrl,
                        label: 'Latitude',
                        colors: colors,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        prefixIcon: LucideIcons.navigation,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _WizardTextField(
                        controller: _lonCtrl,
                        label: 'Longitude',
                        colors: colors,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        prefixIcon: LucideIcons.navigation,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ── Navigation buttons ───────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _back,
                    icon: const Icon(LucideIcons.arrowLeft, size: 16),
                    label: const Text(
                      'Back',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colors.ink60,
                      side: BorderSide(color: colors.ink20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      minimumSize: const Size(0, 50),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (_validateForm()) _next();
                    },
                    icon: const Icon(LucideIcons.arrowRight, size: 18),
                    label: const Text(
                      'Next: Package',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.red,
                      foregroundColor: colors.card,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                      minimumSize: const Size(0, 50),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// Bill Type Option helper
// =============================================================================

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

// =============================================================================
// Shared Widgets
// =============================================================================

class _StepIndicator extends StatelessWidget {
  final int currentStep;
  final AppColors colors;

  const _StepIndicator({
    required this.currentStep,
    required this.colors,
  });

  static const _labels = ['STB', 'Details', 'Package', 'Confirm'];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: colors.card,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(
        children: List.generate(4, (i) {
          final isActive = i == currentStep;
          final isDone = i < currentStep;
          return Expanded(
            child: Row(
              children: [
                if (i > 0)
                  Expanded(
                    child: Container(
                      height: 2,
                      color: isDone ? colors.red : colors.ink10,
                    ),
                  ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDone
                            ? colors.red
                            : isActive
                                ? colors.red
                                : colors.ink05,
                        border: Border.all(
                          color: isDone || isActive ? colors.red : colors.ink20,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: isDone
                            ? Icon(LucideIcons.check,
                                size: 14, color: colors.card)
                            : Text(
                                '${i + 1}',
                                style: TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color:
                                      isActive ? colors.card : colors.ink40,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _labels[i],
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 11,
                        fontWeight:
                            isActive ? FontWeight.w700 : FontWeight.w500,
                        color: isActive || isDone ? colors.red : colors.ink40,
                      ),
                    ),
                  ],
                ),
                if (i < 3 && i > 0) const SizedBox(),
              ],
            ),
          );
        }),
      ),
    );
  }
}

// ── Reusable form field ──────────────────────────────────────────────────────

class _WizardTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final AppColors colors;
  final bool enabled;
  final bool required;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final int maxLines;

  const _WizardTextField({
    required this.controller,
    required this.label,
    required this.colors,
    this.enabled = true,
    this.required = false,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      style: TextStyle(
        fontFamily: 'Plus Jakarta Sans',
        fontSize: 14,
        color: colors.ink,
      ),
      validator: validator,
      decoration: InputDecoration(
        labelText: required ? '$label *' : label,
        labelStyle: TextStyle(
          fontFamily: 'Plus Jakarta Sans',
          fontSize: 14,
          color: colors.ink40,
        ),
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, size: 18, color: colors.ink40)
            : null,
        suffixIcon: suffixIcon,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: colors.ink10),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: colors.ink10),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: colors.red),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: colors.red),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: colors.ink05),
        ),
        filled: true,
        fillColor: enabled ? colors.card : colors.ink05,
      ),
    );
  }
}

// ── Generic dropdown ─────────────────────────────────────────────────────────

class _WizardDropdown<T> extends StatelessWidget {
  final String label;
  final AppColors colors;
  final T? value;
  final List<T> items;
  final bool isLoading;
  final String Function(T) displayName;
  final ValueChanged<T?> onChanged;
  final IconData? prefixIcon;

  const _WizardDropdown({
    required this.label,
    required this.colors,
    required this.value,
    required this.items,
    required this.displayName,
    required this.onChanged,
    this.isLoading = false,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: value != null && items.contains(value) ? value : null,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          fontFamily: 'Plus Jakarta Sans',
          fontSize: 14,
          color: colors.ink40,
        ),
        prefixIcon: isLoading
            ? Padding(
                padding: const EdgeInsets.all(12),
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colors.ink40,
                  ),
                ),
              )
            : prefixIcon != null
                ? Icon(prefixIcon, size: 18, color: colors.ink40)
                : null,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: colors.ink10),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: colors.ink10),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: colors.red),
        ),
        filled: true,
        fillColor: colors.card,
      ),
      style: TextStyle(
        fontFamily: 'Plus Jakarta Sans',
        fontSize: 14,
        color: colors.ink,
      ),
      items: items
          .map((item) => DropdownMenuItem<T>(
                value: item,
                child: Text(
                  displayName(item),
                  overflow: TextOverflow.ellipsis,
                ),
              ))
          .toList(),
      onChanged: onChanged,
    );
  }
}

// ── Date picker field ────────────────────────────────────────────────────────

class _DatePickerField extends StatelessWidget {
  final String label;
  final AppColors colors;
  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;

  const _DatePickerField({
    required this.label,
    required this.colors,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime(2000, 1, 1),
          firstDate: DateTime(1920),
          lastDate: DateTime.now(),
          builder: (ctx, child) {
            return Theme(
              data: Theme.of(ctx).copyWith(
                colorScheme: ColorScheme.light(
                  primary: colors.red,
                  surface: colors.card,
                ),
              ),
              child: child!,
            );
          },
        );
        if (picked != null) onChanged(picked);
      },
      child: AbsorbPointer(
        child: TextFormField(
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 14,
              color: colors.ink40,
            ),
            prefixIcon:
                Icon(LucideIcons.calendar, size: 18, color: colors.ink40),
            suffixIcon:
                Icon(LucideIcons.chevronDown, size: 18, color: colors.ink40),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: colors.ink10),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: colors.ink10),
            ),
            filled: true,
            fillColor: colors.card,
            hintText: value != null
                ? '${value!.day.toString().padLeft(2, '0')}/${value!.month.toString().padLeft(2, '0')}/${value!.year}'
                : 'Select date',
            hintStyle: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 14,
              color: value != null ? colors.ink : colors.ink40,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Section helpers ──────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final AppColors colors;

  const _SectionHeader({required this.title, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontFamily: 'Plus Jakarta Sans',
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: colors.ink,
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final AppColors colors;
  final List<Widget> children;

  const _SectionCard({required this.colors, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.ink10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final AppColors colors;

  const _InfoRow({
    required this.label,
    required this.value,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 13,
                color: colors.ink40,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: colors.ink,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Barcode Scanner Bottom Sheet
// =============================================================================

class _BarcodeScannerSheet extends StatefulWidget {
  final ValueChanged<String> onScanned;

  const _BarcodeScannerSheet({required this.onScanned});

  @override
  State<_BarcodeScannerSheet> createState() => _BarcodeScannerSheetState();
}

class _BarcodeScannerSheetState extends State<_BarcodeScannerSheet> {
  final _scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
  );
  bool _scanned = false;

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colors.ink20,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Scan STB Barcode',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: colors.ink,
              ),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: MobileScanner(
                  controller: _scannerController,
                  onDetect: (capture) {
                    if (_scanned) return;
                    final barcodes = capture.barcodes;
                    if (barcodes.isNotEmpty &&
                        barcodes.first.rawValue != null) {
                      _scanned = true;
                      widget.onScanned(barcodes.first.rawValue!);
                    }
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: colors.ink60,
                  side: BorderSide(color: colors.ink20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
