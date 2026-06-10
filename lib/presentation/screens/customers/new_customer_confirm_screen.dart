import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../application/providers/master_data_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/package/cas_package.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// Step 4: Confirmation & Save
// ═══════════════════════════════════════════════════════════════════════════════

class NewCustomerConfirmScreen extends ConsumerWidget {
  final String stbNumber;
  final String vcNumber;
  final String firstName;
  final String lastName;
  final String fatherName;
  final String mobile;
  final String email;
  final DateTime? dob;
  final String idNumber;
  final String businessName;
  final String accountNumber;
  final String address1;
  final String address2;
  final String pinCode;
  final String instAddress1;
  final String instAddress2;
  final String instPinCode;
  final int billType;
  final String cafNumber;
  final String lcoCustomerId;
  final String remarks;
  final CasPackage? selectedPackage;
  final int cycle;
  final int quantity;
  final int validityDays;
  final bool isSaving;
  final VoidCallback onConfirm;
  final VoidCallback onBack;

  const NewCustomerConfirmScreen({
    super.key,
    required this.stbNumber,
    required this.vcNumber,
    required this.firstName,
    required this.lastName,
    required this.fatherName,
    required this.mobile,
    required this.email,
    required this.dob,
    required this.idNumber,
    required this.businessName,
    required this.accountNumber,
    required this.address1,
    required this.address2,
    required this.pinCode,
    required this.instAddress1,
    required this.instAddress2,
    required this.instPinCode,
    required this.billType,
    required this.cafNumber,
    required this.lcoCustomerId,
    required this.remarks,
    required this.selectedPackage,
    required this.cycle,
    required this.quantity,
    required this.validityDays,
    required this.isSaving,
    required this.onConfirm,
    required this.onBack,
  });

  String get _cycleName {
    switch (cycle) {
      case 1:
        return 'Month';
      case 2:
        return 'Year';
      case 3:
        return 'Day';
      default:
        return 'Month';
    }
  }

  String? get _dobFormatted {
    if (dob == null) return null;
    return '${dob!.day.toString().padLeft(2, '0')}/${dob!.month.toString().padLeft(2, '0')}/${dob!.year}';
  }

