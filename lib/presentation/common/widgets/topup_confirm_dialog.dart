import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Confirmation shown before the LCO top-up screen opens.
///
/// Native parity: tapping the "LCO Topup" drawer entry does not open the
/// top-up form directly — it raises a non-cancelable AlertDialog and only
/// swaps in LcoTopupFragment when the user taps "Yes"
/// (MainActivity.java:485-515). Strings are the native ones verbatim.
///
/// Returns true when the user confirmed.
Future<bool> showTopUpConfirmDialog(BuildContext context) async {
  final confirmed = await showDialog<bool>(
    context: context,
    // Native setCancelable(false): neither a scrim tap nor Back dismisses it.
    barrierDismissible: false,
    builder: (ctx) {
      final c = Theme.of(ctx).extension<AppColors>()!;
      return PopScope(
        canPop: false,
        child: AlertDialog(
          title: const Text('Are you sure ,you want to topup ?'),
          content: const Text("Click 'Yes' to proceed!"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              style: TextButton.styleFrom(foregroundColor: c.red),
              child: const Text('Yes'),
            ),
          ],
        ),
      );
    },
  );
  return confirmed ?? false;
}
