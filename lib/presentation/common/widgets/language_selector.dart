import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../application/providers/locale_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';

/// Data class for language options.
class _LanguageOption {
  final String code;
  final String nativeName;
  final String englishName;
  final Locale locale;

  const _LanguageOption({
    required this.code,
    required this.nativeName,
    required this.englishName,
    required this.locale,
  });
}

const _languages = [
  _LanguageOption(
    code: 'en',
    nativeName: 'English',
    englishName: 'English',
    locale: Locale('en'),
  ),
  _LanguageOption(
    code: 'te',
    nativeName: 'తెలుగు',
    englishName: 'Telugu',
    locale: Locale('te'),
  ),
  _LanguageOption(
    code: 'hi',
    nativeName: 'हिन्दी',
    englishName: 'Hindi',
    locale: Locale('hi'),
  ),
];

/// Shows a bottom sheet with language options.
/// Call this from anywhere to let the user pick a language.
void showLanguageSelector(BuildContext context, WidgetRef ref) {
  final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;

  showModalBottomSheet(
    context: context,
    backgroundColor: colors.card,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) {
      return _LanguageSelectorSheet(colors: colors);
    },
  );
}

class _LanguageSelectorSheet extends ConsumerWidget {
  final AppColors colors;

  const _LanguageSelectorSheet({required this.colors});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colors.ink20,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              'Select Language',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: colors.ink,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Choose your preferred language',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: colors.ink40,
              ),
            ),
            const SizedBox(height: 20),

            // Language options
            ...List.generate(_languages.length, (index) {
              final lang = _languages[index];
              final isSelected =
                  currentLocale.languageCode == lang.locale.languageCode;

              return Padding(
                padding: EdgeInsets.only(
                  bottom: index < _languages.length - 1 ? 8 : 0,
                ),
                child: InkWell(
                  onTap: () {
                    ref.read(localeProvider.notifier).setLocale(lang.locale);
                    Navigator.pop(context);
                  },
                  borderRadius: BorderRadius.circular(AppRadius.card),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? colors.redSoft : colors.bg,
                      borderRadius: BorderRadius.circular(AppRadius.card),
                      border: Border.all(
                        color: isSelected ? colors.red : colors.ink10,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        // Language icon/flag placeholder
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? colors.red.withValues(alpha: 0.1)
                                : colors.ink05,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            lang.code.toUpperCase(),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: isSelected ? colors.red : colors.ink40,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),

                        // Language names
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                lang.nativeName,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected ? colors.red : colors.ink,
                                ),
                              ),
                              if (lang.nativeName != lang.englishName) ...[
                                const SizedBox(height: 2),
                                Text(
                                  lang.englishName,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: colors.ink40,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),

                        // Check mark
                        if (isSelected)
                          Icon(
                            Icons.check_circle_rounded,
                            color: colors.red,
                            size: 22,
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