  double get _estimatedAmount {
    if (selectedPackage == null) return 0;
    final unit = selectedPackage!.price ?? 0;
    if (cycle == 2) return unit * 12 * quantity;
    if (cycle == 3) return (unit / 30.0) * validityDays * quantity;
    return unit * quantity;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final md = ref.watch(masterDataProvider);

    return Stack(
      children: [
        Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colors.blueSoft,
                        borderRadius: BorderRadius.circular(12),
                        border:
                            Border.all(color: colors.blue.withAlpha(60)),
                      ),
                      child: Row(
                        children: [
                          Icon(LucideIcons.clipboardCheck,
                              size: 24, color: colors.blue),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Review & Confirm',
                                  style: TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: colors.ink,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Please verify all details before creating the customer.',
                                  style: TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontSize: 13,
                                    color: colors.ink60,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── STB Details ──────────────────────────────────
                    _ConfirmSection(
                      title: 'STB Details',
                      icon: LucideIcons.monitor,
                      colors: colors,
                      rows: [
                        _ConfirmRow('Serial Number', stbNumber),
                        _ConfirmRow('VC Number', vcNumber),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // ── Personal Details ─────────────────────────────
                    _ConfirmSection(
                      title: 'Personal Details',
                      icon: LucideIcons.user,
                      colors: colors,
                      rows: [
                        _ConfirmRow('First Name', firstName),
                        if (lastName.isNotEmpty)
                          _ConfirmRow('Last Name', lastName),
                        if (fatherName.isNotEmpty)
                          _ConfirmRow("Father's Name", fatherName),
                        if (md.selectedGender != null)
                          _ConfirmRow('Gender', md.selectedGender!.name),
                        if (_dobFormatted != null)
                          _ConfirmRow('Date of Birth', _dobFormatted!),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // ── Contact ──────────────────────────────────────
                    _ConfirmSection(
                      title: 'Contact',
                      icon: LucideIcons.phone,
                      colors: colors,
                      rows: [
                        _ConfirmRow('Mobile', mobile),
                        if (email.isNotEmpty) _ConfirmRow('Email', email),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // ── Identity ─────────────────────────────────────
                    _ConfirmSection(
                      title: 'Identity',
                      icon: LucideIcons.fingerprint,
                      colors: colors,
                      rows: [
                        if (md.selectedCustomerType != null)
                          _ConfirmRow('Customer Type',
                              md.selectedCustomerType!.customerType),
                        if (md.selectedIdType != null)
                          _ConfirmRow('ID Type', md.selectedIdType!.name),
                        if (idNumber.isNotEmpty)
                          _ConfirmRow('ID Number', idNumber),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // ── Business ─────────────────────────────────────
                    if (businessName.isNotEmpty ||
                        accountNumber.isNotEmpty) ...[
                      _ConfirmSection(
                        title: 'Business',
                        icon: LucideIcons.building2,
                        colors: colors,
                        rows: [
                          if (businessName.isNotEmpty)
                            _ConfirmRow('Business Name', businessName),
                          if (accountNumber.isNotEmpty)
                            _ConfirmRow('Account Number', accountNumber),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],

                    // ── Billing Address ──────────────────────────────
                    _ConfirmSection(
                      title: 'Billing Address',
                      icon: LucideIcons.mapPin,
                      colors: colors,
                      rows: [
                        _ConfirmRow('Address', address1),
                        if (address2.isNotEmpty)
                          _ConfirmRow('Address 2', address2),
                        if (pinCode.isNotEmpty)
                          _ConfirmRow('PIN Code', pinCode),
                        if (md.selectedCountry != null)
                          _ConfirmRow('Country', md.selectedCountry!.name),
                        if (md.selectedState != null)
                          _ConfirmRow('State', md.selectedState!.name),
                        if (md.selectedDistrict != null)
                          _ConfirmRow('District', md.selectedDistrict!.name),
                        if (md.selectedMandal != null)
                          _ConfirmRow(
                              'Mandal', md.selectedMandal!.mandalName),
                        if (md.selectedCity != null)
                          _ConfirmRow(
                              'City', md.selectedCity!.locationName),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // ── Installation Address ─────────────────────────
                    _ConfirmSection(
                      title: 'Installation Address',
                      icon: LucideIcons.home,
                      colors: colors,
                      rows: [
                        _ConfirmRow('Address', instAddress1),
                        if (instAddress2.isNotEmpty)
                          _ConfirmRow('Address 2', instAddress2),
                        if (instPinCode.isNotEmpty)
                          _ConfirmRow('PIN Code', instPinCode),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // ── Other ────────────────────────────────────────
                    _ConfirmSection(
                      title: 'Other Details',
                      icon: LucideIcons.settings,
                      colors: colors,
                      rows: [
                        if (md.selectedGroup != null)
                          _ConfirmRow(
                              'Group', md.selectedGroup!.groupName),
                        _ConfirmRow('Bill Type',
                            billType == 1 ? 'Advance Billing' : 'Postpaid'),
                        if (cafNumber.isNotEmpty)
                          _ConfirmRow('CAF Number', cafNumber),
                        if (lcoCustomerId.isNotEmpty)
                          _ConfirmRow('LCO Customer ID', lcoCustomerId),
                        if (remarks.isNotEmpty)
                          _ConfirmRow('Remarks', remarks),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // ── Package ──────────────────────────────────────
                    if (selectedPackage != null)
                      _ConfirmSection(
                        title: 'Package',
                        icon: LucideIcons.package2,
                        colors: colors,
                        rows: [
                          _ConfirmRow(
                              'Package', selectedPackage!.productName),
                          _ConfirmRow('Package ID', selectedPackage!.productId),
                          _ConfirmRow('Cycle', _cycleName),
                          _ConfirmRow('Quantity', quantity.toString()),
                          if (cycle == 3)
                            _ConfirmRow(
                                'Validity', '$validityDays days'),
                          if (selectedPackage!.price != null)
                            _ConfirmRow('Price',
                                '\u20B9${selectedPackage!.price!.toStringAsFixed(2)}'),
                        _ConfirmRow('Estimated Amount', '\u20B9${_estimatedAmount.toStringAsFixed(2)}'),
                        ],
                      ),

                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),

            // ── Bottom action bar ────────────────────────────────────
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
                      onPressed: isSaving ? null : onBack,
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
                      onPressed: isSaving ? null : onConfirm,
                      icon: isSaving
                          ? SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                color: colors.card,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(LucideIcons.userPlus, size: 18),
                      label: Text(
                        isSaving ? 'Creating...' : 'Create Customer',
                        style: const TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.red,
                        foregroundColor: colors.card,
                        disabledBackgroundColor: colors.red.withAlpha(128),
                        disabledForegroundColor: colors.card.withAlpha(200),
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
        ),

        // ── Loading overlay ────────────────────────────────────────────
        if (isSaving)
          Positioned.fill(
            child: Container(
              color: Colors.black26,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: colors.card,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(25),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: colors.red),
                      const SizedBox(height: 16),
                      Text(
                        'Creating customer...',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: colors.ink,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Please wait',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 13,
                          color: colors.ink40,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Confirm Section
// ═══════════════════════════════════════════════════════════════════════════════

class _ConfirmRow {
  final String label;
  final String value;
  const _ConfirmRow(this.label, this.value);
}

class _ConfirmSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final AppColors colors;
  final List<_ConfirmRow> rows;

  const _ConfirmSection({
    required this.title,
    required this.icon,
    required this.colors,
    required this.rows,
  });

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.ink10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: colors.ink05,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Icon(icon, size: 16, color: colors.ink60),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: colors.ink80,
                  ),
                ),
              ],
            ),
          ),
          // Rows
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: rows.map((row) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 120,
                        child: Text(
                          row.label,
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 13,
                            color: colors.ink40,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          row.value,
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: colors.ink,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
