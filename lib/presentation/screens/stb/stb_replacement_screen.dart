import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../application/providers/stb_provider.dart';
import '../../../core/theme/app_colors.dart';

/// STB Replacement screen.
/// Shows old STB details (read-only), new STB input fields, replacement type,
/// amount, receipt number, remarks, and pair condition checkbox.
class StbReplacementScreen extends ConsumerStatefulWidget {
  final String? customerId;
  final String? stbNo;
  final String? customerName;

  const StbReplacementScreen({
    super.key,
    this.customerId,
    this.stbNo,
    this.customerName,
  });

  @override
  ConsumerState<StbReplacementScreen> createState() =>
      _StbReplacementScreenState();
}

class _StbReplacementScreenState extends ConsumerState<StbReplacementScreen> {
  final _newSerialController = TextEditingController();
  final _newVcController = TextEditingController();
  final _amountController = TextEditingController(text: '0');
  final _receiptController = TextEditingController();
  final _remarksController = TextEditingController();

  int _replacementType = 1; // Default type
  bool _pairCondition = false;

  AppColors get _c =>
      Theme.of(context).extension<AppColors>() ?? AppColors.light;

  static const _replacementTypes = [
    {'id': 1, 'name': 'Faulty Replacement'},
    {'id': 2, 'name': 'Upgrade Replacement'},
    {'id': 3, 'name': 'Downgrade Replacement'},
    {'id': 4, 'name': 'Other'},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.customerId != null && widget.stbNo != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(stbProvider.notifier).loadBoxDetails(
              widget.customerId!,
              widget.stbNo!,
            );
      });
    }
  }

  @override
  void dispose() {
    _newSerialController.dispose();
    _newVcController.dispose();
    _amountController.dispose();
    _receiptController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stbState = ref.watch(stbProvider);

    ref.listen<StbState>(stbProvider, (_, state) {
      if (state.successMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.successMessage!),
            backgroundColor: _c.green,
          ),
        );
        ref.read(stbProvider.notifier).clearMessages();
        Navigator.of(context).pop();
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
        title: const Text(
          'STB Replacement',
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
      body: stbState.isLoading && stbState.selectedStb == null
          ? Center(child: CircularProgressIndicator(color: _c.red))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Old STB Details (read-only)
                  _buildOldStbCard(stbState),
                  const SizedBox(height: 20),

                  // New STB section
                  _buildSectionTitle('New STB Details'),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _newSerialController,
                    label: 'Serial Number',
                    hint: 'Enter new STB serial number',
                    icon: LucideIcons.hash,
                    hasScanButton: true,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _newVcController,
                    label: 'VC Number',
                    hint: 'Enter new VC number',
                    icon: LucideIcons.creditCard,
                    hasScanButton: true,
                  ),
                  const SizedBox(height: 20),

                  // Replacement type
                  _buildSectionTitle('Replacement Info'),
                  const SizedBox(height: 12),
                  _buildReplacementTypeDropdown(),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _amountController,
                    label: 'Amount',
                    hint: '0.00',
                    icon: LucideIcons.indianRupee,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _receiptController,
                    label: 'Receipt Number',
                    hint: 'Enter receipt number',
                    icon: LucideIcons.receipt,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _remarksController,
                    label: 'Remarks',
                    hint: 'Enter remarks',
                    icon: LucideIcons.messageSquare,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),

                  // Pair condition
                  Container(
                    decoration: BoxDecoration(
                      color: _c.card,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _c.ink10),
                    ),
                    child: CheckboxListTile(
                      value: _pairCondition,
                      onChanged: (val) =>
                          setState(() => _pairCondition = val ?? false),
                      title: Text(
                        'Pair after replacement',
                        style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _c.ink,
                        ),
                      ),
                      subtitle: Text(
                        'Automatically pair the new STB with the customer',
                        style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 12,
                          color: _c.ink60,
                        ),
                      ),
                      activeColor: _c.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Replace button
                  SizedBox(
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: stbState.isLoading ? null : _onReplace,
                      icon: stbState.isLoading
                          ? SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: _c.card),
                            )
                          : Icon(LucideIcons.refreshCw,
                              size: 18, color: _c.card),
                      label: Text(
                        stbState.isLoading ? 'Replacing...' : 'Replace STB',
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
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  // ── Old STB Card ────────────────────────────────────────────────────────

  Widget _buildOldStbCard(StbState stbState) {
    final box = stbState.selectedStb;
    final details = stbState.boxDetails;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _c.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _c.ink10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _c.amberSoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(LucideIcons.monitor, size: 20, color: _c.amber),
              ),
              const SizedBox(width: 12),
              Text(
                'Current STB',
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: _c.ink,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(color: _c.ink10),
          const SizedBox(height: 8),
          _readOnlyRow(
              'Serial', box?.stbNo ?? widget.stbNo ?? '-'),
          _readOnlyRow('VC Number', box?.vcNo ?? '-'),
          _readOnlyRow('CAS Type', box?.casType ?? '-'),
          _readOnlyRow('Status', box?.status ?? '-'),
          if (box?.macAddress != null)
            _readOnlyRow('MAC Address', box!.macAddress!),
          if (details?['stock_id'] != null)
            _readOnlyRow('Stock ID', details!['stock_id'].toString()),
        ],
      ),
    );
  }

  Widget _readOnlyRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _c.ink40,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 13,
                color: _c.ink80,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Replacement Type Dropdown ────────────────────────────────────────────

  Widget _buildReplacementTypeDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Replacement Type',
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: _c.ink80,
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<int>(
          value: _replacementType,
          decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
            fillColor: _c.card,
          ),
          isExpanded: true,
          items: _replacementTypes.map((t) {
            return DropdownMenuItem<int>(
              value: t['id'] as int,
              child: Text(
                t['name'] as String,
                style: TextStyle(
                    fontFamily: 'DM Sans', fontSize: 14, color: _c.ink),
              ),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) setState(() => _replacementType = val);
          },
        ),
      ],
    );
  }

  // ── Actions ──────────────────────────────────────────────────────────────

  void _onReplace() {
    final newSerial = _newSerialController.text.trim();
    final newVc = _newVcController.text.trim();

    if (newSerial.isEmpty || newVc.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
              'Please enter both Serial Number and VC Number for the new STB'),
          backgroundColor: _c.amber,
        ),
      );
      return;
    }

    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Confirm Replacement',
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontWeight: FontWeight.w700,
            color: _c.ink,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Replace STB ${widget.stbNo ?? ''} with $newSerial?',
              style: TextStyle(
                  fontFamily: 'DM Sans', fontSize: 14, color: _c.ink80),
            ),
            const SizedBox(height: 8),
            Text(
              'This action cannot be undone.',
              style: TextStyle(
                  fontFamily: 'DM Sans', fontSize: 12, color: _c.ink40),
            ),
          ],
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
              ref.read(stbProvider.notifier).replaceStb(
                    widget.customerId ?? '',
                    widget.stbNo ?? '',
                    newSerial,
                    newVc,
                  );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _c.red,
              foregroundColor: _c.card,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Replace',
                style: TextStyle(fontFamily: 'DM Sans')),
          ),
        ],
      ),
    );
  }

  // ── Reusable widgets ────────────────────────────────────────────────────

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontFamily: 'DM Sans',
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: _c.ink,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool hasScanButton = false,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: _c.ink80,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: TextStyle(
              fontFamily: 'DM Sans', fontSize: 14, color: _c.ink),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
                fontFamily: 'DM Sans', fontSize: 14, color: _c.ink40),
            prefixIcon: Icon(icon, size: 18, color: _c.ink40),
            suffixIcon: hasScanButton
                ? IconButton(
                    icon:
                        Icon(LucideIcons.scanLine, size: 20, color: _c.red),
                    tooltip: 'Scan Barcode',
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content:
                              const Text('Barcode scanner coming soon'),
                          backgroundColor: _c.amber,
                        ),
                      );
                    },
                  )
                : null,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
            fillColor: _c.card,
          ),
        ),
      ],
    );
  }
}
