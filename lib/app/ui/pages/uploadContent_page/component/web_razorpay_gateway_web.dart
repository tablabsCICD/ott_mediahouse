import 'dart:async';
import 'dart:html' as html;
// ignore: avoid_web_libraries_in_flutter
import 'dart:js_util' as js_util;

class WebRazorpayGatewayImpl {
  static const String _checkoutScriptSrc =
      'https://checkout.razorpay.com/v1/checkout.js';
  static Future<void>? _scriptLoadFuture;

  static bool get isSupported {
    try {
      final dynamic ctor = js_util.getProperty(html.window, 'Razorpay');
      return ctor != null;
    } catch (_) {
      return false;
    }
  }

  static Future<void> _ensureCheckoutScriptLoaded() {
    if (isSupported) {
      return Future<void>.value();
    }

    if (_scriptLoadFuture != null) {
      return _scriptLoadFuture!;
    }

    final completer = Completer<void>();
    _scriptLoadFuture = completer.future;

    try {
      final existing = html.document
          .querySelectorAll('script')
          .whereType<html.ScriptElement>()
          .where(
              (s) => (s.src).contains('checkout.razorpay.com/v1/checkout.js'))
          .toList();

      if (existing.isNotEmpty) {
        final script = existing.first;
        if (isSupported) {
          completer.complete();
        } else {
          script.onLoad.first.then((_) => completer.complete());
          script.onError.first.then((_) {
            completer.completeError(
                "Failed to load Razorpay checkout script from $_checkoutScriptSrc");
          });
        }
        return _scriptLoadFuture!;
      }

      final script = html.ScriptElement()
        ..src = _checkoutScriptSrc
        ..type = 'text/javascript'
        ..async = true;

      script.onLoad.first.then((_) => completer.complete());
      script.onError.first.then((_) {
        completer.completeError(
            "Failed to load Razorpay checkout script from $_checkoutScriptSrc");
      });

      html.document.body?.append(script);
    } catch (error) {
      completer.completeError(error);
    }

    return _scriptLoadFuture!;
  }

  static Future<void> openCheckout({
    required String keyId,
    required int amountInPaise,
    required String merchantName,
    required String description,
    required String prefillContact,
    required String prefillEmail,
    required String prefillName,
    required void Function(String paymentId) onSuccess,
    required void Function(String message) onError,
    void Function(String walletName)? onExternalWallet,
  }) async {
    try {
      await _ensureCheckoutScriptLoaded();

      final dynamic razorpayConstructor =
          js_util.getProperty(html.window, 'Razorpay');
      if (razorpayConstructor == null) {
        onError("Razorpay checkout script failed to initialize.");
        return;
      }

      final options = <String, dynamic>{
        'key': keyId,
        'amount': amountInPaise,
        'name': merchantName,
        'description': description,
        'prefill': {
          'contact': prefillContact,
          'email': prefillEmail,
          'name': prefillName,
        },
        'theme': {
          'color': '#1A73E8',
        },
        'handler': js_util.allowInterop((dynamic response) {
          final dynamic paymentIdValue =
              js_util.getProperty(response, 'razorpay_payment_id');
          final paymentId = (paymentIdValue ?? '').toString().trim();
          if (paymentId.isEmpty) {
            onError("Payment succeeded but payment ID was not received.");
            return;
          }
          onSuccess(paymentId);
        }),
        'modal': {
          'ondismiss': js_util.allowInterop(() {
            onError("Payment cancelled by user.");
          }),
        },
      };

      if (onExternalWallet != null) {
        options['external'] = {
          'wallets': ['paytm'],
        };
      }

      final checkout = js_util.callConstructor<Object>(
        razorpayConstructor,
        [js_util.jsify(options)],
      );

      if (onExternalWallet != null) {
        js_util.callMethod<void>(
          checkout,
          'on',
          [
            'payment.external_wallet',
            js_util.allowInterop((dynamic response) {
              final walletName =
                  (js_util.getProperty(response, 'external_wallet') as dynamic?)
                      ?.toString()
                      .trim();
              onExternalWallet(walletName?.isNotEmpty == true
                  ? walletName!
                  : "external wallet");
            }),
          ],
        );
      }

      js_util.callMethod<void>(checkout, 'open', const []);
    } catch (error) {
      onError("Unable to open Razorpay web checkout: $error");
    }
  }
}
