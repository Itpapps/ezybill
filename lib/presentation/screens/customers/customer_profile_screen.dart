import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../application/providers/customer_provider.dart';
import '../../../core/config/app_session.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../common/widgets/circle_action_bar.dart';
import '../../common/widgets/status_dot.dart';
import '../../common/widgets/user_avatar.dart';
import '../../../l10n/app_localizations.dart';
import '../../router/route_names.dart';

class CustomerProfileScreen extends ConsumerStatefulWidget {
  final String customerId;
  final String? customerName;
  final String? initialSerialNumber;
  final String? initialVcNumber;
  final Map<String, dynamic>? initialData;

  const CustomerProfileScreen({
    super.key,
    required this.customerId,
    this.customerName,
    this.initialSerialNumber,
    this.initialVcNumber,
    this.initialData,
  });

  @override
  ConsumerState<CustomerProfileScreen> createState() =>
      _CustomerProfileScreenState();
}

class _CustomerProfileScreenState
    extends ConsumerState<CustomerProfileScreen> {
  AppLocalizations get l => AppLocalizations.of(context)!;
  bool _isLoading = true;
  bool _isUpdatingLocation = false;
  String? _error;
  Map<String, dynamic> _customer = {};

  @override
  void initState() {
    super.initState();
    // Pre-populate from route extras so UI shows data immediately
    if (widget.initialData != null && widget.initialData!.isNotEmpty) {
      _customer = {
        'customer_id': widget.customerId,
        'customer_name': widget.initialData!['customerName'] ?? widget.customerName ?? '',
        'mobile_no': widget.initialData!['mobileNumber'] ?? '',
        'account_number': widget.initialData!['accountNumber'] ?? '',
        'status': widget.initialData!['status'] ?? '',
        'pending_amount': widget.initialData!['pendingAmount'] ?? 0.0,
        'billing_address': widget.initialData!['billingAddress'] ?? '',
        'serial_number': widget.initialData!['serialNumber'] ?? widget.initialSerialNumber ?? '',
        'vc_number': widget.initialData!['vcNumber'] ?? widget.initialVcNumber ?? '',
        'caf_no': widget.initialData!['cafNumber'] ?? '',
      };
    }
    _loadCustomer();
  }

  Future<void> _loadCustomer() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    // Guard: don't call API with empty/invalid customer ID (e.g. fresh STBs)
    final id = widget.customerId.trim();
    if (id.isEmpty || id == 'null' || id == '0') {
      setState(() {
        _isLoading = false;
        _customer = {
          'customer_id': id,
          'customer_name': widget.customerName ?? 'Fresh STB',
        };
        _error = 'This is a fresh STB with no customer assigned yet.';
      });
      return;
    }

    try {
      final ds = ref.read(customerRemoteDatasourceProvider);
      final session = ref.read(appSessionProvider);

      if (session == null || session.token.isEmpty) {
        throw Exception('Session expired. Please log in again.');
      }

      final data = await ds.getCustomerDetails(
        authtoken: session.token,
        customerNumber: widget.customerId,
        startValue: 0,
        endValue: 1,
      );

      debugPrint('[PROFILE] Response top-level keys: ${data.keys.toList()}');

      // ── [DEBUG PROBE] existingCustomerRest with accountNumber ──────────
      // Fires in parallel — does NOT affect loading state or displayed data.
      // Purpose: capture the real field names inside existCustomerDetails
      //          when a customer is found on a V1 server.
      // Remove once profile fix is finalised.
      ds.probeExistingCustomerByAccountNumber(
        authtoken: session.token,
        accountNumber: widget.customerId,
      ).then((raw) {
        debugPrint('[PROBE-existingCustomerRest] ── RAW RESPONSE ──');
        debugPrint('[PROBE-existingCustomerRest] top-level keys: ${raw.keys.toList()}');
        debugPrint('[PROBE-existingCustomerRest] status_code: ${raw['status_code']}');
        debugPrint('[PROBE-existingCustomerRest] statusCode:  ${raw['statusCode']}');
        debugPrint('[PROBE-existingCustomerRest] status_msg:  ${raw['status_msg']}');
        final details = raw['existCustomerDetails'];
        if (details is List && details.isNotEmpty) {
          debugPrint('[PROBE-existingCustomerRest] existCustomerDetails length: ${details.length}');
          final first = details[0];
          if (first is Map) {
            debugPrint('[PROBE-existingCustomerRest] first record keys: ${first.keys.toList()}');
            first.forEach((k, v) {
              debugPrint('[PROBE-existingCustomerRest]   $k = $v');
            });
          }
        } else {
          debugPrint('[PROBE-existingCustomerRest] existCustomerDetails = $details');
          // Print every top-level value to see what else was returned
          raw.forEach((k, v) {
            debugPrint('[PROBE-existingCustomerRest] top[$k] = $v');
          });
        }
      }).catchError((e) {
        debugPrint('[PROBE-existingCustomerRest] ERROR: $e');
      });
      // ── end DEBUG PROBE ─────────────────────────────────────────────────

      Map<String, dynamic>? found;

      // Try extracting customer data from known list keys
      for (final key in [
        'customerDetailsList',
        'existCustomerDetails',
        'customerDetails',
        'data',
      ]) {
        final raw = data[key];
        if (raw is List && raw.isNotEmpty) {
          final first = raw[0];
          if (first is Map) {
            found = Map<String, dynamic>.from(first);
            debugPrint('[PROFILE] Found data under "$key" — keys: ${found.keys.toList()}');
            break;
          }
        } else if (raw is Map && raw.isNotEmpty) {
          // Some endpoints return a Map directly instead of a List
          found = Map<String, dynamic>.from(raw);
          debugPrint('[PROFILE] Found data as Map under "$key" — keys: ${found.keys.toList()}');
          break;
        }
      }

      // Validate found data has a real customer (not server placeholder with empty IDs)
      if (found != null) {
        final custId = found['customer_id'] ?? found['customerId'] ?? '';
        final custName = found['customer_name'] ?? found['customerName'] ?? '';
        final isPlaceholder = custId.toString().isEmpty && custName.toString().isEmpty;

        if (isPlaceholder) {
          debugPrint('[PROFILE] API returned placeholder with empty ID+Name — treating as not found');
          found = null;
        }
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
          if (found != null && found.isNotEmpty) {
            final oldSerial = _customer['serial_number']?.toString() ?? '';
            final oldVc = _customer['vc_number']?.toString() ?? '';
            _customer = _normalizeCustomerData(found);
            if (_customer['serial_number']?.toString().isEmpty ?? true) {
              _customer['serial_number'] = oldSerial;
            }
            if (_customer['vc_number']?.toString().isEmpty ?? true) {
              _customer['vc_number'] = oldVc;
            }
            debugPrint('[PROFILE] Normalized customer: '
                'name=${_customer['customer_name']}, '
                'mobile=${_customer['mobile_no']}, '
                'account=${_customer['account_number']}, '
                'pending=${_customer['pending_amount']}');
          } else {
            debugPrint('[PROFILE] No customer data found in response');
            // Only set error if we don't already have pre-populated data
            if (_customer.isEmpty || _customer['customer_name']?.toString().isEmpty == true) {
              _customer = {
                'customer_id': widget.customerId,
                'customer_name': widget.customerName ?? 'Customer',
              };
              _error = 'Could not load customer details. Pull down to retry.';
            }
          }
        });
      }
    } catch (e) {
      debugPrint('[PROFILE] Load error: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          // Only show error and overwrite if we don't have pre-populated data
          if (_customer.isEmpty || _customer['customer_name']?.toString().isEmpty == true) {
            _error = e.toString().replaceAll('Exception: ', '').replaceAll('ApiException: ', '');
            _customer = {
              'customer_id': widget.customerId,
              'customer_name': widget.customerName ?? 'Customer',
            };
          }
        });
      }
    }
  }

  /// Normalize the raw server map into a consistent set of standard keys.
  /// The server may return camelCase, snake_case, or mixed keys depending
  /// on the API endpoint and DB query aliases. This maps all known variants
  /// to a single canonical key set for reliable reading.
  Map<String, dynamic> _normalizeCustomerData(Map<String, dynamic> raw) {
    final n = <String, dynamic>{};

    // Keep the original raw map intact for pass-through to edit screen
    n.addAll(raw);

    // ── Helper: pick first non-null/non-empty value from candidate keys ──
    String s(List<String> keys, [String fallback = '']) {
      for (final k in keys) {
        final v = raw[k];
        if (v != null && v.toString().isNotEmpty) return v.toString();
      }
      return fallback;
    }

    dynamic d(List<String> keys) {
      for (final k in keys) {
        if (raw[k] != null) return raw[k];
      }
      return null;
    }

    // ── Map each field to a canonical key ────────────────────────────────
    n['customer_id'] = s(['customer_id', 'customerId']);
    n['customer_name'] = s(['customer_name', 'customerName', 'customer_Name']);
    n['mobile_no'] = s(['mobile_no', 'mobileNumber', 'mobile_number', 'mobileNo']);
    n['account_number'] = s(['account_number', 'accountNumber', 'accountnumber']);
    n['caf_no'] = s(['caf_no', 'cafNumber', 'caf_number', 'cafNo']);
    n['crf_number'] = s(['crf_number', 'crfNumber', 'crf_no']);
    n['pin_code'] = s(['pin_code', 'pinCode', 'pincode']);
    n['billing_address'] = s([
      'billing_address', 'billingAddress',
      'billing_address1', 'billingAddress1', 'address1',
    ]);
    n['billing_address2'] = s([
      'billing_address2', 'billingAddress2', 'address2',
    ]);
    n['installation_address'] = s([
      'installation_address', 'installationAddress',
      'installation_address1', 'installationAddress1',
    ]);
    n['status'] = s(['status'], '1');
    n['pending_amount'] = d(['pending_amount', 'pendingAmount']) ?? 0;
    n['bill_type'] = s(['bill_type', 'billType']);
    n['reseller_id'] = s(['reseller_id', 'resellerId']);
    n['email'] = s(['email', 'emailId', 'email_id']);
    n['phone_no'] = s(['phone_no', 'phoneNumber', 'phone_number', 'phone']);
    n['gender'] = s(['gender', 'genderId', 'gender_id']);
    n['latitude'] = d(['latitude', 'lati', 'lat', 'Latitude']) ?? 0.0;
    n['longitude'] = d(['longitude', 'longi', 'lng', 'lon', 'Longitude']) ?? 0.0;
    n['serial_number'] = s(['serial_number', 'box_number', 'boxNumber', 'serialNumber', 'stb_no']);
    n['vc_number'] = s(['vc_number', 'vcNumber', 'vc_no']);
    n['baid'] = s(['baid', 'lcoCustomerId', 'lco_customer_id']);
    n['group_id'] = s(['group_id', 'groupId']);
    n['group_name'] = s(['group_name', 'groupName']);
    n['customer_type_id'] = s(['customer_type_id', 'customerTypeId']);
    n['id_type'] = s(['id_type', 'idType']);
    n['id_number'] = s(['id_number', 'idNumber']);
    n['is_direct_lco'] = d(['is_direct_lco', 'isDirectLco']) ?? 0;
    n['location_name'] = s(['location_name', 'city_name', 'city']);
    n['state_name'] = s(['state_name', 'state']);
    n['stb_count'] = d(['stbCount', 'stb_count']) ?? 0;

    return n;
  }

  /// Multi-key lookup — returns first non-empty match.
  String _fm(List<String> keys, [String fallback = '']) {
    for (final k in keys) {
      final v = _customer[k];
      if (v != null && v.toString().isNotEmpty) return v.toString();
    }
    return fallback;
  }

  String get _name =>
      _fm(['customer_name', 'customerName'], widget.customerName ?? 'Customer')
          .trim();

  String get _statusString {
    final s = _fm(['status'], '1');
    if (s == '1' || s.toLowerCase() == 'active') return 'Active';
    if (s == '0' || s.toLowerCase() == 'deactivated' || s.toLowerCase() == 'inactive') {
      return 'Deactivated';
    }
    if (s.toLowerCase() == 'suspended') return 'Suspended';
    if (s.toLowerCase() == 'fresh' || s.toLowerCase() == 'new') return 'Fresh';
    return 'Active';
  }

  double get _pendingAmount {
    final val = _customer['pending_amount'] ?? _customer['pendingAmount'] ?? 0;
    if (val is double) return val;
    if (val is int) return val.toDouble();
    return double.tryParse(val.toString()) ?? 0.0;
  }

  String get _mobile =>
      _fm(['mobile_no', 'mobileNumber', 'mobile_number', 'mobileNo']);

  String get _area =>
      _fm(['area', 'location', 'billing_address', 'billingAddress', 'address1', 'location_name']);

  String get _billingAddress {
    final parts = <String>[];
    final a1 = _fm(['billing_address', 'billingAddress', 'address1', 'billingAddress1', 'billing_address1']);
    final a2 = _fm(['billing_address2', 'billingAddress2', 'address2']);
    final city = _fm(['location_name', 'city_name', 'city']);
    final state = _fm(['state_name', 'state']);
    final country = _fm(['country_name', 'country']);
    if (a1.isNotEmpty) parts.add(a1);
    if (a2.isNotEmpty) parts.add(a2);
    if (city.isNotEmpty) parts.add(city);
    if (state.isNotEmpty) parts.add(state);
    if (country.isNotEmpty) parts.add(country);
    return parts.join(', ');
  }

  String get _pinCode =>
      _fm(['pin_code', 'pinCode', 'pincode']);

  String get _cafNo =>
      _fm(['caf_no', 'cafNumber', 'crf_number', 'crfNumber', 'caf_number']);

  String get _accountNo =>
      _fm(['account_number', 'accountNumber', 'accountnumber']);

  double _readLat() {
    final v = _customer['latitude'] ??
        _customer['lati'] ??
        _customer['lat'] ??
        _customer['Latitude'];
    return double.tryParse(v?.toString() ?? '') ?? 0.0;
  }

  double _readLng() {
    final v = _customer['longitude'] ??
        _customer['longi'] ??
        _customer['lng'] ??
        _customer['lon'] ??
        _customer['Longitude'];
    return double.tryParse(v?.toString() ?? '') ?? 0.0;
  }

  Future<void> _updateLocation() async {
    final session = ref.read(appSessionProvider);
    if (session == null) return;

    setState(() => _isUpdatingLocation = true);

    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) {
        if (mounted) {
          _showSnackBar(
            'Location services are disabled. Please enable GPS.',
            isError: true,
          );
        }
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            _showSnackBar('Location permission denied', isError: true);
          }
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          _showSnackBar(
            'Location permission permanently denied. Enable in Settings.',
            isError: true,
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

      final ds = ref.read(customerRemoteDatasourceProvider);
      await ds.updateCustomerLocation(
        authtoken: session.token,
        customerId: widget.customerId,
        latitude: position.latitude,
        longitude: position.longitude,
      );

      if (mounted) {
        setState(() {
          _customer['latitude'] = position.latitude;
          _customer['longitude'] = position.longitude;
        });
        _showSnackBar('Location updated successfully');
      }
    } catch (e) {
      debugPrint('[PROFILE] Location update error: $e');
      if (mounted) {
        _showSnackBar(
          e.toString().replaceAll('ApiException: ', ''),
          isError: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUpdatingLocation = false);
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    final c = Theme.of(context).extension<AppColors>()!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: isError ? c.red : c.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.smBR),
      ),
    );
  }

  Future<void> _viewOnMap() async {
    final latitude = _readLat();
    final longitude = _readLng();
    if (latitude == 0.0 && longitude == 0.0) {
      _showSnackBar('No location data available. Please update location first.',
          isError: true);
      return;
    }
    try {
      final uri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
      );
      final launched =
          await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched && mounted) {
        _showSnackBar('Could not open Maps app', isError: true);
      }
    } catch (e) {
      debugPrint('[PROFILE] View on map error: $e');
      if (mounted) {
        _showSnackBar('Failed to open map: $e', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;
    final tt = Theme.of(context).textTheme;
    final session = ref.watch(appSessionProvider);
    final cafLabel = (session?.useCRF == 1) ? 'CRF No' : 'CAF No';
    final currencySymbol = session?.currencySymbol ?? '\u20B9';

    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(
        title: Text(
          _name,
          style: tt.titleMedium,
          overflow: TextOverflow.ellipsis,
        ),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.phone, size: 20),
            onPressed: _mobile.isNotEmpty && _mobile != '0'
                ? () async {
                    final uri = Uri(scheme: 'tel', path: _mobile);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri);
                    }
                  }
                : null,
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(color: c.red),
            )
          : RefreshIndicator(
              color: c.red,
              onRefresh: _loadCustomer,
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  // ── Error banner ──────────────────────────────────────
                  if (_error != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      color: c.redSoft,
                      child: Text(
                        _error!,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: c.red,
                        ),
                      ),
                    ),

                  // ── Profile hero section ──────────────────────────────
                  _buildProfileSection(c, tt),

                  const SizedBox(height: 16),

                  // ── Detail grid ───────────────────────────────────────
                  _buildDetailGrid(c, tt, cafLabel, currencySymbol),

                  const SizedBox(height: 16),

                  // ── Circle action bar ─────────────────────────────────
                  _buildCircleActions(c, session),

                  const SizedBox(height: 8),

                  // ── Additional action buttons ─────────────────────────
                  _buildActionButtons(c, tt, session),

                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileSection(AppColors c, TextTheme tt) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      color: c.card,
      child: Column(
        children: [
          UserAvatar(name: _name, size: 64),
          const SizedBox(height: 12),
          Text(
            _name,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: c.ink,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              StatusDot(status: _statusString),
              const SizedBox(width: 6),
              Text(
                _statusString,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: c.ink60,
                ),
              ),
              if (_area.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Text(
                    '\u00B7',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: c.ink20,
                    ),
                  ),
                ),
                Flexible(
                  child: Text(
                    _area,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: c.ink40,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailGrid(
    AppColors c,
    TextTheme tt,
    String cafLabel,
    String currencySymbol,
  ) {
    final pending = _pendingAmount;
    final pendingColor = pending > 0 ? c.red : c.greenDot;

    final cells = <_GridCell>[
      _GridCell(
        label: 'CUSTOMER NAME',
        value: _name,
      ),
      _GridCell(
        label: 'A/C NUMBER',
        value: _accountNo.isNotEmpty ? _accountNo : '-',
      ),
      _GridCell(
        label: cafLabel.toUpperCase(),
        value: _cafNo.isNotEmpty ? _cafNo : '-',
      ),
      _GridCell(
        label: l.mobile.toUpperCase(),
        value: _mobile.isNotEmpty ? _mobile : '-',
      ),
      _GridCell(
        label: 'STATUS',
        value: _statusString,
      ),
      _GridCell(
        label: 'PINCODE',
        value: _pinCode.isNotEmpty ? _pinCode : '-',
      ),
      _GridCell(
        label: 'BILLING ADDRESS',
        value: _billingAddress.isNotEmpty ? _billingAddress : '-',
      ),
      _GridCell(
        label: 'DUE AMOUNT',
        value: formatCurrency(pending, symbol: currencySymbol),
        valueColor: pendingColor,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: c.ink05,
          borderRadius: AppRadius.cardBR,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: _buildGridRows(cells, c),
        ),
      ),
    );
  }

  List<Widget> _buildGridRows(List<_GridCell> cells, AppColors c) {
    final rows = <Widget>[];
    for (int i = 0; i < cells.length; i += 2) {
      final left = cells[i];
      final right = (i + 1 < cells.length) ? cells[i + 1] : null;
      rows.add(
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _buildGridCell(left, c)),
              Container(width: 1, color: c.ink05),
              Expanded(
                child: right != null
                    ? _buildGridCell(right, c)
                    : Container(color: c.card),
              ),
            ],
          ),
        ),
      );
      if (i + 2 < cells.length) {
        rows.add(Container(height: 1, color: c.ink05));
      }
    }
    return rows;
  }

  Widget _buildGridCell(_GridCell cell, AppColors c) {
    return Container(
      color: c.card,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            cell.label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: c.ink20,
              letterSpacing: 0.06 * 9,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            cell.value,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: cell.valueColor ?? c.ink,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleActions(AppColors c, AppSession? session) {
    final actions = <CircleAction>[];

    // Recharge — gated on payment not blocked
    if (session?.isPaymentBlocked != true) {
      actions.add(CircleAction(
        icon: LucideIcons.indianRupee,
        label: 'Recharge',
        color: c.red,
        onTap: () => context.push(
          RouteNames.makePayment,
          extra: {
            'customerId': widget.customerId,
            'customerName': _name,
            'pendingAmount': _pendingAmount,
            'resellerId': _fm(['reseller_id', 'resellerId']),
            'billType': _fm(['bill_type', 'billType']),
            'address': _billingAddress,
            'accountNumber': _accountNo,
          },
        ),
      ));
    }

    // Packages
    actions.add(CircleAction(
      icon: LucideIcons.box,
      label: 'Packages',
      color: c.ink60,
      onTap: () => context.push(
        RouteNames.packageOperations,
        extra: {
          'customerId': widget.customerId,
          'customerName': _name,
        },
      ),
    ));

    // Complaints — gated on access
    if (session?.canAccessComplaints == true) {
      actions.add(CircleAction(
        icon: LucideIcons.messageSquare,
        label: 'Complaints',
        color: c.amber,
        onTap: () => context.push(
          RouteNames.complaints,
          extra: {
            'customerId': widget.customerId,
            'customerName': _name,
            'resellerId': _fm(['reseller_id', 'resellerId']),
          },
        ),
      ));
    }

    // STB Ops — gated on STB activation/deactivation/reactivation access
    if (session?.canActivateStb == true ||
        session?.canDeactivateStb == true ||
        session?.canReactivateStb == true) {
      actions.add(CircleAction(
        icon: LucideIcons.monitor,
        label: 'STB Ops',
        color: c.blue,
        onTap: () => context.push(
          RouteNames.stbOperations,
          extra: {
            'customerId': widget.customerId,
            'customerName': _name,
            'resellerId': _fm(['reseller_id', 'resellerId']),
          },
        ),
      ));
    }

    // Edit
    actions.add(CircleAction(
      icon: LucideIcons.pencil,
      label: _statusString == 'Fresh' ? 'Add Customer' : 'Edit',
      color: c.purple,
      onTap: () async {
        final serial = _fm(
          ['serial_number', 'serialNumber', 'box_number', 'boxNumber'],
          widget.initialSerialNumber ?? '',
        );
        final vc = _fm(
          ['vc_number', 'vcNumber', 'vc_no'],
          widget.initialVcNumber ?? '',
        );

        // Fresh customers have no existing record — use NewCustomerScreen
        // (saveCustomerRest) instead of EditCustomerScreen (editCustomerRest).
        // editCustomerRest requires an existing customer_id on the server,
        // which causes "Dealer or Employee does not exist (statusCode:1)" for
        // fresh STBs.
        if (_statusString == 'Fresh') {
          context.push(
            RouteNames.newCustomer,
            extra: {
              'serialNumber': serial,
              'vcNumber': vc,
            },
          );
          return;
        }

        final result = await context.push<bool>(
          '/customer/${widget.customerId}/edit',
          extra: {
            'customer': {
              ..._customer,
              if (serial.isNotEmpty) 'serialNumber': serial,
              if (vc.isNotEmpty) 'vcNumber': vc,
            },
          },
        );
        if (result == true) {
          _loadCustomer();
        }
      },
    ));

    return CircleActionBar(actions: actions);
  }

  Widget _buildActionButtons(AppColors c, TextTheme tt, AppSession? session) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Invoice History
          _ActionTile(
              icon: LucideIcons.fileText,
              label: l.invoiceHistory,
              iconColor: c.blue,
              iconBg: c.blueSoft,
              colors: c,
              onTap: () {
                context.push('/invoice-history/${widget.customerId}');
              },
            ),

          // Payment History
          _ActionTile(
              icon: LucideIcons.receipt,
              label: l.paymentHistory,
              iconColor: c.green,
              iconBg: c.greenSoft,
              colors: c,
              onTap: () {
                context.push('/payment-history/${widget.customerId}');
              },
            ),

          // View on Map
          _ActionTile(
            icon: LucideIcons.mapPin,
            label: 'View on Map',
            iconColor: c.amber,
            iconBg: c.amberSoft,
            colors: c,
            onTap: _viewOnMap,
          ),

          // Update Location
          _ActionTile(
            icon: LucideIcons.navigation,
            label: _isUpdatingLocation ? 'Updating Location...' : 'Update Location',
            iconColor: c.purple,
            iconBg: c.purpleSoft,
            colors: c,
            trailing: _isUpdatingLocation
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: c.purple,
                    ),
                  )
                : null,
            onTap: _isUpdatingLocation ? null : _updateLocation,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Private helper classes
// ─────────────────────────────────────────────────────────────────────────────

class _GridCell {
  final String label;
  final String value;
  final Color? valueColor;

  const _GridCell({
    required this.label,
    required this.value,
    this.valueColor,
  });
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconColor;
  final Color iconBg;
  final AppColors colors;
  final VoidCallback? onTap;
  final Widget? trailing;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.iconColor,
    required this.iconBg,
    required this.colors,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: colors.card,
        borderRadius: AppRadius.smBR,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.smBR,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Icon(icon, size: 18, color: iconColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: colors.ink,
                    ),
                  ),
                ),
                trailing ??
                    Icon(
                      LucideIcons.chevronRight,
                      size: 18,
                      color: colors.ink20,
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
