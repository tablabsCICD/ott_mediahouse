class WebRazorpayGatewayImpl {
  static bool get isSupported => false;

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
  }) async {
    onError("Web Razorpay checkout is not supported on this platform.");
  }
}
