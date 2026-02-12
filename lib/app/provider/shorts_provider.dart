import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:media_house/app/core/constant/api_constant.dart';
import 'package:media_house/data/models/shorts.dart';
import 'package:universal_html/html.dart' as html;

import '../../data/models/response/short_detail_response.dart';
import '../../data/models/response/video_upload_response.dart';
import '../core/network/api_helper.dart';
import '../core/utils/sharepreferences.dart';

class ShortProvider extends ChangeNotifier {
  List<ShortModel> shorts = [];
  ShortDetailResponse? shortDetail;
  bool isLoading = false;
  bool _isUploading = false;
  bool _isMovieUploading = false;
  double movieUploadProgress = 0.0;

  bool get isMovieUploading => _isMovieUploading;

  final TextEditingController movieUrlController = TextEditingController();

  Future<void> uploadVideoWeb(bool isTrailer) async {
    html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
    uploadInput.accept = 'video/*';
    uploadInput.click();

    uploadInput.onChange.listen((event) {
      final file = uploadInput.files?.first;
      if (file == null) return;

      final xhr = html.HttpRequest();
      final formData = html.FormData();

      formData.appendBlob('video', file, file.name);

      xhr.upload.onProgress.listen((e) {
        if (e.lengthComputable == true &&
            e.loaded != null &&
            e.total != null &&
            e.total! > 0) {
          final progress = e.loaded! / e.total!;

            movieUploadProgress = progress;
          notifyListeners();
        }
      });

      xhr.onLoad.listen((_) {
        if (xhr.status == 200) {
          final response = json.decode(xhr.responseText!);
          VideoUploadResponse contentImageUploadResponse = VideoUploadResponse.fromJson(response);
          final encryptedUrl = contentImageUploadResponse.data!.videoUrl;

            print(encryptedUrl);

            movieUrlController.text = encryptedUrl!;
          //  movieFileName = file.name;
            movieUploadProgress = 1.0;
            _isMovieUploading = false;
          notifyListeners();
        }
      });

      xhr.onError.listen((_) {

          movieUploadProgress = 0.0;
          _isMovieUploading = false;

        notifyListeners();
      });

      xhr.open('POST', ApiConstant.uploadVideo);
      xhr.send(formData);


        _isMovieUploading = true;

      notifyListeners();
    });
  }

  Future<void> uploadVideo(bool isTrailer) async {
    final Uri uploadUri = Uri.parse(ApiConstant.uploadVideo);

    // Reset progress at start and set uploading status

      movieUploadProgress = 0.0;
      _isMovieUploading = true;
    _isUploading = true;
    notifyListeners();

    try {
      if (kIsWeb) {
        uploadVideoWeb(isTrailer);
        return;
      } else {
        // Android/iOS implementation with proper progress tracking
        final picker = ImagePicker();
        final pickedFile = await picker.pickVideo(source: ImageSource.gallery);

        if (pickedFile != null) {
          final File file = File(pickedFile.path);
          final totalBytes = await file.length();

          print(
              "Starting upload for ${isTrailer ? 'trailer' : 'movie'}, file size: $totalBytes bytes");

          // Create a stream controller to track progress
          final StreamController<List<int>> streamController =
          StreamController<List<int>>();
          int bytesSent = 0;

          // Create the progress tracking stream
          final progressStream = file.openRead().transform(
            StreamTransformer.fromHandlers(
              handleData: (List<int> data, EventSink<List<int>> sink) {
                bytesSent += data.length;
                final progress = bytesSent / totalBytes;

                // Update progress

                  movieUploadProgress = progress;

                print(
                    "Upload progress: ${(progress * 100).toStringAsFixed(1)}%");
                notifyListeners();

                sink.add(data);
              },
              handleError: (error, stackTrace, sink) {
                print("Stream error: $error");
                sink.addError(error, stackTrace);
              },
              handleDone: (sink) {
                print("Stream done");
                sink.close();
              },
            ),
          );

          // Create the multipart request
          final request = http.MultipartRequest('POST', uploadUri);

          // Add the file with progress tracking
          request.files.add(http.MultipartFile(
            'video',
            progressStream,
            totalBytes,
            filename: pickedFile.name,
          ));

          print("Sending request...");
          final response = await request.send();

          if (response.statusCode == 200) {
            final responseBody = await response.stream.bytesToString();
            final responseJson = json.decode(responseBody);
            VideoUploadResponse contentImageUploadResponse = VideoUploadResponse.fromJson(responseJson);
            final encryptedUrl = contentImageUploadResponse.data!.videoUrl;


            movieUrlController.text = encryptedUrl!;
            movieUploadProgress = 1.0;

            print("Video uploaded successfully: $encryptedUrl");
          } else {
            print("Video upload failed with status: ${response.statusCode}");
            final responseBody = await response.stream.bytesToString();
            print("Error response: $responseBody");

            movieUploadProgress = 0.0;

          }
          _isMovieUploading = false;

          _isUploading = false;
          notifyListeners();
        } else {
          print("No video selected");
          // Reset progress if no video selected
          movieUploadProgress = 0.0;

          notifyListeners();
        }
      }
    } catch (e) {
      print('Error uploading video: $e');
      // Reset progress on error
      movieUploadProgress = 0.0;

      notifyListeners();
    } finally {
      // ❌ DO NOTHING FOR WEB
      if (!kIsWeb) {

          _isMovieUploading = false;
        _isUploading = false;
        notifyListeners();
      }
    }

  }


