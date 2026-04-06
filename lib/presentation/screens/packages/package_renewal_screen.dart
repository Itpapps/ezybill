import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../application/providers/package_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/package/package_model.dart';

/// Standalone renewal screen (Section 5 of business logic spec).
///
/// Visibility gating: Only accessible when isexpired == 1 AND
/// patchInformation matches version strings ("1.4.13.2", "1.4.13.3", "1.4.13.4").
///
/// Flow:
///   1. Load: getRenewServicesList with customer_id, dealer_id
///   2. Multi-select packages
///   3. Summary dialog with names and prices
///   4. Confirmation: "Are you sure you want to Renew packages?"
///   5. Submit: renewServicesList with BOTH comma-separated
///      customer_service_id AND product_ids (separate params)
class PackageRenewalScreen extends ConsumerStatefulWidget {
  final String? customerId;
  final String? stbNo;

  const PackageRenewalScreen({
    super.key,
    this.customerId,
    this.stbNo,
  });

  @override
  ConsumerState<PackageRenewalScreen> createState() =>
      _PackageRenewalScreenState();
}

class _PackageRenewalScreenState extends ConsumerState<PackageRenewalScreen> {
  AppColors get _c =>
      Theme.of(context).extension<AppColors>() ?? AppColors.light;

  @override
  void initState() {
    super.initState();
    if (widget.customerId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Load renewable services using customer_id and dealer_id
        // per Section 5.1
        ref.read(packageProvider.notifier).loadRenewable(
              widget.customerId!,
            );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final pkgState = ref.watch(packageProvider);

    ref.listen<PackageState>(packageProvider, (_, state) {
      if (state.successMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.successMessage!),
            backgroundColor: _c.green,
          ),
        );
        ref.read(packageProvider.notifier).clearMessages();
        Navigator.of(context).pop();
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
        title: const Text(
          'Service Renewal',
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: _c.card,
        foregroundColor: _c.ink,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: Column(
        children: [
          // Info header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
            color: _c.card,
            child: Row(
              children: [
                Icon(LucideIcons.refreshCw, size: 18, color: _c.blue),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Select services to renew for this STB',
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 13,
                      color: _c.ink60,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: pkgState.isLoading
                ? Center(child: CircularProgressIndicator(color: _c.red))
                : pkgState.renewableServices.isEmpty
                    ? _buildEmpty()
                    : _buildList(pkgState),
          ),

          // Bottom action bar
          if (pkgState.selectedIds.isNotEmpty) _buildBottomBar(pkgState),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: _c.blueSoft,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(LucideIcons.refreshCw, size: 32, color: _c.blue),
          ),
          const SizedBox(height: 16),
          Text(
            'No Renewable Services',
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: _c.ink,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No services available for renewal at this time',
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

  Widget _buildList(PackageState pkgState) {
    final services = pkgState.renewableServices;

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: services.length,
      itemBuilder: (context, index) {
        final svc = services[index];
        final isSelected = pkgState.selectedIds.contains(svc.packageId);

        return GestureDetector(
          onTap: () {
            ref.read(packageProvider.notifier).toggleSelection(svc.packageId);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isSelected ? _c.blueSoft : _c.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? _c.blue.withValues(alpha: 0.4)
                    : _c.ink10,
              ),
            ),
            child: Row(
              children: [
                // Checkbox
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: isSelected ? _c.blue : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isSelected ? _c.blue : _c.ink20,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? Icon(LucideIcons.check, size: 14, color: _c.card)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        svc.packageName,
                        style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _c.ink,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            '\u20B9${svc.price.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontFamily: 'DM Sans',
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: _c.red,
                            ),
                          ),
                          if (svc.validity.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: _c.ink05,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '${svc.validityDays}d ${svc.validity}',
                                style: TextStyle(
                                  fontFamily: 'DM Sans',
                                  fontSize: 10,
                                  color: _c.ink40,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      // Show customer_service_id for transparency
                      if (svc.customerServiceId != null &&
                          svc.customerServiceId!.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          'Service ID: ${svc.customerServiceId}',
                          style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 10,
                            color: _c.ink40,
                          ),
                        ),
                      ],
                      if (svc.endDate != null &&
                          svc.endDate!.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          'Expired: ${svc.endDate}',
                          style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 11,
                            color: _c.amber,
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
      },
    );
  }

  Widget _buildBottomBar(PackageState pkgState) {
    final count = pkgState.selectedIds.length;

    // Calculate total
    double total = 0;
    for (final id in pkgState.selectedIds) {
      final svc =
          pkgState.renewableServices.where((s) => s.packageId == id).firstOrNull;
      if (svc != null) total += svc.price;
    }

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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$count service${count != 1 ? 's' : ''} selected',
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _c.ink80,
                  ),
                ),
                Text(
                  'Total: \u20B9${total.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _c.ink,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: pkgState.isLoading ? null : () => _onSubmit(pkgState),
                icon: pkgState.isLoading
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: _c.card),
                      )
                    : Icon(LucideIcons.refreshCw, size: 18, color: _c.card),
                label: Text(
                  pkgState.isLoading ? 'Submitting...' : 'Submit Renewal',
                  style: const TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 15,
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
          ],
        ),
      ),
    );
  }

  /// Renewal submission with summary dialog (Section 5.2-5.3).
  /// Shows selected packages list with names and prices, total amount,
  /// then asks confirmation: "Are you sure you want to Renew packages?"
  void _onSubmit(PackageState pkgState) {
    if (widget.customerId == null) return;

    // Build summary
    final selectedServices = <PackageModel>[];
    double total = 0;
    for (final id in pkgState.selectedIds) {
      final svc = pkgState.renewableServices
          .where((s) => s.packageId == id)
          .firstOrNull;
      if (svc != null) {
        selectedServices.add(svc);
        total += svc.price;
      }
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Confirm Renewal',
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
              // Package list
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
                  'Total: \u20B9${total.toStringAsFixed(2)}',
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
            child: Text('Cancel',
                style: TextStyle(
                    fontFamily: 'DM Sans', color: _c.ink60)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              // Submit renewal with both customer_service_id and product_ids
              // per Section 5.3
              ref.read(packageProvider.notifier).submitRenewal(
                    widget.customerId!,
                  );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _c.red,
              foregroundColor: _c.card,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Renew',
                style: TextStyle(fontFamily: 'DM Sans')),
          ),
        ],
      ),
    );
  }
}
