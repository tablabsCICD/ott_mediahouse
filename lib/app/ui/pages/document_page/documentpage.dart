import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:media_house/app/core/constant/image_constant.dart';
import 'package:media_house/app/provider/mediaHouseProvider.dart';
import 'dart:io';
import 'package:open_file/open_file.dart';
import 'package:provider/provider.dart';
import 'package:media_house/app/provider/themeProvider.dart';
import 'package:media_house/device/utils/ResponsiveWidget.dart';

class DocumentsPage extends StatefulWidget {
  @override
  _DocumentsPageState createState() => _DocumentsPageState();
}

class _DocumentsPageState extends State<DocumentsPage> {

  Future<void> pickDocument(String docType,MediaHouseProvider provider) async {
    print("Pick document....");
  //await provider.pickImage(docType);
  try {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      File file = File(result.files.single.path!);
      setState(() {
        provider.uploadedDocuments[docType] = {
          'file': file,
          'fileName': result.files.single.name,
          'fileSize': '${result.files.single.size} bytes',
        };
      });
    }
  } catch (e) {
    debugPrint("Error picking document: $e");
  }

  }

  void viewDocument(String docType,MediaHouseProvider provider) {
    print("View document....");
    File? file = provider.uploadedDocuments[docType]!['file'];
    if (file != null) {
      OpenFile.open(file.path);
    }
  }

  void removeDocument(BuildContext context, String docType, MediaHouseProvider provider,String title) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text('Are you sure you want to remove the $docType document?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Dismiss the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                // Proceed with document removal
             await provider.clearController("DElete Title :" +title);
             await provider.updateMediaHouseDocument();
        setState(() {
                 provider.uploadedDocuments[docType]?['file'] = null;
                 provider.uploadedDocuments[docType]?['fileName'] = '';
                 provider.uploadedDocuments[docType]?['fileSize'] = '';
               });


                Navigator.of(dialogContext).pop(); // Dismiss the dialog
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    var selectedThemeData =
        Provider.of<ThemeProvider>(context, listen: true).getTheme;
    return Consumer<MediaHouseProvider>(
        builder: (context, provider, child) {
      return Scaffold(
        backgroundColor: selectedThemeData.scaffoldBackgroundColor,
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: ResponsiveWidget.isDesktop(context)
                  ? 3
                  : ResponsiveWidget.isTablet(context)
                      ? 3
                      : 1,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.5,
            ),
            itemCount: provider.uploadedDocuments.keys.length,
            itemBuilder: (context, index) {
              String docType = provider.uploadedDocuments.keys.elementAt(index);
              String? file = provider.uploadedDocuments[docType]!['file'];
              print(file);
              return GestureDetector(
                onTap: () =>
                    file == null || file == "" ?  provider.pickImage(docType):viewDocument(docType,provider) ,
                child: Card(
                  color: selectedThemeData.cardColor,
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Container(
                          decoration: BoxDecoration(
                            // color: selectedThemeData.cardColor,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(15),
                              bottomLeft: Radius.circular(15),
                            ),
                          ),
                          child: SingleChildScrollView(
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 4,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        file != null && file.isNotEmpty && file != ""
                                            ? Image.network(
                                          file,
                                          width: 130,
                                          height: 130,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) => Icon(
                                            Icons.broken_image,
                                            color: Colors.red,
                                            size: 40,
                                          ),
                                        )
                                            : Icon(
                                          Icons.upload_file,
                                          color: Colors.grey,
                                          size: 40,
                                        ),

                                        const SizedBox(height: 10),

                                        Text(
                                          docType,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(height: 5),
                                        Text(
                                          provider.uploadedDocuments[docType]![
                                              'description'],
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontSize: 12, color: Colors.grey),
                                        ),

                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      file != null
                          ? Expanded(
                              flex: 1,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: selectedThemeData.primaryColor,
                                  borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(15),
                                    bottomRight: Radius.circular(15),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: InkWell(
                                          onTap: () => removeDocument(context,docType,provider,docType.toString()),
                                          child: Icon(
                                            Icons.delete,

                                          ),
                                        ),
                                      ),

                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: GestureDetector(
                                          onTap: () => removeDocument(context,docType,provider,docType.toString()),
                                          child: Container(
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                                border: Border.all(
                                                  color: Colors.white,
                                                )),
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(
                                                  vertical: 4, horizontal: 8),
                                              child: Text(
                                                'Remove',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),

                                    ],
                                  ),
                                ),
                              ),
                            )
                          : SizedBox(),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      );}
    );
  }
}
