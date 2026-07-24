import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../application/providers/core_providers.dart';
import '../../../application/providers/master_data_provider.dart';
import '../../../core/config/app_session.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../core/network/api_exception.dart';
import '../../../data/datasources/remote/customer_remote_datasource.dart';
import '../../../data/datasources/remote/master_data_remote_datasource.dart';
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
  // resellerId from validateBoxInfoRest — sent in saveCustomerRest payload
  String _stbResellerId = '';

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
  final Map<String, String> _custTypeTypesIdByName = {};

  // ── Step 3: Package ────────────────────────────────────────────────────────
  CasPackage? _selectedPackage;
  int _cycle = 1; // Month=1, Year=2, Day=3
  int _quantity = 1;
  int _validityDays = 30;
  List<CasPackage> _packages =[];
  bool _packagesLoading = false;
  String? _packagesError;

  // ── Step 4: Confirm ────────────────────────────────────────────────────────
  bool _isSaving = false;
  bool _isGettingLocation = false;

  // ── Document upload state ──────────────────────────────────────────────
  bool _uploadDocs = false;
  File? _customerPhoto;
  File? _idProofPhoto;
  File? _signaturePhoto;
  String? _customerPhotoBase64;
  String? _idProofPhotoBase64;
  String? _signaturePhotoBase64;

  FlutterExceptionHandler? _prevErrorHandler;

  @override
  void initState() {
    super.initState();
    _prevErrorHandler = FlutterError.onError;
    FlutterError.onError = (details) {
      if (details.toString().contains('_dependents.isEmpty')) {
        debugPrint('═══ [CRASH-DBG] _dependents.isEmpty CAUGHT ═══');
        debugPrint('Exception: ${details.exception}');
        debugPrint('Stack:\n${details.stack}');
        debugPrint('Context: ${details.context}');
        debugPrint('Library: ${details.library}');
        debugPrint('═══ [CRASH-DBG] END ═══');
      }
      _prevErrorHandler?.call(details);
    };
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
      // Resolve resellerId: use session.employeeId as default for pre-filled boxes
      final session = ref.read(appSessionProvider);
      _stbResellerId = (session?.employeeId ?? 0).toString();
      _loadPackages();
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
    FlutterError.onError = _prevErrorHandler;
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
    if (_currentStep < 1) _goToStep(_currentStep + 1);
  }

  bool get _hasVc => _vcController.text.trim().isNotEmpty;

  int _dateTypeFromCycle(int cycle) {
    // Android contract: Month=1, Year=2, Day=3
    if (cycle == 2) return 2;
    if (cycle == 3) return 3;
    return 1;
  }
  Future<void> _loadPackages() async {
    final stb = _stbController.text.trim();
    if (stb.isEmpty) return;
    setState(() {
      _packagesLoading = true;
      _packagesError = null;
    });
    try {
      final session = ref.read(appSessionProvider);
      final ds = PackageRemoteDatasource(dio: ref.read(dioClientProvider));
      final data = await ds.getCasPackages(
        authtoken: session?.token ?? '',
        boxNumber: stb,
      );
      final rawList = data['casPackagesList'] ??
          data['caspackageList'] ??
          data['casPackages'] ??
          data['data'] ??
          [];
      final packages = (rawList as List)
          .whereType<Map<String, dynamic>>()
          .map((e) => CasPackage.fromJson(e))
          .toList();
      if (mounted) {
        setState(() {
          _packages = packages;
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

  Widget _cycleChip(String label, int value, AppColors colors) {
    final selected = _cycle == value;
    return GestureDetector(
      onTap: () => setState(() => _cycle = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? colors.red : colors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? colors.red : colors.ink20,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? colors.card : colors.ink60,
          ),
        ),
      ),
    );
  }

  Future<void> _loadCustomerTypeTypes(CustomerType? customerType) async {
    if (customerType == null) {
      setState(() {
        _selectedCustTypeTypes = null;
        _custTypeTypesList.clear();
        _custTypeTypesIdByName.clear();
      });
      return;
    }
    try {
      final session = ref.read(appSessionProvider);
      final ds = MasterDataRemoteDatasource(dio: ref.read(dioClientProvider));
      final data = await ds.getCustomerTypeTypes(
        authtoken: session?.token ?? '',
        customerTypeId: customerType.customerTypeId.toString(),
      );
      final raw = (data['customerTypeTypesInfoList'] as List?) ??
          (data['customerTypeTypesList'] as List?) ??
          (data['data'] as List?) ??
          const [];

      final parsed = raw
          .whereType<Map<String, dynamic>>()
          .map((e) {
            final name = e['customer_type_name']?.toString() ??
                e['customerTypeName']?.toString() ??
                e['name']?.toString() ??
                '';
            final id = e['customer_type_id']?.toString() ??
                e['customerTypeTypesId']?.toString() ??
                e['id']?.toString() ??
                '';
            return {'name': name.trim(), 'id': id.trim()};
          })
          .where((it) => (it['name'] ?? '').isNotEmpty)
          .toList();

      setState(() {
        _custTypeTypesList
          ..clear()
          ..addAll(parsed.map((e) => e['name']!));
        _custTypeTypesIdByName
          ..clear()
          ..addEntries(parsed.map((e) => MapEntry(e['name']!, e['id']!)));
        _selectedCustTypeTypes = null;
      });
    } catch (_) {
      setState(() {
        _custTypeTypesList.clear();
        _custTypeTypesIdByName.clear();
        _selectedCustTypeTypes = null;
      });
    }
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
    if (stbNo.isEmpty) {
      setState(() => _stbError = 'Please enter an STB serial number');
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
        boxNumber: stbNo,
      );

      final statusCode = result['statusCode'] ?? result['status_code'];
      if (statusCode == 0 || statusCode == '0') {
        setState(() {
          _stbVerified = true;
          _stbVerifying = false;
          _stbInfo = result;
          // Capture resellerId from STB — sent in saveCustomerRest payload (API doc 6.7 / 3.4)
          _stbResellerId = result['resellerId']?.toString() ??
              result['reseller_id']?.toString() ?? '';
        });
        _loadPackages();
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

  Future<void> _getLocation() async {
    setState(() => _isGettingLocation = true);
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location services are disabled. Please enable GPS.')),
          );
        }
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Location permission denied')),
            );
          }
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permission permanently denied. Enable in Settings.')),
          );
        }
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );

      if (mounted) {
        setState(() {
          _latCtrl.text = position.latitude.toString();
          _lonCtrl.text = position.longitude.toString();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Location: ${position.latitude}, ${position.longitude}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to get location: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isGettingLocation = false);
    }
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
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
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
                  borderRadius: BorderRadius.circular(10),
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
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: colors.ink10, width: 1.5),
                  ),
                  alignment: Alignment.center,
                  child: Icon(icon, size: 36, color: colors.green),
                ),
        ),
      ],
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
    debugPrint('[VALIDATE-DBG] Rule 1: md.selectedCustomerType = ${md.selectedCustomerType}');
    if (md.selectedCustomerType == null) {
      debugPrint('[VALIDATE-DBG] Rule 1 FAILED: selectedCustomerType is null');
      return 'Please select a Customer Type!';
    }

    // ── Rule 2: useMandatoryForHotel sub-type required ─────────────────────
    debugPrint('[VALIDATE-DBG] Rule 2: useMandatoryForHotel=${session.useMandatoryForHotel}, '
        'isCommercialMultiBox=${md.selectedCustomerType?.isCommercialMultiBox}, '
        '_selectedCustTypeTypes=$_selectedCustTypeTypes');
     if (session.useMandatoryForHotel == 1 &&
        md.selectedCustomerType!.isCommercialMultiBox == 1 &&
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
    if (_mobileCtrl.text.trim().isEmpty) {
      return 'Mobile number should not be empty';
    }
    if (_mobileCtrl.text.trim().length < 10) {
      return 'Mobile number should not be less than 10 digits';
    }

    // ── Rule 12: PIN code >= 6 digits (always) ────────────────────────────
    if (_pinCodeCtrl.text.trim().isEmpty) {
      return 'Pincode should not be empty';
    }
    if (_pinCodeCtrl.text.trim().length < 6) {
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

    // Country and State are mandatory per creation flow
    if (md.selectedCountry == null) {
      return 'Please select country';
    }
    if (md.selectedState == null) {
      return 'Please select state';
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

    // Package should only be enforced when VC is available.
    // Without VC, customer creation is allowed, but package/STB ops must be blocked.
    final hasVc = _vcController.text.trim().isNotEmpty;
    if (hasVc && _selectedPackage == null) {
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
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(LucideIcons.alertTriangle, color: colors.red, size: 22),
            const SizedBox(width: 8),
            const Expanded(
              child: Text('Validation Error',
                  style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontWeight: FontWeight.w700,
                      fontSize: 16)),
            ),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 14,
              fontWeight: FontWeight.w500),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('OK',
                style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontWeight: FontWeight.w700,
                    color: colors.red)),
          ),
        ],
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

      final hasVc = _hasVc;

      // IMPORTANT: map to server keys exactly (saveCustomerRest_post).
      // Keep this payload minimal & correct to avoid backend mismatch.
      final customerData = <String, dynamic>{
        // Required-ish
        'customerTypeId': (md.selectedCustomerType?.customerTypeId ?? 0).toString(),
        'firstName': _firstNameCtrl.text.trim(),
        'lastName': _lastNameCtrl.text.trim(),
        'mobile': _mobileCtrl.text.trim(),
        'mobileNumber': _mobileCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'fatherName': _fatherNameCtrl.text.trim(),
        'gender': (md.selectedGender?.id ?? '').toString(),
        'dateofbirth': _dob != null
            ? '${_dob!.year}-${_dob!.month.toString().padLeft(2, '0')}-${_dob!.day.toString().padLeft(2, '0')}'
            : '',
        // Identity / misc
        'idType': (md.selectedIdType?.id ?? '').toString(),
        'idNumber': _idNumberCtrl.text.trim(),
        'businessName': _businessNameCtrl.text.trim(),
        'accountNumber': _accountNumberCtrl.text.trim(),
        // Addresses
        'address': _address1Ctrl.text.trim(),
        'address2': _address2Ctrl.text.trim(),
        'pin': _pinCodeCtrl.text.trim(),
        'country': md.selectedCountry?.iso ?? '',
        'countryCode': md.selectedCountry?.iso ?? '',
        'state': md.selectedState?.id.toString() ?? '',
        'stateId': md.selectedState?.id.toString() ?? '',
        'district': md.selectedDistrict?.id.toString() ?? '',
        'districtId': md.selectedDistrict?.id.toString() ?? '',
        'city': md.selectedCity?.locationId.toString() ?? '',
        'cityId': md.selectedCity?.locationId.toString() ?? '',
        'mandal': md.selectedMandal?.mandalId.toString() ?? '',
        'mandalId': md.selectedMandal?.mandalId.toString() ?? '',
        // Installation
        'installationAddress': _sameAsBilling
            ? _address1Ctrl.text.trim()
            : _instAddress1Ctrl.text.trim(),
        'installation_address': _sameAsBilling
            ? _address1Ctrl.text.trim()
            : _instAddress1Ctrl.text.trim(),
        // Group / billing
        'group': (md.selectedGroup?.groupId ?? '').toString(),
        'groupId': (md.selectedGroup?.groupId ?? '').toString(),
        'billType': _billType.toString(),
        'cafNumber': _cafNumberCtrl.text.trim(),
        'lcoCustomerId': _lcoCustomerIdCtrl.text.trim(),
        'remarks': _remarksCtrl.text.trim(),
        'discount': _discountCtrl.text.trim(),
        'latitude': _latCtrl.text.trim(),
        'longitude': _lonCtrl.text.trim(),
        'customerImg': _customerPhotoBase64 ?? '',
        'idProofImg': _idProofPhotoBase64 ?? '',
        'signatureImg': _signaturePhotoBase64 ?? '',
        'customerTypeTypesId': _selectedCustTypeTypes != null
            ? (_custTypeTypesIdByName[_selectedCustTypeTypes!] ?? '')
            : '',

        // STB
        'boxNumber': _stbController.text.trim(),
        // VC number — required for STB-linked customer creation.
        // Was previously missing from payload causing server rejection.
        if (_vcController.text.trim().isNotEmpty)
          'vcNumber': _vcController.text.trim(),
        // reseller_id — required by the server to verify dealer→customer chain.
        // Use STB's resellerId from validateBoxInfoRest, fall back to employeeId.
        'reseller_id': (_stbResellerId.isNotEmpty
            ? _stbResellerId
            : (session?.employeeId ?? 0).toString()),
        // Dealer / Employee IDs — server extracts these from JWT but also
        // validates them in the request body for saveCustomerRest.
        if ((session?.dealerId ?? 0) > 0)
          'dealer_id': session!.dealerId.toString(),
        if ((session?.employeeId ?? 0) > 0)
          'employee_id': session!.employeeId.toString(),
      };
      customerData['resellerId'] = customerData['reseller_id'];
      customerData['phone'] = '';
      customerData['customerapplicationformImg'] = '';
      customerData['dateofanniversary'] = '';
      customerData['ipAddress'] = '';
      customerData['username'] = '';
      customerData['password'] = '';
      customerData['customerId'] = '0';
      customerData['is_surrender'] = '0';
      customerData['packageEndDate'] = '';

      if (hasVc && _selectedPackage != null) {
        customerData['packageId'] = _selectedPackage!.productId;
        customerData['pricingStructureType'] = _selectedPackage!.pricingStructureType;
        customerData['dateType'] = _dateTypeFromCycle(_cycle).toString();
        customerData['quantity'] = _quantity.toString();
        customerData['validityDays'] = (_cycle == 3) ? _validityDays.toString() : '';
      } else {
        customerData['packageId'] = '0';
        customerData['pricingStructureType'] = '';
        customerData['dateType'] = '';
        customerData['quantity'] = '0';
        customerData['validityDays'] = '';
      }

      // ── CRITICAL PAYLOAD DUMP (uses print() — cannot be filtered) ────
      print('========== NEW_CUSTOMER PAYLOAD ==========');
      print('  country   = ${customerData["country"]}');
      print('  state     = ${customerData["state"]}');
      print('  district  = ${customerData["district"]}');
      print('  mandal    = ${customerData["mandal"]}');
      print('  city      = ${customerData["city"]}');
      print('  cityId    = ${customerData["cityId"]}');
      print('  pin       = ${customerData["pin"]}');
      print('  address   = ${customerData["address"]}');
      print('  installationAddress = ${customerData["installationAddress"]}');
      print('  boxNumber = ${customerData["boxNumber"]}');
      print('  selectedCity   = ${md.selectedCity?.locationId}/${md.selectedCity?.locationName}');
      print('  selectedMandal = ${md.selectedMandal?.mandalId}/${md.selectedMandal?.mandalName}');
      print('  ALL KEYS: ${customerData.keys.toList()}');
      print('==========================================');

      if (kDebugMode) {
        debugPrint('[NEW_CUSTOMER] ── Payload ──────────────────────────────');
        debugPrint('[NEW_CUSTOMER] DealerId  : ${session?.dealerId}');
        debugPrint('[NEW_CUSTOMER] EmployeeId: ${session?.employeeId}');
        debugPrint('[NEW_CUSTOMER] UserType  : ${session?.userType}');
        debugPrint('[NEW_CUSTOMER] boxNumber : ${customerData['boxNumber']}');
        debugPrint('[NEW_CUSTOMER] city      : ${customerData['city']}');
        debugPrint('[NEW_CUSTOMER] mandal    : ${customerData['mandal']}');
        debugPrint('[NEW_CUSTOMER] Keys      : ${customerData.keys.toList()}');
        debugPrint('[NEW_CUSTOMER] ─────────────────────────────────────────');
      }

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

      // ── Diagnostic error dialog (shows full server response) ─────────────
      final errMsg = e.toString().replaceAll('ApiException: ', '');
      String serverRaw = '';
      if (e is ApiException && e.data != null) {
        serverRaw = e.data.toString();
      }

      showDialog(
        context: context,
        builder: (ctx) {
          final c = Theme.of(ctx).extension<AppColors>()!;
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: [
                Icon(LucideIcons.alertTriangle, color: c.red, size: 22),
                const SizedBox(width: 8),
                const Text('Customer Creation Failed',
                    style: TextStyle(fontFamily: 'Plus Jakarta Sans',
                        fontWeight: FontWeight.w700, fontSize: 16)),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(errMsg,
                      style: const TextStyle(
                          fontFamily: 'Plus Jakarta Sans', fontSize: 14,
                          fontWeight: FontWeight.w600)),
                  if (serverRaw.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    const Text('Server Response:',
                        style: TextStyle(fontFamily: 'Plus Jakarta Sans',
                            fontWeight: FontWeight.w700, fontSize: 12)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: c.bg,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: c.red.withOpacity(0.3)),
                      ),
                      child: Text(serverRaw,
                          style: const TextStyle(
                              fontFamily: 'monospace', fontSize: 10)),
                    ),
                  ],
                  const SizedBox(height: 12),
                  const Text('📋 Screenshot this dialog and share with developer.',
                      style: TextStyle(fontFamily: 'Plus Jakarta Sans',
                          fontSize: 11, fontStyle: FontStyle.italic)),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text('Close',
                    style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans', color: c.red)),
              ),
            ],
          );
        },
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
        body: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          onPageChanged: (i) => setState(() => _currentStep = i),
          children: [
            // Page 0: STB + Customer Details + Package (merged)
            _buildStep2Form(colors, session),
            // Page 1: Confirm & Save
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
              instPinCode: _sameAsBilling
                  ? _pinCodeCtrl.text.trim()
                  : _instPinCodeCtrl.text.trim(),
              billType: _billType,
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
            const SizedBox(height: 24),
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
    debugPrint('[BUILD-DBG] _buildStep2Form: state=${md.selectedState?.name}, districts=${md.districts.length}, isLoadingDistricts=${md.isLoadingDistricts}, mounted=$mounted');
    final sess = session as AppSession?;
    if (sess == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final showLastName = _showLastName(sess);
    final showCaf = _showCafField(sess);
    final cafMandatory = _isCafMandatory(sess);
    final showAcctNum = _showAccountNumber(sess);
    final showDiscountField = _showDiscount(sess);
    final hotelMode = md.selectedCustomerType?.isCommercialMultiBox == 1;
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
    final isPrefilled = widget.prefilledSerial != null && widget.prefilledSerial!.isNotEmpty;

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── STB Section ────────────────────────────────────────
            _SectionHeader(title: 'Set-Top Box', colors: colors),
            const SizedBox(height: 8),
            if (isPrefilled)
              // Fresh STB: single read-only field (matches Android)
              _SectionCard(
                colors: colors,
                children: [
                  _WizardTextField(
                    controller: _stbController,
                    label: 'STB Number',
                    colors: colors,
                    enabled: false,
                    prefixIcon: LucideIcons.monitor,
                  ),
                ],
              )
            else
              // Manual entry: full scan/verify/reset UI
              _SectionCard(
                colors: colors,
                children: [
                  GestureDetector(
                    onTap: _stbVerified ? null : _openScanner,
                    child: Container(
                      height: 120,
                      decoration: BoxDecoration(
                        color: colors.blueSoft,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _stbVerified ? colors.green : colors.blue,
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _stbVerified
                                ? LucideIcons.checkCircle
                                : LucideIcons.scan,
                            size: 36,
                            color: _stbVerified ? colors.green : colors.blue,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _stbVerified
                                ? 'STB Verified'
                                : 'Tap to Scan STB Barcode',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: _stbVerified ? colors.green : colors.blue,
                            ),
                          ),
                          if (!_stbVerified)
                            Text(
                              'or enter manually below',
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 12,
                                color: colors.ink40,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _WizardTextField(
                    controller: _stbController,
                    label: 'STB Serial Number',
                    colors: colors,
                    enabled: !_stbVerified,
                    prefixIcon: LucideIcons.monitor,
                    suffixIcon: _stbVerified
                        ? Icon(LucideIcons.checkCircle,
                            color: colors.green, size: 20)
                        : null,
                  ),
                  const SizedBox(height: 12),
                  _WizardTextField(
                    controller: _vcController,
                    label: 'VC Number',
                    colors: colors,
                    enabled: !_stbVerified,
                    prefixIcon: LucideIcons.creditCard,
                    suffixIcon: _stbVerified
                        ? Icon(LucideIcons.checkCircle,
                            color: colors.green, size: 20)
                        : null,
                  ),
                  if (_stbError != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colors.redSoft,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(LucideIcons.alertCircle,
                              color: colors.red, size: 18),
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
                  ],
                  const SizedBox(height: 12),
                  if (!_stbVerified)
                    SizedBox(
                      height: 44,
                      width: double.infinity,
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
                            fontSize: 14,
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
                    SizedBox(
                      height: 44,
                      width: double.infinity,
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
                          'Reset STB',
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
                        ),
                      ),
                    ),
                  if (_stbInfo != null && _stbVerified) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colors.greenSoft,
                        borderRadius: BorderRadius.circular(8),
                        border:
                            Border.all(color: colors.green.withAlpha(60)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'STB Information',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: colors.ink,
                            ),
                          ),
                          const SizedBox(height: 4),
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
            const SizedBox(height: 24),

            // ── Identity / Type ──────────────────────────────────────
            _SectionHeader(title: 'Customer Type', colors: colors),
            const SizedBox(height: 8),
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
                  onChanged: (ct) {
                    ref.read(masterDataProvider.notifier).selectCustomerType(ct);
                    _loadCustomerTypeTypes(ct);
                  },
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
            const SizedBox(height: 24),

            // ── CAF / LCO Customer ID ────────────────────────────────
            if (showCaf || lcoIdMandatory) ...[
              _SectionHeader(title: 'Reference Numbers', colors: colors),
              const SizedBox(height: 8),
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
              const SizedBox(height: 24),
            ],

            // ── Personal Information ─────────────────────────────────
            _SectionHeader(title: 'Personal Information', colors: colors),
            const SizedBox(height: 8),
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
            const SizedBox(height: 24),

            // ── Contact Information ──────────────────────────────────
            _SectionHeader(title: 'Contact Information', colors: colors),
            const SizedBox(height: 8),
            _SectionCard(
              colors: colors,
              children: [
                _WizardTextField(
                  controller: _mobileCtrl,
                  label: 'Mobile Number',
                  colors: colors,
                  required: true,
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
            const SizedBox(height: 24),

            // ── Identity Documents ───────────────────────────────────
            _SectionHeader(title: 'Identity', colors: colors),
            const SizedBox(height: 8),
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
            const SizedBox(height: 24),

            // ── Account Number (conditional: useAccountNumber==0) ────
            if (showAcctNum) ...[
              _SectionHeader(title: 'Account', colors: colors),
              const SizedBox(height: 8),
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
              const SizedBox(height: 24),
            ],

            // ── Billing Address ──────────────────────────────────────
            _SectionHeader(title: 'Billing Address', colors: colors),
            const SizedBox(height: 8),
            _SectionCard(
              colors: colors,
              children: [
                _WizardTextField(
                  controller: _address1Ctrl,
                  label: 'Address Line 1',
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
                  required: true,
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
                _WizardDialogSelector<Country>(
                  label: 'Country *',
                  colors: colors,
                  value: md.selectedCountry,
                  items: md.countries,
                  isLoading: md.isLoadingCountries,
                  displayName: (c) => c.name,
                  onChanged: (c) {
                    if (c != null) ref.read(masterDataProvider.notifier).selectCountry(c);
                  },
                  prefixIcon: LucideIcons.globe,
                ),
                const SizedBox(height: 12),

                // State
                _WizardDialogSelector<StateModel>(
                  label: 'State *',
                  colors: colors,
                  value: md.selectedState,
                  items: md.states,
                  isLoading: md.isLoadingStates,
                  displayName: (s) => s.name,
                  onChanged: (s) {
                    debugPrint('[STATE-DBG] onChanged called, s=${s?.name}, mounted=$mounted');
                    if (s != null) {
                      debugPrint('[STATE-DBG] calling selectState...');
                      ref.read(masterDataProvider.notifier).selectState(s);
                      debugPrint('[STATE-DBG] selectState returned');
                    }
                  },
                  emptyMessage: 'Please select a Country first',
                  prefixIcon: LucideIcons.map,
                ),
                const SizedBox(height: 12),

                // District
                _WizardDialogSelector<District>(
                  label: 'District *',
                  colors: colors,
                  value: md.selectedDistrict,
                  items: md.districts,
                  isLoading: md.isLoadingDistricts,
                  displayName: (d) => d.name,
                  onChanged: (d) {
                    if (d != null) ref.read(masterDataProvider.notifier).selectDistrict(d);
                  },
                  emptyMessage: 'Please select a State first',
                  prefixIcon: LucideIcons.mapPin,
                ),
                const SizedBox(height: 12),

                // Mandal (before City — selecting mandal filters city list)
                _WizardDialogSelector<Mandal>(
                  label: isMandalMandatory ? 'Mandal *' : 'Mandal',
                  colors: colors,
                  value: md.selectedMandal,
                  items: md.mandals,
                  isLoading: md.isLoadingMandals,
                  displayName: (m) => m.mandalName,
                  allowDeselect: true,
                  onChanged: (m) {
                    ref.read(masterDataProvider.notifier).selectMandal(m);
                    ref.read(masterDataProvider.notifier).selectCity(null);
                    if (md.selectedDistrict != null) {
                      // m==null means user deselected mandal → reload all district cities
                      ref.read(masterDataProvider.notifier).loadCitiesForMandal(
                        districtId: md.selectedDistrict!.id.toString(),
                        mandalId: m?.mandalId.toString() ?? '0',
                        boxNumber: _stbController.text.trim(),
                      );
                    }
                  },
                  emptyMessage: 'Please select a District first',
                  prefixIcon: LucideIcons.landmark,
                ),
                const SizedBox(height: 12),

                // City (always mandatory per rule 19)
                _WizardDialogSelector<City>(
                  label: 'City *',
                  colors: colors,
                  value: md.selectedCity,
                  items: md.cities,
                  isLoading: md.isLoadingCities,
                  displayName: (c) => c.locationName,
                  onChanged: (c) {
                    print('[CITY-SELECTED] locationId=${c?.locationId} name=${c?.locationName}');
                    ref.read(masterDataProvider.notifier).selectCity(c);
                  },
                  emptyMessage: md.selectedDistrict == null
                      ? 'Please select a District first'
                      : 'No cities configured for this LCO.\nAsk admin to map cities in EB location settings.',
                  prefixIcon: LucideIcons.building,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ── Installation Address ─────────────────────────────────
            _SectionHeader(title: 'Installation Address', colors: colors),
            const SizedBox(height: 8),
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
            const SizedBox(height: 24),

            // ── Group / Billing / Discount ────────────────────────────
            _SectionHeader(title: 'Group & Billing', colors: colors),
            const SizedBox(height: 8),
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
            const SizedBox(height: 24),

            // ── Other ────────────────────────────────────────────────
            if (!showCaf && !lcoIdMandatory) ...[
              // Show LCO ID and CAF in Other section if not shown above
            ],
            _SectionHeader(title: 'Other', colors: colors),
            const SizedBox(height: 8),
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
                SizedBox(
                  height: 44,
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _isGettingLocation ? null : _getLocation,
                    icon: _isGettingLocation
                        ? SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: colors.ink40,
                            ),
                          )
                        : Icon(LucideIcons.mapPin, size: 18),
                    label: Text(
                      _isGettingLocation ? 'Getting Location...' : 'Get Location',
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colors.ink60,
                      side: BorderSide(color: colors.ink20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
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

            // ── Documents Section ────────────────────────────────────
            Row(
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Checkbox(
                    value: _uploadDocs,
                    onChanged: (v) => setState(() => _uploadDocs = v ?? false),
                    activeColor: colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Upload Photo, ID Proof and Signature',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 14,
                    color: colors.ink80,
                  ),
                ),
              ],
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
                colors: colors,
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
                colors: colors,
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
                colors: colors,
              ),
            ],
            const SizedBox(height: 24),

            // ── Package Selection (inline) ───────────────────────────
            if (_hasVc) ...[
              Text(
                'PACKAGE',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: colors.ink60,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),

              if (_packagesLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: LinearProgressIndicator(),
                ),

              if (_packagesError != null && !_packagesLoading)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _packagesError!,
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: colors.red,
                      ),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: _loadPackages,
                      icon: const Icon(LucideIcons.refreshCw, size: 16),
                      label: const Text('Retry Packages'),
                    ),
                  ],
                ),

              if (!_packagesLoading && _packagesError == null)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _packages.isEmpty
                        ? null
                        : () async {
                            final result = await _openSelectorDialog<CasPackage>(
                              context: context,
                              title: 'SELECT PACKAGE',
                              items: _packages,
                              displayName: (p) =>
                                  '${p.productName} (₹${p.price.toStringAsFixed(2)})',
                              colors: colors,
                              current: _selectedPackage,
                              prefixIcon: LucideIcons.package2,
                            );
                            if (result != null) {
                              setState(() {
                                _selectedPackage = result.item;
                                if (_selectedPackage != null) {
                                  if (_selectedPackage!.pricingStructureType == '1') {
                                    _cycle = 1;
                                  } else {
                                    _cycle = 2;
                                  }
                                }
                              });
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.blue,
                      foregroundColor: colors.card,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      _selectedPackage?.productName ?? 'Select Package',
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),

              if (_selectedPackage != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colors.red.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: colors.red.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedPackage!.productName,
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: colors.ink,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ID: ${_selectedPackage!.productId}  |  '
                        '${_selectedPackage!.pricingStructureType == '1' ? 'One-time' : 'Recurring'}  |  '
                        '₹${_selectedPackage!.price.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontFamily: 'JetBrains Mono',
                          fontSize: 12,
                          color: colors.ink60,
                        ),
                      ),
                      const SizedBox(height: 12),

                      Text('Cycle', style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: colors.ink60,
                      )),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          _cycleChip('Year', 2, colors),
                          const SizedBox(width: 8),
                          if (_selectedPackage!.pricingStructureType == '1') ...[
                            _cycleChip('Month', 1, colors),
                            const SizedBox(width: 8),
                            _cycleChip('Day', 3, colors),
                          ],
                        ],
                      ),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Text('Quantity: ', style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: colors.ink60,
                          )),
                          SizedBox(
                            width: 60,
                            child: TextFormField(
                              initialValue: _quantity.toString(),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              style: const TextStyle(
                                fontFamily: 'JetBrains Mono',
                                fontSize: 14,
                              ),
                              decoration: InputDecoration(
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 8,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  borderSide: BorderSide(color: colors.ink20),
                                ),
                              ),
                              onChanged: (v) {
                                _quantity = int.tryParse(v) ?? 1;
                              },
                            ),
                          ),
                        ],
                      ),

                      if (_cycle == 3) ...[
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Text('Validity (days): ', style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: colors.ink60,
                            )),
                            SizedBox(
                              width: 80,
                              child: TextFormField(
                                initialValue: _validityDays.toString(),
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                style: const TextStyle(
                                  fontFamily: 'JetBrains Mono',
                                  fontSize: 14,
                                ),
                                decoration: InputDecoration(
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 8,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(6),
                                    borderSide: BorderSide(color: colors.ink20),
                                  ),
                                ),
                                onChanged: (v) {
                                  _validityDays = int.tryParse(v) ?? 30;
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),
            ],

            // ── Navigation button ─────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  if (_validateForm()) _next();
                },
                icon: const Icon(LucideIcons.arrowRight, size: 18),
                label: const Text(
                  'Review & Create',
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
                ),
              ),
            ),
            const SizedBox(height: 24),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: label,
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 14,
                  color: colors.ink40,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (required)
                TextSpan(
                  text: ' *',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 14,
                    color: colors.red,
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
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
            hintText: label,
            hintStyle: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 13,
              color: colors.ink20,
            ),
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, size: 18, color: colors.ink40)
                : null,
            suffixIcon: suffixIcon,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: colors.ink10, width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: colors.ink10, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: colors.red, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: colors.red, width: 1.5),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: colors.ink05, width: 1.5),
            ),
            filled: true,
            fillColor: enabled ? colors.card : colors.ink05,
          ),
        ),
      ],
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
    final hasRequired = label.endsWith(' *');
    final baseLabel = hasRequired ? label.substring(0, label.length - 2) : label;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: baseLabel,
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 14,
                  color: colors.ink40,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (hasRequired)
                TextSpan(
                  text: ' *',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 14,
                    color: colors.red,
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<T>(
          value: value != null && items.contains(value) ? value : null,
          isExpanded: true,
          decoration: InputDecoration(
            hintText: 'Select $baseLabel',
            hintStyle: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 13,
              color: colors.ink20,
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
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: colors.ink10, width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: colors.ink10, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: colors.red, width: 1.5),
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
        ),
      ],
    );
  }
}

