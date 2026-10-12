import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../application/providers/dashboard_provider.dart';
import '../../../application/providers/stb_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../common/widgets/app_shell.dart';
import '../../router/route_names.dart';

/// STB Replacement screen — the native replace sheet
/// (Box_Operations_Fragment.showBottomSheet, :448-626; fragment_replace.xml)
/// as a full screen.
///
/// The reasons and the amount/receipt rules come from the server for this box
/// (getCustomerParticularBoxDetailsRest), and the request goes out with the
/// server's own field names (StbRemoteDatasource.stbReplacement).
class StbReplacementScreen extends ConsumerStatefulWidget {
  final String? customerId;
  final String? stbNo;
  final String? customerName;
  final String? stockId;
  final String? vcNo;
  final String? casType;
  final String? status;

  const StbReplacementScreen({
    super.key,
    this.customerId,
    this.stbNo,
    this.customerName,
    this.stockId,
    this.vcNo,
    this.casType,
    this.status,
  });

  @override
  ConsumerState<StbReplacementScreen> createState() =>
      _StbReplacementScreenState();
}

/// Native "Replace with" spinner: Choose / Serial Number / VC Number.
enum _ReplaceWith { serial, vc }

class _StbReplacementScreenState extends ConsumerState<StbReplacementScreen> {
  final _replaceWithController = TextEditingController();
  final _amountController = TextEditingController();
  final _receiptController = TextEditingController();
  final _remarksController = TextEditingController();

  ReplacementOptions? _options;
  bool _loadingOptions = true;
  bool _submitting = false;

  /// Null = native's "Choose".
  ReplacementType? _reason;
  _ReplaceWith? _replaceWith;
  bool _permanentSurrender = false;
  bool _unpair = false;

  AppColors get _c =>
      Theme.of(context).extension<AppColors>() ?? AppColors.light;

