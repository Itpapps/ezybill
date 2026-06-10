import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../application/providers/package_provider.dart';
import '../../../application/providers/stb_provider.dart';
import '../../../core/config/app_session.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/parse_utils.dart';
import '../../../data/models/package/package_model.dart';
import '../../../l10n/app_localizations.dart';
import '../../router/route_names.dart';

// ---------------------------------------------------------------------------
// Mode enum
// ---------------------------------------------------------------------------

enum _OpMode { activate, deactivate, renew }

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

/// Package Operations screen implementing the exact Android app business logic
/// from FragActive_plan, Frag_deact_pack, and Package_Operations_Fragment.
///
/// Visibility rules (Section 2.1):
/// - Activate: visible when intStbActivation == 1
/// - Deactivate: visible when intStbDeactivation == 1
/// - Renew: visible when isexpired == 1 AND patchInformation in version list
///
/// Two-Step Activation Flow (Section 3.6):
///   1. Select packages -> "Get Bill" -> shows bill breakdown
///   2. Review bill -> "Activate" -> confirmation -> API call
///
/// Deactivation (Section 4):
///   - Uses customer_service_id NOT product_id
///   - Reason filtering: exclude ID 17, 21, global_reason == 1
///   - Mandatory remarks + suffix ". Deactivation From Flutter App"
class PackageOperationsScreen extends ConsumerStatefulWidget {
  final String? customerId;
  final String? stbNo;
  final String? customerName;
  final String? customerDeviceId;
  final String? customerStockId;
  final String? resellerId;
  final int? isExpired;

  const PackageOperationsScreen({
    super.key,
    this.customerId,
    this.stbNo,
    this.customerName,
    this.customerDeviceId,
    this.customerStockId,
    this.resellerId,
    this.isExpired,
  });

  @override
  ConsumerState<PackageOperationsScreen> createState() =>
      _PackageOperationsScreenState();
}

