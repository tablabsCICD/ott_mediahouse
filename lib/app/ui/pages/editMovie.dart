import 'package:flutter/material.dart';
import 'package:media_house/app/ui/pages/uploadContent_page/component/upload_form_helpers.dart';
import 'package:media_house/app/ui/pages/uploadContent_page/component/upload_media_helpers.dart';
import 'package:media_house/app/widget/custom_textfield.dart';
import 'package:provider/provider.dart';
import '../../../../../device/utils/ResponsiveWidget.dart';
import '../../../domain/entities/content.dart';
import '../../provider/themeProvider.dart';
import '../../provider/videoProvider.dart';
import '../../widget/show_toast.dart';
import 'uploadContent_page/upload_video.dart';

class EditVideoMovie extends StatefulWidget {
  final Content movie;
  const EditVideoMovie({super.key, required this.movie});

  @override
  State<EditVideoMovie> createState() => _EditVideoMovieState();
}

class _EditVideoMovieState extends State<EditVideoMovie> {
  final PageController _pageController = PageController();

  int _currentPage = 0;
  bool _isSubmitting = false;
  int get _totalSteps => _isApproved ? 2 : 3;
  int get _lastPageIndex => _totalSteps - 1;
  bool get _isMobile => ResponsiveWidget.isMobile(context);
  EdgeInsets get _pagePadding =>
      EdgeInsets.symmetric(horizontal: _isMobile ? 12 : 24, vertical: 16);

