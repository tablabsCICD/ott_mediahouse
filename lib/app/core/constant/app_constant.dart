class AppConstant {
  static final String appVersion = "1.0.0"; // 1
  static const String appName = "Filmytell";

  static final String GOOGLE_KEY = "AIzaSyAm332fBuy8QoCC6ZFv7pizIqdmaT-jz30";
  static const String razorpayKeyId = String.fromEnvironment(
    'RAZORPAY_KEY_ID',
    defaultValue: 'rzp_test_qds9tiF6d4FFtb',
  );
  static const String razorpayMerchantName = 'Filmytell';
  static const String razorpayLogoUrl = String.fromEnvironment(
    'RAZORPAY_LOGO_URL',
    defaultValue:
        'https://filmytell-document.s3.ap-south-1.amazonaws.com/documents/filmytell-logo-1778238183653.jpeg',
  );
  static const playStoreLink =
      "https://play.google.com/store/apps/details?id=com.filmytell.ott";
  static const webAppLink = "https://filmytell.in";

  static const privacyPolicy =
      "https://filmytell-document.s3.ap-south-1.amazonaws.com/filmytell_privacy_policy.html";
  static const termsAndCondition =
      "https://filmytell-document.s3.ap-south-1.amazonaws.com/filmytell_privacy_policy.html";
}
