import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/network_info.dart';
import '../../../core/theme/app_colors.dart';

/// A persistent banner that appears at the top of the screen when the device
/// is offline. It auto-hides when connectivity is restored.
///
/// Wrap your [MaterialApp.builder] content with this widget:
/// ```dart
/// builder: (context, child) => OfflineBanner(child: child!),
/// ```
class OfflineBanner extends ConsumerWidget {
  final Widget child;

  const OfflineBanner({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectivityAsync = ref.watch(connectivityStreamProvider);
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.light;

    return Column(
      children: [
        // Show banner only when explicitly offline.
        connectivityAsync.when(
          data: (isConnected) {
            if (isConnected) return const SizedBox.shrink();
            return Material(
              color: colors.amber,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.wifi_off_rounded,
                        size: 16,
                        color: colors.ink,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'No internet connection',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: colors.ink,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        ),
        Expanded(child: child),
      ],
    );
  }
}