  void _nextPage() {
    if (_currentPage < _lastPageIndex) {
      setState(() {
        _currentPage++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      setState(() {
        _currentPage--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  bool get _isMovie => widget.movie.type!.toLowerCase() == "movie";
  bool get _isApproved =>
      widget.movie.approvalStatus!.toLowerCase() == "approved";
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    getMediaHouse();
  }

  void getMediaHouse() async {
    final provider = Provider.of<VideoProvider>(context, listen: false);
    await provider.fetchGroupedLanguages();
    await provider.getContentById(widget.movie.id!);
  }

  @override
  Widget build(BuildContext context) {
    ThemeProvider themeProvider =
        Provider.of<ThemeProvider>(context, listen: false);
    var selectedThemeData = themeProvider.getTheme;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Container(
          constraints: BoxConstraints(
            maxWidth: _isMobile
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
          child: Consumer<VideoProvider>(builder: (context, provider, child) {
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
          }),
        ),
      ),
    );
  }

  List<Widget> _moviePages(ThemeData theme, VideoProvider provider) {
    final pages = <Widget>[
      _commonPricingPage(theme, provider, 1),
      _moviePageThree(theme, provider),
    ];
    if (!_isApproved) {
      pages.insert(0, _moviePageOne(theme, provider));
    }
    return pages;
  }

  List<Widget> _seriesPages(ThemeData theme, VideoProvider provider) {
    final pages = <Widget>[
      _commonPricingPage(theme, provider, 0),
      _seriesPageThree(theme, provider),
    ];
    if (!_isApproved) {
      pages.insert(0, _seriesPageOne(theme, provider));
    }
    return pages;
  }

  Widget _moviePageOne(ThemeData theme, VideoProvider provider) {
    return SingleChildScrollView(
      padding: _pagePadding,
      child: Column(
        children: [
          UploadFormHelpers.buildSectionCard(
            "Language & Basic Details",
            [
              _isApproved
                  ? SizedBox.shrink()
                  : CustomTextField(
                      controller: provider.titleController,
                      hintText: "Enter movie title",
                      label: "Title",
                      textInputType: TextInputType.text,
                    ),
              _isApproved
                  ? SizedBox.shrink()
                  : CustomTextField(
                      controller: provider.descriptionController,
                      hintText: "Enter description",
                      label: "Description",
                      textInputType: TextInputType.text,
                    ),
              _isApproved
                  ? SizedBox.shrink()
                  : CustomTextField(
                      controller: provider.runTimeController,
                      hintText: "Enter runtime in minutes",
                      label: "Runtime (min)",
                      textInputType: TextInputType.number,
                    ),
            ],
            theme,
          ),
          const SizedBox(height: 8),
          _isApproved
              ? SizedBox.shrink()
              : UploadFormHelpers.buildSectionCard(
                  "Cast And Crew",
                  [
                    _castImageSection(theme, provider),
                    const SizedBox(height: 8),
                    _crewListSection(theme, provider),
                  ],
                  theme,
                ),
          const SizedBox(height: 8),
          _isApproved
              ? SizedBox.shrink()
              : UploadFormHelpers.buildSectionCard(
                  "Classification",
                  [
                    UploadFormHelpers.buildModernDropdownField(
                      'Age Rating',
                      ageRatings,
                      context,
                      provider,
                      theme,
                    ),
                    const SizedBox(height: 16),
                    UploadFormHelpers.buildModernMultiSelectDropdownField(
                      'Genres',
                      genres,
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
                provider.languageOptions,
                context,
                theme,
                groupedItems: provider.groupedLanguageOptions,
              ),
              const SizedBox(height: 16),
              _isApproved
                  ? SizedBox.shrink()
                  : CustomTextField(
                      controller: provider.titleController,
                      hintText: "Enter series title",
                      label: "Title",
                      textInputType: TextInputType.text,
                    ),
              _isApproved
                  ? SizedBox.shrink()
                  : CustomTextField(
                      controller: provider.descriptionController,
                      hintText: "Enter description",
                      label: "Description",
                      textInputType: TextInputType.text,
                    ),
            ],
            theme,
          ),
          const SizedBox(height: 8),
          _isApproved
              ? SizedBox.shrink()
              : UploadFormHelpers.buildSectionCard(
                  "Cast And Crew",
                  [
                    _castImageSection(theme, provider),
                    const SizedBox(height: 8),
                    _crewListSection(theme, provider),
                  ],
                  theme,
                ),
          const SizedBox(height: 8),
          _isApproved
              ? SizedBox.shrink()
              : UploadFormHelpers.buildSectionCard(
                  "Classification",
                  [
                    UploadFormHelpers.buildModernDropdownField(
                      'Age Rating',
                      ageRatings,
                      context,
                      provider,
                      theme,
                    ),
                    const SizedBox(height: 16),
                    UploadFormHelpers.buildModernMultiSelectDropdownField(
                      'Genres',
                      genres,
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
                rentalDurations,
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
              _isApproved
                  ? SizedBox.shrink()
                  : UploadMediaHelpers.buildEnhancedUploadSection(
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
              _isApproved
                  ? SizedBox.shrink()
                  : UploadMediaHelpers.buildEnhancedUploadSection(
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
              _isApproved
                  ? SizedBox.shrink()
                  : UploadMediaHelpers.buildEnhancedUploadSection(
                      "Trailer File", theme, context),
            ],
            theme,
          ),
          const SizedBox(height: 8),
          _audioSubtitleAndSettings(theme, provider),
        ],
      ),
    );
  }

  Widget _castImageSection(ThemeData theme, VideoProvider provider) {
    return UploadFormHelpers.buildSectionCard(
      "Cast",
      [
        CustomTextField(
          controller: provider.castNameController,
          hintText: "Enter cast name",
          label: "Cast Name",
          textInputType: TextInputType.text,
          showRequiredAsterisk: true,
        ),
        CustomTextField(
          controller: provider.castRoleController,
          hintText: "Enter cast role",
          label: "Cast Role",
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
                  side: BorderSide(
                      color: theme.primaryColor.withValues(alpha: 0.4)),
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
                  side: BorderSide(color: Colors.red.withValues(alpha: 0.4)),
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
                color: theme.cardColor.withValues(alpha: 0.5),
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

  Widget _crewListSection(ThemeData theme, VideoProvider provider) {
    return UploadFormHelpers.buildSectionCard(
      "Crew",
      [
        CustomTextField(
          controller: provider.crewNameController,
          hintText: "Enter crew name",
          label: "Crew Name",
          textInputType: TextInputType.text,
          showRequiredAsterisk: true,
        ),
        CustomTextField(
          controller: provider.crewRoleController,
          hintText: "Enter crew role (Director/Writer/Producer)",
          label: "Crew Role",
          textInputType: TextInputType.text,
          showRequiredAsterisk: true,
        ),
        UploadMediaHelpers.buildEnhancedUploadSection(
          "Crew Image",
          theme,
          context,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: provider.addCurrentCrewToQueue,
                icon: const Icon(Icons.add),
                label: const Text("Add Crew"),
                style: OutlinedButton.styleFrom(
                  foregroundColor: theme.primaryColor,
                  side: BorderSide(
                      color: theme.primaryColor.withValues(alpha: 0.4)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: provider.clearCrewDraft,
                icon: const Icon(Icons.clear),
                label: const Text("Clear Draft"),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: BorderSide(color: Colors.red.withValues(alpha: 0.4)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
        if (provider.pendingCrews.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            "Added Crews (${provider.pendingCrews.length})",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: theme.canvasColor,
            ),
          ),
          const SizedBox(height: 8),
          ...List.generate(provider.pendingCrews.length, (index) {
            final crew = provider.pendingCrews[index];
            return Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: theme.cardColor.withValues(alpha: 0.5),
                border: Border.all(color: theme.dividerColor),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      "${crew["name"] ?? ""} (${crew["role"] ?? ""})",
                      style: TextStyle(
                        color: theme.canvasColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => provider.removePendingCrewAt(index),
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    tooltip: "Remove crew",
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
              audioFormats,
              context,
              theme,
            ),
            const SizedBox(height: 16),
            UploadFormHelpers.buildModernMultiSelectDropdownField(
              'Subtitle Languages',
              provider.languageOptions,
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
          ],
          theme,
        ),
      ],
    );
  }

  Widget _buildHeader(ThemeData themeData) {
    final List<String> stepTitles = _isMovie
        ? (_isApproved
            ? const [
                "Release, Price & Rental",
                "Upload Files & Settings",
              ]
            : const [
                "Language, Details & Cast",
                "Release, Price & Rental",
                "Upload Files & Settings"
              ])
        : (_isApproved
            ? const [
                "Release, Price & Rental",
                "Upload & Episodes",
              ]
            : const [
                "Language, Details & Cast",
                "Release, Price & Rental",
                "Upload & Episodes"
              ]);

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
                "Edit Movie",
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
              "Step ${_currentPage + 1}/$_totalSteps",
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
        children: List.generate(_totalSteps, (index) {
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
                if (index < _lastPageIndex) const SizedBox(width: 8),
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
              onPressed: _isSubmitting
                  ? null
                  : () => _handleButtonPress(provider, themeData),
              style: ElevatedButton.styleFrom(
                backgroundColor: themeData.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isSubmitting && _currentPage == _lastPageIndex
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(_currentPage == _lastPageIndex ? "Submit" : "Next"),
            ),
          ),
        ],
      ),
    );
  }

  void _handleButtonPress(VideoProvider provider, ThemeData themeData) {
    if (_isApproved) {
      if (_currentPage == 0) {
        if (!_validatePageTwo(provider)) return;
        _syncFeaturedFlag(provider);
        _nextPage();
        return;
      }

      if (!_validatePageThree(provider)) return;
      _handleAdd(provider, themeData, widget.movie.id!);
      return;
    }

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
    _handleAdd(provider, themeData, widget.movie.id!);
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
    /*  if (!provider.isRegistrationFeePaid) {
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
    } */

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

    /*  if (provider.hasIncompleteCastDraft) {
      CustomToast.show(
        "Please complete cast draft or clear it before submit.",
        isSuccess: false,
      );
      return false;
    } */
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
      VideoProvider provider, ThemeData selectedThemeDat, int movieId) async {
    setState(() => _isSubmitting = true);
    try {
      Content? content = await provider.editContent(context, movieId);
      if (!mounted) return;
      if (content != null) {
        Navigator.of(context).pop();
        Navigator.of(context).pop();
      } else {
        CustomToast.show(
          "Failed to update content.",
          isSuccess: false,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}
