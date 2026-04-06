import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../application/providers/stb_provider.dart';
import '../../../core/config/app_session.dart';
import '../../../core/network/network_info.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/stb/deactivation_reason.dart';
import '../../../data/models/stb/stb_model.dart';
import '../../../l10n/app_localizations.dart';
import '../../router/route_names.dart';

class StbOperationsScreen extends ConsumerStatefulWidget {
  final String? customerId;
  final String? customerName;

  const StbOperationsScreen({
    super.key,
    this.customerId,
    this.customerName,
  });

  @override
  ConsumerState<StbOperationsScreen> createState() =>
      _StbOperationsScreenState();
}

class _StbOperationsScreenState extends ConsumerState<StbOperationsScreen> {
  AppLocalizations get l => AppLocalizations.of(context)!;
  final _searchController = TextEditingController();
  String? _activeCustomerId;

  @override
  void initState() {
    super.initState();
    if (widget.customerId != null) {
      _activeCustomerId = widget.customerId;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(stbProvider.notifier).loadBoxes(widget.customerId!);
        ref.read(stbProvider.notifier).loadDeactivationReasons();
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  AppColors get _c =>
      Theme.of(context).extension<AppColors>() ?? AppColors.light;

  void _searchCustomer() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      _activeCustomerId = query;
      ref.read(stbProvider.notifier).loadBoxes(query);
      ref.read(stbProvider.notifier).loadDeactivationReasons();
    }
  }

