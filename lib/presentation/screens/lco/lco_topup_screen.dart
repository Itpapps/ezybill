import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../application/providers/dashboard_provider.dart';
import '../../../core/config/app_session.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../common/widgets/app_shell.dart';
import '../../common/widgets/app_toast.dart';
import '../../router/route_names.dart';

/// LCO Wallet top-up screen.
///
/// Shows current balance, preset amount buttons, custom input, and
/// navigates to the payment WebView to complete the top-up.
class LcoTopupScreen extends ConsumerStatefulWidget {
  const LcoTopupScreen({super.key});

  @override
  ConsumerState<LcoTopupScreen> createState() => _LcoTopupScreenState();
}

class _LcoTopupScreenState extends ConsumerState<LcoTopupScreen> {
  final _customAmountController = TextEditingController();
  int? _selectedPreset;

  static const List<int> _presets = [1000, 2500, 5000, 10000];

  @override
  void dispose() {
    _customAmountController.dispose();
    super.dispose();
  }

  double get _selectedAmount {
    if (_selectedPreset != null) return _selectedPreset!.toDouble();
    final custom = double.tryParse(_customAmountController.text.trim());
    return custom ?? 0;
  }

  void _selectPreset(int amount) {
    setState(() {
      _selectedPreset = amount;
      _customAmountController.clear();
    });
  }

  void _onCustomAmountChanged(String value) {
    if (value.isNotEmpty) {
      setState(() => _selectedPreset = null);
    }
  }

  void _onAddToWallet() {
    final amount = _selectedAmount;
    if (amount <= 0) {
      AppToast.show(context,
          message: 'Select or enter an amount.', variant: ToastVariant.info);
      return;
    }

    final session = ref.read(appSessionProvider);
    if (session == null) return;

    context.pushNamed(
      RouteNames.paymentWebviewName,
      extra: {
        'customerId': '', // LCO top-up — no customer ID needed
        'amount': amount.toStringAsFixed(2),
        'authKey': session.token,
        'employeeId': session.employeeId.toString(),
        'dealerId': session.dealerId.toString(),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;
    final session = ref.watch(appSessionProvider);
    final dashState = ref.watch(dashboardProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Top Up Wallet'),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        // The shell hosts this route with extendBody:true, so the content
        // paints under the nav bar and the AI button. Reserve that band or the
        // Add to Wallet button below is left behind them.
        padding: EdgeInsets.fromLTRB(
          16,
          16,
          16,
          16 + shellBottomClearance(context),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── LCO Name + Balance Card ──────────────────────────────────
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: c.card,
                borderRadius: AppRadius.cardBR,
                boxShadow: AppShadow.card,
              ),
              child: Column(
                children: [
                  // LCO name
                  Text(
                    session?.businessName ?? 'LCO',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: c.ink,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    session?.lcoCode ?? '',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: c.ink40,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Wallet icon
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: c.greenSoft,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    alignment: Alignment.center,
                    child: Icon(LucideIcons.wallet, size: 24, color: c.green),
                  ),
                  const SizedBox(height: 12),

                  // Balance label
                  Text(
                    'Current Balance',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: c.ink40,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formatCurrency(dashState.walletBalance),
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: c.ink,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Section label ────────────────────────────────────────────
            Text(
              'SELECT AMOUNT',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: c.ink40,
              ),
            ),
            const SizedBox(height: 12),

            // ── Preset Grid ──────────────────────────────────────────────
            GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 2.5,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: _presets.map((amount) {
                final selected = _selectedPreset == amount;
                return GestureDetector(
                  onTap: () => _selectPreset(amount),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: selected ? c.redSoft : c.card,
                      borderRadius: AppRadius.cardBR,
                      border: Border.all(
                        color: selected ? c.red : c.ink10,
                        width: selected ? 2 : 1.5,
                      ),
                      boxShadow: selected ? null : AppShadow.card,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      formatCurrency(amount.toDouble()),
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: selected ? c.red : c.ink,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // ── Custom Amount ────────────────────────────────────────────
            Text(
              'OR ENTER CUSTOM AMOUNT',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: c.ink40,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _customAmountController,
              onChanged: _onCustomAmountChanged,
              decoration: InputDecoration(
                hintText: 'Enter amount',
                prefixText: '\u20B9 ',
                prefixStyle: GoogleFonts.jetBrainsMono(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: c.ink,
                ),
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              style: GoogleFonts.jetBrainsMono(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: c.ink,
              ),
            ),
            const SizedBox(height: 32),

            // ── Add to Wallet Button ─────────────────────────────────────
            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _onAddToWallet,
                icon: const Icon(LucideIcons.plus, size: 18),
                label: Text(
                  'Add to Wallet',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: c.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.pillBR,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
