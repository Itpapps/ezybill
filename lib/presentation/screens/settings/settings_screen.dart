import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../application/providers/auth_provider.dart';
import '../../../application/providers/core_providers.dart';
import '../../../application/providers/locale_provider.dart';
import '../../../application/providers/theme_provider.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/bluetooth_print_service.dart';
import '../../../core/services/debug_log_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../common/widgets/language_selector.dart';
import '../../common/widgets/logout_confirm_dialog.dart';
import '../../router/route_names.dart';
import '../bluetooth/paired_device_list_screen.dart';
import '../../../l10n/app_localizations.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final authLocal = ref.watch(authLocalDatasourceProvider);
    final themeMode = ref.watch(themeProvider);
    final currentLocale = ref.watch(localeProvider);
    final debugLog = ref.watch(debugLogProvider);
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final bottomInset = MediaQuery.of(context).padding.bottom;
    // Keep bottom actions visible above persistent bottom bars / overlays.
    final bottomSafeSpace = bottomInset + 92;

    return Scaffold(
      backgroundColor: colors.bg,
      body: CustomScrollView(
        slivers: [
          // ── Profile header ────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            // The page's own colour, so the header (expanded or collapsed)
            // reads as part of the page in both themes. The AppBar picks
            // dark or light status-bar icons from this colour by itself.
            backgroundColor: colors.bg,
            flexibleSpace: FlexibleSpaceBar(
              background: _SoftHeaderBackdrop(
                colors: colors,
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      _SoftAvatar(
                        initials: _getInitials(
                            authLocal.firstName, authLocal.lastName),
                        colors: colors,
                      ),
                      const SizedBox(height: 12),
                      // Centred and kept to one line. Without textAlign a name
                      // long enough to wrap rendered its lines start-aligned,
                      // which read as left-aligned against the centred avatar;
                      // the extra line also pushed this Column past the
                      // SliverAppBar's 200px expandedHeight.
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          authLocal.employeeName,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: colors.ink,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          'LCO: ${authLocal.lcoCode}  |  ${authLocal.userType}',
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: colors.ink60,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            title: Text(
              l.settings,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),

          SliverPadding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomSafeSpace),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // ── Account section ─────────────────────────────────────
                _SectionHeader(title: 'Account', colors: colors),
                _SettingsCard(
                  colors: colors,
                  children: [
                    _SettingsTile(
                      colors: colors,
                      icon: LucideIcons.user,
                      title: 'Full Name',
                      subtitle: authLocal.employeeName,
                    ),
                    _SettingsTile(
                      colors: colors,
                      icon: LucideIcons.mail,
                      title: 'Email',
                      subtitle: authLocal.email.isNotEmpty
                          ? authLocal.email
                          : 'Not set',
                    ),
                    _SettingsTile(
                      colors: colors,
                      icon: LucideIcons.phone,
                      title: 'Phone',
                      subtitle: authLocal.phone.isNotEmpty
                          ? authLocal.phone
                          : 'Not set',
                    ),
                    _SettingsTile(
                      colors: colors,
                      icon: LucideIcons.building2,
                      title: 'Business Name',
                      subtitle: authLocal.businessName.isNotEmpty
                          ? authLocal.businessName
                          : 'Not set',
                    ),
                    _SettingsTile(
                      colors: colors,
                      icon: LucideIcons.lock,
                      title: l.changePassword,
                      onTap: () =>
                          context.push(RouteNames.changePassword),
                      showDivider: false,
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // ── Preferences section ─────────────────────────────────
                _SectionHeader(title: 'Preferences', colors: colors),
                _SettingsCard(
                  colors: colors,
                  children: [
                    _SettingsTile(
                      colors: colors,
                      icon: LucideIcons.sun,
                      title: l.theme,
                      subtitle: _themeModeLabel(themeMode, l),
                      trailing: _ThemeToggle(
                        colors: colors,
                        currentMode: themeMode,
                        onChanged: (mode) {
                          ref.read(themeProvider.notifier).setThemeMode(mode);
                        },
                      ),
                    ),
                    _SettingsTile(
                      colors: colors,
                      icon: LucideIcons.globe,
                      title: l.language,
                      subtitle: _localeLabel(currentLocale),
                      showDivider: false,
                      onTap: () => showLanguageSelector(context, ref),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // ── Hardware section ────────────────────────────────────
                _SectionHeader(title: 'Hardware', colors: colors),
                _SettingsCard(
                  colors: colors,
                  children: [
                    Consumer(
                      builder: (ctx, watchRef, _) {
                        final btState =
                            watchRef.watch(bluetoothPrintProvider);
                        final subtitle = btState.isConnected
                            ? btState.connectedDevice?.name ?? 'Connected'
                            : l.notConnected;
                        return _SettingsTile(
                          colors: colors,
                          icon: LucideIcons.printer,
                          title: l.bluetoothPrinter,
                          subtitle: subtitle,
                          showDivider: false,
                          trailing: btState.isConnected
                              ? Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: colors.green,
                                    shape: BoxShape.circle,
                                  ),
                                )
                              : null,
                          onTap: () {
                              // Use rootNavigator: true to push above the
                              // StatefulShellRoute — GoRouter's pushNamed for
                              // parentNavigatorKey routes can show a black
                              // frame when called from within a shell branch.
                              Navigator.of(context, rootNavigator: true).push(
                                MaterialPageRoute<void>(
                                  builder: (_) =>
                                      const PairedDeviceListScreen(),
                                ),
                              );
                            },
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // ── Developer Tools section (debug/profile builds only) ──
                // Absent from release. The Debug Console holds pre-encryption
                // request bodies (including login credentials) and decrypted
                // responses (including tokens), so it must not ship.
                if (kDevToolsEnabled) ...[
                  _SectionHeader(title: l.developerTools, colors: colors),
                  _SettingsCard(
                    colors: colors,
                    children: [
                      _SettingsTile(
                        colors: colors,
                        icon: LucideIcons.terminal,
                        title: l.debugConsole,
                        subtitle: '${debugLog.entries.length} entries',
                        onTap: () =>
                            context.push(RouteNames.debugConsole),
                      ),
                      _SettingsTile(
                        colors: colors,
                        icon: LucideIcons.server,
                        title: l.apiBaseUrl,
                        subtitle: ApiConstants.baseUrl,
                        onTap: () => _showServerUrlDialog(context, ref, colors),
                      ),
                      _SettingsTile(
                        colors: colors,
                        icon: LucideIcons.bug,
                        title: l.enableDebugLogging,
                        subtitle: ref.watch(debugEnabledProvider) ? l.debugOn : l.debugOff,
                        trailing: Switch(
                          value: ref.watch(debugEnabledProvider),
                          activeThumbColor: colors.green,
                          inactiveTrackColor: colors.ink10,
                          onChanged: (value) {
                            debugLog.enabled = value;
                            ref.invalidate(debugEnabledProvider);
                            ref
                                .read(sharedPreferencesProvider)
                                .setBool('debug_logging_enabled', value);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    Icon(
                                      value ? LucideIcons.bug : LucideIcons.shieldOff,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      value
                                          ? l.debugEnabled
                                          : l.debugDisabled,
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                  ],
                                ),
                                backgroundColor: value ? colors.green : colors.ink60,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                        ),
                        showDivider: false,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],

                // ── App section ─────────────────────────────────────────
                _SectionHeader(title: 'App', colors: colors),
                _SettingsCard(
                  colors: colors,
                  children: [
                    _SettingsTile(
                      colors: colors,
                      icon: LucideIcons.info,
                      title: l.about,
                      onTap: () => context.push(RouteNames.about),
                    ),
                    _SettingsTile(
                      colors: colors,
                      icon: LucideIcons.shieldCheck,
                      title: l.privacyPolicy,
                      onTap: () => context.push(RouteNames.privacyPolicy),
                    ),
                    _SettingsTile(
                      colors: colors,
                      icon: LucideIcons.tag,
                      title: 'App Version',
                      subtitle: AppConstants.appVersion,
                      showDivider: false,
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // ── Danger zone ─────────────────────────────────────────
                _SectionHeader(title: 'Danger Zone', colors: colors),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () => _showLogoutDialog(context, ref, colors),
                    icon: const Icon(LucideIcons.logOut, size: 18),
                    label: Text(
                      l.logout,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  String _getInitials(String first, String last) {
    final f = first.isNotEmpty ? first[0].toUpperCase() : '';
    final l = last.isNotEmpty ? last[0].toUpperCase() : '';
    return '$f$l';
  }

  String _localeLabel(Locale locale) {
    switch (locale.languageCode) {
      case 'te':
        return 'తెలుగు (Telugu)';
      case 'hi':
        return 'हिन्दी (Hindi)';
      default:
        return 'English';
    }
  }

  String _themeModeLabel(ThemeMode mode, AppLocalizations l) {
    switch (mode) {
      case ThemeMode.light:
        return l.light;
      case ThemeMode.dark:
        return l.dark;
      case ThemeMode.system:
        return l.system;
    }
  }

  void _showLogoutDialog(
      BuildContext context, WidgetRef ref, AppColors colors) {
    final l = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => LogoutConfirmDialog(
        title: l.logout,
        message: l.logoutConfirm,
        cancelLabel: l.cancel,
        confirmLabel: l.logout,
        onCancel: () => Navigator.pop(ctx),
        onConfirm: () {
          Navigator.pop(ctx);
          ref.read(authProvider.notifier).logout();
        },
      ),
    );
  }

  void _showServerUrlDialog(
      BuildContext context, WidgetRef ref, AppColors colors) {
    final l = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: ApiConstants.baseUrl);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: colors.card,
        title: Text(
          l.apiBaseUrl,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: colors.ink,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Configure the base URL for API requests. '
              'Changes apply immediately.',
              style: TextStyle(fontSize: 13, color: colors.ink60),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
                color: colors.ink,
              ),
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'http://192.168.1.143/...',
                hintStyle: TextStyle(color: colors.ink20, fontSize: 12),
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
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                onTap: () {
                  controller.text = ApiConstants.defaultBaseUrl;
                },
                child: Text(
                  l.resetToDefault,
                  style: TextStyle(
                    fontSize: 12,
                    color: colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l.cancel, style: TextStyle(color: colors.ink40)),
          ),
          ElevatedButton(
            onPressed: () {
              final url = controller.text.trim();
              if (url.isNotEmpty) {
                ApiConstants.setBaseUrl(url);
                ref
                    .read(sharedPreferencesProvider)
                    .setString('api_base_url', url);
              }
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('API Base URL updated.'),
                  backgroundColor: colors.green,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(l.save),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Theme Toggle Widget
// ─────────────────────────────────────────────────────────────────────────────

class _ThemeToggle extends StatelessWidget {
  final AppColors colors;
  final ThemeMode currentMode;
  final ValueChanged<ThemeMode> onChanged;

  const _ThemeToggle({
    required this.colors,
    required this.currentMode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: colors.ink05,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _chip(LucideIcons.sun, ThemeMode.light),
          _chip(LucideIcons.moon, ThemeMode.dark),
          _chip(LucideIcons.monitor, ThemeMode.system),
        ],
      ),
    );
  }

  Widget _chip(IconData icon, ThemeMode mode) {
    final isSelected = currentMode == mode;
    return GestureDetector(
      onTap: () => onChanged(mode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? colors.red : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(
          icon,
          size: 16,
          color: isSelected ? Colors.white : colors.ink40,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section Header
// ─────────────────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final AppColors colors;

  const _SectionHeader({required this.title, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: colors.ink40,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Settings Card
// ─────────────────────────────────────────────────────────────────────────────

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  final AppColors colors;

  const _SettingsCard({required this.children, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: AppShadow.card,
      ),
      child: Column(children: children),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Settings Tile
// ─────────────────────────────────────────────────────────────────────────────

class _SettingsTile extends StatelessWidget {
  final AppColors colors;
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showDivider;

  const _SettingsTile({
    required this.colors,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.card),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: colors.ink,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          style: TextStyle(
                            fontSize: 12,
                            color: colors.ink40,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                ?trailing,
                if (onTap != null && trailing == null)
                  Icon(
                    LucideIcons.chevronRight,
                    size: 16,
                    color: colors.ink20,
                  ),
              ],
            ),
          ),
        ),
        if (showDivider)
          Divider(height: 1, indent: 64, color: colors.ink05),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Soft profile header (the login screen's soft look, in the app's own colours)
// ─────────────────────────────────────────────────────────────────────────────

/// The page colour with a faint red glow and a small dot cluster in the
/// top-right corner, echoing the login screen. Static: behind its
/// RepaintBoundary it is painted once and only redraws when the theme flips.
class _SoftHeaderBackdrop extends StatelessWidget {
  const _SoftHeaderBackdrop({required this.colors, required this.child});

  final AppColors colors;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        RepaintBoundary(
          child: CustomPaint(
            painter: _HeaderBackdropPainter(
              bg: colors.bg,
              red: colors.red,
              isDark: Theme.of(context).brightness == Brightness.dark,
            ),
          ),
        ),
        child,
      ],
    );
  }
}

class _HeaderBackdropPainter extends CustomPainter {
  const _HeaderBackdropPainter({
    required this.bg,
    required this.red,
    required this.isDark,
  });

  final Color bg;
  final Color red;
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    canvas.drawRect(Offset.zero & size, Paint()..color = bg);

    // Faint red glow from the top-right corner.
    final glowCenter = Offset(size.width, 0);
    final glowRadius = math.max(size.width, size.height) * 0.8;
    canvas.drawCircle(
      glowCenter,
      glowRadius,
      Paint()
        ..shader = RadialGradient(
          colors: [
            red.withValues(alpha: isDark ? 0.14 : 0.08),
            red.withValues(alpha: 0.0),
          ],
        ).createShader(
            Rect.fromCircle(center: glowCenter, radius: glowRadius)),
    );

    // Dot cluster, densest in the top-right corner and fading out from it.
    final unit = math.min(size.width, 460.0);
    final step = unit * 0.03;
    final maxRadius = unit * 0.0055;
    final cluster =
        Rect.fromLTRB(size.width * 0.72, 0, size.width, size.height * 0.75);
    final dot = Paint()..isAntiAlias = true;
    for (double y = cluster.top + step / 2; y <= cluster.bottom; y += step) {
      for (double x = cluster.right - step / 2; x >= cluster.left; x -= step) {
        final t = 1.0 -
            Offset(
              (cluster.right - x) / cluster.width,
              (y - cluster.top) / cluster.height,
            ).distance;
        if (t <= 0.05) continue;
        dot.color = red.withValues(alpha: (isDark ? 0.22 : 0.16) * t);
        canvas.drawCircle(Offset(x, y), maxRadius * (0.35 + 0.65 * t), dot);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _HeaderBackdropPainter oldDelegate) =>
      bg != oldDelegate.bg ||
      red != oldDelegate.red ||
      isDark != oldDelegate.isDark;
}

/// Red initials disc inside a raised soft ring, like the login logo. 80x80
/// overall — the old CircleAvatar's size — so the header's layout and its
/// fit inside the 200px expandedHeight are unchanged.
class _SoftAvatar extends StatelessWidget {
  const _SoftAvatar({required this.initials, required this.colors});

  final String initials;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 80,
      height: 80,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [Color(0xFF232A3B), Color(0xFF161B27)]
              : const [Color(0xFFFFFFFF), Color(0xFFEDF0F5)],
        ),
        // Light from the top-left, then the shadow bottom-right.
        boxShadow: isDark
            ? [
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.05),
                  offset: const Offset(-5, -5),
                  blurRadius: 12,
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.55),
                  offset: const Offset(6, 8),
                  blurRadius: 16,
                ),
              ]
            : const [
                BoxShadow(
                  color: Colors.white,
                  offset: Offset(-6, -6),
                  blurRadius: 14,
                ),
                BoxShadow(
                  color: Color(0x80A3B1C6), // rgba(163, 177, 198, 0.50)
                  offset: Offset(6, 8),
                  blurRadius: 16,
                ),
              ],
      ),
      child: Container(
        width: 68,
        height: 68,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [const Color(0xFFEF5350), colors.red, colors.redDark],
          ),
          boxShadow: [
            BoxShadow(
              color: colors.red.withValues(alpha: 0.30),
              offset: const Offset(0, 5),
              blurRadius: 12,
            ),
          ],
        ),
        child: Text(
          initials,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
        ),
      ),
    );
  }
}