  /// Check network before performing an action. Shows alert if offline.
  Future<bool> _checkNetwork() async {
    final networkInfo = ref.read(networkInfoProvider);
    final connected = await networkInfo.isConnected;
    if (!connected && mounted) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            AppLocalizations.of(context)!.noInternet,
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontWeight: FontWeight.w700,
              color: _c.ink,
            ),
          ),
          content: Text(
            'Please turn on Wifi or Data Network',
            style: TextStyle(
                fontFamily: 'DM Sans', fontSize: 14, color: _c.ink80),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(AppLocalizations.of(context)!.ok,
                  style: TextStyle(fontFamily: 'DM Sans', color: _c.red)),
            ),
          ],
        ),
      );
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final stbState = ref.watch(stbProvider);
    final session = ref.watch(appSessionProvider);

    ref.listen<StbState>(stbProvider, (_, state) {
      if (state.successMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.successMessage!),
            backgroundColor: _c.green,
          ),
        );
        ref.read(stbProvider.notifier).clearMessages();
        if (_activeCustomerId != null) {
          ref.read(stbProvider.notifier).loadBoxes(_activeCustomerId!);
        }
      }
      if (state.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.errorMessage!),
            backgroundColor: _c.red,
          ),
        );
        ref.read(stbProvider.notifier).clearMessages();
      }
    });

    return Scaffold(
      backgroundColor: _c.bg,
      appBar: AppBar(
        title: Text(
          l.stbOperations,
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
          if (session != null &&
              (session.stbPairing == 1 || session.stbUnpairing == 1))
            IconButton(
              icon: Icon(LucideIcons.link, color: _c.ink60),
              tooltip: 'Pair / Unpair',
              onPressed: () {
                context.push(RouteNames.stbPairUnpair, extra: {
                  'customerId': _activeCustomerId,
                });
              },
            ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          if (widget.customerId == null)
            Container(
              color: _c.card,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Enter Customer ID',
                        hintStyle: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 14,
                          color: _c.ink40,
                        ),
                        prefixIcon: Icon(LucideIcons.search,
                            size: 18, color: _c.ink40),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: _c.ink10),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: _c.ink10),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: _c.red),
                        ),
                        filled: true,
                        fillColor: _c.bg,
                      ),
                      onSubmitted: (_) => _searchCustomer(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _searchCustomer,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _c.red,
                        foregroundColor: _c.card,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        l.search,
                        style: const TextStyle(
                          fontFamily: 'DM Sans',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          if (widget.customerName != null)
            Container(
              width: double.infinity,
              color: _c.card,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Text(
                'Customer: ${widget.customerName}',
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _c.ink60,
                ),
              ),
            ),

          // Content
          Expanded(
            child: stbState.isLoading
                ? Center(child: CircularProgressIndicator(color: _c.red))
                : stbState.stbList.isEmpty
                    ? _buildEmptyState()
                    : _buildBoxList(stbState, session),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: _c.redSoft,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(LucideIcons.monitor, size: 36, color: _c.red),
          ),
          const SizedBox(height: 16),
          Text(
            'No STBs Found',
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: _c.ink,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _activeCustomerId == null
                ? 'Search for a customer to view STBs'
                : 'No set-top boxes found for this customer',
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

  Widget _buildBoxList(StbState stbState, AppSession? session) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: stbState.stbList.length,
      itemBuilder: (context, index) {
        final box = stbState.stbList[index];

        // ---- Status logic per Android spec ----
        // stockStatus: "1" = ACTIVE, "2" = DEACTIVE
        final stockStatus =
            int.tryParse(box.stockStatus ?? '') ?? 0;
        final isActive = stockStatus == 1;
        final isDeactive = stockStatus == 2;
        final isTempDeactivated = box.isTempDeactivated == 1;

        // Status text and colors per spec
        String statusText;
        Color statusColor;
        Color statusBgColor;

        if (isActive) {
          statusText = 'ACTIVE';
          statusColor = _c.greenDot;
          statusBgColor = _c.greenSoft;
        } else if (isDeactive && isTempDeactivated) {
          statusText = 'TEMPORARY DE-ACTIVE';
          statusColor = _c.amber;
          statusBgColor = _c.amberSoft;
        } else {
          statusText = 'DE-ACTIVE';
          statusColor = _c.redDot;
          statusBgColor = _c.redSoft;
        }

        // ---- Button enabled/disabled per spec ----
        // ACTIVE:  Activate=DISABLED, Deactivate=ENABLED, Reactivate=ENABLED
        // DEACTIVE: Activate=ENABLED, Deactivate=DISABLED, Reactivate=DISABLED
        final deactivateEnabled = isActive;
        final reactivateEnabled = isActive;
        final activateEnabled = isDeactive;

        // ---- Button visibility per config flags ----
        final showDeactivate = session?.intStbDeactivation == 1;
        final showReactivate = session?.intStbReactivation == 1;
        final showActivate = session?.intStbActivation == 1;

        // Activate button label per spec
        String activateLabel;
        if (isDeactive && isTempDeactivated) {
          activateLabel = l.temporaryActivate;
        } else {
          activateLabel = l.activate;
        }

        return _StbCard(
          box: box,
          colors: _c,
          statusText: statusText,
          statusColor: statusColor,
          statusBgColor: statusBgColor,
          // Deactivate
          showDeactivate: showDeactivate && deactivateEnabled,
          onDeactivate: () async {
            if (!await _checkNetwork()) return;
            if (!mounted) return;
            _showDeactivateDialog(box, stbState.filteredReasons);
          },
          // Reactivate
          showReactivate: showReactivate && reactivateEnabled,
          onReactivate: () async {
            if (!await _checkNetwork()) return;
            if (!mounted) return;
            _confirmReactivate(box);
          },
          // Activate (or Temp Activate)
          showActivate: showActivate && activateEnabled,
          activateLabel: activateLabel,
          activateColor:
              isTempDeactivated ? _c.amber : _c.green,
          onActivate: () async {
            if (isDeactive && isTempDeactivated) {
              // Temporary Activate: fires immediately, NO confirmation
              if (!await _checkNetwork()) return;
              ref.read(stbProvider.notifier).temporaryActivate(
                    _activeCustomerId!,
                    box.stockId ?? '',
                  );
            } else {
              // Regular Activate: redirect to package activation
              if (!await _checkNetwork()) return;
              if (!mounted) return;
              _confirmRegularActivate(box);
            }
          },
          // Other actions
          onPackages: () {
            context.push(RouteNames.packageOperations, extra: {
              'customerId': _activeCustomerId,
              'stbNo': box.stbNo,
              'customerName': widget.customerName,
            });
          },
          onReplace: () {
            context.push(RouteNames.stbReplacement, extra: {
              'customerId': _activeCustomerId,
              'stbNo': box.stbNo,
              'customerName': widget.customerName,
            });
          },
        );
      },
    );
  }

  // --------------------------------------------------------------------------
  // Deactivation dialog
  // --------------------------------------------------------------------------

  void _showDeactivateDialog(
      StbModel box, List<DeactivationReason> reasons) {
    int? selectedReasonId;
    final remarksController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            AppLocalizations.of(context)!.deactivateStb,
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontWeight: FontWeight.w700,
              color: _c.ink,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'STB: ${box.stbNo}',
                  style: TextStyle(
                      fontFamily: 'DM Sans', fontSize: 14, color: _c.ink80),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  value: selectedReasonId,
                  decoration: InputDecoration(
                    labelText: 'Reason *',
                    labelStyle:
                        TextStyle(fontFamily: 'DM Sans', color: _c.ink40),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  isExpanded: true,
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
                      setDialogState(() => selectedReasonId = val),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: remarksController,
                  maxLines: 2,
                  style:
                      const TextStyle(fontFamily: 'DM Sans', fontSize: 14),
                  decoration: InputDecoration(
                    labelText: 'Remarks (optional)',
                    labelStyle:
                        TextStyle(fontFamily: 'DM Sans', color: _c.ink40),
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
              child: Text('Close',
                  style:
                      TextStyle(fontFamily: 'DM Sans', color: _c.ink60)),
            ),
            ElevatedButton(
              onPressed: selectedReasonId == null
                  ? null
                  : () {
                      Navigator.pop(ctx);
                      ref.read(stbProvider.notifier).deactivateBox(
                            _activeCustomerId!,
                            selectedReasonId.toString(),
                            remarks: remarksController.text.trim().isNotEmpty
                                ? remarksController.text.trim()
                                : null,
                            serialNumber: box.stbNo,
                            vcNumber: box.vcNo,
                            boxNumber: box.boxNumber,
                            macAddress: box.macAddress,
                            stockId: box.stockId,
                            deviceId: box.deviceId,
                            backEndSetupId: box.backendSetupId,
                          );
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: _c.red,
                foregroundColor: _c.card,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(AppLocalizations.of(context)!.deactivate,
                  style: const TextStyle(fontFamily: 'DM Sans')),
            ),
          ],
        ),
      ),
    );
  }

  // --------------------------------------------------------------------------
  // Reactivation confirmation
  // --------------------------------------------------------------------------

  void _confirmReactivate(StbModel box) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          AppLocalizations.of(context)!.reactivateStb,
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontWeight: FontWeight.w700,
            color: _c.ink,
          ),
        ),
        content: Text(
          AppLocalizations.of(context)!.confirmReactivate,
          style: TextStyle(
              fontFamily: 'DM Sans', fontSize: 14, color: _c.ink80),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppLocalizations.of(context)!.cancel,
                style:
                    TextStyle(fontFamily: 'DM Sans', color: _c.ink60)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(stbProvider.notifier).reactivateBox(
                    serialNumber: box.stbNo,
                    boxNumber: box.boxNumber,
                    macAddress: box.macAddress,
                    stockId: box.stockId,
                    deviceId: box.deviceId,
                    backEndSetupId: box.backendSetupId,
                  );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _c.red,
              foregroundColor: _c.card,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(AppLocalizations.of(context)!.ok,
                style: const TextStyle(fontFamily: 'DM Sans')),
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------------------------------
  // Regular Activate confirmation (redirects to package activation)
  // --------------------------------------------------------------------------

  void _confirmRegularActivate(StbModel box) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Activate STB',
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontWeight: FontWeight.w700,
            color: _c.ink,
          ),
        ),
        content: Text(
          'You will be redirected to Package Activation operation. Do you want to continue?',
          style: TextStyle(
              fontFamily: 'DM Sans', fontSize: 14, color: _c.ink80),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppLocalizations.of(context)!.cancel,
                style:
                    TextStyle(fontFamily: 'DM Sans', color: _c.ink60)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.push(RouteNames.packageOperations, extra: {
                'customerId': _activeCustomerId,
                'stbNo': box.stbNo,
                'customerName': widget.customerName,
                'boxNumber': box.boxNumber,
                'deviceId': box.deviceId,
                'stockId': box.stockId,
                'activateMode': true,
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _c.red,
              foregroundColor: _c.card,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Continue',
                style: TextStyle(fontFamily: 'DM Sans')),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// STB Card
// ---------------------------------------------------------------------------

class _StbCard extends StatelessWidget {
  final StbModel box;
  final AppColors colors;
  final String statusText;
  final Color statusColor;
  final Color statusBgColor;
  // Deactivate
  final bool showDeactivate;
  final VoidCallback onDeactivate;
  // Reactivate
  final bool showReactivate;
  final VoidCallback onReactivate;
  // Activate / Temp Activate
  final bool showActivate;
  final String activateLabel;
  final Color activateColor;
  final VoidCallback onActivate;
  // Other
  final VoidCallback onPackages;
  final VoidCallback onReplace;

  const _StbCard({
    required this.box,
    required this.colors,
    required this.statusText,
    required this.statusColor,
    required this.statusBgColor,
    required this.showDeactivate,
    required this.onDeactivate,
    required this.showReactivate,
    required this.onReactivate,
    required this.showActivate,
    required this.activateLabel,
    required this.activateColor,
    required this.onActivate,
    required this.onPackages,
    required this.onReplace,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.ink10),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Header row: icon + STB no + status badge
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: statusBgColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        LucideIcons.monitor,
                        size: 20,
                        color: statusColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Serial: ${box.stbNo}',
                            style: TextStyle(
                              fontFamily: 'DM Sans',
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: colors.ink,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'VC: ${box.vcNo}',
                            style: TextStyle(
                              fontFamily: 'DM Sans',
                              fontSize: 12,
                              color: colors.ink60,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Status badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusBgColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: statusColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            statusText,
                            style: TextStyle(
                              fontFamily: 'DM Sans',
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Detail rows
                Padding(
                  padding: const EdgeInsets.only(left: 56),
                  child: Column(
                    children: [
                      if (box.boxNumber != null &&
                          box.boxNumber!.isNotEmpty)
                        _detailRow('Box No', box.boxNumber!),
                      if (box.casType.isNotEmpty)
                        _detailRow('CAS', box.casType),
                      if (box.activatedDate != null &&
                          box.activatedDate!.isNotEmpty)
                        _detailRow('Activated', box.activatedDate!),
                      if (box.assignedDate != null &&
                          box.assignedDate!.isNotEmpty)
                        _detailRow('Assigned', box.assignedDate!),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Action buttons
          Container(
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: colors.ink10)),
            ),
            padding:
                const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Wrap(
              alignment: WrapAlignment.start,
              children: [
                // Deactivate (visible when config flag on AND box is active)
                if (showDeactivate)
                  _ActionButton(
                    icon: LucideIcons.powerOff,
                    label: AppLocalizations.of(context)!.deactivate,
                    color: colors.red,
                    onTap: onDeactivate,
                  ),

                // Reactivate (visible when config flag on AND box is active)
                if (showReactivate)
                  _ActionButton(
                    icon: LucideIcons.refreshCcw,
                    label: AppLocalizations.of(context)!.reactivateStb,
                    color: colors.green,
                    onTap: onReactivate,
                  ),

                // Activate / Temporary Activate (visible when config flag
                // on AND box is deactive)
                if (showActivate)
                  _ActionButton(
                    icon: activateLabel.contains('Temporary')
                        ? LucideIcons.timerReset
                        : LucideIcons.power,
                    label: activateLabel,
                    color: activateColor,
                    onTap: onActivate,
                  ),

                // Packages
                _ActionButton(
                  icon: LucideIcons.box,
                  label: AppLocalizations.of(context)!.packages,
                  color: colors.blue,
                  onTap: onPackages,
                ),

                // Replace
                _ActionButton(
                  icon: LucideIcons.refreshCw,
                  label: AppLocalizations.of(context)!.replacement,
                  color: colors.purple,
                  onTap: onReplace,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: colors.ink40,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 11,
                color: colors.ink60,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Action Button
// ---------------------------------------------------------------------------

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 14, color: color),
      label: Text(
        label,
        style: TextStyle(
          fontFamily: 'DM Sans',
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
      style: TextButton.styleFrom(
        padding:
            const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}
