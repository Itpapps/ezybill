import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../router/route_names.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Gateway contract — mirrors the native Android app exactly
// (Payment_Webview_Frag.java + assets/configg.properties).
// ─────────────────────────────────────────────────────────────────────────────

/// Gateway page the native app POSTs to (`payweb` in configg.properties:54,
/// used at Payment_Webview_Frag.java:57/100).
const String _kGatewayViewPath = '/mobile_paymentsview';

/// URL the gateway redirects to once the payment finishes. The native app
/// treats this exact URL as the completion signal
/// (Payment_Webview_Frag.java:159, `url.equals(...)`).
const String _kGatewayReturnPath = '/mobile_paymentsend';

/// Static key the gateway page expects. The native app hardcodes it
/// (Payment_Webview_Frag.java:76) and never sends the session token here.
const String _kGatewayAuthKey = 'abcd1234abcd';

// ─────────────────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────────────────

class PaymentWebviewScreen extends StatefulWidget {
  final String customerId;
  final String amount;
  final String authKey;
  final String employeeId;
  final String dealerId;

  const PaymentWebviewScreen({
    super.key,
    required this.customerId,
    required this.amount,
    required this.authKey,
    required this.employeeId,
    required this.dealerId,
  });

  @override
  State<PaymentWebviewScreen> createState() => _PaymentWebviewScreenState();
}

class _PaymentWebviewScreenState extends State<PaymentWebviewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _transactionInProgress = true;
  double _loadingProgress = 0;

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  void _initWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (progress) {
            setState(() {
              _loadingProgress = progress / 100;
            });
          },
          onPageStarted: (_) {
            setState(() => _isLoading = true);
          },
          onPageFinished: (url) {
            setState(() => _isLoading = false);
            _checkForCompletion(url);
          },
          onNavigationRequest: (request) {
            return _handleNavigation(request);
          },
          onWebResourceError: (error) {
            debugPrint('WebView error: ${error.description}');
          },
        ),
      );

    // Load the PG URL with POST data
    _loadPaymentPage();
  }

  void _loadPaymentPage() {
    final pgUrl = '${ApiConstants.paymentGatewayBase}$_kGatewayViewPath';

    // Load using POST via an auto-submitting HTML form
    final html = '''
<!DOCTYPE html>
<html>
<body onload="document.getElementById('pgForm').submit();">
  <form id="pgForm" method="POST" action="$pgUrl">
    <input type="hidden" name="auth_key" value="$_kGatewayAuthKey" />
    <input type="hidden" name="employee_id" value="${_escapeHtml(widget.employeeId)}" />
    <input type="hidden" name="dealer_id" value="${_escapeHtml(widget.dealerId)}" />
    <input type="hidden" name="customer_id" value="${_escapeHtml(_gatewayCustomerId)}" />
    <input type="hidden" name="amount" value="${_escapeHtml(widget.amount)}" />
    <input type="hidden" name="from_mobile_app" value="0" />
  </form>
  <p style="text-align:center;margin-top:40px;font-family:sans-serif;color:#666;">
    Redirecting to payment gateway...
  </p>
</body>
</html>
''';

    _controller.loadHtmlString(html);
  }

  /// The native app always posts `customer_id=0` from the LCO top-up path
  /// (Payment_Webview_Frag.java:87-88); the top-up screen passes an empty
  /// string, so fall back to "0" and keep any real customer id intact.
  String get _gatewayCustomerId =>
      widget.customerId.isEmpty ? '0' : widget.customerId;

  String _escapeHtml(String text) {
    return text
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#39;');
  }

  NavigationDecision _handleNavigation(NavigationRequest request) {
    final url = request.url;

    // Intercept UPI intent URLs and launch them natively
    if (url.startsWith('upi://') ||
        url.startsWith('intent://') ||
        url.startsWith('tez://') ||
        url.startsWith('phonepe://') ||
        url.startsWith('paytmmp://') ||
        url.startsWith('gpay://')) {
      _launchUpiIntent(url);
      return NavigationDecision.prevent;
    }

    // Detect the gateway's completion redirect
    if (_isCompletionUrl(url)) {
      _onPaymentComplete();
      return NavigationDecision.prevent;
    }

    return NavigationDecision.navigate;
  }

  /// True only for the gateway's completion redirect
  /// `<base>/paymentgateway/mobile_paymentsend`.
  ///
  /// The native app compares the whole URL with `equals`
  /// (Payment_Webview_Frag.java:159). Here the query/fragment is dropped
  /// before comparing, which still matches nothing but that exact path —
  /// substring matching is deliberately not used, because an intermediate
  /// gateway page could contain such a fragment and end the session before
  /// the payment is actually finished.
  bool _isCompletionUrl(String url) {
    final expected = '${ApiConstants.paymentGatewayBase}$_kGatewayReturnPath';
    if (url == expected) return true;
    final cut = url.indexOf(RegExp(r'[?#]'));
    return cut != -1 && url.substring(0, cut) == expected;
  }

  Future<void> _launchUpiIntent(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No UPI app found to handle this payment'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Failed to launch UPI intent: $e');
    }
  }

  void _checkForCompletion(String url) {
    if (_isCompletionUrl(url)) {
      _onPaymentComplete();
    }
  }

  void _onPaymentComplete() {
    setState(() => _transactionInProgress = false);

    // Navigate to payment response screen
    context.pushReplacementNamed(
      RouteNames.paymentResponseName,
      extra: {
        'customerId': widget.customerId,
      },
    );
  }

  Future<bool> _onWillPop() async {
    if (_transactionInProgress) {
      final shouldLeave = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          final c = Theme.of(context).extension<AppColors>()!;
          return AlertDialog(
            title: const Text('Cancel Payment?'),
            content: const Text(
              'A transaction is in progress. Are you sure you want to go back? '
              'This may result in the payment not being completed.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Stay'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(foregroundColor: c.red),
                child: const Text('Leave'),
              ),
            ],
          );
        },
      );
      return shouldLeave ?? false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;
    final tt = Theme.of(context).textTheme;

    return PopScope(
      canPop: !_transactionInProgress,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          final shouldLeave = await _onWillPop();
          if (shouldLeave && mounted) {
            Navigator.of(context).pop();
          }
        }
      },
      child: Scaffold(
        backgroundColor: c.bg,
        appBar: AppBar(
          title: Text('Payment Gateway',
              style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
          leading: IconButton(
            icon: Icon(LucideIcons.arrowLeft, color: c.ink),
            onPressed: () async {
              final canPop = await _onWillPop();
              if (canPop && mounted) {
                Navigator.of(context).pop();
              }
            },
          ),
          bottom: _isLoading
              ? PreferredSize(
                  preferredSize: const Size.fromHeight(3),
                  child: LinearProgressIndicator(
                    value: _loadingProgress,
                    backgroundColor: c.ink05,
                    valueColor: AlwaysStoppedAnimation(c.red),
                  ),
                )
              : null,
        ),
        body: WebViewWidget(controller: _controller),
      ),
    );
  }
}
