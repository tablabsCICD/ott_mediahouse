import 'dart:convert';
import 'dart:io' as io;
import 'dart:ui' as html hide window;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:media_house/app/provider/series_provider.dart';
import 'package:provider/provider.dart';
import 'package:universal_html/html.dart' as html;
import '../../../../../data/models/response/content_image_upload_response.dart';
import '../../../../../main.dart';
import '../../../../core/constant/api_constant.dart';
import '../../DisplayTrailer.dart';

class AddEpisodeDialog extends StatefulWidget {
  final int seriesId;
  final int seasonId;
  final VoidCallback onSuccess;

  const AddEpisodeDialog({
    super.key,
    required this.seriesId,
    required this.seasonId,
    required this.onSuccess,
  });

  @override
  State<AddEpisodeDialog> createState() => _AddEpisodeDialogState();
}

class _AddEpisodeDialogState extends State<AddEpisodeDialog> {
  final _formKey = GlobalKey<FormState>();

  final titleCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final amountCtrl = TextEditingController();
  final episodeNoCtrl = TextEditingController();

  bool isLoading = false;
  bool isFreePreview = false;

  String? uploadedImageUrl;

  /// THUMBNAIL
  io.File? imageFile;
  html.File? webFile;
  Uint8List? previewBytes;
  double uploadProgress = 0;

  // ===============================================================
  // GLOBAL SNACK
  // ===============================================================

  void showGlobalSnack(String message) {
    globalMessengerKey.currentState
        ?.showSnackBar(SnackBar(content: Text(message)));
  }

  // ===============================================================
  // IMAGE UPLOAD
  // ===============================================================

  Future<void> uploadImage(StateSetter setState) async {
    try {
      final uri = Uri.parse(ApiConstant.uploadContentImg);
      uploadProgress = 0;

      http.MultipartRequest request =
      http.MultipartRequest('POST', uri);

      Uint8List bytes;

      if (kIsWeb && webFile != null) {
        final reader = html.FileReader();
        reader.readAsArrayBuffer(webFile!);
        await reader.onLoad.first;
        bytes = Uint8List.fromList(reader.result as List<int>);
      } else if (!kIsWeb && imageFile != null) {
        bytes = await imageFile!.readAsBytes();
      } else {
        return;
      }

      previewBytes = bytes;

      request.files.add(
        http.MultipartFile.fromBytes(
          'thumbnail',
          bytes,
          filename: 'thumb.jpg',
        ),
      );

      setState(() => uploadProgress = 0.3);

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      final decoded = jsonDecode(responseBody);
      final res = ContentImageUploadResponse.fromJson(decoded);

      uploadedImageUrl = res.data?.thumbnailUrl;

      if (uploadedImageUrl == null || uploadedImageUrl!.isEmpty) {
        throw Exception("Thumbnail URL missing");
      }

      setState(() => uploadProgress = 1);
    } catch (e) {
      uploadProgress = 0;
      showGlobalSnack("Thumbnail upload failed");
      debugPrint("Thumbnail upload error => $e");
    }
  }

  Future<void> pickImage(StateSetter setState) async {
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
        await uploadImage(setState);
        setState(() {});
      }
    }
  }

  // ===============================================================
  // UI
  // ===============================================================

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SeriesProvider>();

    return AlertDialog(
      title: const Text("Add Episode"),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                _field(titleCtrl, "Title"),
                _field(descCtrl, "Description", maxLines: 3),
                _field(amountCtrl, "Episode Amount"),
                _field(
                  episodeNoCtrl,
                  "Episode Number",
                  keyboard: TextInputType.number,
                ),
                _videoUploadCard(provider),
                _thumbnailUploadCard(),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () => _submit(provider),
          child: isLoading
              ? const SizedBox(
            height: 18,
            width: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
              : const Text("Add"),
        ),
      ],
    );
  }

  // ===============================================================
  // SUBMIT
  // ===============================================================

  Future<void> _submit(SeriesProvider provider) async {
    if (!_formKey.currentState!.validate()) return;

    if (uploadedImageUrl == null || uploadedImageUrl!.isEmpty) {
      showGlobalSnack("Please upload thumbnail");
      return;
    }

    if (provider.movieUrlController.text.isEmpty) {
      showGlobalSnack("Please upload episode video");
      return;
    }

    setState(() => isLoading = true);

    /// ✅ EXACT BODY AS SWAGGER
    final body = {
      "amount": amountCtrl.text.trim(),
      "title": titleCtrl.text.trim(),
      "description": descCtrl.text.trim(),
      "episodeNumber": int.parse(episodeNoCtrl.text.trim()),
      "partName": titleCtrl.text.trim(),
      "free": isFreePreview,
      "posterUrl": uploadedImageUrl,
      "videoUrl": provider.movieUrlController.text.trim(),
      "releaseDate": DateTime.now().toIso8601String(),
      "runtime": 0
    };

    final success = await provider.createEpisodeApi(
      body,
      widget.seasonId,
    );

    if (!mounted) return;

    setState(() => isLoading = false);

    if (success) {
      widget.onSuccess();
      Navigator.pop(context, true);
    } else {
      showGlobalSnack("Failed to save episode");
    }
  }

  // ===============================================================
  // VIDEO CARD
  // ===============================================================

  Widget _videoUploadCard(SeriesProvider provider) {
    final isUploaded =
        provider.movieUrlController.text.isNotEmpty &&
            !provider.isMovieUploading;

    return _uploadCard(
      title: "Episode File",
      uploading: provider.isMovieUploading,
      progress: provider.movieUploadProgress,
      uploadedFileName: isUploaded ? "Video Uploaded" : null,
      onPreview: () => _previewVideo(provider.movieUrlController.text),
      onRemove: () => provider.movieUrlController.clear(),
      onReplace: () => provider.uploadVideo(false),
      onTap: () => provider.uploadVideo(false),
    );
  }

  Widget _thumbnailUploadCard() {
    return StatefulBuilder(
      builder: (_, setState) {
        return _uploadCard(
          title: "Episode Poster",
          uploading: uploadProgress > 0 && uploadProgress < 1,
          progress: uploadProgress,
          preview: previewBytes,
          onTap: () => pickImage(setState),
        );
      },
    );
  }

  void _previewVideo(String url) {
    if (kIsWeb) {
      html.window.open(url, "_blank");
    } else {
      showDialog(
        context: context,
        builder: (_) => Dialog(
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: TrailerPage(trailerUrl: url),
          ),
        ),
      );
    }
  }

  // ===============================================================
  // UPLOAD CARD
  // ===============================================================

  Widget _uploadCard({
    required String title,
    required bool uploading,
    required double progress,
    required VoidCallback onTap,
    Uint8List? preview,
    String? uploadedFileName,
    VoidCallback? onPreview,
    VoidCallback? onRemove,
    VoidCallback? onReplace,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),

          if (preview != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.memory(preview, height: 120),
            ),

          if (uploadedFileName != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(uploadedFileName,
                      style: const TextStyle(color: Colors.green)),
                ),
              ],
            ),
          ] else if (uploading) ...[
            const SizedBox(height: 12),
            LinearProgressIndicator(value: progress),
          ] else ...[
            const SizedBox(height: 12),
            GestureDetector(
              onTap: onTap,
              child: Container(
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red),
                ),
                child: const Text(
                  "Upload File",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _field(
      TextEditingController ctrl,
      String label, {
        int maxLines = 1,
        TextInputType keyboard = TextInputType.text,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: ctrl,
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
}
