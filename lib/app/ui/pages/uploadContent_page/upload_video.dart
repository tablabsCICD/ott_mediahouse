import 'package:flutter/material.dart';
import 'package:media_house/app/provider/themeProvider.dart';
import 'package:media_house/app/ui/pages/uploadContent_page/component/upload_form_helpers.dart';
import 'package:media_house/app/ui/pages/uploadContent_page/component/upload_media_helpers.dart';
import 'package:media_house/app/widget/custom_textfield.dart';
import 'package:media_house/app/widget/show_toast.dart';
import 'package:media_house/device/utils/ResponsiveWidget.dart';
import 'package:provider/provider.dart';

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
  int _currentPage = 0;

  bool get _isMovie => widget.uploadType == UploadContentType.movie;
  bool get _isMobile => ResponsiveWidget.isMobile(context);
  EdgeInsets get _pagePadding =>
      EdgeInsets.symmetric(horizontal: _isMobile ? 12 : 24, vertical: 16);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context
          .read<VideoProvider>()
          .prepareUploadForm(_isMovie ? "MOVIE" : "SERIES");
    });
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
      _commonPricingPage(theme, provider),
      _moviePageThree(theme, provider),
    ];
  }

  List<Widget> _seriesPages(ThemeData theme, VideoProvider provider) {
    return [
      _seriesPageOne(theme, provider),
      _commonPricingPage(theme, provider),
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
            "Cast & Crew",
            [
              UploadFormHelpers.builtModernMultiValueTextField("Cast", theme),
              const SizedBox(height: 12),
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
            "Cast & Crew",
            [
              UploadFormHelpers.builtModernMultiValueTextField("Cast", theme),
              const SizedBox(height: 12),
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

  Widget _commonPricingPage(ThemeData theme, VideoProvider provider) {
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
                  "Poster 1", theme, context),
              const SizedBox(height: 16),
              UploadMediaHelpers.buildEnhancedUploadSection(
                  "Poster 2", theme, context),
              const SizedBox(height: 16),
              UploadMediaHelpers.buildEnhancedUploadSection(
                  "Poster 3", theme, context),
              const SizedBox(height: 16),
              UploadMediaHelpers.buildEnhancedUploadSection(
                  "Trailer File", theme, context),
              const SizedBox(height: 16),
              UploadMediaHelpers.buildEnhancedUploadSection(
                  "Movie File", theme, context),
              const SizedBox(height: 16),
              UploadMediaHelpers.buildEnhancedUploadSection(
                  "Censor Certificate", theme, context),
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
                  "Poster 1", theme, context),
              const SizedBox(height: 16),
              UploadMediaHelpers.buildEnhancedUploadSection(
                  "Poster 2", theme, context),
              const SizedBox(height: 16),
              UploadMediaHelpers.buildEnhancedUploadSection(
                  "Poster 3", theme, context),
              const SizedBox(height: 16),
              UploadMediaHelpers.buildEnhancedUploadSection(
                  "Trailer File", theme, context),
              const SizedBox(height: 16),
              UploadMediaHelpers.buildEnhancedUploadSection(
                  "Censor Certificate", theme, context),
            ],
            theme,
          ),
          const SizedBox(height: 8),
          UploadFormHelpers.buildSectionCard(
            "Episodes",
            [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.primaryColor.withValues(alpha: 0.22),
                  ),
                ),
                child: Text(
                  "Upload episodes separately after series is created.",
                  style: TextStyle(
                    color: theme.canvasColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
            theme,
          ),
          const SizedBox(height: 8),
          _audioSubtitleAndSettings(theme, provider),
        ],
      ),
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
    if (provider.selectedLanguages.isEmpty) {
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
    }
    return true;
  }

  bool _validatePageTwo(VideoProvider provider) {
    final releaseDate = provider.releaseDateController.text.trim();
    final priceText = provider.priceController.text.trim();
    final rentalDuration = provider.rentalDurationController.text.trim();
    final price = double.tryParse(priceText);

    if (releaseDate.isEmpty) {
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
    }
    return true;
  }

  bool _validatePageThree(VideoProvider provider) {
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
      if (content != null && mounted) {
        Navigator.of(context).pop();
      }
      return;
    }

    final Content? content = await provider.uploadSeries(context);
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
