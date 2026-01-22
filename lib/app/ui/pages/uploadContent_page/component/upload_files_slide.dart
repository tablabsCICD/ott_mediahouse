import 'package:flutter/material.dart';
import 'package:media_house/app/ui/pages/uploadContent_page/component/upload_form_helpers.dart';
import 'package:media_house/app/ui/pages/uploadContent_page/component/upload_media_helpers.dart';
import 'package:provider/provider.dart';

class UploadFilesSlide extends StatelessWidget {
  final ThemeData themeData;
  String? type;
  UploadFilesSlide({super.key, required this.themeData,required this.type});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          UploadFormHelpers.buildSectionCard(
            'Cast & Crew',
            [
              UploadFormHelpers.builtModernMultiValueTextField("Cast", themeData),
              const SizedBox(height: 16),
              UploadFormHelpers.builtModernMultiValueTextField("Director", themeData),
            ],
            themeData,
          ),
          const SizedBox(height: 24),
          UploadFormHelpers.buildSectionCard(
            'Media Files',
            [
              UploadMediaHelpers.buildEnhancedUploadSection("Trailer File", themeData, context),
              const SizedBox(height: 16),
              type=="MOVIE"?UploadMediaHelpers.buildEnhancedUploadSection("Movie File", themeData, context):SizedBox.shrink(),
              const SizedBox(height: 16),
              UploadMediaHelpers.buildEnhancedUploadSection("Censor Certificate", themeData, context),
            ],
            themeData,
          ),
          const SizedBox(height: 24),
          UploadFormHelpers.buildSectionCard(
            'Poster Images',
            [
              ...List.generate(3, (index) {
                return Column(
                  children: [
                    UploadMediaHelpers.buildEnhancedUploadSection("Poster ${index + 1}", themeData, context),
                    if (index < 2) const SizedBox(height: 16),
                  ],
                );
              }),
            ],
            themeData,
          ),
        ],
      ),
    );
  }
}
