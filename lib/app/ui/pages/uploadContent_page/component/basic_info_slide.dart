import 'package:flutter/material.dart';
import 'package:media_house/app/ui/pages/uploadContent_page/component/upload_form_helpers.dart';
import 'package:provider/provider.dart';
import 'package:media_house/app/widget/custom_textfield.dart';

import '../../../../provider/videoProvider.dart';

class BasicInfoSlide extends StatelessWidget {
  final ThemeData themeData;

  const BasicInfoSlide({super.key, required this.themeData});

  @override
  Widget build(BuildContext context) {
    return Consumer<VideoProvider>(builder: (context, provider, child) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            UploadFormHelpers.buildSectionCard(
              'Content Details',
              [
                CustomTextField(
                  controller: provider.titleController,
                  hintText: "Content Name",
                  textInputType: TextInputType.text,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: provider.descriptionController,
                  hintText: "Description",
                  textInputType: TextInputType.text,
                ),
                const SizedBox(height: 16),
                UploadFormHelpers.buildModernDateField(context, provider, themeData, (pickedDate) {
                  provider.setDate(pickedDate);
                }),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: provider.runTimeController,
                  hintText: "Runtime (e.g., 181 minutes)",
                  textInputType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: provider.priceController,
                  hintText: "Price (e.g., 300)",
                  textInputType: TextInputType.text,
                ),
              ],
              themeData,
            ),
            const SizedBox(height: 24),
            UploadFormHelpers.buildSectionCard(
              'Classification',
              [
                UploadFormHelpers.buildModernDropdownField(
                  'Age Rating',
                  [
                    'U (Universal)',
                    'U/A (Parental Guidance for Children Below 12)',
                    'A (Adults Only)',
                    'S (Restricted to a Special Class of Persons)'
                  ],
                  context,
                  provider,
                  themeData,
                ),
                const SizedBox(height: 16),
                UploadFormHelpers.buildModernDropdownField(
                  'Type',
                  ['MOVIE', 'SERIES'],
                  context,
                  provider,
                  themeData,
                ),
                const SizedBox(height: 16),
                UploadFormHelpers.buildModernDropdownField(
                  'Rental Duration',
                  [
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
                  ],
                  context,
                  provider,
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

