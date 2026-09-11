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
            backgroundColor: colors.red,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [colors.red, colors.redDark],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        child: Text(
                          _getInitials(
                              authLocal.firstName, authLocal.lastName),
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
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
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
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
                            color: Colors.white.withValues(alpha: 0.7),
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

                // ── Developer Tools section ─────────────────────────────
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
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: colors.card,
        title: Text(
          l.logout,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: colors.ink,
          ),
        ),
        content: Text(
          l.logoutConfirm,
          style: TextStyle(fontSize: 14, color: colors.ink60),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              l.cancel,
              style: TextStyle(color: colors.ink40),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(authProvider.notifier).logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(l.logout),
          ),
        ],
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
