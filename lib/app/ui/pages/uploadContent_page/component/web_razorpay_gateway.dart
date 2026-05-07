import 'web_razorpay_gateway_stub.dart'
    if (dart.library.html) 'web_razorpay_gateway_web.dart' as impl;

class WebRazorpayGateway {
  static bool get isSupported => impl.WebRazorpayGatewayImpl.isSupported;

  static Future<void> openCheckout({
    required String keyId,
    required int amountInPaise,
    required String merchantName,
    required String description,
    required String prefillContact,
    required String prefillEmail,
    required String prefillName,
    String? logoUrl,
    required void Function(String paymentId) onSuccess,
    required void Function(String message) onError,
    void Function(String walletName)? onExternalWallet,
  }) {
    return impl.WebRazorpayGatewayImpl.openCheckout(
      keyId: keyId,
      amountInPaise: amountInPaise,
      merchantName: merchantName,
      description: description,
      prefillContact: prefillContact,
      prefillEmail: prefillEmail,
      prefillName: prefillName,
      logoUrl: logoUrl,
      onSuccess: onSuccess,
      onError: onError,
      onExternalWallet: onExternalWallet,
    );
  }
}
