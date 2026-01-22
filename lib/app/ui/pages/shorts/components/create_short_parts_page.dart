import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:universal_html/html.dart' as html;

import '../../../../../data/models/response/content_image_upload_response.dart';
import '../../../../../main.dart';
import '../../../../core/constant/api_constant.dart';
import '../../../../provider/shorts_provider.dart';
import '../../../../provider/themeProvider.dart';
import '../../DisplayTrailer.dart';

class CreateShortPartsDialog extends StatefulWidget {
  final int shortId;
  final int totalParts;

  const CreateShortPartsDialog({
    super.key,
    required this.shortId,
    required this.totalParts,
  });

  @override
  State<CreateShortPartsDialog> createState() =>
      _CreateShortPartsDialogState();
}

class _CreateShortPartsDialogState extends State<CreateShortPartsDialog> {
  int currentPart = 1;

  final titleCtrl = TextEditingController();
  final coinsCtrl = TextEditingController();
  final videoUrlCtrl = TextEditingController();
  String? uploadedImageUrl;
  bool isFreePreview = false;

  /// THUMBNAIL
  io.File? imageFile;
  html.File? webFile;
  Uint8List? previewBytes;
  double uploadProgress = 0;
  String? uploadedVideoName;
  String? videoDuration;
  String? videoSize;


  // ===============================================================
  // GLOBAL SNACK
  // ===============================================================

  void showGlobalSnack(String message) {
    globalMessengerKey.currentState
        ?.showSnackBar(SnackBar(content: Text(message)));
  }

  String _getFileNameFromUrl(String url) {
    return Uri.parse(url).pathSegments.last;
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return "$bytes B";
    if (bytes < 1024 * 1024) return "${(bytes / 1024).toStringAsFixed(1)} KB";
    return "${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB";
  }


  @override
  void initState() {
    super.initState();

    final provider = context.read<ShortProvider>();

    provider.movieUrlController.addListener(() {
      final url = provider.movieUrlController.text;
      if (url.isNotEmpty) {
        setState(() {
          videoUrlCtrl.text = url;
          uploadedVideoName = _getFileNameFromUrl(url);
          videoDuration = "Auto"; // backend / ffmpeg later
          videoSize = "Uploaded";
        });
      }
    });

  }


  // ===============================================================
  // IMAGE PICK + UPLOAD
  // ===============================================================

  Future<void> uploadImage(StateSetter setState) async {
    debugPrint(" uploade image url : ${ApiConstant.uploadContentImg}");
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
        previewBytes = bytes;

        request.files.add(
          http.MultipartFile.fromBytes(
            'thumbnail',
            bytes,
            filename: webFile!.name,
          ),
        );
      } else if (!kIsWeb && imageFile != null) {
        bytes = await imageFile!.readAsBytes();
        previewBytes = bytes;

        request.files.add(
          http.MultipartFile.fromBytes(
            'thumbnail',
            bytes,
            filename: imageFile!.path.split('/').last,
          ),
        );
      } else {
        return;
      }

      setState(() => uploadProgress = 0.3);

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      final decoded = jsonDecode(responseBody);
      final res = ContentImageUploadResponse.fromJson(decoded);

      uploadedImageUrl = res.data?.thumbnailUrl;

      if (uploadedImageUrl == null || uploadedImageUrl!.isEmpty) {
        throw Exception("Thumbnail URL not received");
      }

      debugPrint("✅ Thumbnail uploaded: $uploadedImageUrl");

