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

  const CustomerProfileScreen({
    super.key,
    required this.customerId,
    this.customerName,
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
    _loadCustomer();
  }

  Future<void> _loadCustomer() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

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
        final list = data[key];
        if (list is List && list.isNotEmpty) {
          found = list[0] as Map<String, dynamic>;
          break;
        }
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
          _customer = found ??
              {
                'customer_id': widget.customerId,
                'customerName': widget.customerName ?? 'Customer',
              };
        });
      }
    } catch (e) {
      debugPrint('[PROFILE] Load error: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = e.toString().replaceAll('ApiException: ', '');
          _customer = {
            'customer_id': widget.customerId,
            'customerName': widget.customerName ?? 'Customer',
          };
        });
      }
    }
  }

  String _f(String key, [String fallback = '']) =>
      _customer[key]?.toString() ?? fallback;

  String get _name =>
      _f('customer_name', _f('customerName', widget.customerName ?? 'Customer'))
          .trim();

  String get _statusString {
    final s = _f('status', '1');
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
      _f('mobile_no', _f('mobileNumber', _f('mobile_number', '')));

  String get _area =>
      _f('area', _f('location', _f('billing_address', '')));

  Future<void> _updateLocation() async {
    final session = ref.read(appSessionProvider);
    if (session == null) return;

    setState(() => _isUpdatingLocation = true);

    try {
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

  void _viewOnMap() {
    final lat = _customer['latitude'];
    final lng = _customer['longitude'];
    if (lat == null || lng == null) {
      _showSnackBar('No location data available for this customer', isError: true);
      return;
    }
    final latitude = double.tryParse(lat.toString()) ?? 0.0;
    final longitude = double.tryParse(lng.toString()) ?? 0.0;
    if (latitude == 0.0 && longitude == 0.0) {
      _showSnackBar('No location data available for this customer', isError: true);
      return;
    }
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
    );
    launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
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
        label: 'CUSTOMER ID',
        value: widget.customerId,
      ),
      _GridCell(
        label: 'A/C NUMBER',
        value: _f('accountnumber', _f('account_number', '-')),
      ),
      _GridCell(
        label: cafLabel.toUpperCase(),
        value: _f('cafNumber', _f('caf_no', _f('crfNumber', _f('crf_number', '-')))),
      ),
      _GridCell(
        label: l.mobile.toUpperCase(),
        value: _mobile.isNotEmpty ? _mobile : '-',
      ),
      _GridCell(
        label: 'STB COUNT',
        value: _f('stbCount', _f('stb_count', '-')),
      ),
      _GridCell(
        label: 'BILL TYPE',
        value: _f('bill_type', _f('billType', '-')),
      ),
      _GridCell(
        label: 'STATUS',
        value: _statusString,
      ),
      _GridCell(
        label: 'PENDING',
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
            'resellerId': _f('reseller_id', _f('resellerId', '')),
            'billType': _f('bill_type', _f('billType', '')),
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
          },
        ),
      ));
    }

    // Edit
    actions.add(CircleAction(
      icon: LucideIcons.pencil,
      label: 'Edit',
      color: c.purple,
      onTap: () async {
        final result = await context.push<bool>(
          '/customer/${widget.customerId}/edit',
          extra: {'customer': _customer},
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
          if (session?.canAccessInvoices == true)
            _ActionTile(
              icon: LucideIcons.fileText,
              label: l.invoiceHistory,
              iconColor: c.blue,
              iconBg: c.blueSoft,
              colors: c,
              onTap: () {
                // TODO: Navigate to invoice history
                _showSnackBar('Invoice History coming soon');
              },
            ),

          // Payment History
          if (session?.canAccessPaymentHistory == true)
            _ActionTile(
              icon: LucideIcons.receipt,
              label: l.paymentHistory,
              iconColor: c.green,
              iconBg: c.greenSoft,
              colors: c,
              onTap: () {
                // TODO: Navigate to payment history
                _showSnackBar('Payment History coming soon');
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