  bool get _isSurrender => _reason?.isSurrender ?? false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadOptions());
  }

  Future<void> _loadOptions() async {
    final customerId = widget.customerId ?? '';
    final stockId = widget.stockId ?? '';
    ReplacementOptions? options;
    if (customerId.isNotEmpty && stockId.isNotEmpty) {
      options = await ref
          .read(stbProvider.notifier)
          .loadReplacementOptions(customerId, stockId);
    }
    if (!mounted) return;
    setState(() {
      _options = options;
      _loadingOptions = false;
    });
  }

  @override
  void dispose() {
    _replaceWithController.dispose();
    _amountController.dispose();
    _receiptController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final options = _options;
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
      body: _loadingOptions
          ? Center(child: CircularProgressIndicator(color: _c.red))
          : (options == null || !options.enabled)
              ? _buildUnavailable(options == null)
              : _buildForm(options),
    );
  }

  Widget _buildUnavailable(bool failedToLoad) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text(
          failedToLoad
              ? 'Could not load the replacement details. Please go back and try again.'
              : 'STB replacement is not enabled for this account.',
          textAlign: TextAlign.center,
          style: TextStyle(fontFamily: 'DM Sans', fontSize: 14, color: _c.ink60),
        ),
      ),
    );
  }

  Widget _buildForm(ReplacementOptions options) {
    return SingleChildScrollView(
      // The shell hosts this route with extendBody:true, so the content
      // paints under the nav bar and the AI button. Reserve that band or the
      // Replace button ends up behind them (same fix as LcoTopupScreen).
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        20 + shellBottomClearance(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildOldStbCard(),
          const SizedBox(height: 20),
          _buildSectionTitle('Replacement Details'),
          const SizedBox(height: 12),
          _buildReasonDropdown(options),
          // Native hides the new-box fields for a surrender
          // (Box_Operations_Fragment.java:519-527).
          if (!_isSurrender) ...[
            const SizedBox(height: 12),
            _buildReplaceWithDropdown(),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _replaceWithController,
              label: switch (_replaceWith) {
                _ReplaceWith.serial => 'Replace with Serial No. *',
                _ReplaceWith.vc => 'Replace with VC No. *',
                null => 'Replace with *',
              },
              hint: _replaceWith == _ReplaceWith.vc
                  ? 'Enter new VC number'
                  : 'Enter new STB serial number',
              icon: LucideIcons.hash,
            ),
          ],
          const SizedBox(height: 12),
          _buildTextField(
            controller: _amountController,
            label: options.amountMandatory ? 'Amount *' : 'Amount',
            hint: '0.00',
            icon: LucideIcons.indianRupee,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _receiptController,
            label: options.receiptMandatory ? 'Receipt No. *' : 'Receipt No.',
            hint: 'Enter receipt number',
            icon: LucideIcons.receipt,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _remarksController,
            label: 'Remarks *',
            hint: 'Enter remarks',
            icon: LucideIcons.messageSquare,
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          if (_isSurrender) ...[
            _buildCheckbox(
              value: _permanentSurrender,
              title: 'Is it permanent surrender',
              onChanged: (v) => setState(() => _permanentSurrender = v),
            ),
            const SizedBox(height: 8),
          ],
          _buildCheckbox(
            value: _unpair,
            title: 'Unpair the box',
            onChanged: (v) => setState(() => _unpair = v),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _submitting ? null : _onReplace,
              icon: _submitting
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: _c.card),
                    )
                  : Icon(LucideIcons.refreshCw, size: 18, color: _c.card),
              label: Text(
                _submitting ? 'Replacing...' : 'Replace STB',
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
    );
  }

  // ── Current STB card ─────────────────────────────────────────────────────

  Widget _buildOldStbCard() {
    String orDash(String? v) => (v == null || v.trim().isEmpty) ? '-' : v;
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
          if ((widget.customerName ?? '').trim().isNotEmpty)
            _readOnlyRow('Customer', widget.customerName!),
          _readOnlyRow('Serial', orDash(widget.stbNo)),
          _readOnlyRow('VC Number', orDash(widget.vcNo)),
          _readOnlyRow('CAS Type', orDash(widget.casType)),
          _readOnlyRow('Status', orDash(widget.status)),
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

  // ── Dropdowns ────────────────────────────────────────────────────────────

  Widget _buildReasonDropdown(ReplacementOptions options) {
    return _labelled(
      'Replacement Reason *',
      DropdownButtonFormField<String>(
        initialValue: _reason?.id,
        decoration: _fieldDecoration(),
        isExpanded: true,
        hint: Text(
          options.types.isEmpty ? 'No replacement reasons available' : 'Choose',
          style: TextStyle(fontFamily: 'DM Sans', fontSize: 14, color: _c.ink40),
        ),
        items: [
          for (final t in options.types)
            DropdownMenuItem<String>(
              value: t.id,
              child: Text(
                t.name,
                style:
                    TextStyle(fontFamily: 'DM Sans', fontSize: 14, color: _c.ink),
              ),
            ),
        ],
        onChanged: (id) => setState(() {
          _reason = options.types.firstWhere((t) => t.id == id);
        }),
      ),
    );
  }

  Widget _buildReplaceWithDropdown() {
    return _labelled(
      'Replace with Type *',
      DropdownButtonFormField<_ReplaceWith>(
        initialValue: _replaceWith,
        decoration: _fieldDecoration(),
        isExpanded: true,
        hint: Text(
          'Choose',
          style: TextStyle(fontFamily: 'DM Sans', fontSize: 14, color: _c.ink40),
        ),
        items: [
          for (final (value, text) in const [
            (_ReplaceWith.serial, 'Serial Number'),
            (_ReplaceWith.vc, 'VC Number'),
          ])
            DropdownMenuItem<_ReplaceWith>(
              value: value,
              child: Text(
                text,
                style:
                    TextStyle(fontFamily: 'DM Sans', fontSize: 14, color: _c.ink),
              ),
            ),
        ],
        onChanged: (v) => setState(() => _replaceWith = v),
      ),
    );
  }

  // ── Actions ──────────────────────────────────────────────────────────────

  /// Validation order and messages are native's
  /// (Box_Operations_Fragment.java:589-603).
  void _onReplace() {
    final options = _options!;
    final amount = _amountController.text.trim();
    final newBox = _replaceWithController.text.trim();

    String? error;
    if (_reason == null) {
      error = 'Please choose any Replacement Reason';
    } else if (options.amountMandatory && amount.isEmpty) {
      error = 'Amount should not be empty';
    } else if (options.amountMandatory && (double.tryParse(amount) ?? 0) == 0) {
      error = 'Amount should be greater than 0';
    } else if (options.receiptMandatory &&
        _receiptController.text.trim().isEmpty) {
      error = 'Please Enter Receipt Number';
    } else if (_remarksController.text.trim().isEmpty) {
      error = 'Please Enter Remarks';
    } else if (!_isSurrender && newBox.isEmpty) {
      error = 'Please Enter Box Details';
    } else if (!_isSurrender && _replaceWith == null) {
      error = 'Please choose replacement type';
    }
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: _c.amber),
      );
      return;
    }

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Replacement:'),
        content: const Text('Are you sure you want to replace this STB?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _submit();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    final newBox = _isSurrender ? '' : _replaceWithController.text.trim();
    final result = await ref.read(stbProvider.notifier).replaceStb(
          customerId: widget.customerId ?? '',
          serialNumber: widget.stbNo ?? '',
          replacementTypeId: _reason!.id,
          amount: _amountController.text.trim(),
          receiptNumber: _receiptController.text.trim(),
          remarks: _remarksController.text.trim(),
          replaceSerialNumber: _replaceWith == _ReplaceWith.serial ? newBox : '',
          replaceVcNumber: _replaceWith == _ReplaceWith.vc ? newBox : '',
          // Only meaningful for a surrender; native keeps the checkbox
          // hidden otherwise.
          permanentSurrender: _isSurrender && _permanentSurrender,
          unpair: _unpair,
        );
    if (!mounted) return;
    setState(() => _submitting = false);
    _showResult(result.code, result.message);
  }

  /// Native's three result dialogs (Box_Operations_Fragment.java:2350-2390).
  void _showResult(int code, String message) {
    if (code == 0) {
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => PopScope(
          canPop: false,
          child: AlertDialog(
            title: const Text('STB Replacement!'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  // Native returns to a freshly built Dashboard.
                  ref.read(dashboardProvider.notifier).loadDashboard();
                  context.go(RouteNames.home);
                },
                child: const Text('OK'),
              ),
            ],
          ),
        ),
      );
      return;
    }
    if (code < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: _c.red),
      );
      return;
    }
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(code == 1 ? 'STB Replacement failed:' : 'Connectivity Error'),
        content: Text('$message!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
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

  Widget _labelled(String label, Widget field) {
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
        field,
      ],
    );
  }

  InputDecoration _fieldDecoration({String? hint, IconData? icon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle:
          TextStyle(fontFamily: 'DM Sans', fontSize: 14, color: _c.ink40),
      prefixIcon: icon == null ? null : Icon(icon, size: 18, color: _c.ink40),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return _labelled(
      label,
      TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: TextStyle(fontFamily: 'DM Sans', fontSize: 14, color: _c.ink),
        decoration: _fieldDecoration(hint: hint, icon: icon),
      ),
    );
  }

  Widget _buildCheckbox({
    required bool value,
    required String title,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _c.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _c.ink10),
      ),
      child: CheckboxListTile(
        value: value,
        onChanged: (v) => onChanged(v ?? false),
        title: Text(
          title,
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: _c.ink,
          ),
        ),
        activeColor: _c.red,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        controlAffinity: ListTileControlAffinity.leading,
      ),
    );
  }
}