      setState(() => uploadProgress = 1);
    } catch (e) {
      uploadProgress = 0;
      showGlobalSnack("Thumbnail upload failed");
      debugPrint("❌ Upload error: $e");
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
    final provider = context.watch<ShortProvider>();
       var selectedThemeData =  Provider.of<ThemeProvider>(context, listen: false).getTheme;
    return  WillPopScope(
        onWillPop: () async {
          return await showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text("Discard progress?"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text("Discard"),
                ),
              ],
            ),
          );
        },
        child: Container(
          width: 720,
          alignment: Alignment.center,
          constraints: const BoxConstraints(maxHeight: 640),
          color: selectedThemeData.cardColor,
          child: Column(
            children: [
              _dialogHeader(),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _stepProgressBar(),
                      const SizedBox(height: 20),
                      _darkField("Title", titleCtrl),
                      _videoUploadCard(provider),
                      _thumbnailUploadCard(),
                      _darkField("Coins", coinsCtrl),
                      _freePreviewSwitch(),
                    ],
                  ),
                ),
              ),

              _footerActions(provider),
            ],
          ),
        ),
      );
  }

  // ===============================================================
  // HEADER
  // ===============================================================

  Widget _dialogHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius:
        const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border(
          bottom: BorderSide(color: Colors.red.withOpacity(0.4)),
        ),
      ),
      child: Row(
        children: [
          const Text(
            "Upload Video Content",
            style: TextStyle(
              color: Colors.red,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // STEP BAR
  // ===============================================================

  Widget _stepProgressBar() {
    final progress = currentPart / widget.totalParts;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Part $currentPart Out of ${widget.totalParts}",
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  // ===============================================================
  // FIELDS
  // ===============================================================

  Widget _darkField(String label, TextEditingController ctrl) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: ctrl,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.grey),
          filled: true,
          fillColor: const Color(0xFF141414),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  // ===============================================================
  // UPLOAD CARDS
  // ===============================================================

  Widget _videoUploadCard(ShortProvider provider) {
    final isUploaded =
        provider.movieUrlController.text.isNotEmpty &&
            !provider.isMovieUploading;

    return _uploadCard(
      title: "Movie File",
      uploading: provider.isMovieUploading,
      progress: provider.movieUploadProgress,
      uploadedFileName: isUploaded ? uploadedVideoName : null,
      duration: videoDuration,
      size: videoSize,
      onPreview: () => _previewVideo(provider.movieUrlController.text),
      onRemove: () => _removeUploadedVideo(provider),
      onReplace: () => provider.uploadVideo(false),
      onTap: () => provider.uploadVideo(false),
    );
  }


  Widget _thumbnailUploadCard() {
    return StatefulBuilder(
      builder: (_, setState) {
        return _uploadCard(
          title: "Thumbnail",
          uploading: uploadProgress > 0 && uploadProgress < 1,
          progress: uploadProgress,
          preview: previewBytes,
          onTap: () => pickImage(setState),
        );
      },
    );
  }

  void _removeUploadedVideo(ShortProvider provider) {
    setState(() {
      provider.movieUrlController.clear();
      uploadedVideoName = null;
      videoDuration = null;
      videoSize = null;
    });
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
            child: TrailerPage(trailerUrl: url), // if you already have one
          ),
        ),
      );
    }
  }

  Widget _uploadCard({
    required String title,
    required bool uploading,
    required double progress,
    required VoidCallback onTap,
    Uint8List? preview,
    String? uploadedFileName,
    String? duration,
    String? size,
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
        gradient: LinearGradient(
          colors: [Colors.red.withOpacity(0.25), Colors.red.withOpacity(0.25)],
        ),
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

          const SizedBox(height: 12),

          const SizedBox(height: 12),

          /// ✅ SUCCESS STATE (FILE UPLOADED)
          if (uploadedFileName != null) ...[
            Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    uploadedFileName,
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),

            /// 🎬 META INFO
            Row(
              children: [
                if (duration != null)
                  Text(
                    "⏱ $duration",
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                const SizedBox(width: 12),
                if (size != null)
                  Text(
                    "📦 $size",
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
              ],
            ),

            const SizedBox(height: 12),

            /// ACTION BUTTONS
            Row(
              children: [
                /// 👁 PREVIEW
                TextButton.icon(
                  onPressed: onPreview,
                  icon: const Icon(Icons.visibility, color: Colors.white),
                  label: const Text(
                    "Preview",
                    style: TextStyle(color: Colors.white),
                  ),
                ),

                const Spacer(),

                /// 🔁 REPLACE
                TextButton(
                  onPressed: onReplace,
                  child: const Text(
                    "Replace",
                    style: TextStyle(color: Colors.orange),
                  ),
                ),

                /// ❌ REMOVE
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: onRemove,
                ),
              ],
            ),
          ]

          /// ⏳ UPLOADING
          else if (uploading) ...[
            LinearProgressIndicator(
              value: progress,
              color: Colors.red,
            ),
          ]

          /// ⬆️ DEFAULT UPLOAD BUTTON
          else ...[
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




  // ===============================================================
  // FOOTER
  // ===============================================================

  Widget _freePreviewSwitch() {
    return SwitchListTile(
      value: isFreePreview,
      activeColor: Colors.red,
      title: const Text("Free Preview",
          style: TextStyle(color: Colors.white)),
      onChanged: (v) => setState(() => isFreePreview = v),
    );
  }

  Widget _footerActions(ShortProvider provider) {
    final canSubmit =
        provider.movieUrlController.text.isNotEmpty &&
            !provider.isMovieUploading &&
            !provider.isSubmitting;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.red.withOpacity(0.4)),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: canSubmit ? Colors.red : Colors.grey.shade700,
          ),
          onPressed: canSubmit ? () => _submit(provider) : null,
          child: provider.isSubmitting
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text("Save & Continue"),
        ),
      ),
    );
  }


  // ===============================================================
  // SUBMIT
  // ===============================================================

  Future<void> _submit(ShortProvider provider) async {
    final body = {

      "coins": coinsCtrl.text.trim(),
      "durationSec": 0,
      "isFreePreview": isFreePreview,
      "likes": 0,
      "partNumber": currentPart,
      "shortId": widget.shortId,
      "thumbnail": uploadedImageUrl,
      "title": titleCtrl.text.trim(),
      "videoUrl": videoUrlCtrl.text.trim(),
      "views": 0
    };

    final success = await provider.createShortPart(body);

    if (!mounted) return;

    if (success) {
      if (currentPart == widget.totalParts) {
        Navigator.pop(context, true);
      } else {
        setState(() {
          currentPart++;
          titleCtrl.clear();
          videoUrlCtrl.clear();
          previewBytes = null;
          uploadProgress = 0;
          isFreePreview = false;
        });
      }
    }
  }

  bool get _canSubmit {
    final provider = context.read<ShortProvider>();
    return provider.movieUrlController.text.isNotEmpty &&
        !provider.isMovieUploading &&
        !provider.isSubmitting;
  }

}
