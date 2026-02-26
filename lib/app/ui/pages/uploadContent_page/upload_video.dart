import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:media_house/app/provider/themeProvider.dart';
import 'package:media_house/app/core/utils/sharepreferences.dart';
import 'package:media_house/app/ui/pages/uploadContent_page/component/upload_form_helpers.dart';
import 'package:media_house/app/ui/pages/uploadContent_page/component/upload_media_helpers.dart';
import 'package:media_house/app/ui/pages/uploadContent_page/component/web_razorpay_gateway.dart';
import 'package:media_house/app/widget/custom_textfield.dart';
import 'package:media_house/app/widget/show_toast.dart';
import 'package:media_house/device/utils/ResponsiveWidget.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../../../provider/videoProvider.dart';
import '../../../../domain/entities/content.dart';

enum UploadContentType { movie, series }

class UploadVideoWidget extends StatefulWidget {
  final UploadContentType uploadType;

  const UploadVideoWidget({
    super.key,
    this.uploadType = UploadContentType.movie,
  });

  @override
  State<UploadVideoWidget> createState() => _UploadVideoWidgetState();
}

class _UploadVideoWidgetState extends State<UploadVideoWidget> {
  final PageController _pageController = PageController();
  static const String _razorpayKeyId = String.fromEnvironment('RAZORPAY_KEY_ID',
      defaultValue: 'rzp_live_LraIKZvldr9N1J');
  static const double _defaultRegistrationAmount = 499.0;
  static const String _defaultRegistrationPlan = 'Basic';
  static const String _defaultRegistrationValidity = '1 Year';

  Razorpay? _razorpay;
  int _currentPage = 0;

  bool get _isMovie => widget.uploadType == UploadContentType.movie;
  bool get _isMobile => ResponsiveWidget.isMobile(context);
  EdgeInsets get _pagePadding =>
      EdgeInsets.symmetric(horizontal: _isMobile ? 12 : 24, vertical: 16);

