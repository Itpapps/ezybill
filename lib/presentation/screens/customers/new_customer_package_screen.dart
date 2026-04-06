import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../application/providers/core_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/datasources/remote/package_remote_datasource.dart';
import '../../../data/models/package/cas_package.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// Step 3: Package Selection
// ═══════════════════════════════════════════════════════════════════════════════

class NewCustomerPackageScreen extends ConsumerStatefulWidget {
  final String stbNumber;
  final CasPackage? selectedPackage;
  final int cycle;
  final int quantity;
  final int validityDays;
  final void Function(CasPackage? pkg, int cycle, int qty, int days)
      onPackageSelected;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const NewCustomerPackageScreen({
    super.key,
    required this.stbNumber,
    required this.selectedPackage,
    required this.cycle,
    required this.quantity,
    required this.validityDays,
    required this.onPackageSelected,
    required this.onNext,
    required this.onBack,
  });

  @override
  ConsumerState<NewCustomerPackageScreen> createState() =>
      _NewCustomerPackageScreenState();
}

class _NewCustomerPackageScreenState
    extends ConsumerState<NewCustomerPackageScreen> {
  List<CasPackage> _packages = [];
  List<CasPackage> _filtered = [];
  bool _isLoading = true;
  String? _error;
  final _searchCtrl = TextEditingController();

  CasPackage? _selected;
  int _cycle = 2;
  int _quantity = 1;
  int _validityDays = 30;
  final _quantityCtrl = TextEditingController(text: '1');
  final _validityCtrl = TextEditingController(text: '30');

  @override
  void initState() {
    super.initState();
    _selected = widget.selectedPackage;
    _cycle = widget.cycle;
    _quantity = widget.quantity;
    _validityDays = widget.validityDays;
    _quantityCtrl.text = _quantity.toString();
    _validityCtrl.text = _validityDays.toString();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadPackages());
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _quantityCtrl.dispose();
    _validityCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadPackages() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final session = ref.read(appSessionProvider);
      final ds = PackageRemoteDatasource(dio: ref.read(dioClientProvider));
      final data = await ds.getCasPackages(
        authtoken: session?.token ?? '',
        boxNumber:
            widget.stbNumber.isNotEmpty ? widget.stbNumber : null,
      );

      final rawList = data['casPackagesList'] ??
          data['casPackages'] ??
          data['data'] ??
          [];
      final packages = (rawList as List)
          .whereType<Map<String, dynamic>>()
          .map((e) => CasPackage.fromJson(e))
          .toList();

      setState(() {
        _packages = packages;
        _filtered = packages;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString().replaceAll('ApiException: ', '');
      });
    }
  }

  void _filterPackages(String query) {
    final q = query.toLowerCase().trim();
    setState(() {
      _filtered = q.isEmpty
          ? _packages
          : _packages
              .where((p) =>
                  p.productName.toLowerCase().contains(q) ||
                  p.productId.toLowerCase().contains(q))
              .toList();
    });
  }

  void _selectPackage(CasPackage pkg) {
    setState(() {
      _selected = pkg;
      // Default cycle based on pricing structure type
      if (pkg.pricingStructureType == '1') {
        // One-time: allow Year/Month/Day
        _cycle = 2;
      } else {
        // Recurring: Year only
        _cycle = 1;
      }
    });
  }

  void _notifyParent() {
    _quantity = int.tryParse(_quantityCtrl.text) ?? 1;
    _validityDays = int.tryParse(_validityCtrl.text) ?? 30;
    widget.onPackageSelected(_selected, _cycle, _quantity, _validityDays);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search bar
                TextFormField(
                  controller: _searchCtrl,
                  onChanged: _filterPackages,
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 14,
                    color: colors.ink,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search packages...',
                    hintStyle: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      color: colors.ink40,
                    ),
                    prefixIcon:
                        Icon(LucideIcons.search, size: 18, color: colors.ink40),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
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
                    filled: true,
                    fillColor: colors.card,
                  ),
                ),
                const SizedBox(height: 16),

                // Package list
                if (_isLoading)
                  _LoadingIndicator(colors: colors)
                else if (_error != null)
                  _ErrorCard(error: _error!, colors: colors, onRetry: _loadPackages)
                else if (_packages.isEmpty)
                  _EmptyState(colors: colors)
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (ctx, i) {
                      final pkg = _filtered[i];
                      final isSelected =
                          _selected?.productId == pkg.productId;
                      return _PackageCard(
                        package: pkg,
                        isSelected: isSelected,
                        colors: colors,
                        onTap: () => _selectPackage(pkg),
                      );
                    },
                  ),

                // Activation details (when a package is selected)
                if (_selected != null) ...[
                  const SizedBox(height: 20),
                  Text(
                    'Activation Details',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: colors.ink,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colors.card,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: colors.ink10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Cycle dropdown
                        Text(
                          'Activation Cycle',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: colors.ink60,
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<int>(
                          value: _cycle,
                          isExpanded: true,
                          decoration: InputDecoration(
                            prefixIcon: Icon(LucideIcons.repeat,
                                size: 18, color: colors.ink40),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: colors.ink10),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: colors.ink10),
                            ),
                            filled: true,
                            fillColor: colors.bg,
                          ),
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 14,
                            color: colors.ink,
                          ),
                          items: [
                            DropdownMenuItem(
                              value: 1,
                              child: const Text('Year'),
                            ),
                            if (_selected!.pricingStructureType == '1') ...[
                              DropdownMenuItem(
                                value: 2,
                                child: const Text('Month'),
                              ),
                              DropdownMenuItem(
                                value: 3,
                                child: const Text('Day'),
                              ),
                            ],
                          ],
                          onChanged: (v) {
                            if (v != null) setState(() => _cycle = v);
                          },
                        ),
                        const SizedBox(height: 16),

                        // Quantity
                        Text(
                          'Quantity',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: colors.ink60,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _quantityCtrl,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 14,
                            color: colors.ink,
                          ),
                          decoration: InputDecoration(
                            prefixIcon: Icon(LucideIcons.hash,
                                size: 18, color: colors.ink40),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 12),
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
                            filled: true,
                            fillColor: colors.bg,
                          ),
                        ),

                        // Validity days (visible only for Day cycle)
                        if (_cycle == 3) ...[
                          const SizedBox(height: 16),
                          Text(
                            'Validity (Days)',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: colors.ink60,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _validityCtrl,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 14,
                              color: colors.ink,
                            ),
                            decoration: InputDecoration(
                              prefixIcon: Icon(LucideIcons.clock,
                                  size: 18, color: colors.ink40),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 12),
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
                              filled: true,
                              fillColor: colors.bg,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),

        // ── Bottom navigation bar ──────────────────────────────────────
        Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          decoration: BoxDecoration(
            color: colors.card,
            border: Border(top: BorderSide(color: colors.ink10)),
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: widget.onBack,
                  icon: const Icon(LucideIcons.arrowLeft, size: 16),
                  label: const Text(
                    'Back',
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
                  onPressed: _selected != null
                      ? () {
                          _notifyParent();
                          widget.onNext();
                        }
                      : null,
                  icon: const Icon(LucideIcons.arrowRight, size: 18),
                  label: const Text(
                    'Next: Review',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.red,
                    foregroundColor: colors.card,
                    disabledBackgroundColor: colors.red.withAlpha(80),
                    disabledForegroundColor: colors.card.withAlpha(128),
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
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Package Card
// ═══════════════════════════════════════════════════════════════════════════════

class _PackageCard extends StatelessWidget {
  final CasPackage package;
  final bool isSelected;
  final AppColors colors;
  final VoidCallback onTap;

  const _PackageCard({
    required this.package,
    required this.isSelected,
    required this.colors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? colors.redSoft : colors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? colors.red : colors.ink10,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected ? colors.red : colors.ink05,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                LucideIcons.package2,
                size: 20,
                color: isSelected ? colors.card : colors.ink40,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    package.productName,
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: colors.ink,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'ID: ${package.productId}  |  Type: ${package.pricingStructureType == '1' ? 'One-time' : 'Recurring'}',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 12,
                      color: colors.ink40,
                    ),
                  ),
                ],
              ),
            ),
            if (package.price != null)
              Text(
                '\u20B9${package.price!.toStringAsFixed(2)}',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: colors.red,
                ),
              ),
            const SizedBox(width: 8),
            Icon(
              isSelected ? LucideIcons.checkCircle2 : LucideIcons.circle,
              size: 22,
              color: isSelected ? colors.red : colors.ink20,
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Helper widgets
// ═══════════════════════════════════════════════════════════════════════════════

class _LoadingIndicator extends StatelessWidget {
  final AppColors colors;
  const _LoadingIndicator({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            CircularProgressIndicator(color: colors.red),
            const SizedBox(height: 16),
            Text(
              'Loading packages...',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 14,
                color: colors.ink40,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String error;
  final AppColors colors;
  final VoidCallback onRetry;

  const _ErrorCard({
    required this.error,
    required this.colors,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.redSoft,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(LucideIcons.alertCircle, color: colors.red, size: 32),
          const SizedBox(height: 12),
          Text(
            error,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 14,
              color: colors.red,
            ),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: onRetry,
            icon: Icon(LucideIcons.refreshCw, size: 16, color: colors.red),
            label: Text(
              'Retry',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontWeight: FontWeight.w600,
                color: colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final AppColors colors;
  const _EmptyState({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(LucideIcons.package2, color: colors.ink20, size: 48),
            const SizedBox(height: 12),
            Text(
              'No packages available',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 14,
                color: colors.ink40,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
