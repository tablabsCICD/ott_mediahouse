import 'package:flutter/material.dart';
import 'package:media_house/app/provider/themeProvider.dart';
import 'package:media_house/app/ui/pages/uploadContent_page/component/basic_info_slide.dart';
import 'package:media_house/app/ui/pages/uploadContent_page/component/pricing_slide.dart';
import 'package:provider/provider.dart';
import 'package:media_house/domain/entities/content.dart';
import 'package:media_house/domain/entities/mediaHouse.dart';
import 'package:media_house/app/widget/show_toast.dart';
import 'package:media_house/device/utils/ResponsiveWidget.dart';

import '../../../provider/videoProvider.dart';
import 'component/upload_files_slide.dart';

class UploadVideoWidget extends StatefulWidget {
  const UploadVideoWidget({super.key});

  @override
  State<UploadVideoWidget> createState() => _UploadVideoWidgetState();
}

class _UploadVideoWidgetState extends State<UploadVideoWidget> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  void _nextPage() {
    if (_currentPage < 2) {
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

  @override
  void initState() {
    super.initState();
    getMediaHouse();
  }

  void getMediaHouse() async {
    // Your existing logic for getting media house data
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
            maxWidth: ResponsiveWidget.isMobile(context)
                ? MediaQuery.of(context).size.width - 5
                : MediaQuery.of(context).size.width - 70,
            maxHeight: MediaQuery.of(context).size.height - 40,
          ),
          margin: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            color: selectedThemeData.cardColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Consumer<VideoProvider>(builder: (context, provider, child) {
            return Column(
              children: [
                _buildModernHeader(selectedThemeData),
                _buildProgressIndicator(selectedThemeData),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      BasicInfoSlide(themeData: selectedThemeData),
                      UploadFilesSlide(
                          themeData: selectedThemeData,
                          type: provider.typeController.text.trim()),
                      PricingSlide(
                          themeData: selectedThemeData,
                          type: provider.typeController.text.trim()),
                    ],
                  ),
                ),
                _buildModernFooter(selectedThemeData, provider),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildModernHeader(ThemeData themeData) {
    final List<String> stepTitles = [
      'Basic Information',
      'Upload Files',
      'Settings & Pricing'
    ];

    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(24.0),
          width: double.infinity,
          decoration: BoxDecoration(
              color: themeData.canvasColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12)),
          child: Column(
            children: [
              SizedBox(
                height: 12,
              ),
              Text(
                'Upload Content',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: themeData.primaryColor,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                stepTitles[_currentPage],
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
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
              'Step ${_currentPage + 1}/3',
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
                    themeData.scaffoldBackgroundColor.withOpacity(0.3)),
            icon: Icon(
              Icons.close,
              color: themeData.canvasColor,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressIndicator(ThemeData themeData) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: List.generate(3, (index) {
          bool isActive = index <= _currentPage;
          bool isCurrent = index == _currentPage;

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

  Widget _buildModernFooter(ThemeData themeData, VideoProvider provider) {
    return Container(
      padding: const EdgeInsets.all(24.0),
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.arrow_back, color: themeData.primaryColor),
                    const SizedBox(width: 8),
                    Text(
                      'Previous',
                      style: TextStyle(
                        color: themeData.primaryColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (_currentPage > 0) const SizedBox(width: 16),
          Expanded(
            flex: _currentPage == 0 ? 1 : 1,
            child: ElevatedButton(
              onPressed: () => _handleButtonPress(provider, themeData),
              style: ElevatedButton.styleFrom(
                backgroundColor: themeData.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _currentPage == 2 ? "Submit" : "Next",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    _currentPage == 2 ? Icons.check : Icons.arrow_forward,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleButtonPress(VideoProvider provider, ThemeData themeData) {
    if (_currentPage == 2) {
      String type = provider.typeController.text.trim();
      _handleAdd(provider, themeData, type);
    } else {
      // Validation logic (keeping original logic)
      String releaseDate = provider.releaseDateController.text.trim();
      String title = provider.titleController.text.trim();
      String movieUrl = provider.movieUrlController.text.trim();
      String trailerUrl = provider.trailerUrlController.text.trim();
      String type = provider.typeController.text.trim();
      String priceText = provider.priceController.text.trim();
      double? price = double.tryParse(priceText);

      if (releaseDate.isEmpty ||
          title.isEmpty ||
          price == null ||
          price <= 0 ||
          type.isEmpty ||
          type == null) {
        CustomToast.show(
          "Please enter valid title, price, and release date and content type",
          isSuccess: false,
        );
        return;
      }

      if (_currentPage == 1) {
        if (type == "MOVIE") {
          if (movieUrl.isEmpty || trailerUrl.isEmpty) {
            CustomToast.show(
              "Please upload movie url and trailer url",
              isSuccess: false,
            );
            return;
          }
        } else {
          if (trailerUrl.isEmpty) {
            CustomToast.show(
              "Please upload trailer url",
              isSuccess: false,
            );
            return;
          }
        }
      }

      try {
        DateTime currentDate = DateTime.now();
        DateTime targetDate = DateTime.parse(releaseDate);
        if (targetDate.isAfter(currentDate)) {
          provider.toggleFeatured(true);
        } else {
          provider.toggleFeatured(false);
        }
        _nextPage();
      } catch (e) {
        CustomToast.show(
          "Invalid release date format. Please correct it.",
          isSuccess: false,
        );
      }
    }
  }

  Future<void> _handleAdd(
      VideoProvider provider, ThemeData selectedThemeData, String type) async {
    if (type == "MOVIE") {
      Content? content = await provider.uploadContent(context);
      if (content != null) {
        Navigator.of(context).pop();
      } else {
        CustomToast.show(
            "Failed to add content. Please check your inputs and try again.",
            isSuccess: false);
      }
    } else {
      Content? content = await provider.uploadSeries(context);
      if (content != null) {
        Navigator.of(context).pop();
      } else {
        CustomToast.show(
            "Failed to add content. Please check your inputs and try again.",
            isSuccess: false);
      }
    }
  }
}