  @override
  void initState() {
    super.initState();
    _initRazorpay();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context
          .read<VideoProvider>()
          .prepareUploadForm(_isMovie ? "MOVIE" : "SERIES");
    });
  }

  @override
  void dispose() {
    _razorpay?.clear();
    _pageController.dispose();
    super.dispose();
  }

  void _initRazorpay() {
    if (kIsWeb) return;
    _razorpay = Razorpay();
    _razorpay!.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay!.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay!.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  Future<void> _startRegistrationPayment(VideoProvider provider) async {
    if (!kIsWeb && _razorpay == null) {
      CustomToast.show("Payment gateway not initialized.", isSuccess: false);
      return;
    }

    if (_razorpayKeyId.isEmpty) {
      CustomToast.show(
        "Razorpay key is missing. Configure --dart-define=RAZORPAY_KEY_ID=...",
        isSuccess: false,
      );
      return;
    }

    final enteredAmount =
        double.tryParse(provider.registrationAmountPaidController.text.trim());
    if (enteredAmount == null || enteredAmount <= 0) {
      CustomToast.show(
        "Please enter a valid registration fee amount before payment.",
        isSuccess: false,
      );
      return;
    }
    final amount = enteredAmount;
    final amountInPaise = (amount * 100).round();

    final localSharePreferences = LocalSharePreferences();
    final user = await localSharePreferences.getUser();
    final userName = "${user?.firstName ?? ''} ${user?.lastName ?? ''}".trim();

    final options = {
      'key': _razorpayKeyId,
      'amount': amountInPaise,
      'name': 'OTT Media House',
      'description': 'Registration Fee',
      'prefill': {
        'contact': user?.mobileNumber ?? '',
        'email': user?.emailId ?? '',
        'name': userName,
      },
      'theme': {'color': '#1A73E8'},
    };

    if (kIsWeb) {
      await WebRazorpayGateway.openCheckout(
        keyId: _razorpayKeyId,
        amountInPaise: amountInPaise,
        merchantName: 'OTT Media House',
        description: 'Registration Fee',
        prefillContact: user?.mobileNumber ?? '',
        prefillEmail: user?.emailId ?? '',
        prefillName: userName,
        onSuccess: (paymentId) => _applyPaymentSuccess(
          paymentId: paymentId,
          paymentMethod: 'Razorpay (Web)',
        ),
        onError: (message) => CustomToast.show(message, isSuccess: false),
        onExternalWallet: (wallet) =>
            CustomToast.show("Payment switched to $wallet.", isWarning: true),
      );
      return;
    }

    try {
      _razorpay!.open(options);
    } catch (error) {
      CustomToast.show("Unable to open payment gateway: $error",
          isSuccess: false);
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    final paymentId =
        (response.paymentId ?? response.orderId ?? '').toString().trim();

    _applyPaymentSuccess(paymentId: paymentId, paymentMethod: 'Razorpay');
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    final errorMessage = response.message ?? "Payment failed.";
    CustomToast.show(errorMessage, isSuccess: false);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    final wallet = response.walletName ?? "external wallet";
    CustomToast.show("Payment switched to $wallet.", isWarning: true);
  }

  String _formatDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return "$year-$month-$day";
  }

  void _applyPaymentSuccess({
    required String paymentId,
    required String paymentMethod,
  }) {
    if (!mounted) return;
    final normalizedPaymentId = paymentId.trim();
    if (normalizedPaymentId.isEmpty) {
      CustomToast.show(
        "Payment succeeded but payment ID was not received.",
        isSuccess: false,
      );
      return;
    }

    final provider = context.read<VideoProvider>();
    final amountText = provider.registrationAmountPaidController.text.trim();
    final amount = (double.tryParse(amountText) ?? _defaultRegistrationAmount)
        .toStringAsFixed(2);

    provider.setRegistrationPaymentDetails(
      paymentId: normalizedPaymentId,
      paymentDate: _formatDate(DateTime.now()),
      amountPaid: amount,
      planType: provider.registrationPlanTypeController.text.trim().isEmpty
          ? _defaultRegistrationPlan
          : provider.registrationPlanTypeController.text.trim(),
      validity: provider.registrationValidityController.text.trim().isEmpty
          ? _defaultRegistrationValidity
          : provider.registrationValidityController.text.trim(),
      paymentMethod: paymentMethod,
      markPaid: true,
    );

    CustomToast.show("Registration fee payment successful.", isSuccess: true);
  }

  void _nextPage() {
    if (_currentPage < 2) {
      setState(() => _currentPage++);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      setState(() => _currentPage--);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedThemeData =
        Provider.of<ThemeProvider>(context, listen: false).getTheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Container(
          constraints: BoxConstraints(
            maxWidth: ResponsiveWidget.isMobile(context)
                ? MediaQuery.of(context).size.width - 8
                : MediaQuery.of(context).size.width - 70,
            maxHeight: MediaQuery.of(context).size.height - 40,
          ),
          margin: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: selectedThemeData.cardColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Consumer<VideoProvider>(
            builder: (context, provider, child) {
              return Column(
                children: [
                  _buildHeader(selectedThemeData),
                  _buildProgressIndicator(selectedThemeData),
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      children: _isMovie
                          ? _moviePages(selectedThemeData, provider)
                          : _seriesPages(selectedThemeData, provider),
                    ),
                  ),
                  _buildFooter(selectedThemeData, provider),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  List<Widget> _moviePages(ThemeData theme, VideoProvider provider) {
    return [
      _moviePageOne(theme, provider),
      _commonPricingPage(theme, provider, 1),
      _moviePageThree(theme, provider),
    ];
  }

  List<Widget> _seriesPages(ThemeData theme, VideoProvider provider) {
    return [
      _seriesPageOne(theme, provider),
      _commonPricingPage(theme, provider, 0),
      _seriesPageThree(theme, provider),
    ];
  }

  Widget _moviePageOne(ThemeData theme, VideoProvider provider) {
    return SingleChildScrollView(
      padding: _pagePadding,
      child: Column(
        children: [
          UploadFormHelpers.buildSectionCard(
            "Language & Basic Details",
            [
              UploadFormHelpers.buildModernMultiSelectDropdownField(
                'Languages',
                _languages,
                context,
                theme,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: provider.titleController,
                hintText: "Enter movie title",
                label: "Title",
                textInputType: TextInputType.text,
              ),
              CustomTextField(
                controller: provider.descriptionController,
                hintText: "Enter description",
                label: "Description",
                textInputType: TextInputType.text,
              ),
              CustomTextField(
                controller: provider.runTimeController,
                hintText: "Enter runtime in minutes",
                label: "Runtime (min)",
                textInputType: TextInputType.number,
              ),
            ],
            theme,
          ),
          const SizedBox(height: 8),
          UploadFormHelpers.buildSectionCard(
            "Cast And Crew",
            [
              _castImageSection(theme, provider),
              const SizedBox(height: 8),
              UploadFormHelpers.builtModernMultiValueTextField(
                  "Director", theme),
            ],
            theme,
          ),
          const SizedBox(height: 8),
          UploadFormHelpers.buildSectionCard(
            "Classification",
            [
              UploadFormHelpers.buildModernDropdownField(
                'Age Rating',
                _ageRatings,
                context,
                provider,
                theme,
              ),
              const SizedBox(height: 16),
              UploadFormHelpers.buildModernMultiSelectDropdownField(
                'Genres',
                _genres,
                context,
                theme,
              ),
            ],
            theme,
          ),
        ],
      ),
    );
  }

  Widget _seriesPageOne(ThemeData theme, VideoProvider provider) {
    return SingleChildScrollView(
      padding: _pagePadding,
      child: Column(
        children: [
          UploadFormHelpers.buildSectionCard(
            "Language & Basic Details",
            [
              UploadFormHelpers.buildModernMultiSelectDropdownField(
                'Languages',
                _languages,
                context,
                theme,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: provider.titleController,
                hintText: "Enter series title",
                label: "Title",
                textInputType: TextInputType.text,
              ),
              CustomTextField(
                controller: provider.descriptionController,
                hintText: "Enter description",
                label: "Description",
                textInputType: TextInputType.text,
              ),
              CustomTextField(
                controller: provider.runTimeController,
                hintText: "Enter number of episodes",
                label: "Number of Episodes",
                textInputType: TextInputType.number,
              ),
            ],
            theme,
          ),
          const SizedBox(height: 8),
          UploadFormHelpers.buildSectionCard(
            "Cast And Crew",
            [
              _castImageSection(theme, provider),
              const SizedBox(height: 8),
              UploadFormHelpers.builtModernMultiValueTextField(
                  "Director", theme),
            ],
            theme,
          ),
          const SizedBox(height: 8),
          UploadFormHelpers.buildSectionCard(
            "Classification",
            [
              UploadFormHelpers.buildModernDropdownField(
                'Age Rating',
                _ageRatings,
                context,
                provider,
                theme,
              ),
              const SizedBox(height: 16),
              UploadFormHelpers.buildModernMultiSelectDropdownField(
                'Genres',
                _genres,
                context,
                theme,
              ),
            ],
            theme,
          ),
        ],
      ),
    );
  }

  Widget _commonPricingPage(
      ThemeData theme, VideoProvider provider, int isMovie) {
    return SingleChildScrollView(
      padding: _pagePadding,
      child: Column(
        children: [
          UploadFormHelpers.buildSectionCard(
            "Release & Pricing",
            [
              UploadFormHelpers.buildModernDateField(
                context,
                provider,
                theme,
                (pickedDate) => provider.setDate(pickedDate),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: provider.priceController,
                hintText: "Enter price",
                label: "Price",
                textInputType: TextInputType.number,
              ),
              UploadFormHelpers.buildModernDropdownField(
                'Rental Duration',
                _rentalDurations,
                context,
                provider,
                theme,
              ),
              const SizedBox(height: 16),
              isMovie == 1
                  ? CustomTextField(
                      controller: provider.numberOfAttemptController,
                      hintText: "No Of Attempts",
                      label: "No Of Attempts",
                      textInputType: TextInputType.number,
                    )
                  : SizedBox.shrink()
            ],
            theme,
          ),
        ],
      ),
    );
  }

  Widget _moviePageThree(ThemeData theme, VideoProvider provider) {
    return SingleChildScrollView(
      padding: _pagePadding,
      child: Column(
        children: [
          UploadFormHelpers.buildSectionCard(
            "Upload Files",
            [
              UploadMediaHelpers.buildEnhancedUploadSection(
                  "Censor Certificate", theme, context),
              const SizedBox(height: 16),
              UploadMediaHelpers.buildEnhancedUploadSection(
                  "Poster 1", theme, context),
              const SizedBox(height: 16),
              UploadMediaHelpers.buildEnhancedUploadSection(
                  "Poster 2", theme, context),
              const SizedBox(height: 16),
              UploadMediaHelpers.buildEnhancedUploadSection(
                  "Poster 3", theme, context),
              const SizedBox(height: 16),
              UploadMediaHelpers.buildEnhancedUploadSection(
                  "Teaser File", theme, context),
              const SizedBox(height: 16),
              UploadMediaHelpers.buildEnhancedUploadSection(
                  "Trailer File", theme, context),
              const SizedBox(height: 16),
              UploadMediaHelpers.buildEnhancedUploadSection(
                  "Movie File", theme, context),
              const SizedBox(height: 16),
            ],
            theme,
          ),
          const SizedBox(height: 8),
          _audioSubtitleAndSettings(theme, provider),
        ],
      ),
    );
  }

  Widget _seriesPageThree(ThemeData theme, VideoProvider provider) {
    return SingleChildScrollView(
      padding: _pagePadding,
      child: Column(
        children: [
          UploadFormHelpers.buildSectionCard(
            "Upload Files",
            [
              UploadMediaHelpers.buildEnhancedUploadSection(
                  "Censor Certificate", theme, context),
              const SizedBox(height: 16),
              UploadMediaHelpers.buildEnhancedUploadSection(
                  "Poster 1", theme, context),
              const SizedBox(height: 16),
              UploadMediaHelpers.buildEnhancedUploadSection(
                  "Poster 2", theme, context),
              const SizedBox(height: 16),
              UploadMediaHelpers.buildEnhancedUploadSection(
                  "Poster 3", theme, context),
              const SizedBox(height: 16),
              UploadMediaHelpers.buildEnhancedUploadSection(
                  "Teaser File", theme, context),
              const SizedBox(height: 16),
              UploadMediaHelpers.buildEnhancedUploadSection(
                  "Trailer File", theme, context),
            ],
            theme,
          ),
          const SizedBox(height: 8),
          _castImageSection(theme, provider),
          const SizedBox(height: 8),
          _audioSubtitleAndSettings(theme, provider),
        ],
      ),
    );
  }

  Widget _castImageSection(ThemeData theme, VideoProvider provider) {
    return UploadFormHelpers.buildSectionCard(
      "Cast Image",
      [
        CustomTextField(
          controller: provider.castNameController,
          hintText: "Enter cast name",
          label: "Cast Name",
          textInputType: TextInputType.text,
        ),
        CustomTextField(
          controller: provider.castRoleController,
          hintText: "Enter cast role",
          label: "Cast Role",
          textInputType: TextInputType.text,
        ),
        CustomTextField(
          controller: provider.castDescriptionController,
          hintText: "Enter cast description",
          label: "Cast Description",
          textInputType: TextInputType.text,
        ),
        UploadMediaHelpers.buildEnhancedUploadSection(
          "Cast Image",
          theme,
          context,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: provider.addCurrentCastToQueue,
                icon: const Icon(Icons.add),
                label: const Text("Add Cast"),
                style: OutlinedButton.styleFrom(
                  foregroundColor: theme.primaryColor,
                  side: BorderSide(color: theme.primaryColor.withOpacity(0.4)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: provider.clearCastDraft,
                icon: const Icon(Icons.clear),
                label: const Text("Clear Draft"),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: BorderSide(color: Colors.red.withOpacity(0.4)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
        if (provider.pendingCasts.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            "Added Casts (${provider.pendingCasts.length})",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: theme.canvasColor,
            ),
          ),
          const SizedBox(height: 8),
          ...List.generate(provider.pendingCasts.length, (index) {
            final cast = provider.pendingCasts[index];
            return Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: theme.cardColor.withOpacity(0.5),
                border: Border.all(color: theme.dividerColor),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      "${cast["name"] ?? ""} (${cast["role"] ?? ""})",
                      style: TextStyle(
                        color: theme.canvasColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => provider.removePendingCastAt(index),
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    tooltip: "Remove cast",
                  ),
                ],
              ),
            );
          }),
        ],
      ],
      theme,
    );
  }

  Widget _audioSubtitleAndSettings(ThemeData theme, VideoProvider provider) {
    return Column(
      children: [
        UploadFormHelpers.buildSectionCard(
          "Audio & Subtitles",
          [
            UploadFormHelpers.buildModernMultiSelectDropdownField(
              'Audio Formats',
              _audioFormats,
              context,
              theme,
            ),
            const SizedBox(height: 16),
            UploadFormHelpers.buildModernMultiSelectDropdownField(
              'Subtitle Languages',
              _languages,
              context,
              theme,
            ),
            const SizedBox(height: 20),
            UploadMediaHelpers.buildDynamicLanguageAudioSection(context, theme),
          ],
          theme,
        ),
        const SizedBox(height: 8),
        UploadFormHelpers.buildSectionCard(
          "Content Settings",
          [
            UploadFormHelpers.buildModernToggleRow(
              'Downloadable Content',
              'Allow users to download this content',
              provider.isDownloadable,
              provider.toggleDownloadable,
              theme,
            ),
            const SizedBox(height: 16),
            UploadFormHelpers.buildModernToggleRow(
              'Featured Content',
              'Automatically controlled by release date logic',
              provider.isFeatured,
              (value) {
                CustomToast.show(
                  provider.isFeatured
                      ? "Featured content is enabled for upcoming releases."
                      : "Featured content is disabled for already released content.",
                  isWarning: true,
                );
              },
              theme,
            ),
            const SizedBox(height: 16),
            UploadFormHelpers.buildModernToggleRow(
              'Registration Fee Paid',
              'Y = Paid (upload allowed), N = Not paid (upload blocked)',
              provider.isRegistrationFeePaid,
              (value) {
                if (value) {
                  _startRegistrationPayment(provider);
                  return;
                }
                provider.clearRegistrationPaymentDetails(markUnpaid: true);
              },
              theme,
            ),
            const SizedBox(height: 16),
            if (!provider.isRegistrationFeePaid)
              CustomTextField(
                controller: provider.registrationAmountPaidController,
                hintText: "Enter registration fee amount",
                label: "Registration Fee Amount",
                textInputType: TextInputType.number,
              ),
            if (!provider.isRegistrationFeePaid) const SizedBox(height: 12),
            if (!provider.isRegistrationFeePaid)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _startRegistrationPayment(provider),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(Icons.payments_outlined),
                  label: const Text("Pay Registration Fee"),
                ),
              ),
            if (!provider.isRegistrationFeePaid) const SizedBox(height: 16),
            if (provider.isRegistrationFeePaid) ...[
              CustomTextField(
                controller: provider.registrationPaymentIdController,
                hintText: "Enter transaction/payment id",
                label: "Payment ID / Transaction ID",
                textInputType: TextInputType.text,
              ),
              CustomTextField(
                controller: provider.registrationPaymentDateController,
                hintText: "Enter payment date (e.g. 2026-02-10)",
                label: "Payment Date",
                textInputType: TextInputType.datetime,
              ),
              CustomTextField(
                controller: provider.registrationAmountPaidController,
                hintText: "Enter amount paid",
                label: "Amount Paid",
                textInputType: TextInputType.number,
              ),
              CustomTextField(
                controller: provider.registrationPlanTypeController,
                hintText: "Enter plan (Basic/Premium)",
                label: "Plan Type",
                textInputType: TextInputType.text,
              ),
              CustomTextField(
                controller: provider.registrationValidityController,
                hintText: "Enter validity (e.g. 1 year / 2027-02-10)",
                label: "Validity",
                textInputType: TextInputType.text,
              ),
              CustomTextField(
                controller: provider.registrationPaymentMethodController,
                hintText: "Enter payment method (UPI/Card/Net Banking)",
                label: "Payment Method",
                textInputType: TextInputType.text,
              ),
            ] else ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: theme.primaryColor.withValues(alpha: 0.2),
                  ),
                ),
                child: Text(
                  "Set Registration Fee Paid = Y to fill payment details and enable upload.",
                  style: TextStyle(
                    color: theme.canvasColor,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ],
          theme,
        ),
      ],
    );
  }

  Widget _buildHeader(ThemeData themeData) {
    final List<String> stepTitles = _isMovie
        ? const [
            "Language, Details & Cast",
            "Release, Price & Rental",
            "Upload Files & Settings"
          ]
        : const [
            "Language, Details & Cast",
            "Release, Price & Rental",
            "Upload & Episodes"
          ];

    return Stack(
      children: [
        Container(
          padding: EdgeInsets.all(_isMobile ? 14 : 24),
          width: double.infinity,
          decoration: BoxDecoration(
            color: themeData.canvasColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Text(
                _isMovie ? "Upload Movie" : "Upload Series",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: themeData.primaryColor,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                stepTitles[_currentPage],
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: _isMobile ? 16 : 20,
                  fontWeight: FontWeight.w600,
                  color: themeData.canvasColor,
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: 5,
          right: 5,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: themeData.primaryColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "Step ${_currentPage + 1}/3",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ),
        Positioned(
          top: 5,
          left: 5,
          child: IconButton(
            onPressed: () => Navigator.pop(context),
            style: IconButton.styleFrom(
              backgroundColor:
                  themeData.scaffoldBackgroundColor.withValues(alpha: 0.35),
              foregroundColor: themeData.canvasColor,
            ),
            icon: const Icon(Icons.close, size: 20),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressIndicator(ThemeData themeData) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: _isMobile ? 14 : 24, vertical: _isMobile ? 12 : 16),
      child: Row(
        children: List.generate(3, (index) {
          final isActive = index <= _currentPage;
          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: isActive
                          ? themeData.primaryColor
                          : themeData.dividerColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                if (index < 2) const SizedBox(width: 8),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildFooter(ThemeData themeData, VideoProvider provider) {
    return Container(
      padding: EdgeInsets.all(_isMobile ? 14 : 24),
      decoration: BoxDecoration(
        color: themeData.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          if (_currentPage > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousPage,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: themeData.primaryColor),
                  foregroundColor: themeData.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text("Previous"),
              ),
            ),
          if (_currentPage > 0) const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: () => _handleButtonPress(provider, themeData),
              style: ElevatedButton.styleFrom(
                backgroundColor: themeData.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(_currentPage == 2 ? "Submit" : "Next"),
            ),
          ),
        ],
      ),
    );
  }

  void _handleButtonPress(VideoProvider provider, ThemeData themeData) {
    if (_currentPage == 0) {
      if (!_validatePageOne(provider)) return;
      _nextPage();
      return;
    }

    if (_currentPage == 1) {
      if (!_validatePageTwo(provider)) return;
      _syncFeaturedFlag(provider);
      _nextPage();
      return;
    }

    if (!_validatePageThree(provider)) return;
    _handleAdd(provider, themeData);
  }

  bool _validatePageOne(VideoProvider provider) {
    /*  if (provider.selectedLanguages.isEmpty) {
      CustomToast.show("Please select at least one language", isSuccess: false);
      return false;
    }
    if (provider.titleController.text.trim().isEmpty) {
      CustomToast.show("Please enter title", isSuccess: false);
      return false;
    }
    if (provider.descriptionController.text.trim().isEmpty) {
      CustomToast.show("Please enter description", isSuccess: false);
      return false;
    }
    if (provider.runTimeController.text.trim().isEmpty) {
      CustomToast.show(
        _isMovie ? "Please enter runtime" : "Please enter number of episodes",
        isSuccess: false,
      );
      return false;
    } */
    return true;
  }

  bool _validatePageTwo(VideoProvider provider) {
    final releaseDate = provider.releaseDateController.text.trim();
    final priceText = provider.priceController.text.trim();
    final rentalDuration = provider.rentalDurationController.text.trim();
    final price = double.tryParse(priceText);

    /*  if (releaseDate.isEmpty) {
      CustomToast.show("Please select release date", isSuccess: false);
      return false;
    }
    if (price == null || price <= 0) {
      CustomToast.show("Please enter valid price", isSuccess: false);
      return false;
    }
    if (rentalDuration.isEmpty) {
      CustomToast.show("Please select rental duration", isSuccess: false);
      return false;
    } */
    return true;
  }

  bool _validatePageThree(VideoProvider provider) {
    if (!provider.isRegistrationFeePaid) {
      CustomToast.show(
        "Registration fee is not paid (N). Upload is blocked.",
        isSuccess: false,
      );
      return false;
    }

    if (provider.registrationPaymentIdController.text.trim().isEmpty ||
        provider.registrationPaymentDateController.text.trim().isEmpty ||
        provider.registrationAmountPaidController.text.trim().isEmpty ||
        provider.registrationPlanTypeController.text.trim().isEmpty ||
        provider.registrationValidityController.text.trim().isEmpty ||
        provider.registrationPaymentMethodController.text.trim().isEmpty) {
      CustomToast.show(
        "Please fill all registration fee detail fields.",
        isSuccess: false,
      );
      return false;
    }

    final trailerUrl = provider.trailerUrlController.text.trim();
    if (trailerUrl.isEmpty) {
      CustomToast.show("Please upload trailer file", isSuccess: false);
      return false;
    }

    if (_isMovie) {
      final movieUrl = provider.movieUrlController.text.trim();
      if (movieUrl.isEmpty) {
        CustomToast.show("Please upload movie file", isSuccess: false);
        return false;
      }
    }

    if (provider.hasIncompleteCastDraft) {
      CustomToast.show(
        "Please complete cast draft or clear it before submit.",
        isSuccess: false,
      );
      return false;
    }
    return true;
  }

  void _syncFeaturedFlag(VideoProvider provider) {
    try {
      final releaseDate = provider.releaseDateController.text.trim();
      final targetDate = DateTime.parse(releaseDate);
      provider.toggleFeatured(targetDate.isAfter(DateTime.now()));
    } catch (_) {
      CustomToast.show("Invalid release date format. Please correct it.",
          isSuccess: false);
    }
  }

  Future<void> _handleAdd(
      VideoProvider provider, ThemeData selectedThemeData) async {
    if (_isMovie) {
      final Content? content = await provider.uploadContent(context);
      if (content != null) {
        if (provider.hasAnyCastToSave) {
          final contentId = content.id;
          if (contentId == null) {
            CustomToast.show(
              "Content saved but content ID not received for cast save.",
              isSuccess: false,
            );
            return;
          }
          final castSaved =
              await provider.saveAllCastsForContent(contentId: contentId);
          if (!castSaved) {
            return;
          }
        }
        provider.disposeData();
      }
      if (content != null && mounted) {
        Navigator.of(context).pop();
      }
      return;
    }

    final Content? content = await provider.uploadSeries(context);
    if (content != null) {
      if (provider.hasAnyCastToSave) {
        final contentId = content.id;
        if (contentId == null) {
          CustomToast.show(
            "Content saved but content ID not received for cast save.",
            isSuccess: false,
          );
          return;
        }
        final castSaved =
            await provider.saveAllCastsForContent(contentId: contentId);
        if (!castSaved) {
          return;
        }
      }
      provider.disposeData();
    }
    if (content != null && mounted) {
      Navigator.of(context).pop();
    }
  }
}

const List<String> _ageRatings = [
  'U (Universal)',
  'U/A (Parental Guidance for Children Below 12)',
  'A (Adults Only)',
  'S (Restricted to a Special Class of Persons)',
];

const List<String> _rentalDurations = [
  "One Time",
  "One Day",
  "Two Day",
  "Three Day",
  "One Week",
  "Two Week",
  "One Month",
  "Three Month",
  "Six Month",
  "One Year",
  "Lifetime",
];

const List<String> _genres = [
  'Action',
  'Drama',
  'Comedy',
  'Thriller',
  'Horror',
  'Romance',
  'Sci-Fi',
  'Fantasy',
  'Mystery',
  'Documentary',
  'Animation',
  'Adventure',
  'Musical',
  'Historical',
  'Crime',
];

const List<String> _audioFormats = [
  'Stereo',
  'Dolby',
  'Mono',
  'Surround Sound',
  'Dolby Atmos',
  'Dolby Digital (AC-3)',
];

const List<String> _languages = [
  'Hindi',
  'English',
  'Bengali',
  'Marathi',
  'Telugu',
  'Tamil',
  'Gujarati',
  'Urdu',
  'Kannada',
  'Odia',
  'Malayalam',
  'Punjabi',
  'Assamese',
  'Rajasthani',
  'Bhojpuri',
  'Sindhi',
  'Konkani',
  'Maithili',
  'Santali',
  'Manipuri',
  'Kashmiri',
  'Dogri',
  'Tulu',
  'Mizo',
  'Bodo',
];
