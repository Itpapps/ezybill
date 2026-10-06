import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../common/widgets/app_toast.dart';
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

    // Same six fields, same order, same encoding as the native app
    // (Payment_Webview_Frag.java:73-93, URLEncoder.encode → '+' for spaces,
    // which is what Uri.encodeQueryComponent produces too).
    final body = <String, String>{
      'auth_key': _kGatewayAuthKey,
      'employee_id': widget.employeeId,
      'dealer_id': widget.dealerId,
      'customer_id': _gatewayCustomerId,
      'amount': widget.amount,
      'from_mobile_app': '0',
    }
        .entries
        .map((e) =>
            '${Uri.encodeQueryComponent(e.key)}=${Uri.encodeQueryComponent(e.value)}')
        .join('&');

    // Direct POST, exactly like the native WebView.postUrl()
    // (Payment_Webview_Frag.java:100). webview_flutter maps this to postUrl on
    // Android and to an NSURLRequest POST on iOS. The previous
    // auto-submitting HTML form worked too, but it submitted from an
    // about:blank document — the gateway saw `Origin: null`/no referer, and
    // the blank page stayed in the WebView history.
    _controller.loadRequest(
      Uri.parse(pgUrl),
      method: LoadRequestMethod.post,
      // Android's postUrl implies this content type and drops custom headers;
      // iOS needs it stated explicitly for the same wire format.
      headers: const {'Content-Type': 'application/x-www-form-urlencoded'},
      body: Uint8List.fromList(utf8.encode(body)),
    );
  }

  /// The native app always posts `customer_id=0` from the LCO top-up path
  /// (Payment_Webview_Frag.java:87-88); the top-up screen passes an empty
  /// string, so fall back to "0" and keep any real customer id intact.
  String get _gatewayCustomerId =>
      widget.customerId.isEmpty ? '0' : widget.customerId;

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
    // Navigate to payment response screen
    context.pushReplacementNamed(
      RouteNames.paymentResponseName,
      extra: {
        'customerId': widget.customerId,
      },
    );
  }

  /// Native parity: the gateway WebView swallows Back while the page itself
  /// can go back and shows a toast instead; on the first page Back is left to
  /// the default handler and leaves the screen
  /// (Payment_Webview_Frag.java:101-108). The native app never asks whether to
  /// cancel the payment, so no confirmation dialog here either.
  Future<bool> _onWillPop() async {
    if (await _controller.canGoBack()) {
      if (mounted) {
        AppToast.show(context,
            message: 'Cannot go back!', variant: ToastVariant.info);
      }
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;
    final tt = Theme.of(context).textTheme;

    return PopScope(
      // Always intercept: whether Back may leave depends on an async
      // canGoBack() probe, which `canPop` cannot await.
      canPop: false,
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