  Future<void> fetchShorts() async {
    try {
      isLoading = true;
      notifyListeners();
      final localSharePreferences = LocalSharePreferences();
      final mediaHouse =
      await localSharePreferences.getMediaHouse();
      var url = ApiConstant.shortsMaster(mediaHouse!.id);
      ApiHelper apiHelper = ApiHelper();
      var response = await apiHelper.getApi(url);
      final data = jsonDecode(response.body);
      ShortMasterResponse shortMasterResponse = ShortMasterResponse.fromJson(data);
      shorts = shortMasterResponse.data!.shorts!;
    } catch (e) {
      print("Shorts Fetch Error → $e");
    }

    isLoading = false;
    notifyListeners();
  }

  Future<bool> addShortMaster(Map<String, dynamic> body) async {
    try {
      isLoading = true;
      notifyListeners();

      final url = ApiConstant.addShortMaster;

      ApiHelper apiHelper = ApiHelper();
      var response = await apiHelper.postApiWithBody(url,body);


      debugPrint("Request Body → ${jsonEncode(body)}");
      debugPrint("Response Code → ${response.statusCode}");
      debugPrint("Response Body → ${response.body}");

      final Map<String, dynamic> data = jsonDecode(response.body);

      /// ✅ SUCCESS CHECK (THIS IS THE KEY FIX)
      if (data["success"] == true) {
        if (data["data"] != null) {
         ShortModel shortModel = ShortModel.fromJson(data["data"]);
        }

        /// Refresh list
        await fetchShorts();

        isLoading = false;
        notifyListeners();
        return true;
      } else {
        debugPrint("Add Short Failed → ${data["message"]}");
      }
    } catch (e, s) {
      debugPrint("Add Short Exception → $e");
      debugPrintStack(stackTrace: s);
    }

    isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> deleteShortMaster({
    required int shortId,
    void Function(String message)? onMessage,
  }) async {
    try {
      isLoading = true;
      notifyListeners();

      final url =
        "${ApiConstant.deleteShortMaster}/$shortId";

      debugPrint("DELETE SHORT → $url");

      ApiHelper apiHelper = ApiHelper();
      var response = await apiHelper.deleteApi(url);


      debugPrint("Delete Response Code → ${response.statusCode}");
      debugPrint("Delete Response Body → ${response.body}");

      final Map<String, dynamic> data = jsonDecode(response.body);

      /// ✅ SUCCESS
      if (data["success"] == true) {
        onMessage?.call(data["message"] ?? "Short deleted successfully");

        /// 🔄 Refresh list safely
        await fetchShorts();

        isLoading = false;
        notifyListeners();
        return true;
      }

      /// ❌ FAILURE (API responded but success=false)
      onMessage?.call(
        data["message"] ?? "Failed to delete short",
      );
    } catch (e, s) {
      debugPrint("Delete Short Exception → $e");
      debugPrintStack(stackTrace: s);

      onMessage?.call("Something went wrong while deleting short");
    }

    isLoading = false;
    notifyListeners();
    return false;
  }

  /*Future<bool> updateShortMaster({
    required int shortId,
    required Map<String, dynamic> body,
    void Function(String message)? onMessage,
  }) async {
    try {
      isLoading = true;
      notifyListeners();

      final url = Uri.parse(
        "${ApiConstant.updateShortMaster}/$shortId",
      );

      debugPrint("UPDATE SHORT → $url");
      debugPrint("BODY → ${jsonEncode(body)}");

      final response = await http.put(
        url,
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(body),
      );

      debugPrint("Response Code → ${response.statusCode}");
      debugPrint("Response Body → ${response.body}");

      final Map<String, dynamic> data = jsonDecode(response.body);

      /// ✅ SUCCESS
      if (data["success"] == true) {
        onMessage?.call(data["message"] ?? "Short updated successfully");

        /// Update local model if backend returns updated short
        if (data["data"] != null) {
          shortDetail = ShortDetailResponse.fromJson(data["data"]);
        }

        /// 🔄 Refresh list
        await fetchShorts();

        isLoading = false;
        notifyListeners();
        return true;
      }

      /// ❌ API returned success=false
      onMessage?.call(
        data["message"] ?? "Failed to update short",
      );
    } catch (e, s) {
      debugPrint("Update Short Exception → $e");
      debugPrintStack(stackTrace: s);

      onMessage?.call("Something went wrong while updating short");
    }

    isLoading = false;
    notifyListeners();
    return false;
  }*/

  /// Optimistic remove
  void removeShortLocally(int shortId) {
    shorts.removeWhere((s) => s.id == shortId);
    notifyListeners();
  }

  /// Undo restore
  void restoreShort(ShortModel short, int index) {
    shorts.insert(index, short);
    notifyListeners();
  }


  bool isSubmitting = false;

  Future<bool> createShortPart(Map<String, dynamic> body) async {
    try {
      isSubmitting = true;
      notifyListeners();

      String apiUrl =  ApiConstant.createShortPart;
      print(apiUrl);
      ApiHelper apiHelper = ApiHelper();
      var response = await apiHelper.postApiWithBody(apiUrl,body);
      print(response.body);
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint("Create Short Part Error: $e");
      return false;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  bool isDetailLoading = false;
  String? detailError;

  Future<void> fetchShortDetail({
    required int shortId,
    required int userId,
  }) async {
    try {
      isDetailLoading = true;
      detailError = null;
      notifyListeners();

      var url = ApiConstant.shortsDetails(shortId, userId);
      ApiHelper apiHelper = ApiHelper();
      var response = await apiHelper.getApi(url);

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final res = ShortDetailResponse.fromJson(decoded);
        shortDetail = res;
      } else {
        detailError = "Failed to load short details";
      }
    } catch (e) {
      detailError = e.toString();
    } finally {
      isDetailLoading = false;
      notifyListeners();
    }
  }

  bool isPartDeleting = false;
  Future<bool> deleteShortPart({
    required String partId,
  }) async {
    try {
      isPartDeleting = true;
      notifyListeners();

      final url =
        "${ApiConstant.deletePart(partId)}";
      ApiHelper apiHelper = ApiHelper();
      var response = await apiHelper.deleteApi(url);
      debugPrint(response.body);
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        if (decoded['success'] == true) {
          return true;
        } else {
          debugPrint("❌ Delete part failed: ${decoded['message']}");
          return false;
        }
      } else {
        debugPrint("❌ Delete part HTTP error: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      debugPrint("❌ Delete part exception: $e");
      return false;
    } finally {
      isPartDeleting = false;
      notifyListeners();
    }
  }

  Future<bool> updateShortPart(Map<String, dynamic> body,String partId) async {
    try {
      isSubmitting = true;
      notifyListeners();

      String url = "${ApiConstant.baseUrl}api/short-parts/$partId";
      ApiHelper apiHelper = ApiHelper();
      var response = await apiHelper.postApiWithBody(url,body);
      debugPrint(jsonEncode(body));
      debugPrint(response.body);

      return response.statusCode == 200;
    } catch (e) {
      debugPrint("❌ Update part error: $e");
      return false;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  Future<bool> updateShortMaster(Map<String, dynamic> body,String shortId) async {
    try {
      isSubmitting = true;
      notifyListeners();
      String url = "${ApiConstant.baseUrl}api/shortsMaster/$shortId";
      ApiHelper apiHelper = ApiHelper();
      var response = await apiHelper.postApiWithBody(url,body);
      debugPrint(jsonEncode(body));
      debugPrint(response.body);

      return response.statusCode == 200;
    } catch (e) {
      debugPrint("❌ Update part error: $e");
      return false;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }
}
