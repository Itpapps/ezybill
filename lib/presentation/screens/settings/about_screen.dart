import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const String _companyName = 'ITP World Technologies';
  static const String _companyEmail = 'support@itpworld.com';
  static const String _companyWebsite = 'https://www.itpworld.com';
  static const String _playStoreUrl =
      'https://play.google.com/store/apps/details?id=com.itp.ezybill.androidapp';

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        title: const Text('About'),
        backgroundColor: colors.card,
        foregroundColor: colors.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // ── App logo & name card ──────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
              decoration: BoxDecoration(
                color: colors.card,
                borderRadius: BorderRadius.circular(AppRadius.card),
                boxShadow: AppShadow.card,
              ),
              child: Column(
                children: [
                  // Logo circle
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [colors.red, colors.redDark],
                      ),
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: colors.red.withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'EB',
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    AppConstants.appName,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: colors.ink,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: colors.redSoft,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: Text(
                      'Version ${AppConstants.appVersion}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: colors.red,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Cable TV Billing Management System',
                    style: TextStyle(
                      fontSize: 13,
                      color: colors.ink40,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Company info card ─────────────────────────────────────────
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: colors.card,
                borderRadius: BorderRadius.circular(AppRadius.card),
                boxShadow: AppShadow.card,
              ),
              child: Column(
                children: [
                  _InfoTile(
                    colors: colors,
                    icon: LucideIcons.building2,
                    title: 'Developed by',
                    value: _companyName,
                  ),
                  Divider(height: 1, indent: 64, color: colors.ink05),
                  _InfoTile(
                    colors: colors,
                    icon: LucideIcons.mail,
                    title: 'Contact',
                    value: _companyEmail,
                    onTap: () => _launchUrl('mailto:$_companyEmail'),
                  ),
                  Divider(height: 1, indent: 64, color: colors.ink05),
                  _InfoTile(
                    colors: colors,
                    icon: LucideIcons.globe,
                    title: 'Website',
                    value: _companyWebsite,
                    onTap: () => _launchUrl(_companyWebsite),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Rate this app card ────────────────────────────────────────
            InkWell(
              onTap: () => _launchUrl(_playStoreUrl),
              borderRadius: BorderRadius.circular(AppRadius.card),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colors.card,
                  borderRadius: BorderRadius.circular(AppRadius.card),
                  boxShadow: AppShadow.card,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: colors.amberSoft,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child:
                          Icon(LucideIcons.star, size: 16, color: colors.amber),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Rate this app',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: colors.ink,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Love EzyBill? Rate us on the Play Store!',
                            style: TextStyle(
                              fontSize: 12,
                              color: colors.ink40,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(LucideIcons.externalLink,
                        size: 16, color: colors.ink20),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // ── Copyright ─────────────────────────────────────────────────
            Text(
              '\u00A9 ${DateTime.now().year} $_companyName.\nAll rights reserved.',
              style: TextStyle(
                fontSize: 12,
                color: colors.ink20,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Info Tile
// ─────────────────────────────────────────────────────────────────────────────

class _InfoTile extends StatelessWidget {
  final AppColors colors;
  final IconData icon;
  final String title;
  final String value;
  final VoidCallback? onTap;

  const _InfoTile({
    required this.colors,
    required this.icon,
    required this.title,
    required this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: colors.redSoft,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 16, color: colors.red),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      color: colors.ink40,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: colors.ink,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(LucideIcons.externalLink, size: 14, color: colors.ink20),
          ],
        ),
      ),
    );
  }
}