class _PackageOperationsScreenState
    extends ConsumerState<PackageOperationsScreen>
    with TickerProviderStateMixin {
  AppLocalizations get l => AppLocalizations.of(context)!;
  late TabController _categoryTabController;
  final _searchController = TextEditingController();
  final _customerIdController = TextEditingController();
  final _stbNoController = TextEditingController();

  String? _activeCustomerId;
  String? _activeStbNo;
  String? _activeDeviceId;
  String? _activeStockId;
  String? _activeResellerId;
  _OpMode _mode = _OpMode.activate;
  String _searchQuery = '';

  // Deactivation form
  int? _selectedReasonId;
  final _remarksController = TextEditingController();

  AppColors get _c =>
      Theme.of(context).extension<AppColors>() ?? AppColors.light;

  bool _fetchingStb = false;

  @override
  void initState() {
    super.initState();
    _categoryTabController = TabController(length: 4, vsync: this);

    if (widget.customerId != null) {
      _activeCustomerId = widget.customerId;
      if (widget.stbNo != null) {
        _activeStbNo = widget.stbNo;
        _activeDeviceId = widget.customerDeviceId;
        _activeStockId = widget.customerStockId;
        _activeResellerId = widget.resellerId;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _loadData();
        });
      } else {
        // No stbNo passed — fetch STB details first
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _fetchStbAndLoad();
        });
      }
    }
  }

  /// Fetch STB box details when stbNo wasn't passed (e.g. from customer profile).
  Future<void> _fetchStbAndLoad() async {
    if (_activeCustomerId == null || _fetchingStb) return;
    setState(() => _fetchingStb = true);
    try {
      final stbDs = ref.read(stbRemoteDatasourceProvider);
      final token = ref.read(appSessionProvider)?.token ?? '';
      final rawResult = await stbDs.getCustomerBoxDetails(
        authtoken: token,
        customerId: _activeCustomerId!,
      );
      final boxList = parseMapList(rawResult['customerBoxList']);
      if (!mounted) return;
      if (boxList.isEmpty) {
        setState(() => _fetchingStb = false);
        return;
      }
      final boxes = boxList.cast<Map<String, dynamic>>();
      if (boxes.length == 1) {
        _applyStb(boxes.first);
      } else {
        // Multiple STBs — let user pick
        _showStbPickerDialog(boxes);
      }
    } catch (e) {
      debugPrint('[PackageOps] Failed to fetch STB: $e');
      if (mounted) setState(() => _fetchingStb = false);
    }
  }

  void _applyStb(Map<String, dynamic> stb) {
    _activeStbNo = stb['serial_number']?.toString() ?? '';
    _activeDeviceId = stb['device_id']?.toString();
    _activeStockId = stb['stock_id']?.toString();
    setState(() => _fetchingStb = false);
    _loadData();
  }

  void _showStbPickerDialog(List<Map<String, dynamic>> boxes) {
    setState(() => _fetchingStb = false);
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Select STB'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: boxes.length,
              itemBuilder: (_, i) {
                final stb = boxes[i];
                final serial = stb['serial_number']?.toString() ?? 'Unknown';
                final vc = stb['vc_number']?.toString() ?? '';
                return ListTile(
                  title: Text(serial),
                  subtitle: vc.isNotEmpty ? Text('VC: $vc') : null,
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _applyStb(stb);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _loadData() {
    if (_activeCustomerId == null || _activeStbNo == null) return;
    final notifier = ref.read(packageProvider.notifier);
    notifier.loadAssigned(_activeCustomerId!, _activeStbNo!);
    notifier.loadAvailable(_activeCustomerId!, _activeStbNo!);
    notifier.loadDeactivationReasons();
  }

  @override
  void dispose() {
    _categoryTabController.dispose();
    _searchController.dispose();
    _customerIdController.dispose();
    _stbNoController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  void _searchPackages() {
    final custId = _customerIdController.text.trim();
    final stbNo = _stbNoController.text.trim();
    if (custId.isNotEmpty && stbNo.isNotEmpty) {
      _activeCustomerId = custId;
      _activeStbNo = stbNo;
      _loadData();
    }
  }

  // ── Visibility Gating (Section 2.1) ─────────────────────────────────────

  /// Check whether the Activate mode should be visible.
  /// Gated by: intStbActivation == 1
  bool _canActivate(AppSession? session) {
    return session?.canActivateStb ?? false;
  }

  /// Check whether the Deactivate mode should be visible.
  /// Gated by: intStbDeactivation == 1
  bool _canDeactivate(AppSession? session) {
    return session?.canDeactivateStb ?? false;
  }

  /// Check whether the Renew mode should be visible.
  /// Gated by: isexpired == 1 AND patchInformation in version list.
  ///
  /// CRITICAL: The Android app has an operator precedence bug where the
  /// second and third patch checks bypass isexpired==1. Flutter uses
  /// proper parentheses per the spec doc recommendation.
  bool _canRenew(AppSession? session) {
    final isExpired = widget.isExpired == 1;
    final patchInfo = session?.patchInformation ?? '';
    const allowedVersions = ['1.4.13.2', '1.4.13.3', '1.4.13.4'];
    return isExpired && allowedVersions.contains(patchInfo);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final pkgState = ref.watch(packageProvider);
    final session = ref.watch(appSessionProvider);

    final canActivate = _canActivate(session);
    final canDeactivate = _canDeactivate(session);
    final canRenew = _canRenew(session);

    // If current mode is not allowed, switch to first available
    if (_mode == _OpMode.activate && !canActivate) {
      if (canDeactivate) {
        _mode = _OpMode.deactivate;
      } else if (canRenew) {
        _mode = _OpMode.renew;
      }
    } else if (_mode == _OpMode.deactivate && !canDeactivate) {
      if (canActivate) {
        _mode = _OpMode.activate;
      } else if (canRenew) {
        _mode = _OpMode.renew;
      }
    } else if (_mode == _OpMode.renew && !canRenew) {
      if (canActivate) {
        _mode = _OpMode.activate;
      } else if (canDeactivate) {
        _mode = _OpMode.deactivate;
      }
    }

    ref.listen<PackageState>(packageProvider, (_, state) {
      if (state.successMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.successMessage!),
            backgroundColor: _c.green,
          ),
        );
        ref.read(packageProvider.notifier).clearMessages();
        _loadData();
      }
      if (state.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.errorMessage!),
            backgroundColor: _c.red,
          ),
        );
        ref.read(packageProvider.notifier).clearMessages();
      }
    });

    return Scaffold(
      backgroundColor: _c.bg,
      appBar: AppBar(
        title: Text(
          l.packageOperations,
          style: const TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: _c.card,
        foregroundColor: _c.ink,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        actions: [
          // Renew nav (only if renewal is available)
          if (canRenew)
            IconButton(
              icon: Icon(LucideIcons.refreshCw, color: _c.ink60),
              tooltip: 'Renewal',
              onPressed: () {
                context.push(RouteNames.packageRenewal, extra: {
                  'customerId': _activeCustomerId,
                  'stbNo': _activeStbNo,
                });
              },
            ),
        ],
      ),
      body: Column(
        children: [
          // Search section if no customer passed
          if (widget.customerId == null)
            Container(
              color: _c.card,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _customerIdController,
                      style: const TextStyle(
                          fontFamily: 'DM Sans', fontSize: 14),
                      decoration: _inputDecor('Customer ID'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _stbNoController,
                      style: const TextStyle(
                          fontFamily: 'DM Sans', fontSize: 14),
                      decoration: _inputDecor('STB Number'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    height: 44,
                    child: ElevatedButton(
                      onPressed: _searchPackages,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _c.red,
                        foregroundColor: _c.card,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      child: const Icon(LucideIcons.search, size: 18),
                    ),
                  ),
                ],
              ),
            ),

          if (widget.customerName != null)
            Container(
              width: double.infinity,
              color: _c.card,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Text(
                'Customer: ${widget.customerName} | STB: ${widget.stbNo}',
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _c.ink60,
                ),
              ),
            ),

          // Mode toggle — only show buttons the user has access to
          Container(
            color: _c.card,
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
            child: Row(
              children: [
                if (canActivate)
                  _ModeChip(
                    label: l.activatePackage,
                    icon: LucideIcons.plusCircle,
                    selected: _mode == _OpMode.activate,
                    color: _c.green,
                    bgColor: _c.greenSoft,
                    colors: _c,
                    onTap: () => setState(() {
                      _mode = _OpMode.activate;
                      ref.read(packageProvider.notifier).clearSelection();
                    }),
                  ),
                if (canActivate && (canDeactivate || canRenew))
                  const SizedBox(width: 8),
                if (canDeactivate)
                  _ModeChip(
                    label: l.deactivatePackage,
                    icon: LucideIcons.minusCircle,
                    selected: _mode == _OpMode.deactivate,
                    color: _c.red,
                    bgColor: _c.redSoft,
                    colors: _c,
                    onTap: () => setState(() {
                      _mode = _OpMode.deactivate;
                      ref.read(packageProvider.notifier).clearSelection();
                    }),
                  ),
                if (canDeactivate && canRenew) const SizedBox(width: 8),
                if (canRenew)
                  _ModeChip(
                    label: l.renewPackage,
                    icon: LucideIcons.refreshCw,
                    selected: _mode == _OpMode.renew,
                    color: _c.blue,
                    bgColor: _c.blueSoft,
                    colors: _c,
                    onTap: () => setState(() {
                      _mode = _OpMode.renew;
                      ref.read(packageProvider.notifier).clearSelection();
                      if (_activeCustomerId != null) {
                        ref.read(packageProvider.notifier).loadRenewable(
                              _activeCustomerId!,
                            );
                      }
                    }),
                  ),
              ],
            ),
          ),

          // Search filter for activate/deactivate
          if (_mode != _OpMode.renew)
            Container(
              color: _c.card,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: TextField(
                controller: _searchController,
                onChanged: (q) => setState(() => _searchQuery = q),
                style:
                    const TextStyle(fontFamily: 'DM Sans', fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Search packages...',
                  hintStyle: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 13,
                      color: _c.ink40),
                  prefixIcon:
                      Icon(LucideIcons.search, size: 16, color: _c.ink40),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: _c.ink10),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: _c.ink10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: _c.red),
                  ),
                  filled: true,
                  fillColor: _c.bg,
                  isDense: true,
                ),
              ),
            ),

          // Category tabs for activate/deactivate (4 tabs per Section 3.2)
          if (_mode != _OpMode.renew)
            Container(
              color: _c.card,
              child: TabBar(
                controller: _categoryTabController,
                labelColor: _c.red,
                unselectedLabelColor: _c.ink40,
                labelStyle: const TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                indicatorColor: _c.red,
                indicatorWeight: 3,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                tabs: const [
                  Tab(text: 'Base'),
                  Tab(text: 'Add-On'),
                  Tab(text: 'A-La-Carte'),
                  Tab(text: 'Broadcaster'),
                ],
              ),
            ),

          // Content
          Expanded(
            child: pkgState.isLoading
                ? Center(child: CircularProgressIndicator(color: _c.red))
                : _mode == _OpMode.renew
                    ? _buildRenewList(pkgState)
                    : TabBarView(
                        controller: _categoryTabController,
                        children: [
                          _buildPackageTab(0, pkgState),
                          _buildPackageTab(1, pkgState),
                          _buildPackageTab(2, pkgState),
                          _buildPackageTab(3, pkgState),
                        ],
                      ),
          ),

          // Bottom action bar
          if (pkgState.selectedIds.isNotEmpty) _buildBottomBar(pkgState),
        ],
      ),
    );
  }

  // ── Package Tab ──────────────────────────────────────────────────────────

  Widget _buildPackageTab(int tabIndex, PackageState pkgState) {
    final List<PackageModel> packages;
    if (_mode == _OpMode.activate) {
      switch (tabIndex) {
        case 0:
          packages = pkgState.availableBase;
        case 1:
          packages = pkgState.availableAddon;
        case 2:
          packages = pkgState.availableAla;
        case 3:
          packages = pkgState.availableBroadcaster;
        default:
          packages = [];
      }
    } else {
      // Deactivate mode: show assigned packages
      switch (tabIndex) {
        case 0:
          packages = pkgState.assignedBase;
        case 1:
          packages = pkgState.assignedAddon;
        case 2:
          packages = pkgState.assignedAla;
        case 3:
          packages = pkgState.assignedBroadcaster;
        default:
          packages = [];
      }
    }

    // Filter by search query
    final filtered = _searchQuery.isEmpty
        ? packages
        : packages
            .where((p) => p.packageName
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()))
            .toList();

    if (filtered.isEmpty) {
      return _buildEmptyTab();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final pkg = filtered[index];
        // For deactivation, selection key is customer_service_id if available
        final selectionKey = _mode == _OpMode.deactivate
            ? (pkg.customerServiceId ?? pkg.packageId)
            : pkg.packageId;
        final isSelected = pkgState.selectedIds.contains(selectionKey);
        return _PackageCard(
          package: pkg,
          isSelected: isSelected,
          isActivateMode: _mode == _OpMode.activate,
          colors: _c,
          showDates: _mode == _OpMode.activate,
          onToggle: () {
            ref.read(packageProvider.notifier).toggleSelection(selectionKey);
          },
        );
      },
    );
  }

  Widget _buildEmptyTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: _c.redSoft,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(LucideIcons.box, size: 28, color: _c.red),
          ),
          const SizedBox(height: 12),
          Text(
            'No Packages',
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: _c.ink,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _activeCustomerId == null
                ? 'Search for a customer and STB'
                : 'No packages in this category',
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 13,
              color: _c.ink60,
            ),
          ),
        ],
      ),
    );
  }

  // ── Renew List ───────────────────────────────────────────────────────────

  Widget _buildRenewList(PackageState pkgState) {
    final services = pkgState.renewableServices;
    if (services.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: _c.blueSoft,
                borderRadius: BorderRadius.circular(16),
              ),
              child:
                  Icon(LucideIcons.refreshCw, size: 28, color: _c.blue),
            ),
            const SizedBox(height: 12),
            Text(
              'No Renewable Services',
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: _c.ink,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'No services available for renewal',
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 13,
                color: _c.ink60,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: services.length,
      itemBuilder: (context, index) {
        final svc = services[index];
        final isSelected = pkgState.selectedIds.contains(svc.packageId);
        return _PackageCard(
          package: svc,
          isSelected: isSelected,
          isActivateMode: false,
          colors: _c,
          showRenewalBadge: true,
          onToggle: () {
            ref.read(packageProvider.notifier).toggleSelection(svc.packageId);
          },
        );
      },
    );
  }

  // ── Bottom Bar ───────────────────────────────────────────────────────────

  Widget _buildBottomBar(PackageState pkgState) {
    final count = pkgState.selectedIds.length;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: BoxDecoration(
        color: _c.card,
        border: Border(top: BorderSide(color: _c.ink10)),
        boxShadow: [
          BoxShadow(
            color: _c.ink.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text(
                  '$count package${count != 1 ? 's' : ''} selected',
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _c.ink80,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () =>
                      ref.read(packageProvider.notifier).clearSelection(),
                  child: Text(
                    'Clear',
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 13,
                      color: _c.ink40,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // ── Activate mode: Two-step flow (Section 3.6) ─────────────
            // Step 1: "Get Bill" → calls getbilldetailsRest
            // Step 2: Bill shown → "Activate" button appears
            if (_mode == _OpMode.activate) ...[
              if (!pkgState.billFetched)
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: pkgState.isLoading
                        ? null
                        : () => _onGetBill(pkgState),
                    icon: pkgState.isLoading
                        ? SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: _c.card),
                          )
                        : Icon(LucideIcons.receipt, size: 18, color: _c.card),
                    label: Text(
                      pkgState.isLoading ? '${l.loading}' : l.getBill,
                      style: const TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _c.blue,
                      foregroundColor: _c.card,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),

              // Show bill summary + Activate button after bill is fetched
              if (pkgState.billFetched && pkgState.billDetail != null) ...[
                _buildBillSummary(pkgState),
                const SizedBox(height: 8),
                // Show selected packages summary with computed dates
                _buildSelectedPackagesSummary(pkgState),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: pkgState.isLoading
                        ? null
                        : () => _onActivate(pkgState),
                    icon: pkgState.isLoading
                        ? SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: _c.card),
                          )
                        : Icon(LucideIcons.checkCircle,
                            size: 18, color: _c.card),
                    label: Text(
                      pkgState.isLoading ? '${l.loading}' : l.activatePackage,
                      style: const TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _c.green,
                      foregroundColor: _c.card,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ],

              // Bill fetched but no detail returned — still allow activation
              if (pkgState.billFetched && pkgState.billDetail == null)
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: pkgState.isLoading
                        ? null
                        : () => _onActivate(pkgState),
                    icon: Icon(LucideIcons.checkCircle,
                        size: 18, color: _c.card),
                    label: Text(
                      l.activatePackage,
                      style: const TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _c.green,
                      foregroundColor: _c.card,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
            ],

            // ── Deactivate mode ────────────────────────────────────────
            if (_mode == _OpMode.deactivate)
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: pkgState.isLoading
                      ? null
                      : () => _showDeactivateDialog(pkgState),
                  icon:
                      Icon(LucideIcons.minusCircle, size: 18, color: _c.card),
                  label: const Text(
                    'Deactivate Selected',
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _c.red,
                    foregroundColor: _c.card,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),
              ),

            // ── Renew mode ─────────────────────────────────────────────
            if (_mode == _OpMode.renew)
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: pkgState.isLoading
                      ? null
                      : () => _onRenew(pkgState),
                  icon:
                      Icon(LucideIcons.refreshCw, size: 18, color: _c.card),
                  label: const Text(
                    'Submit Renewal',
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _c.blue,
                    foregroundColor: _c.card,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ── Bill Summary (Section 3.5) ──────────────────────────────────────────

  Widget _buildBillSummary(PackageState pkgState) {
    final bill = pkgState.billDetail!;
    final session = ref.read(appSessionProvider);
    final sym = session?.currencySymbol ?? '\u20B9';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _c.greenSoft,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _c.green.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          _billRow(AppLocalizations.of(context)!.lcoShare, '$sym${bill.lcoShare.toStringAsFixed(2)}'),
          _billRow(AppLocalizations.of(context)!.msoShare, '$sym${bill.msoShare.toStringAsFixed(2)}'),
          // NCF row hidden if ncf_total_amount <= 0 (per Section 3.5)
          if (bill.ncfTotalAmount > 0)
            _billRow(
                bill.ncfDisplayName ?? 'NCF',
                '$sym${bill.ncfTotalAmount.toStringAsFixed(2)}'),
          // ENCF row hidden if encf_total_amount <= 0 (per Section 3.5)
          if (bill.encfTotalAmount > 0)
            _billRow(
                bill.encfDisplayName ?? 'ENCF',
                '$sym${bill.encfTotalAmount.toStringAsFixed(2)}'),
          Divider(color: _c.green.withValues(alpha: 0.3)),
          _billRow(
            AppLocalizations.of(context)!.grandTotal,
            '$sym${bill.totalAmount.toStringAsFixed(2)}',
            isBold: true,
          ),
          // Show prorata discount flag if enabled
          if (bill.enableProrataDiscount == 1)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Pro-rata discount applied',
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                  color: _c.green,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Shows computed start/end dates for selected packages (Section 3.4).
  Widget _buildSelectedPackagesSummary(PackageState pkgState) {
    final allAvailable = pkgState.allAvailable;
    final selectedPkgs = <PackageModel>[];
    for (final id in pkgState.selectedIds) {
      final pkg = allAvailable.where((p) => p.packageId == id).firstOrNull;
      if (pkg != null) selectedPkgs.add(pkg);
    }

    if (selectedPkgs.isEmpty) return const SizedBox.shrink();

    final startDate = PackageNotifier.computeStartDate();

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _c.bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _c.ink10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Package Summary',
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: _c.ink80,
            ),
          ),
          const SizedBox(height: 6),
          ...selectedPkgs.map((pkg) {
            final endDate = PackageNotifier.computeEndDate(pkg);
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      pkg.packageName,
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 11,
                        color: _c.ink,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '$startDate - $endDate',
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 10,
                      color: _c.ink60,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _billRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 12,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
              color: _c.ink80,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 12,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
              color: _c.ink,
            ),
          ),
        ],
      ),
    );
  }

  // ── Actions ──────────────────────────────────────────────────────────────

  /// Step 1 of activation: Get Bill (Section 3.5).
  /// Calls getbilldetailsRest with serial_number, comma-separated package_ids,
  /// customer_id, employee_id, dealer_id.
  void _onGetBill(PackageState pkgState) {
    if (_activeCustomerId == null || _activeStbNo == null) return;
    final ids = pkgState.selectedIds.join(',');
    ref.read(packageProvider.notifier).loadBillDetails(
          customerId: _activeCustomerId!,
          boxNumber: _activeStbNo!,
          productIds: ids,
          resellerId: _activeResellerId,
        );
  }

  /// Step 2 of activation: Confirm and activate (Section 3.6-3.7).
  /// Shows confirmation dialog: "Are you sure you want to Activate packages?"
  /// Then calls activateServiceRest with all required params.
  void _onActivate(PackageState pkgState) {
    if (_activeCustomerId == null || _activeStbNo == null) return;
    final ids = pkgState.selectedIds.join(',');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          AppLocalizations.of(context)!.confirmActivate,
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontWeight: FontWeight.w700,
            color: _c.ink,
          ),
        ),
        content: Text(
          'Are you sure you want to Activate ${pkgState.selectedIds.length} package(s)?',
          style: TextStyle(
              fontFamily: 'DM Sans', fontSize: 14, color: _c.ink80),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('No',
                style: TextStyle(
                    fontFamily: 'DM Sans', color: _c.ink60)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(packageProvider.notifier).activateService(
                    customerId: _activeCustomerId!,
                    customerDeviceId: _activeDeviceId ?? '',
                    productIds: ids,
                    stockId: _activeStockId ?? '',
                    resellerId: _activeResellerId,
                  );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _c.green,
              foregroundColor: _c.card,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Yes',
                style: TextStyle(fontFamily: 'DM Sans')),
          ),
        ],
      ),
    );
  }

  /// Deactivation dialog (Section 4.5-4.7).
  /// Shows selected packages summary, reason dropdown (filtered), remarks
  /// field (mandatory), and two-step confirmation.
  void _showDeactivateDialog(PackageState pkgState) {
    _selectedReasonId = null;
    _remarksController.clear();

    // Build summary of selected packages for display
    final allAssigned = pkgState.allAssigned;
    final selectedPkgs = <PackageModel>[];
    for (final id in pkgState.selectedIds) {
      final pkg = allAssigned
          .where((p) => (p.customerServiceId ?? p.packageId) == id)
          .firstOrNull;
      if (pkg != null) selectedPkgs.add(pkg);
    }

    // Calculate total
    double total = 0;
    for (final pkg in selectedPkgs) {
      total += pkg.price;
    }

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          // Filtered reasons: exclude ID 17, 21, global_reason == 1
          final reasons = pkgState.filteredReasons;
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            title: Text(
              '${AppLocalizations.of(context)!.deactivatePackage} ${AppLocalizations.of(context)!.packages}',
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontWeight: FontWeight.w700,
                color: _c.ink,
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Selected packages summary (Section 4.7)
                  Text(
                    '${selectedPkgs.length} package(s) selected',
                    style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _c.ink80),
                  ),
                  const SizedBox(height: 8),
                  // Package list with details
                  ...selectedPkgs.map((pkg) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                pkg.packageName,
                                style: TextStyle(
                                  fontFamily: 'DM Sans',
                                  fontSize: 12,
                                  color: _c.ink,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              '\u20B9${pkg.price.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontFamily: 'DM Sans',
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: _c.red,
                              ),
                            ),
                          ],
                        ),
                      )),
                  Divider(color: _c.ink10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '${AppLocalizations.of(context)!.total}: \u20B9${total.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _c.ink,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Reason dropdown
                  DropdownButtonFormField<int>(
                    value: _selectedReasonId,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: 'Reason *',
                      labelStyle: TextStyle(
                          fontFamily: 'DM Sans', color: _c.ink40),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: reasons.map((r) {
                      return DropdownMenuItem<int>(
                        value: r.reasonId,
                        child: Text(
                          r.reasonName,
                          style: const TextStyle(
                              fontFamily: 'DM Sans', fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (val) =>
                        setDialogState(() => _selectedReasonId = val),
                  ),
                  const SizedBox(height: 12),
                  // Remarks field (mandatory per Section 4.5)
                  TextField(
                    controller: _remarksController,
                    maxLines: 2,
                    style: const TextStyle(
                        fontFamily: 'DM Sans', fontSize: 14),
                    decoration: InputDecoration(
                      labelText: 'Remarks *',
                      hintText: 'Enter deactivation remarks (required)',
                      hintStyle: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 12,
                          color: _c.ink40),
                      labelStyle: TextStyle(
                          fontFamily: 'DM Sans', color: _c.ink40),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text('Cancel',
                    style: TextStyle(
                        fontFamily: 'DM Sans', color: _c.ink60)),
              ),
              ElevatedButton(
                onPressed: (_selectedReasonId == null ||
                        _remarksController.text.trim().isEmpty)
                    ? null
                    : () {
                        Navigator.pop(ctx);
                        _confirmDeactivation(pkgState);
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _c.red,
                  foregroundColor: _c.card,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(AppLocalizations.of(context)!.deactivatePackage,
                    style: const TextStyle(fontFamily: 'DM Sans')),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Second confirmation before deactivation (Section 4.7):
  /// "Are you sure you want to deactivate packages?" Yes/No
  void _confirmDeactivation(PackageState pkgState) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          AppLocalizations.of(context)!.confirmDeactivatePackage,
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontWeight: FontWeight.w700,
            color: _c.ink,
          ),
        ),
        content: Text(
          'Are you sure you want to deactivate packages?',
          style: TextStyle(
              fontFamily: 'DM Sans', fontSize: 14, color: _c.ink80),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('No',
                style: TextStyle(
                    fontFamily: 'DM Sans', color: _c.ink60)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _executeDeactivation(pkgState);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _c.red,
              foregroundColor: _c.card,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Yes',
                style: TextStyle(fontFamily: 'DM Sans')),
          ),
        ],
      ),
    );
  }

  /// Execute the actual deactivation API call (Section 4.6).
  /// CRITICAL: Uses customer_service_id NOT product_id.
  void _executeDeactivation(PackageState pkgState) {
    if (_activeCustomerId == null) return;

    // Validation: remarks must not be empty (Section 4.5)
    if (_remarksController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Remarks should not be empty.'),
          backgroundColor: _c.red,
        ),
      );
      return;
    }

    // Collect customer_service_id (comma-separated), NOT product_id per spec.
    // The selectedIds already contain customer_service_id values when in
    // deactivate mode (see _buildPackageTab selection key logic).
    final serviceIds = pkgState.selectedIds.toList();

    ref.read(packageProvider.notifier).deactivateService(
          customerId: _activeCustomerId!,
          serviceIds: serviceIds.join(','),
          reasonId: _selectedReasonId!.toString(),
          remarks: _remarksController.text.trim(),
          stockId: _activeStockId,
          resellerId: _activeResellerId,
        );
  }

  /// Renewal confirmation (Section 5.2).
  /// Shows summary dialog: "Are you sure you want to Renew packages?"
  void _onRenew(PackageState pkgState) {
    if (_activeCustomerId == null) return;

    // Calculate total
    double total = 0;
    final selectedServices = <PackageModel>[];
    for (final id in pkgState.selectedIds) {
      final svc = pkgState.renewableServices
          .where((s) => s.packageId == id)
          .firstOrNull;
      if (svc != null) {
        total += svc.price;
        selectedServices.add(svc);
      }
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          AppLocalizations.of(context)!.confirmRenewal,
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontWeight: FontWeight.w700,
            color: _c.ink,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...selectedServices.map((svc) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            svc.packageName,
                            style: TextStyle(
                              fontFamily: 'DM Sans',
                              fontSize: 12,
                              color: _c.ink,
                            ),
                          ),
                        ),
                        Text(
                          '\u20B9${svc.price.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _c.blue,
                          ),
                        ),
                      ],
                    ),
                  )),
              Divider(color: _c.ink10),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '${AppLocalizations.of(context)!.total}: \u20B9${total.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _c.ink,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Are you sure you want to Renew packages?',
                style: TextStyle(
                    fontFamily: 'DM Sans', fontSize: 14, color: _c.ink80),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppLocalizations.of(context)!.cancel,
                style: TextStyle(
                    fontFamily: 'DM Sans', color: _c.ink60)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(packageProvider.notifier).submitRenewal(
                    _activeCustomerId!,
                  );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _c.blue,
              foregroundColor: _c.card,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(AppLocalizations.of(context)!.renewPackage,
                style: const TextStyle(fontFamily: 'DM Sans')),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecor(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        fontFamily: 'DM Sans',
        fontSize: 13,
        color: _c.ink40,
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: _c.ink10),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: _c.ink10),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: _c.red),
      ),
      filled: true,
      fillColor: _c.bg,
    );
  }
}

