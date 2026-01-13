import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:media_house/app/provider/shorts_provider.dart';
import 'package:media_house/app/widget/custom_textfield.dart';
import 'package:provider/provider.dart';

class AddShortMaster {
  static void show(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.read<ShortProvider>();

    // Controllers
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final creatorCtrl = TextEditingController();
    final categoryCtrl = TextEditingController();
    final partsCtrl = TextEditingController();
    final coinsCtrl = TextEditingController();

    bool isTrending = false;
    Uint8List? pickedImageBytes;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return Dialog(
          insetPadding: const EdgeInsets.all(20),
          backgroundColor: theme.scaffoldBackgroundColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: StatefulBuilder(
            builder: (context, setState) {
              return Container(
                padding: const EdgeInsets.all(20),
                width: 500,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // ---------------- HEADER ----------------
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Add New Short",
                            style: TextStyle(
                              color: theme.canvasColor,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: Icon(Icons.close, color: theme.canvasColor),
                          )
                        ],
                      ),

                      const SizedBox(height: 20),

                      // ---------------- IMAGE PICKER ----------------
                      GestureDetector(
                        onTap: () async {
                          final picker = ImagePicker();
                          final file = await picker.pickImage(
                            source: ImageSource.gallery,
                          );

                          if (file != null) {
                            pickedImageBytes = await file.readAsBytes();
                            setState(() {});
                          }
                        },
                        child: Container(
                          height: 180,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: theme.cardColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: theme.canvasColor),
                            image: pickedImageBytes != null
                                ? DecorationImage(
                                    image: MemoryImage(pickedImageBytes!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: pickedImageBytes == null
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.upload,
                                        color: theme.canvasColor, size: 40),
                                    SizedBox(height: 10),
                                    Text(
                                      "Upload Poster",
                                      style:
                                          TextStyle(color: theme.canvasColor),
                                    ),
                                  ],
                                )
                              : null,
                        ),
                      ),

                      const SizedBox(height: 15),

                      // ---------------- TEXT FIELDS ----------------
                      CustomTextField(
                        controller: titleCtrl,
                        hintText: "Title",
                        textInputType: TextInputType.text,
                      ),
                      const SizedBox(height: 10),

                      CustomTextField(
                        controller: descCtrl,
                        hintText: "Description",
                        textInputType: TextInputType.multiline,
                        maxLine: 3,
                      ),
                      const SizedBox(height: 10),

                      CustomTextField(
                        controller: creatorCtrl,
                        hintText: "Creator Name",
                        textInputType: TextInputType.text,
                      ),
                      const SizedBox(height: 10),

                      CustomTextField(
                        controller: categoryCtrl,
                        hintText: "Category",
                        textInputType: TextInputType.text,
                      ),
                      const SizedBox(height: 10),

                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              controller: partsCtrl,
                              hintText: "Total Parts",
                              textInputType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: CustomTextField(
                              controller: coinsCtrl,
                              hintText: "Coins per Part",
                              textInputType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 15),

                      // ---------------- TOGGLE ----------------
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Trending",
                              style: TextStyle(color: theme.canvasColor)),
                          Switch(
                            value: isTrending,
                            onChanged: (v) => setState(() => isTrending = v),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // ---------------- SUBMIT BUTTON ----------------
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primaryColor,
                          minimumSize: const Size(double.infinity, 48),
                        ),
                        onPressed: () async {
                          if (titleCtrl.text.isEmpty ||
                              descCtrl.text.isEmpty ||
                              pickedImageBytes == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("Please fill all fields")),
                            );
                            return;
                          }

                          final posterBase64 = base64Encode(pickedImageBytes!);

                          final body = {
                            "category": categoryCtrl.text,
                            "coinsPerPart": int.tryParse(coinsCtrl.text) ?? 0,
                            "creatorName": creatorCtrl.text,
                            "description": descCtrl.text,
                            "id": 0,
                            "isTrending": isTrending,
                            "likeCount": 0,
                            "posterUrl": posterBase64,
                            "title": titleCtrl.text,
                            "totalParts": int.tryParse(partsCtrl.text) ?? 1,
                            "viewCount": 0,
                          };

                          final success = await provider.addShortMaster(body);

                          if (success) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("Short added successfully")),
                            );
                          }
                        },
                        child: const Text(
                          "Submit",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),

                      const SizedBox(height: 20),
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
