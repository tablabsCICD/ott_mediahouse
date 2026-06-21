import 'package:flutter/material.dart';
import 'package:media_house/app/core/constant/image_constant.dart';
import 'package:media_house/app/provider/themeProvider.dart';
import 'package:media_house/app/ui/pages/uploadContent_page/select_upload_type.dart';
import 'package:media_house/app/widget/show_toast.dart';
import 'package:media_house/domain/entities/mediaHouse.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class ContentUploadCard extends StatelessWidget {
  MediaHouse mediaHouse;
  ContentUploadCard(this.mediaHouse, {super.key});

  @override
  Widget build(BuildContext context) {
    var selectedThemeData =
        Provider.of<ThemeProvider>(context, listen: true).getTheme;

    return Card(
      color: selectedThemeData.cardColor,
      child: InkWell(
        onTap: () {
          mediaHouse.status == "APPROVED"
              ? showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) => SelectUploadTypeDialog(),
                )
              // ? showDialog(
              //     context: context,
              //     builder: (BuildContext context) {
              //       return Dialog(
              //         backgroundColor: selectedThemeData.cardColor,
              //         child: SizedBox(
              //             width: ResponsiveWidget.isMobile(context)
              //                 ? MediaQuery.of(context).size.width * 0.8
              //                 : MediaQuery.of(context).size.width *
              //                     0.5, // 80% of screen width,
              //             child: UploadVideoWidget()),
              //       );
              //     },
              //   )
              : CustomToast.show(
                  context, "First you need to get approval from admin",
                  isSuccess: false);
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                'Upload New Content',
                style: TextStyle(
                  color: selectedThemeData.primaryColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              Spacer(),
              Opacity(
                opacity: 0.7,
                child: Image.asset(
                  ImageConstant.upload,
                  //width: 100,
                  height: 120,
                ),
              ),
              Spacer(),
              Text(
                'Upload your masterpiece and let it steal the spotlight! 🎬✨',
                style: TextStyle(
                  color: selectedThemeData.canvasColor.withOpacity(0.6),
                  fontWeight: FontWeight.normal,
                ),
                textAlign: TextAlign.center,
              ),
              Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