// ---------------------------------------------------------------------------
// Mode Chip
// ---------------------------------------------------------------------------

class _ModeChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final Color color;
  final Color bgColor;
  final AppColors colors;
  final VoidCallback onTap;

  const _ModeChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.color,
    required this.bgColor,
    required this.colors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? bgColor : colors.bg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? color.withValues(alpha: 0.4) : colors.ink10,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 14, color: selected ? color : colors.ink40),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: selected ? color : colors.ink40,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Package Card
// ---------------------------------------------------------------------------

class _PackageCard extends StatelessWidget {
  final PackageModel package;
  final bool isSelected;
  final bool isActivateMode;
  final AppColors colors;
  final bool showRenewalBadge;
  final bool showDates;
  final VoidCallback onToggle;

  const _PackageCard({
    required this.package,
    required this.isSelected,
    required this.isActivateMode,
    required this.colors,
    this.showRenewalBadge = false,
    this.showDates = false,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
              ? (isActivateMode ? colors.greenSoft : colors.redSoft)
              : colors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? (isActivateMode ? colors.green : colors.red)
                    .withValues(alpha: 0.4)
                : colors.ink10,
          ),
        ),
        child: Row(
          children: [
            // Checkbox
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: isSelected
                    ? (isActivateMode ? colors.green : colors.red)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isSelected
                      ? (isActivateMode ? colors.green : colors.red)
                      : colors.ink20,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Icon(LucideIcons.check, size: 14, color: colors.card)
                  : null,
            ),
            const SizedBox(width: 12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          package.packageName,
                          style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: colors.ink,
                          ),
                        ),
                      ),
                      if (showRenewalBadge)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: colors.blueSoft,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Renewable',
                            style: TextStyle(
                              fontFamily: 'DM Sans',
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: colors.blue,
                            ),
                          ),
                        ),
                      // Pricing structure badge
                      if (package.pricingStructureType == '1')
                        Container(
                          margin: const EdgeInsets.only(left: 4),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: colors.ink05,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'OneTime',
                            style: TextStyle(
                              fontFamily: 'DM Sans',
                              fontSize: 9,
                              color: colors.ink40,
                            ),
                          ),
                        ),
                      if (package.pricingStructureType == '2')
                        Container(
                          margin: const EdgeInsets.only(left: 4),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: colors.blueSoft,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Recurring',
                            style: TextStyle(
                              fontFamily: 'DM Sans',
                              fontSize: 9,
                              color: colors.blue,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '\u20B9${package.price.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: colors.red,
                        ),
                      ),
                      if (package.validity.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: colors.ink05,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${package.validityDays}d ${package.validity}',
                            style: TextStyle(
                              fontFamily: 'DM Sans',
                              fontSize: 10,
                              color: colors.ink40,
                            ),
                          ),
                        ),
                      ],
                      if (package.sdChannels + package.hdChannels > 0) ...[
                        const SizedBox(width: 8),
                        Text(
                          '${package.sdChannels + package.hdChannels} ch',
                          style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 11,
                            color: colors.ink40,
                          ),
                        ),
                      ],
                    ],
                  ),
                  // Show computed start/end dates for activation mode
                  if (showDates && isSelected) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Start: ${PackageNotifier.computeStartDate()}  '
                      'End: ${PackageNotifier.computeEndDate(package)}',
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: colors.green,
                      ),
                    ),
                  ],
                  // Show existing dates for assigned/renewable packages
                  if (!showDates &&
                      package.startDate != null &&
                      package.startDate!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      'Active: ${package.startDate} - ${package.endDate ?? ""}',
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 11,
                        color: colors.ink40,
                      ),
                    ),
                  ],
                  if (package.endDate != null &&
                      package.endDate!.isNotEmpty &&
                      package.startDate == null) ...[
                    const SizedBox(height: 2),
                    Text(
                      'Expires: ${package.endDate}',
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 11,
                        color: colors.ink40,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
