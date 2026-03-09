import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:media_house/app/provider/shorts_provider.dart';
import 'package:media_house/app/widget/custom_textfield.dart';
import 'package:provider/provider.dart';
import 'package:universal_html/html.dart' as html;

import '../../../../../data/models/response/content_image_upload_response.dart';
import '../../../../../main.dart';
import '../../../../core/constant/api_constant.dart';
import '../../../../core/utils/sharepreferences.dart';

class AddShortMaster {
  static void show(BuildContext rootContext) {
    final theme = Theme.of(rootContext);
    final provider = rootContext.read<ShortProvider>();

    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final creatorCtrl = TextEditingController();
    final categoryCtrl = TextEditingController();
    final partsCtrl = TextEditingController();
    final coinsCtrl = TextEditingController();

    bool isTrending = false;
    bool isSubmitting = false;
    double uploadProgress = 0;

    io.File? imageFile;
    html.File? webFile;
    Uint8List? previewBytes;
    String? uploadedImageUrl;

    // ---------- GLOBAL SNACK ----------
    void showGlobalSnack(String message) {
      final messenger = globalMessengerKey.currentState;
      if (messenger == null) return;

      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(message),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
    }

    // ---------- VALIDATION ----------
    String? validate() {
      if (uploadedImageUrl == null) return "Poster image required";
      if (titleCtrl.text.trim().length < 3) return "Title too short";
      if (descCtrl.text.trim().length < 10) return "Description too short";
      if (int.tryParse(partsCtrl.text) == null) return "Invalid parts";
      if (int.tryParse(coinsCtrl.text) == null) return "Invalid coins";
      return null;
    }

    // ---------- UPLOAD IMAGE ----------
    Future<void> uploadImage(StateSetter setState) async {
      final uri = Uri.parse(ApiConstant.uploadContentImg);
      uploadProgress = 0;

      try {
        if (kIsWeb && webFile != null) {
          final reader = html.FileReader();
          reader.readAsArrayBuffer(webFile!);
          await reader.onLoad.first;

          final bytes = Uint8List.fromList(reader.result as List<int>);
          previewBytes = bytes;

          final request = http.MultipartRequest('POST', uri)
            ..files.add(
              http.MultipartFile.fromBytes(
                'thumbnail',
                bytes,
                filename: webFile!.name,
              ),
            );

          final response = await request.send();
          final body = await response.stream.bytesToString();
          final res = ContentImageUploadResponse.fromJson(jsonDecode(body));
          uploadedImageUrl = res.data?.thumbnailUrl;
        } else if (!kIsWeb && imageFile != null) {
          final total = await imageFile!.length();
          int sent = 0;

          final stream = http.ByteStream(
            imageFile!.openRead().transform(
              StreamTransformer.fromHandlers(
                handleData: (data, sink) {
                  sent += data.length;
                  setState(() => uploadProgress = sent / total);
                  sink.add(data);
                },
              ),
            ),
          );

          final request = http.MultipartRequest('POST', uri)
            ..files.add(
              http.MultipartFile(
                'thumbnail',
                stream,
                total,
                filename: imageFile!.path.split('/').last,
              ),
            );

          final response = await request.send();
          final body = await response.stream.bytesToString();
          uploadedImageUrl = jsonDecode(body)['data'];
        }
      } catch (_) {
        showGlobalSnack("Image upload failed");
      }

      setState(() => uploadProgress = 1);
    }

    // ---------- PICK IMAGE ----------
    Future<void> pickImage(StateSetter setState) async {
      try {
        if (kIsWeb) {
          final input = html.FileUploadInputElement()..accept = 'image/*';
          input.click();
          input.onChange.listen((_) async {
            webFile = input.files!.first;
            await uploadImage(setState);
            setState(() {});
          });
        } else {
          final picker = ImagePicker();
          final file = await picker.pickImage(source: ImageSource.gallery);
          if (file != null) {
            imageFile = io.File(file.path);
            previewBytes = await file.readAsBytes();
            await uploadImage(setState);
            setState(() {});
          }
        }
      } catch (_) {
        showGlobalSnack("Failed to pick image");
      }
    }

    // ---------- UI ----------
    final screenWidth = MediaQuery.of(rootContext).size.width;

    showDialog(
      context: rootContext,
      barrierDismissible: false,
      builder: (_) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: StatefulBuilder(
            builder: (dialogContext, setState) {
              return Container(
                width: screenWidth > 600 ? 420 : screenWidth * 0.9,
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      /// HEADER WITH CLOSE ICON
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Add New Short",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: theme.primaryColor,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: isSubmitting
                                ? null
                                : () => Navigator.pop(dialogContext),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      /// IMAGE PICKER
                      GestureDetector(
                        onTap: isSubmitting ? null : () => pickImage(setState),
                        child: Container(
                          height: 180,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: theme.canvasColor),
                            image: previewBytes != null
                                ? DecorationImage(
                                    image: MemoryImage(previewBytes!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: previewBytes == null
                              ? const Center(child: Text("Upload Poster"))
                              : null,
                        ),
                      ),

                      if (uploadProgress > 0 && uploadProgress < 1)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: LinearProgressIndicator(
                            value: uploadProgress,
                            color: theme.primaryColor,
                          ),
                        ),

                      const SizedBox(height: 15),

                      CustomTextField(
                          controller: titleCtrl,
                          hintText: "Title",
                          textInputType: TextInputType.text),
                      CustomTextField(
                          controller: descCtrl,
                          hintText: "Description",
                          maxLine: 3,
                          textInputType: TextInputType.text),
                      CustomTextField(
                          controller: creatorCtrl,
                          hintText: "Creator",
                          textInputType: TextInputType.text),
                      CustomTextField(
                          controller: categoryCtrl,
                          hintText: "Category",
                          textInputType: TextInputType.text),

                      Row(
                        children: [
                          Expanded(
                              child: CustomTextField(
                                  controller: partsCtrl,
                                  hintText: "Parts",
                                  textInputType: TextInputType.text)),
                          const SizedBox(width: 10),
                          Expanded(
                              child: CustomTextField(
                                  controller: coinsCtrl,
                                  hintText: "Coins",
                                  textInputType: TextInputType.text)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Trending",
                            style: TextStyle(color: theme.canvasColor),
                          ),
                          Switch(
                            activeThumbColor: Colors.white,
                            activeTrackColor: theme.primaryColor,
                            value: isTrending,
                            onChanged: isSubmitting
                                ? null
                                : (v) => setState(() => isTrending = v),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      /// SUBMIT BUTTON WITH LOADER
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primaryColor,
                          minimumSize: const Size(double.infinity, 48),
                        ),
                        onPressed: isSubmitting
                            ? null
                            : () async {
                                final error = validate();
                                if (error != null) {
                                  showGlobalSnack(error);
                                  return;
                                }

                                setState(() => isSubmitting = true);

                                final localSharePreferences =
                                    LocalSharePreferences();
                                final mediaHouse =
                                    await localSharePreferences.getMediaHouse();

                                if (mediaHouse == null) {
                                  setState(() => isSubmitting = false);
                                  showGlobalSnack(
                                      "Sorry, Production House is not available.");
                                  return;
                                }

                                final body = {
                                  "title": titleCtrl.text.trim(),
                                  "description": descCtrl.text.trim(),
                                  "creatorName": creatorCtrl.text.trim(),
                                  "category": categoryCtrl.text.trim(),
                                  "totalParts": int.parse(partsCtrl.text),
                                  "coinsPerPart": int.parse(coinsCtrl.text),
                                  "isTrending": isTrending,
                                  "mediaHouseId": mediaHouse.id,
                                  "posterUrl": uploadedImageUrl,
                                  "likeCount": 0,
                                  "viewCount": 0,
                                };

                                final success =
                                    await provider.addShortMaster(body);

                                setState(() => isSubmitting = false);

                                if (success) {
                                  if (Navigator.of(rootContext,
                                          rootNavigator: true)
                                      .canPop()) {
                                    Navigator.of(rootContext,
                                            rootNavigator: true)
                                        .pop();
                                  }

                                  Future.microtask(() {
                                    showGlobalSnack("Short added successfully");
                                  });
                                }
                              },
                        child: isSubmitting
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                "Submit",
                                style: TextStyle(color: Colors.white),
                              ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