// ── Sentinel wrapper so we can distinguish cancel vs deselect ────────────────
class _Selected<T> {
  final T? item;
  const _Selected(this.item);
}

// ── Dialog-based selector (replaces DropdownButtonFormField for address) ──────

class _WizardDialogSelector<T> extends StatelessWidget {
  final String label;
  final AppColors colors;
  final T? value;
  final List<T> items;
  final bool isLoading;
  final String Function(T) displayName;
  final ValueChanged<T?> onChanged;
  final IconData? prefixIcon;
  final String? emptyMessage;
  final bool allowDeselect;

  const _WizardDialogSelector({
    required this.label,
    required this.colors,
    required this.value,
    required this.items,
    required this.displayName,
    required this.onChanged,
    this.isLoading = false,
    this.prefixIcon,
    this.emptyMessage,
    this.allowDeselect = false,
  });

  @override
  Widget build(BuildContext context) {
    final hasRequired = label.endsWith(' *');
    final baseLabel = hasRequired ? label.substring(0, label.length - 2) : label;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: baseLabel,
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 14,
                  color: colors.ink40,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (hasRequired)
                TextSpan(
                  text: ' *',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 14,
                    color: colors.red,
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: isLoading
              ? null
              : () async {
                  if (items.isEmpty) {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        title: Row(
                          children: [
                            Icon(LucideIcons.info, color: colors.blue, size: 22),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                baseLabel,
                                style: const TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        content: Text(
                          emptyMessage ?? 'No $baseLabel data available.',
                          style: const TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 14,
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: Text(
                              'OK',
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontWeight: FontWeight.w700,
                                color: colors.red,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                    return;
                  }
                  final result = await _openSelectorDialog<T>(
                    context: context,
                    title: baseLabel,
                    items: items,
                    displayName: displayName,
                    colors: colors,
                    current: value,
                    prefixIcon: prefixIcon,
                    allowDeselect: allowDeselect,
                  );
                  debugPrint('[SELECTOR-DBG] dialog returned for $baseLabel, result=$result, context.mounted=${context.mounted}');
                  if (result != null) {
                    debugPrint('[SELECTOR-DBG] calling onChanged for $baseLabel');
                    onChanged(result.item);
                    debugPrint('[SELECTOR-DBG] onChanged returned for $baseLabel');
                  }
                },
          borderRadius: BorderRadius.circular(10),
          child: InputDecorator(
            isEmpty: value == null && !isLoading,
            decoration: InputDecoration(
              hintText: 'Select $baseLabel',
              hintStyle: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 13,
                color: colors.ink20,
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
              suffixIcon:
                  Icon(LucideIcons.chevronDown, size: 18, color: colors.ink40),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: colors.ink10, width: 1.5),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: colors.ink10, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: colors.red, width: 1.5),
              ),
              filled: true,
              fillColor: colors.card,
            ),
            child: Text(
              isLoading
                  ? 'Loading...'
                  : value != null
                      ? displayName(value as T)
                      : '',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 14,
                color: value != null ? colors.ink : colors.ink20,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }
}

Future<_Selected<T>?> _openSelectorDialog<T>({
  required BuildContext context,
  required String title,
  required List<T> items,
  required String Function(T) displayName,
  required AppColors colors,
  T? current,
  IconData? prefixIcon,
  bool allowDeselect = false,
}) async {
  return showDialog<_Selected<T>>(
    context: context,
    builder: (ctx) {
      return _SelectorDialogContent<T>(
        title: title,
        items: items,
        displayName: displayName,
        colors: colors,
        current: current,
        prefixIcon: prefixIcon,
        allowDeselect: allowDeselect,
      );
    },
  );
}

// ── Selector dialog content (StatefulWidget — owns its own TextEditingController lifecycle) ──

class _SelectorDialogContent<T> extends StatefulWidget {
  final String title;
  final List<T> items;
  final String Function(T) displayName;
  final AppColors colors;
  final T? current;
  final IconData? prefixIcon;
  final bool allowDeselect;

  const _SelectorDialogContent({
    required this.title,
    required this.items,
    required this.displayName,
    required this.colors,
    this.current,
    this.prefixIcon,
    this.allowDeselect = false,
  });

  @override
  State<_SelectorDialogContent<T>> createState() =>
      _SelectorDialogContentState<T>();
}

class _SelectorDialogContentState<T>
    extends State<_SelectorDialogContent<T>> {
  late TextEditingController _searchCtrl;
  late List<T> _filtered;

  @override
  void initState() {
    super.initState();
    _searchCtrl = TextEditingController();
    _filtered = List<T>.from(widget.items);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors;

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      titlePadding: EdgeInsets.zero,
      contentPadding: EdgeInsets.zero,
      title: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: colors.blueSoft,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Row(
          children: [
            if (widget.prefixIcon != null) ...[
              Icon(widget.prefixIcon, size: 18, color: colors.blue),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Text(
                'Select ${widget.title}',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: colors.ink,
                ),
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Icon(LucideIcons.x, size: 20, color: colors.ink40),
            ),
          ],
        ),
      ),
      content: SizedBox(
        width: double.maxFinite,
        height: MediaQuery.of(context).size.height * 0.5,
        child: Column(
          children: [
            if (widget.items.length > 5)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: TextField(
                  controller: _searchCtrl,
                  autofocus: true,
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search ${widget.title}...',
                    hintStyle: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 13,
                      color: colors.ink20,
                    ),
                    prefixIcon: Icon(LucideIcons.search,
                        size: 18, color: colors.ink40),
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
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    filled: true,
                    fillColor: colors.card,
                  ),
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
                ),
              ),
            const SizedBox(height: 4),
            Expanded(
              child: _filtered.isEmpty
                  ? Center(
                      child: Text(
                        'No results found',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 14,
                          color: colors.ink40,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount:
                          _filtered.length + (widget.allowDeselect ? 1 : 0),
                      itemBuilder: (_, i) {
                        if (widget.allowDeselect && i == 0) {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                dense: true,
                                contentPadding:
                                    const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 2),
                                title: Text(
                                  '— None —',
                                  style: TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: colors.ink40,
                                  ),
                                ),
                                onTap: () => Navigator.of(context)
                                    .pop(_Selected<T>(null)),
                              ),
                              Divider(height: 1, color: colors.ink05),
                            ],
                          );
                        }
                        final item =
                            _filtered[i - (widget.allowDeselect ? 1 : 0)];
                        final isSelected = widget.current != null &&
                            widget.displayName(item) ==
                                widget.displayName(widget.current as T);
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              dense: true,
                              selected: isSelected,
                              selectedTileColor: colors.blueSoft,
                              contentPadding:
                                  const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 2),
                              title: Text(
                                widget.displayName(item),
                                style: TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: 14,
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: colors.ink,
                                ),
                              ),
                              trailing: isSelected
                                  ? Icon(LucideIcons.check,
                                      size: 16, color: colors.blue)
                                  : null,
                              onTap: () {
                                Navigator.of(context)
                                    .pop(_Selected(item));
                              },
                            ),
                            if (i <
                                _filtered.length -
                                    1 +
                                    (widget.allowDeselect ? 1 : 0))
                              Divider(height: 1, color: colors.ink05),
                          ],
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
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: colors.ink10, width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: colors.ink10, width: 1.5),
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
        fontSize: 15,
        fontWeight: FontWeight.w800,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
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
