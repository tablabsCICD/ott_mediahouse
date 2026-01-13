import 'package:flutter/material.dart';
import 'package:media_house/app/ui/pages/uploadContent_page/component/upload_form_helpers.dart';
import 'package:media_house/app/ui/pages/uploadContent_page/component/upload_media_helpers.dart';
import 'package:provider/provider.dart';

import 'package:media_house/app/widget/show_toast.dart';

import '../../../../provider/videoProvider.dart';

class PricingSlide extends StatelessWidget {
  final ThemeData themeData;

  const PricingSlide({super.key, required this.themeData});

  @override
  Widget build(BuildContext context) {
    return Consumer<VideoProvider>(builder: (context, provider, child) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            UploadFormHelpers.buildSectionCard(
              'Content Classification',
              [
                UploadFormHelpers.buildModernMultiSelectDropdownField(
                  'Genres',
                  [
                    'Action', 'Drama', 'Comedy', 'Thriller', 'Horror',
                    'Romance', 'Sci-Fi', 'Fantasy', 'Mystery', 'Documentary',
                    'Animation', 'Adventure', 'Musical', 'Historical', 'Crime'
                  ],
                  context,
                  themeData,
                ),
                const SizedBox(height: 16),
                UploadFormHelpers.buildModernMultiSelectDropdownField(
                  'Languages',
                  [
                    'Hindi', 'English', 'Bengali', 'Marathi', 'Telugu',
                    'Tamil', 'Gujarati', 'Urdu', 'Kannada', 'Odia',
                    'Malayalam', 'Punjabi', 'Assamese', 'Rajasthani',
                    'Bhojpuri', 'Sindhi', 'Konkani', 'Maithili', 'Santali',
                    'Manipuri', 'Kashmiri', 'Dogri', 'Tulu', 'Mizo', 'Bodo'
                  ],
                  context,
                  themeData,
                ),
              ],
              themeData,
            ),
            const SizedBox(height: 24),
            UploadFormHelpers.buildSectionCard(
              'Audio & Subtitles',
              [
                UploadFormHelpers.buildModernMultiSelectDropdownField(
                  'Audio Formats',
                  [
                    'Stereo', 'Dolby', 'Mono', 'Surround Sound',
                    'Dolby Atmos', 'Dolby Digital (AC-3)'
                  ],
                  context,
                  themeData,
                ),
                const SizedBox(height: 16),
                UploadFormHelpers.buildModernMultiSelectDropdownField(
                  'Subtitle Languages',
                  [
                    'Hindi', 'English', 'Bengali', 'Marathi', 'Telugu',
                    'Tamil', 'Gujarati', 'Urdu', 'Kannada', 'Odia',
                    'Malayalam', 'Punjabi', 'Assamese', 'Rajasthani',
                    'Bhojpuri', 'Sindhi', 'Konkani', 'Maithili', 'Santali',
                    'Manipuri', 'Kashmiri', 'Dogri', 'Tulu', 'Mizo', 'Bodo'
                  ],
                  context,
                  themeData,
                ),
                const SizedBox(height: 24),
                UploadMediaHelpers.buildDynamicLanguageAudioSection(context, themeData),
              ],
              themeData,
            ),
            const SizedBox(height: 24),
            UploadFormHelpers.buildSectionCard(
              'Content Settings',
              [
                UploadFormHelpers.buildModernToggleRow(
                  'Downloadable Content',
                  'Allow users to download this content',
                  provider.isDownloadable,
                      (value) => provider.toggleDownloadable(value),
                  themeData,
                ),
                const SizedBox(height: 16),
                UploadFormHelpers.buildModernToggleRow(
                  'Featured Content',
                  'Mark as featured content',
                  provider.isFeatured,
                      (value) {
                    provider.isFeatured == true
                        ? CustomToast.show(
                      "You cannot disable this flag because the movie release date is still upcoming ${provider.releaseDateController.text}",
                      isWarning: true,
                    )
                        : CustomToast.show(
                      "You cannot enable this flag because the movie release date has already passed. ${provider.releaseDateController.text}",
                      isWarning: true,
                    );
                  },
                  themeData,
                ),
              ],
              themeData,
            ),
          ],
        ),
      );
    });
  }
}
