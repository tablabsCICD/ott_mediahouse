import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:io' as io;
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:media_house/main.dart';
import 'package:provider/provider.dart';
import 'package:universal_html/html.dart' as html;

import '../../../../../data/models/response/content_image_upload_response.dart';
import '../../../../core/constant/api_constant.dart';
import '../../../../provider/themeProvider.dart';

class AddSeasonDialog extends StatefulWidget {
  final int seriesId;
  final VoidCallback onSuccess;

  const AddSeasonDialog({
    super.key,
    required this.seriesId,
    required this.onSuccess,
  });

  @override
  State<AddSeasonDialog> createState() => _AddSeasonDialogState();
}

class _AddSeasonDialogState extends State<AddSeasonDialog> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController titleCtrl = TextEditingController();
  final TextEditingController descCtrl = TextEditingController();
  final TextEditingController seasonNoCtrl = TextEditingController();
  final amountCtrl = TextEditingController();
  DateTime selectedDate = DateTime.now();

  XFile? pickedImage;
  Uint8List? webImageBytes;
  String uploadedPosterUrl = '';

  bool isLoading = false;
  bool isUploading = false;
  bool isSubmitting = false;

  io.File? imageFile;
  html.File? webFile;
  Uint8List? previewBytes;
  String? uploadedImageUrl;
  double uploadProgress = 0;

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

  // ------------------ Submit ------------------

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;



    setState(() => isLoading = true);

    try {
      final url =
          '${ApiConstant.baseUrl}series/${widget.seriesId}/season/add';
      debugPrint(url);
      final body = {
        "amount": amountCtrl.text.trim(),
        "title": titleCtrl.text.trim(),
        "description": descCtrl.text.trim(),
        "posterUrl": uploadedImageUrl,
        "releaseDate": selectedDate.toIso8601String(),
        "seasonNumber": int.parse(seasonNoCtrl.text.trim()),
      };
      debugPrint(jsonEncode(body));
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        widget.onSuccess();
        if (mounted) Navigator.of(context).pop();

        Future.microtask(() {
          debugPrint("Season added successfully");
        });
      } else {
        throw Exception(response.body);
      }
    } catch (e) {
      debugPrint("Failed: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  // ------------------ Snackbar Safe Handler ------------------



  // ------------------ UI ------------------

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).getTheme;

    return AlertDialog(
      backgroundColor: theme.cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        "Add New Season",
        style: TextStyle(
          color: theme.primaryColor,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
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
                    child: LinearProgressIndicator(value: uploadProgress),
                  ),

                const SizedBox(height: 15),
                _field(titleCtrl, "Season Title"),
                _field(descCtrl, "Description", maxLines: 3),
                _field(amountCtrl, "Season Price", maxLines: 3),
                _field(
                  seasonNoCtrl,
                  "Season Number",
                  keyboard: TextInputType.number,
                ),
                const SizedBox(height: 12),
                _datePicker(theme),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: isLoading ? null : () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: isLoading ? null : _submit,
          child: isLoading
              ? const SizedBox(
            height: 18,
            width: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
              : const Text("Add Season"),
        ),
      ],
    );
  }

  Widget _imagePicker(ThemeData theme) {
    return GestureDetector(
      onTap: (){
        isUploading ? null : pickImage(setState);
      },
      child: Container(
        height: 170,
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white24),
          borderRadius: BorderRadius.circular(12),
          color: theme.scaffoldBackgroundColor.withOpacity(0.4),
        ),
        child: isUploading
            ? const Center(child: CircularProgressIndicator())
            : uploadedPosterUrl.isNotEmpty
            ? ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            uploadedPosterUrl,
            fit: BoxFit.cover,
          ),
        )
            : const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_upload, size: 40),
            SizedBox(height: 8),
            Text("Upload Season Poster"),
          ],
        ),
      ),
    );
  }



  Widget _datePicker(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: Text(
            "Release Date: ${DateFormat('dd MMM yyyy').format(selectedDate)}",
            style: TextStyle(color: theme.primaryColor),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.date_range),
          onPressed: _pickDate,
        ),
      ],
    );
  }

  Widget _field(
      TextEditingController controller,
      String label, {
        int maxLines = 1,
        TextInputType keyboard = TextInputType.text,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboard,
        validator: (v) => v == null || v.isEmpty ? 'Required' : null,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }
}
