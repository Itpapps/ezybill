import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../application/providers/stb_provider.dart';
import '../../../core/config/app_session.dart';
import '../../../core/theme/app_colors.dart';

/// Screen for pairing / unpairing STBs.
/// Tabs are gated by [AppSession.stbPairing] and [AppSession.stbUnpairing].
class StbPairUnpairScreen extends ConsumerStatefulWidget {
  final String? customerId;

  const StbPairUnpairScreen({super.key, this.customerId});

  @override
  ConsumerState<StbPairUnpairScreen> createState() =>
      _StbPairUnpairScreenState();
}

class _StbPairUnpairScreenState extends ConsumerState<StbPairUnpairScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Pair fields
  final _pairSerialController = TextEditingController();
  final _pairVcController = TextEditingController();

  // Unpair fields
  final _unpairSerialController = TextEditingController();

  AppColors get _c =>
      Theme.of(context).extension<AppColors>() ?? AppColors.light;

  @override
  void initState() {
    super.initState();
    final session = ref.read(appSessionProvider);
    final showPair = session?.stbPairing == 1;
    final showUnpair = session?.stbUnpairing == 1;
    final tabCount = (showPair ? 1 : 0) + (showUnpair ? 1 : 0);
    _tabController =
        TabController(length: tabCount > 0 ? tabCount : 1, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pairSerialController.dispose();
    _pairVcController.dispose();
    _unpairSerialController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(appSessionProvider);
    final stbState = ref.watch(stbProvider);
    final showPair = session?.stbPairing == 1;
    final showUnpair = session?.stbUnpairing == 1;

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

    final tabs = <Tab>[];
    final views = <Widget>[];

    if (showPair) {
      tabs.add(const Tab(text: 'Pair'));
      views.add(_buildPairTab(stbState));
    }
    if (showUnpair) {
      tabs.add(const Tab(text: 'Unpair'));
      views.add(_buildUnpairTab(stbState));
    }

    if (tabs.isEmpty) {
      tabs.add(const Tab(text: 'Not Available'));
      views.add(Center(
        child: Text(
          'Pair/Unpair not enabled for this account',
          style: TextStyle(
              fontFamily: 'DM Sans', fontSize: 14, color: _c.ink60),
        ),
      ));
    }

    // Ensure tab controller length matches
    if (_tabController.length != tabs.length) {
      _tabController.dispose();
      _tabController = TabController(length: tabs.length, vsync: this);
    }

    return Scaffold(
      backgroundColor: _c.bg,
      appBar: AppBar(
        title: const Text(
          'STB Pair / Unpair',
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
        bottom: TabBar(
          controller: _tabController,
          labelColor: _c.red,
          unselectedLabelColor: _c.ink40,
          labelStyle: const TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          indicatorColor: _c.red,
          indicatorWeight: 3,
          tabs: tabs,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: views,
      ),
    );
  }

  // ── Pair Tab ─────────────────────────────────────────────────────────────

  Widget _buildPairTab(StbState stbState) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildInfoBanner(
            'Enter the serial number and VC number to pair a set-top box.',
            LucideIcons.link,
          ),
          const SizedBox(height: 24),
          _buildTextField(
            controller: _pairSerialController,
            label: 'Serial Number',
            hint: 'Enter STB serial number',
            icon: LucideIcons.hash,
            hasScanButton: true,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _pairVcController,
            label: 'VC Number',
            hint: 'Enter VC number',
            icon: LucideIcons.creditCard,
            hasScanButton: true,
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              onPressed: stbState.isLoading ? null : _onPair,
              icon: stbState.isLoading
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child:
                          CircularProgressIndicator(strokeWidth: 2, color: _c.card),
                    )
                  : Icon(LucideIcons.link, size: 18, color: _c.card),
              label: Text(
                stbState.isLoading ? 'Pairing...' : 'Pair STB',
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

  // ── Unpair Tab ───────────────────────────────────────────────────────────

  Widget _buildUnpairTab(StbState stbState) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildInfoBanner(
            'Enter the serial number to unpair a set-top box.',
            LucideIcons.unlink,
          ),
          const SizedBox(height: 24),
          _buildTextField(
            controller: _unpairSerialController,
            label: 'Serial Number',
            hint: 'Enter STB serial number',
            icon: LucideIcons.hash,
            hasScanButton: true,
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              onPressed: stbState.isLoading ? null : _onUnpair,
              icon: stbState.isLoading
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child:
                          CircularProgressIndicator(strokeWidth: 2, color: _c.card),
                    )
                  : Icon(LucideIcons.unlink, size: 18, color: _c.card),
              label: Text(
                stbState.isLoading ? 'Unpairing...' : 'Unpair STB',
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

  // ── Actions ──────────────────────────────────────────────────────────────

  void _onPair() {
    final serial = _pairSerialController.text.trim();
    final vc = _pairVcController.text.trim();
    if (serial.isEmpty || vc.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter both Serial Number and VC Number'),
          backgroundColor: _c.amber,
        ),
      );
      return;
    }
    ref.read(stbProvider.notifier).pairStb(
          widget.customerId ?? '',
          serial,
          vc,
        );
  }

  void _onUnpair() {
    final serial = _unpairSerialController.text.trim();
    if (serial.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a Serial Number'),
          backgroundColor: _c.amber,
        ),
      );
      return;
    }
    ref.read(stbProvider.notifier).unpairStb(
          widget.customerId ?? '',
          serial,
        );
  }

  // ── Reusable widgets ────────────────────────────────────────────────────

  Widget _buildInfoBanner(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _c.blueSoft,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _c.blue.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: _c.blue),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 13,
                color: _c.blue,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool hasScanButton = false,
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
          style: TextStyle(
              fontFamily: 'DM Sans', fontSize: 14, color: _c.ink),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
                fontFamily: 'DM Sans', fontSize: 14, color: _c.ink40),
            prefixIcon: Icon(icon, size: 18, color: _c.ink40),
            suffixIcon: hasScanButton
                ? IconButton(
                    icon: Icon(LucideIcons.scanLine,
                        size: 20, color: _c.red),
                    tooltip: 'Scan Barcode',
                    onPressed: () {
                      // Barcode scanner integration placeholder
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Barcode scanner coming soon'),
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
