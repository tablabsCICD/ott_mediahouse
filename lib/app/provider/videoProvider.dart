import 'dart:async';
import 'dart:io';
import 'dart:io' as io;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:media_house/data/models/request/save_series_request.dart';
import 'package:media_house/data/models/response/content_image_upload_response.dart';
import 'package:media_house/data/models/response/video_upload_response.dart';
//import 'dart:html' as html;
import 'package:universal_html/html.dart' as html;

import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:media_house/app/widget/get_date_time.dart';
import 'package:media_house/data/models/request/moviePrcentageRequest.dart';
import 'package:media_house/data/models/response/addVideoResponse.dart';
import 'package:media_house/data/models/response/getAllMediaHouseResponse.dart';
import 'package:media_house/data/models/response/graphResponse.dart';
import 'package:media_house/data/models/response/searchResponse.dart';
import 'dart:convert';
import '../../data/models/request/content_request.dart';
import '../../data/models/response/getAllUserResponse.dart';
import '../../data/models/response/getAllVideoResponse.dart';
import '../../data/models/response/getContentResponse.dart';
import '../../domain/entities/content.dart';
import '../../domain/entities/mediaHouse.dart';
import '../../domain/entities/user.dart';
import '../core/constant/api_constant.dart';
import '../core/network/api_helper.dart';
import '../core/utils/sharepreferences.dart';
import '../widget/show_toast.dart';
import 'dart:io';
import 'dart:typed_data';

class VideoProvider extends ChangeNotifier {
  VideoProvider() : super() {
    searchContentController.addListener(filterContent);
  }

  TextEditingController searchContentController = TextEditingController();
  final TextEditingController videoController = TextEditingController();
  final TextEditingController ageRatingController = TextEditingController();
  final TextEditingController statusController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController movieUrlController = TextEditingController();
  final TextEditingController trailerUrlController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController releaseDateController = TextEditingController();
  final TextEditingController rentlDurationController = TextEditingController();
  final TextEditingController censorCertificateController =
      TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController reasonController = TextEditingController();
  final TextEditingController typeController = TextEditingController();
  final TextEditingController runTimeController = TextEditingController();
  final TextEditingController poster1Controller = TextEditingController();
  final TextEditingController poster2Controller = TextEditingController();
  final TextEditingController poster3Controller = TextEditingController();
  final TextEditingController castController = TextEditingController();
  final TextEditingController directorController = TextEditingController();
  final TextEditingController rentalDurationController =
      TextEditingController();

  bool isEnbale = false;
  List<Content> _contentList = [];
  List<Content> _filteredContentList = [];
  Content? _content = Content();
  Content _selectedContent = Content();

  List<Content> get contentList => _contentList;
  List<Content> get filteredContentList => _filteredContentList;
  Content? get content => _content;
  Content get selectedContent => _selectedContent;

  List<String> _selectedItems = [];
  List<String> get selectedItems => _selectedItems;
  List<String> _selectedGeners = [];
  List<String> get selectedGeners => _selectedGeners;
  List<String> _selectedAudioFormat = [];
  List<String> get selectedAudioFormat => _selectedAudioFormat;
  List<LanguageList> _selectedLanguages = [];
  List<LanguageList> get selectedLanguages => _selectedLanguages;
  List<String> _selectedSubLanguages = [];
  List<String> get selectedSubLanguages => _selectedSubLanguages;
  List<String> _castList = [];
  List<String> get castList => _castList;
  List<String> _directorList = [];
  List<String> get directorList => _directorList;

  // Progress tracking for all upload types
  double trailerUploadProgress = 0.0;
  double movieUploadProgress = 0.0;
  double censorUploadProgress = 0.0;
  double poster1UploadProgress = 0.0;
  double poster2UploadProgress = 0.0;
  double poster3UploadProgress = 0.0;

  // Individual uploading status for each file type
  bool _isTrailerUploading = false;
  bool _isMovieUploading = false;
  bool _isCensorUploading = false;
  bool _isPoster1Uploading = false;
  bool _isPoster2Uploading = false;
  bool _isPoster3Uploading = false;

  // Getters for uploading status
  bool get isTrailerUploading => _isTrailerUploading;
  bool get isMovieUploading => _isMovieUploading;
  bool get isCensorUploading => _isCensorUploading;
  bool get isPoster1Uploading => _isPoster1Uploading;
  bool get isPoster2Uploading => _isPoster2Uploading;
  bool get isPoster3Uploading => _isPoster3Uploading;

  // Dynamic audio language controllers and lists
  final Map<String, TextEditingController> audioControllers = {};
  final List<String> _audioLanguages = [];
  List<String> get audioLanguages =>
      _audioLanguages; // Public getter for the private list

  // Specific upload statuses and progress for dynamic audio files
  final Map<String, double> _audioUploadProgress = {};
  final Map<String, bool> _isAudioUploading = {};

  // Helper method to get uploading status by label
  bool getUploadStatus(String label) {
    switch (label) {
      case "Trailer File":
        return trailerUrlController.text.isNotEmpty;
      case "Movie File":
        return movieUrlController.text.isNotEmpty;
      case "Censor Certificate":
        return censorCertificateController.text.isNotEmpty;
      case "Poster 1":
        return poster1Controller.text.isNotEmpty;
      case "Poster 2":
        return poster2Controller.text.isNotEmpty;
      case "Poster 3":
        return poster3Controller.text.isNotEmpty;
      default:
        if (label.endsWith(" Audio")) {
          final language = label.replaceAll(" Audio", "");
          return audioControllers[language]?.text.isNotEmpty ?? false;
        }
        return false;
    }
  }

  // Merged helper method to get uploading status by label for all file types
  bool getUploadingStatusByLabel(String label) {
    switch (label) {
      case "Censor Certificate":
        return _isCensorUploading;
      case "Poster 1":
        return _isPoster1Uploading;
      case "Poster 2":
        return _isPoster2Uploading;
      case "Poster 3":
        return _isPoster3Uploading;
      default:
        if (label.endsWith(" Audio")) {
          final language = label.replaceAll(" Audio", "");
          return _isAudioUploading[language] ?? false;
        }
        return false;
    }
  }


  // Merged helper method to get upload progress by label for all file types
  double getProgressByLabel(String label) {
    if (label == "Trailer File") {
      return trailerUploadProgress;
    } else if (label == "Movie File") {
      return movieUploadProgress;
    } else if (label == "Censor Certificate" || label.startsWith("Poster")) {
      // For images, we assume 1.0 progress if uploaded, otherwise 0.0,
      // as granular progress for images is not currently tracked.
      return getUploadStatus(label) ? 1.0 : 0.0;
    } else if (label.endsWith(" Audio")) {
      final language = label.replaceAll(" Audio", "");
      return _audioUploadProgress[language] ?? 0.0;
    }
    return 0.0;
  }

  // Helper method to set uploading status by label
  void _setUploadingStatus(String label, bool status) {
    switch (label) {
      case "Trailer File":
        _isTrailerUploading = status;
        break;
      case "Movie File":
        _isMovieUploading = status;
        break;
      case "Censor Certificate":
        _isCensorUploading = status;
        break;
      case "Poster 1":
        _isPoster1Uploading = status;
        break;
      case "Poster 2":
        _isPoster2Uploading = status;
        break;
      case "Poster 3":
        _isPoster3Uploading = status;
        break;
    }
  }

  // Helper method to set progress by label
  void _setProgressByLabel(String label, double progress) {
    switch (label) {
      case "Trailer File":
        trailerUploadProgress = progress;
        break;
      case "Movie File":
        movieUploadProgress = progress;
        break;
      case "Censor Certificate":
        censorUploadProgress = progress;
        break;
      case "Poster 1":
        poster1UploadProgress = progress;
        break;
      case "Poster 2":
        poster2UploadProgress = progress;
        break;
      case "Poster 3":
        poster3UploadProgress = progress;
        break;
    }
  }

  void addValuesToList(String label) {
    if (label == "Cast") {
      if (castController.text.trim().isNotEmpty) {
        _castList.addAll(
          castController.text
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty),
        );
        castController.clear();
      }
    } else if (label == "Director") {
      if (directorController.text.trim().isNotEmpty) {
        _directorList.addAll(
          directorController.text
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty),
        );
        directorController.clear();
      }
    }
    // Debug print
    print("Cast List: $_castList");
    print("Director List: $_directorList");
    // Notify listeners after updating
    notifyListeners();
  }

  void removeValue(String value) {
    _castList.remove(value);
  }

  void toggleSelection(String item, String label) {
    if (label == "Genres") {
      if (selectedGeners.contains(item)) {
        selectedGeners.remove(item);
      } else {
        selectedGeners.add(item);
      }
    } else if (label == "Audio Formats") {
      if (selectedAudioFormat.contains(item)) {
        selectedAudioFormat.remove(item);
      } else {
        selectedAudioFormat.add(item);
      }
    } else if (label == "Subtitle Languages") {
      if (selectedSubLanguages.contains(item)) {
        selectedSubLanguages.remove(item);
      } else {
        selectedSubLanguages.add(item);
      }
    } else {
      if (selectedLanguages.contains(item)) {
        selectedLanguages.remove(item);
      } else {
        selectedLanguages.add(LanguageList(language: item,fileUrl: ''));
      }
    }
    notifyListeners(); // Notify listeners to update the UI
  }

  void dropDownSelection(String item, String label) {
    if (label == "Age Rating") {
      ageRatingController.text = item;
    } else if (label == "Type") {
      typeController.text = item;
    } else if (label == "Rental Duration") {
      rentalDurationController.text = item;
    }
    notifyListeners(); // Notify listeners to update the UI
  }

  void clearSelections() {
    _selectedItems.clear();
    notifyListeners();
  }

  bool _isDownloadable = false;
  bool get isDownloadable => _isDownloadable;

  void toggleDownloadable(bool value) {
    _isDownloadable = value;
    notifyListeners();
  }

  bool _isFeatured = false;
  bool get isFeatured => _isFeatured;

  void toggleFeatured(bool value) {
    _isFeatured = value;
    notifyListeners();
  }

  // Fetch all content
  Future<void> fetchContent() async {
    String apiUrl = ApiConstant.getAllVideo;
    ApiHelper apiHelper = ApiHelper();
    try {
      var response = await apiHelper.getApi(apiUrl);
      if (response.statusCode == 200) {
        Map<String, dynamic> responseBody = json.decode(response.body);
        GetAllVideoResponse getAllContentResponse =
            GetAllVideoResponse.fromJson(responseBody);
        if (getAllContentResponse.success == true) {
          if (getAllContentResponse.data!.contentList != null) {
            _contentList.clear();
            _filteredContentList.clear();
            _contentList = getAllContentResponse.data!.contentList!;
            _filteredContentList.addAll(_contentList);
            notifyListeners();
          } else {
            debugPrint("empty list: ${getAllContentResponse.message}");
          }
        } else {
          debugPrint("Error: ${getAllContentResponse.message}");
        }
      } else {
        throw Exception(
            'Failed to fetch content. Status code: ${response.statusCode}');
      }
    } catch (error) {
      debugPrint("Error: $error");
      throw Exception('An error occurred while fetching content.');
    }
  }

  // search all content
  Future<void> searchContent() async {
    String apiUrl = ApiConstant.searchContent(searchContentController.text);
    ApiHelper apiHelper = ApiHelper();
    try {
      var response = await apiHelper.getApi(apiUrl);
      if (response.statusCode == 200) {
        Map<String, dynamic> responseBody = json.decode(response.body);
        SearchResponse searchResponse = SearchResponse.fromJson(responseBody);
        if (searchResponse.success == true) {
          if (searchResponse.data != null) {
            _filteredContentList.clear();
            _filteredContentList = searchResponse.data!
                .map((item) => Content.fromJson(item as Map<String, dynamic>))
                .toList();
            notifyListeners();
          } else {
            debugPrint("empty list: ${searchResponse.message}");
          }
        } else {
          debugPrint("Error: ${searchResponse.message}");
        }
      } else {
        throw Exception(
            'Failed to fetch content. Status code: ${response.statusCode}');
      }
    } catch (error) {
      debugPrint("Error: $error");
      throw Exception('An error occurred while fetching content.');
    }
  }

  void filterContent() {
    _filteredContentList = _contentList.where((content) {
      final query = searchContentController.text.toLowerCase();
      return content.title!.toLowerCase().contains(query) ||
          content.ageRating!.toLowerCase().contains(query) ||
          (content.description!.toLowerCase().contains(query) ?? false) ||
          (content.description!.toLowerCase().contains(query) ?? false) ||
          (content.type!.toLowerCase().contains(query) ?? false) ||
          (content.ageRating!.toLowerCase().contains(query) ?? false);
    }).toList();
    notifyListeners();
  }

  setSelectedContent(Content content) {
    _selectedContent = content;
    searchContentController.clear();
    notifyListeners();
  }

  // Fetch all moviesByMediaHouseId
  Future<void> fetchMoviesByMediaHouseId(int mediaHouseId) async {
    String apiUrl = ApiConstant.getVideoByMediaHouseId(mediaHouseId);
    debugPrint(apiUrl);
    ApiHelper apiHelper = ApiHelper();
    try {
      var response = await apiHelper.getApi(apiUrl);
      debugPrint("response::: " + response.body);
      if (response.statusCode == 200) {
        Map<String, dynamic> responseBody = json.decode(response.body);
        GetAllVideoResponse getAllContentResponse =
            GetAllVideoResponse.fromJson(responseBody);
        if (getAllContentResponse.success == true) {
          if (getAllContentResponse.data!.contentList != null) {
            _contentList.clear();
            _contentList = getAllContentResponse.data!.contentList!;
            _filteredContentList.clear();
            _filteredContentList = getAllContentResponse.data!.contentList!;
            notifyListeners();
          } else {
            debugPrint("empty list: ${getAllContentResponse.message}");
          }
        } else {
          debugPrint("Error: ${getAllContentResponse.message}");
        }
      } else {
        throw Exception(
            'Failed to fetch Content. Status code: ${response.statusCode}');
      }
    } catch (error) {
      debugPrint("Error: $error");
      throw Exception('An error occurred while fetching Content.');
    }
  }

  // Fetch all moviesByStatusAndMediaHouseId
  Future<void> fetchMoviesByStatusAndMediaHouseId(
      String status, int mediaHouseId) async {
    String apiUrl =
        ApiConstant.getVideoByStatusAndMediaHouse(status, mediaHouseId);
    debugPrint(apiUrl);
    ApiHelper apiHelper = ApiHelper();
    try {
      var response = await apiHelper.getApi(apiUrl);
      debugPrint("get movie response by status::: " + response.body);
      if (response.statusCode == 200) {
        Map<String, dynamic> responseBody = json.decode(response.body);
        GetAllVideoResponse getAllContentResponse =
            GetAllVideoResponse.fromJson(responseBody);
        if (getAllContentResponse.success == true) {
          if (getAllContentResponse.data!.contentList != null) {
            _contentList.clear();
            _contentList = getAllContentResponse.data!.contentList!;
            _filteredContentList.clear();
            _filteredContentList = getAllContentResponse.data!.contentList!;
            notifyListeners();
          } else {
            debugPrint("empty list: ${getAllContentResponse.message}");
          }
        } else {
          _filteredContentList.clear();
          debugPrint("Error: ${getAllContentResponse.message}");
        }
      } else if (response.statusCode == 404) {
        Map<String, dynamic> responseBody = json.decode(response.body);
        GetAllVideoResponse getAllContentResponse =
            GetAllVideoResponse.fromJson(responseBody);
        if (getAllContentResponse.success == false) {
          _filteredContentList.clear();
          notifyListeners();
        }
      } else {
        if (status == "ALL") {
          filteredContentList.clear();
          _filteredContentList.addAll(_contentList);
          notifyListeners();
        }
        throw Exception(
            'Failed to fetch Content. Status code: ${response.statusCode}');
      }
    } catch (error) {
      debugPrint("Error: $error");
      throw Exception('An error occurred while fetching Content.');
    }
  }

  // Fetch all moviesByStatusAndMediaHouseId
  Future<void> fetchReleasedMoviesByMediaHouseId(int mediaHouseId) async {
    String apiUrl = ApiConstant.getReleaseVideoByMediaHouse(mediaHouseId);
    ApiHelper apiHelper = ApiHelper();
    try {
      var response = await apiHelper.getApi(apiUrl);
      debugPrint("get movie response by status::: " + response.body);
      if (response.statusCode == 200) {
        Map<String, dynamic> responseBody = json.decode(response.body);
        GetAllVideoResponse getAllContentResponse =
            GetAllVideoResponse.fromJson(responseBody);
        if (getAllContentResponse.success == true) {
          if (getAllContentResponse.data!.contentList != null) {
            _contentList.clear();
            _filteredContentList.clear();
            _contentList = getAllContentResponse.data!.contentList!;
            notifyListeners();
            _filteredContentList = _contentList;
          } else {
            debugPrint("empty list: ${getAllContentResponse.message}");
          }
        } else {
          _filteredContentList.clear();
          debugPrint("Error: ${getAllContentResponse.message}");
        }
      } else {}
    } catch (error) {
      debugPrint("Error: $error");
      throw Exception('An error occurred while fetching Content.');
    }
  }

  // Fetch all moviesByStatusAndMediaHouseId
  Future<void> changeContentStatus(context, String status, int id) async {
    String apiUrl = ApiConstant.changeContentStatus(status, id);
    ApiHelper apiHelper = ApiHelper();
    try {
      var response = await apiHelper.putApi(apiUrl);
      debugPrint("response::: " + response.body);
      if (response.statusCode == 200) {
        Map<String, dynamic> responseBody = json.decode(response.body);
        _content = Content.fromJson(responseBody);
        CustomToast.show("Content '${status.toLowerCase()}' successfully",
            isSuccess: true);
        notifyListeners();
      } else {
        throw Exception(
            'Failed to fetch Content. Status code: ${response.statusCode}');
      }
    } catch (error) {
      debugPrint("Error: $error");
      throw Exception('An error occurred while fetching Content.');
    }
  }

  Future<Content?> uploadContent(BuildContext context) async {
    final localSharePreferences = LocalSharePreferences();
    final mediaHouse = await localSharePreferences.getMediaHouse();
    if (mediaHouse == null) {
      CustomToast.show("Media house not found.", isSuccess: false);
      return null;
    }

    Availability availability = Availability();
    DateTime now = DateTime.now();
    String isoDate = now.toUtc().toIso8601String();
    String apiUrl = ApiConstant.saveVideo;

    SaveContentRequest saveContent = SaveContentRequest();
    saveContent.ageRating = ageRatingController.text;
    saveContent.approvalStatus = "PENDING";
    saveContent.approvedDateTime = '';
    saveContent.audioFormatList = selectedAudioFormat;
    saveContent.availability = availability;
    saveContent.castList = castList;
    saveContent.contentUrl = movieUrlController.text;
    saveContent.directorList = directorList;
    saveContent.description = descriptionController.text;
    saveContent.genersList = selectedGeners;
    saveContent.isDownloadable = isDownloadable;
    saveContent.isFeatured = isFeatured;
    saveContent.languageList = selectedLanguages;
    saveContent.mediaHouseId = mediaHouse.id!;
    saveContent.price =
        double.tryParse(priceController.text) ?? 0.0; // Handle invalid input
    saveContent.posterUrlList = [
      poster1Controller.text,
      poster2Controller.text,
      poster3Controller.text,
    ];
    saveContent.ratings = 0;
    saveContent.ratingCount = 0;
    saveContent.reason = '';
    saveContent.releaseDate = releaseDateController.text;
    saveContent.rentlDuration = rentalDurationController.text;
    saveContent.totalRevenue = 0;
    saveContent.runtime = 0;
    saveContent.subtitleLanguageList = selectedSubLanguages;
    saveContent.sensorCertificate = censorCertificateController.text;
    saveContent.type = typeController.text;
    saveContent.title = titleController.text;
    saveContent.trailerUrl = trailerUrlController.text;
    saveContent.uploadDateTime = isoDate;
    saveContent.views = 0;

    ApiHelper apiHelper = ApiHelper();
    try {
      final payload = saveContent.toJson();
      debugPrint("Payload: ${json.encode(payload)}");
      var response = await apiHelper.postApiWithBody(apiUrl, payload);
      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        final addVideoResponse = AddVideoResponse.fromJson(responseBody);
        if (addVideoResponse.isSuccess == true) {
          Content contentObj = addVideoResponse.data!;
          CustomToast.show("Video added successfully", isSuccess: true);
          fetchMoviesByStatusAndMediaHouseId("All", mediaHouse.id!);
          disposeData();
          notifyListeners();
          return contentObj;
        } else {
          debugPrint(
              "Error: ${addVideoResponse.message ?? 'Record not added'}");
          CustomToast.show("Failed to add content: ${addVideoResponse.message}",
              isSuccess: false);
          return null;
        }
      } else {
        debugPrint("Failed: ${response.statusCode}, ${response.body}");
        CustomToast.show("Error: ${response.statusCode}. Please try again.",
            isSuccess: false);
      }
    } catch (error) {
      debugPrint("Error: $error");
      CustomToast.show("An unexpected error occurred: $error",
          isSuccess: false);
    }
    return null;
  }

  Future<Content?> uploadSeries(BuildContext context) async {
    final localSharePreferences = LocalSharePreferences();
    final mediaHouse = await localSharePreferences.getMediaHouse();
    if (mediaHouse == null) {
      CustomToast.show("Media house not found.", isSuccess: false);
      return null;
    }

    Availability availability = Availability();
    DateTime now = DateTime.now();
    String isoDate = now.toUtc().toIso8601String();
    String apiUrl = ApiConstant.saveSeries;

    SaveSeriesRequest saveContent = SaveSeriesRequest();
    saveContent.audioFormatList = selectedAudioFormat;
    saveContent.availability = availability;
    saveContent.castList = castList;
    saveContent.directorList = directorList;
    saveContent.description = descriptionController.text;
    saveContent.isDownloadable = isDownloadable;
    saveContent.isFeatured = isFeatured;
    saveContent.genreList = selectedGeners;
    saveContent.languageList = selectedLanguages;
    saveContent.mediaHouseId = mediaHouse.id!;
    saveContent.price =
        double.tryParse(priceController.text) ?? 0.0; // Handle invalid input
    saveContent.posterUrlList = [
      poster1Controller.text,
      poster2Controller.text,
      poster3Controller.text,
    ];
    saveContent.ratings = 0;
    saveContent.ratingCount = 0;
    saveContent.releaseDate = releaseDateController.text;
    saveContent.rentlDuration = rentalDurationController.text;
    saveContent.runtime = 0;
    saveContent.subtitleLanguageList = selectedSubLanguages;
    saveContent.sensorCertificate = censorCertificateController.text;
    saveContent.title = titleController.text;
    saveContent.trailerUrl = trailerUrlController.text;


    ApiHelper apiHelper = ApiHelper();
    try {
      final payload = saveContent.toJson();
      debugPrint("Payload: ${json.encode(payload)}");
      debugPrint("Payload: ${saveContent.toJson()}");
      var response = await apiHelper.postApiWithBody(apiUrl, payload);
      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        final addVideoResponse = AddVideoResponse.fromJson(responseBody);
        if (addVideoResponse.isSuccess == true) {
          Content contentObj = addVideoResponse.data!;
          CustomToast.show("Series added successfully", isSuccess: true);
          fetchMoviesByStatusAndMediaHouseId("All", mediaHouse.id!);
          disposeData();
          notifyListeners();
          return contentObj;
        } else {
          debugPrint(
              "Error: ${addVideoResponse.message ?? 'Record not added'}");
          CustomToast.show("Failed to add content: ${addVideoResponse.message}",
              isSuccess: false);
          return null;
        }
      } else {
        debugPrint("Failed: ${response.statusCode}, ${response.body}");
        CustomToast.show("Error: ${response.statusCode}. Please try again.",
            isSuccess: false);
      }
    } catch (error) {
      debugPrint("Error: $error");
      CustomToast.show("An unexpected error occurred: $error",
          isSuccess: false);
    }
    return null;
  }

  Future<Content?> editContent(BuildContext context, int movieId) async {
    final localSharePreferences = LocalSharePreferences();
    final mediaHouse = await localSharePreferences.getMediaHouse();
    if (mediaHouse == null) {
      CustomToast.show("Media House not found. Please login again.",
          isSuccess: false);
      return null;
    }

    Availability availability = Availability();
    DateTime now = DateTime.now();
    String isoDate = now.toUtc().toIso8601String();
    String apiUrl = ApiConstant.editVideoById(movieId);

    // Create the content request object
    SaveContentRequest saveContent = SaveContentRequest();
    try {
      saveContent.ageRating = ageRatingController.text;
      saveContent.approvalStatus = content!.approvalStatus;
      saveContent.approvedDateTime = null;
      saveContent.audioFormatList = selectedAudioFormat;
      saveContent.availability = availability;
      saveContent.castList = castList;
      saveContent.contentUrl = movieUrlController.text;
      saveContent.directorList = directorList;
      saveContent.description = descriptionController.text;
      saveContent.genersList = selectedGeners;
      saveContent.isDownloadable = isDownloadable;
      saveContent.isFeatured = isFeatured;
      saveContent.languageList = selectedLanguages;
      saveContent.mediaHouseId = mediaHouse.id;
      saveContent.price = double.tryParse(priceController.text) ?? 0.0;
      saveContent.posterUrlList = [
        poster1Controller.text,
        poster2Controller.text,
        poster3Controller.text,
      ];
      saveContent.ratings = 0;
      saveContent.ratingCount = 0;
      saveContent.reason = '';
      saveContent.releaseDate = releaseDateController.text;
      saveContent.rentlDuration = rentalDurationController.text;
      saveContent.totalRevenue = 0;
      saveContent.runtime = double.tryParse(runTimeController.text) ?? 0.0;
      saveContent.subtitleLanguageList = selectedSubLanguages;
      saveContent.sensorCertificate = censorCertificateController.text;
      saveContent.type = typeController.text;
      saveContent.title = titleController.text;
      saveContent.trailerUrl = trailerUrlController.text;
      saveContent.uploadDateTime = isoDate;
      saveContent.views = 0;

      ApiHelper apiHelper = ApiHelper();
      final payload = saveContent.toJson();
      debugPrint("Payload: ${json.encode(payload)}");
      var response = await apiHelper.putApiWithBody(apiUrl, payload);
      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        final addVideoResponse = AddVideoResponse.fromJson(responseBody);
        if (addVideoResponse.isSuccess == true) {
          CustomToast.show("Video edited successfully", isSuccess: true);
          fetchMoviesByStatusAndMediaHouseId("All", mediaHouse.id!);
          notifyListeners();
          return addVideoResponse.data; // Return the content object
        } else {
          debugPrint(
              "Edit failed: ${addVideoResponse.message ?? 'Unknown error'}");
          CustomToast.show(addVideoResponse.message ?? "Edit failed.",
              isSuccess: false);
        }
      } else {
        debugPrint("Failed: ${response.statusCode}, ${response.body}");
        CustomToast.show("Failed to edit content. Please try again.",
            isSuccess: false);
      }
    } catch (error) {
      debugPrint("Error: $error");
      CustomToast.show("An unexpected error occurred. Please try again.",
          isSuccess: false);
    }
    return null; // Return null if the edit fails
  }

  File? selectedImage;

  void setImage(XFile pickedFile) {
    selectedImage = File(pickedFile.path);
    notifyListeners();
  }

  List<User> users = [];
  List<User> get userList => users;

  // Fetch all users
  Future<void> fetchUsers() async {
    String apiUrl = ApiConstant.getAllUser;
    ApiHelper apiHelper = ApiHelper();
    try {
      var response = await apiHelper.getApi(apiUrl);
      if (response.statusCode == 200) {
        Map<String, dynamic> responseBody = json.decode(response.body);
        GetAllUserResponse getAllUserResponse =
            GetAllUserResponse.fromJson(responseBody);
        if (getAllUserResponse.success == true) {
          if (getAllUserResponse.data != null) {
            users = getAllUserResponse.data!.user!;
            print("User list:::::::" + users.length.toString());
            notifyListeners();
          } else {
            debugPrint("empty list: ${getAllUserResponse.message}");
          }
        } else {
          debugPrint("Error: ${getAllUserResponse.message}");
        }
      } else {
        throw Exception(
            'Failed to fetch users. Status code: ${response.statusCode}');
      }
    } catch (error) {
      debugPrint("Error: $error");
      throw Exception('An error occurred while fetching users.');
    }
  }

  io.File? _imageFile; // For mobile platforms
  html.File? _webFile; // For web platform
  String? _uploadedImageUrl;
  bool _isUploading = false;

  // Getters
  io.File? get imageFile => _imageFile;
  html.File? get webFile => _webFile;
  String? get uploadedImageUrl => _uploadedImageUrl;
  bool get isUploading => _isUploading;

  // Pick Image
  Future<void> pickImage(String label) async {
    if (kIsWeb) {
      // Web file picker
      final html.FileUploadInputElement uploadInput =
          html.FileUploadInputElement();
      uploadInput.accept = 'image/*';
      uploadInput.click();
      uploadInput.onChange.listen((event) async {
        if (uploadInput.files != null && uploadInput.files!.isNotEmpty) {
          _webFile = uploadInput.files!.first;
          await uploadImage(label);
          notifyListeners();
        }
      });
    } else {
      // Mobile/desktop file picker
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        _imageFile = io.File(pickedFile.path);
        await uploadImage(label);
        notifyListeners();
      }
    }
  }

  // Enhanced Upload Image with Progress Tracking
  Future<void> uploadImage(String label) async {
    if ((!kIsWeb && _imageFile == null) || (kIsWeb && _webFile == null)) {
      return; // No file selected
    }

    final url = Uri.parse(ApiConstant.uploadContentImg);

    // Set uploading status and reset progress
    _setUploadingStatus(label, true);
    _setProgressByLabel(label, 0.0);
    _isUploading = true;
    notifyListeners();

    try {
      if (kIsWeb && _webFile != null) {
        // Web upload logic with progress tracking
        final request = http.MultipartRequest('POST', url);
        final reader = html.FileReader();
        reader.readAsArrayBuffer(_webFile!);
        await reader.onLoad.first;
        final byteData = reader.result as List<int>;

        final multipartFile = http.MultipartFile.fromBytes(
          'thumbnail',
          byteData,
          filename: _webFile!.name,
        );
        request.files.add(multipartFile);

        // Simulate progress for web (since we can't track actual progress easily)
        Timer.periodic(Duration(milliseconds: 100), (timer) {
          if (_getProgressByLabel(label) < 0.9) {
            _setProgressByLabel(label, _getProgressByLabel(label) + 0.1);
            notifyListeners();
          } else {
            timer.cancel();
          }
        });

        final response = await request.send();
        if (response.statusCode == 200) {
          final responseBody = await response.stream.bytesToString();
          ContentImageUploadResponse contentImageUploadResponse = ContentImageUploadResponse.fromJson(jsonDecode(responseBody));
          _uploadedImageUrl = contentImageUploadResponse.data!.thumbnailUrl;
          _setControllerText(label, _uploadedImageUrl!);
          _setProgressByLabel(label, 1.0);
        } else {
          print("Image upload failed with status: ${response.statusCode}");
          _setProgressByLabel(label, 0.0);
        }
      } else if (!kIsWeb && _imageFile != null) {
        // Mobile/desktop upload logic with progress tracking
        final totalBytes = await _imageFile!.length();
        int bytesSent = 0;

        final stream = http.ByteStream(_imageFile!.openRead().transform(
          StreamTransformer.fromHandlers(
            handleData: (data, sink) {
              bytesSent += data.length;
              final progress = bytesSent / totalBytes;
              _setProgressByLabel(label, progress);
              notifyListeners();
              sink.add(data);
            },
          ),
        ));

        final request = http.MultipartRequest('POST', url);
        request.files.add(http.MultipartFile(
          'profilePicture',
          stream,
          totalBytes,
          filename: _imageFile!.path.split('/').last,
        ));

        final response = await request.send();
        if (response.statusCode == 200) {
          final responseBody = await response.stream.bytesToString();
          _uploadedImageUrl = jsonDecode(responseBody);
          _setControllerText(label, _uploadedImageUrl!);
          _setProgressByLabel(label, 1.0);
          print("$label uploaded successfully: $_uploadedImageUrl");
        } else {
          print("Image upload failed with status: ${response.statusCode}");
          _setProgressByLabel(label, 0.0);
        }
      }
    } catch (e) {
      print('Error uploading image: $e');
      _setProgressByLabel(label, 0.0);
    } finally {
      _setUploadingStatus(label, false);
      _isUploading = false;
      notifyListeners();
    }
  }

  // Helper method to set controller text based on label
  void _setControllerText(String label, String url) {
    switch (label) {
      case "Trailer File":
        trailerUrlController.text = url;
        break;
      case "Movie File":
        movieUrlController.text = url;
        break;
      case "Censor Certificate":
        censorCertificateController.text = url;
        break;
      case "Poster 1":
        poster1Controller.text = url;
        break;
      case "Poster 2":
        poster2Controller.text = url;
        break;
      case "Poster 3":
        poster3Controller.text = url;
        break;
    }
  }

  // Helper method to get progress by label (for internal use)
  double _getProgressByLabel(String label) {
    switch (label) {
      case "Trailer File":
        return trailerUploadProgress;
      case "Movie File":
        return movieUploadProgress;
      case "Censor Certificate":
        return censorUploadProgress;
      case "Poster 1":
        return poster1UploadProgress;
      case "Poster 2":
        return poster2UploadProgress;
      case "Poster 3":
        return poster3UploadProgress;
      default:
        return 0.0;
    }
  }

  deleteVideo(int id, context) async {
    final localSharePreferences = LocalSharePreferences();
    final mediaHouse = await localSharePreferences.getMediaHouse();
    String apiUrl = ApiConstant.deleteVideoById(id);
    ApiHelper apiHelper = ApiHelper();
    try {
      var response = await apiHelper.deleteApi(apiUrl);
      if (response.statusCode == 200 || response.statusCode == 500) {
        CustomToast.show("Video edited successfully", isSuccess: true);
        fetchMoviesByStatusAndMediaHouseId("PENDING", mediaHouse!.id!);
        notifyListeners();
        Navigator.pop(context);
      } else {
        throw Exception(
            'Failed to fetch mediaHouse. Status code: ${response.statusCode}');
      }
    } catch (error) {
      debugPrint("Error: $error");
      throw Exception('An error occurred while fetching mediaHouse.');
    }
  }

  getContentById(int id) async {
    String apiUrl = ApiConstant.getVideoById(id);
    ApiHelper apiHelper = ApiHelper();
    try {
      var response = await apiHelper.getApi(apiUrl);
      if (response.statusCode == 200) {
        Map<String, dynamic> responseBody = json.decode(response.body);
        GetContentResponse addUserResponse =
            GetContentResponse.fromJson(responseBody);
        print("\ncontent by id response " + responseBody.toString());
        if (addUserResponse.success == true) {
          if (addUserResponse.data != null &&
              addUserResponse.data!.contentList != null) {
            _content = addUserResponse.data!.contentList!;
            notifyListeners();
          } else {
            debugPrint("empty data: ${addUserResponse.message}");
          }
        } else {
          debugPrint("Error: ${addUserResponse.message}");
        }
      } else {
        throw Exception(
            'Failed to delete user. Status code: ${response.statusCode}');
      }
    } catch (error) {
      debugPrint("Error: $error");
      throw Exception('An error occurred while delete user.');
    }
  }

  void setValu(Content movie) {
    releaseDateController.text = movie.releaseDate ?? "";
    ageRatingController.text = movie.ageRating ?? '';
    castController.text = movie.castList.toString() ?? '';
    censorCertificateController.text = movie.sensorCertificate ?? '';
    directorController.text = movie.directorList.toString() ?? '';
    descriptionController.text = movie.description ?? '';
    titleController.text = movie.title ?? '';
    typeController.text = movie.type ?? '';
    rentlDurationController.text = movie.rentlDuration ?? "";
    priceController.text = movie.price.toString() ?? "";
    runTimeController.text = movie.runtime.toString() ?? "";
    _selectedLanguages = movie.languageList ?? [];
    _selectedSubLanguages = movie.subtitleLanguageList ?? [];
    _selectedAudioFormat = movie.audioFormatList ?? [];
    _selectedGeners = movie.genreList ?? [];
    if (movie.posterUrlList != null && movie.posterUrlList!.isNotEmpty) {
      poster1Controller.text =
          movie.posterUrlList!.length > 0 && movie.posterUrlList![0].isNotEmpty
              ? movie.posterUrlList![0]
              : ''; // Assign value or empty string if null/missing
      poster2Controller.text =
          movie.posterUrlList!.length > 1 && movie.posterUrlList![1].isNotEmpty
              ? movie.posterUrlList![1]
              : ''; // Assign value or empty string if null/missing
      poster3Controller.text =
          movie.posterUrlList!.length > 2 && movie.posterUrlList![2].isNotEmpty
              ? movie.posterUrlList![2]
              : ''; // Assign value or empty string if null/missing
    }
    trailerUrlController.text = movie.trailerUrl!;
    movieUrlController.text = movie.contentUrl!;
    censorCertificateController.text = movie.sensorCertificate!;
  }

  setMoviePercentage(BuildContext context, Content content, int adminPercentage,
      int mediaHousePercentage) async {
    final localSharePreferences = LocalSharePreferences();
    final mediaHouse = await localSharePreferences.getMediaHouse();
    DateTime now = DateTime.now();
    String isoDate = now.toUtc().toIso8601String();
    String apiUrl = ApiConstant.setPercentage;
    print(apiUrl);
    PercentageRequest percentageRequest = PercentageRequest();
    percentageRequest.contentList = content.id;
    percentageRequest.date = isoDate;
    percentageRequest.isActive = true;
    percentageRequest.mediaHouse = mediaHouse!.id!;
    percentageRequest.percentageAdmin = adminPercentage;
    percentageRequest.percentageMediaHouse = mediaHousePercentage;
    percentageRequest.ticketRate = content.price;
    ApiHelper apiHelper = ApiHelper();
    try {
      final payload = percentageRequest.toJson();
      debugPrint("Payload: ${json.encode(payload)}");
      var response = await apiHelper.postApiWithBody(
        apiUrl,
        payload,
      );
      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        final addVideoResponse = AddVideoResponse.fromJson(responseBody);
        if (addVideoResponse.isSuccess == true) {
          CustomToast.show("Percentage set successfully", isSuccess: true);
          fetchMoviesByStatusAndMediaHouseId("All", mediaHouse.id!);
          notifyListeners();
          Navigator.of(context).pop();
        } else {
          debugPrint("Empty data: Record not added");
        }
      } else {
        debugPrint("Failed: ${response.statusCode}, ${response.body}");
      }
    } catch (error) {
      debugPrint("Error: $error");
    }
  }

  String? trailerFileName;
  String? movieFileName;

  TextEditingController startDateController = TextEditingController();
  TextEditingController endDateNameController = TextEditingController();
  bool isYear = false;
  bool isMonth = true;
  bool isWeek = false;
  List<GraphData> chartData = [];

  falseAllFilter() {
    isYear = false;
    isMonth = false;
    isWeek = false;
  }

  Future<void> contentRevenueGraph(int selectedTimeRange, int id,
      String startDateString, String endDateString) async {
    if (selectedTimeRange == 0) {
      isWeek = true;
      isMonth = false;
      isYear = false;
    } else if (selectedTimeRange == 1) {
      isWeek = false;
      isMonth = true;
      isYear = false;
    } else if (selectedTimeRange == 2) {
      isWeek = false;
      isMonth = false;
      isYear = true;
    } else {
      isWeek = false;
      isMonth = false;
      isYear = false;
    }
    String apiUrl = ApiConstant.contentRevenueGraph(
      id,
      startDateString,
      endDateString,
      isYear,
      isMonth,
      isWeek,
    );
    ApiHelper apiHelper = ApiHelper();
    try {
      var response = await apiHelper.getApi(apiUrl);
      Map<String, dynamic> responseBody = json.decode(response.body);
      GraphResponse chartResponse = GraphResponse.fromJson(responseBody);
      if (chartResponse.success == true) {
        chartData.clear();
        chartData = chartResponse.data!;
        // Debug print to verify
        for (var item in chartData) {
          print('Label: ${item.label}, Value: ${item.value}');
        }
        notifyListeners();
      } else {
        CustomToast.show(chartResponse.message.toString(),
            isSuccess: chartResponse.success!);
      }
    } catch (error) {
      debugPrint("Error occurred while fetching graph data: $error");
      throw Exception('Failed to fetch graph data. Error: $error');
    }
  }

// Replace the uploadVideo method in your VideoProvider with this enhanced version:

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
          if (isTrailer) {
            trailerUploadProgress = progress;
          } else {
            movieUploadProgress = progress;
          }
          notifyListeners();
        }
      });

      xhr.onLoad.listen((_) {
        if (xhr.status == 200) {
          final response = json.decode(xhr.responseText!);
          VideoUploadResponse contentImageUploadResponse = VideoUploadResponse.fromJson(response);
          final encryptedUrl = contentImageUploadResponse.data!.videoUrl;


          if (isTrailer) {
            trailerUrlController.text = encryptedUrl!;
            trailerFileName = file.name;
            trailerUploadProgress = 1.0;
            _isTrailerUploading = false;
          } else {
            movieUrlController.text = encryptedUrl!;
            movieFileName = file.name;
            movieUploadProgress = 1.0;
            _isMovieUploading = false;
          }
          notifyListeners();
        }
      });

      xhr.onError.listen((_) {
        if (isTrailer) {
          trailerUploadProgress = 0.0;
          _isTrailerUploading = false;
        } else {
          movieUploadProgress = 0.0;
          _isMovieUploading = false;
        }
        notifyListeners();
      });

      xhr.open('POST', ApiConstant.uploadVideo);
      xhr.send(formData);

      if (isTrailer) {
        _isTrailerUploading = true;
      } else {
        _isMovieUploading = true;
      }
      notifyListeners();
    });
  }

  Future<void> uploadVideo(bool isTrailer) async {
    final Uri uploadUri = Uri.parse(ApiConstant.uploadVideo);

    // Reset progress at start and set uploading status
    if (isTrailer) {
      trailerUploadProgress = 0.0;
      _isTrailerUploading = true;
    } else {
      movieUploadProgress = 0.0;
      _isMovieUploading = true;
    }
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
                    if (isTrailer) {
                      trailerUploadProgress = progress;
                    } else {
                      movieUploadProgress = progress;
                    }

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


            if (isTrailer) {
              trailerUrlController.text = encryptedUrl!;
              trailerUploadProgress = 1.0;

            } else {
              movieUrlController.text = encryptedUrl!;
              movieUploadProgress = 1.0;
            }

            print("Video uploaded successfully: $encryptedUrl");
          } else {
            print("Video upload failed with status: ${response.statusCode}");
            final responseBody = await response.stream.bytesToString();
            print("Error response: $responseBody");

            // Reset progress on failure
            if (isTrailer) {
              trailerUploadProgress = 0.0;
            } else {
              movieUploadProgress = 0.0;
            }
          }
          if (isTrailer) {
            _isTrailerUploading = false;
          } else {
            _isMovieUploading = false;
          }
          _isUploading = false;
          notifyListeners();
        } else {
          print("No video selected");
          // Reset progress if no video selected
          if (isTrailer) {
            trailerUploadProgress = 0.0;
          } else {
            movieUploadProgress = 0.0;
          }
          notifyListeners();
        }
      }
    } catch (e) {
      print('Error uploading video: $e');
      // Reset progress on error
      if (isTrailer) {
        trailerUploadProgress = 0.0;
      } else {
        movieUploadProgress = 0.0;
      }
      notifyListeners();
    } finally {
      // ❌ DO NOTHING FOR WEB
      if (!kIsWeb) {
        if (isTrailer) {
          _isTrailerUploading = false;
        } else {
          _isMovieUploading = false;
        }
        _isUploading = false;
        notifyListeners();
      }
    }

  }

// Also add these helper methods to better track video upload status:

  bool get isVideoUploading => _isTrailerUploading || _isMovieUploading;

// Method to check if a specific video type is uploading
  bool isSpecificVideoUploading(bool isTrailer) {
    return isTrailer ? _isTrailerUploading : _isMovieUploading;
  }

// Method to get specific video upload progress
  double getVideoUploadProgress(bool isTrailer) {
    return isTrailer ? trailerUploadProgress : movieUploadProgress;
  }

// Method to reset specific video upload progress
  void resetVideoUploadProgress(bool isTrailer) {
    if (isTrailer) {
      trailerUploadProgress = 0.0;
      _isTrailerUploading = false;
    } else {
      movieUploadProgress = 0.0;
      _isMovieUploading = false;
    }
    notifyListeners();
  }

  void disposeData() {
    videoController.clear();
    ageRatingController.clear();
    statusController.clear();
    descriptionController.clear();
    movieUrlController.clear();
    trailerUrlController.clear();
    priceController.clear();
    releaseDateController.clear();
    rentlDurationController.clear(); // double-check spelling here
    censorCertificateController.clear();
    titleController.clear();
    reasonController.clear();
    typeController.clear();
    runTimeController.clear();
    poster1Controller.clear();
    poster2Controller.clear();
    poster3Controller.clear();
    castController.clear();
    directorController.clear();
    rentalDurationController.clear();

    // Reset all progress indicators
    trailerUploadProgress = 0.0;
    movieUploadProgress = 0.0;
    censorUploadProgress = 0.0;
    poster1UploadProgress = 0.0;
    poster2UploadProgress = 0.0;
    poster3UploadProgress = 0.0;

    // Reset all uploading status
    _isTrailerUploading = false;
    _isMovieUploading = false;
    _isCensorUploading = false;
    _isPoster1Uploading = false;
    _isPoster2Uploading = false;
    _isPoster3Uploading = false;
  }

  setDate(DateTime pickedDate) {
    releaseDateController.text = pickedDate.toLocal().toString().split(' ')[0];
    notifyListeners();
  }

  // Method to pick and simulate audio file upload for dynamic languages
  Future<void> pickAudioFile(String label) async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.audio);
    if (result != null && result.files.single.path != null) {
      final language = label.replaceAll(" Audio", "");
      _isAudioUploading[language] = true;
      _audioUploadProgress[language] = 0.0;
      notifyListeners();

      double currentProgress = 0.0;
      while (currentProgress < 1.0) {
        await Future.delayed(const Duration(milliseconds: 100));
        currentProgress += 0.1;
        _audioUploadProgress[language] = currentProgress;
        notifyListeners();
      }

      final audioUrl =
          "https://example.com/${language.toLowerCase()}_audio_${DateTime.now().millisecondsSinceEpoch}.mp3"; // Mock URL
      audioControllers[language]?.text = audioUrl;

      _isAudioUploading[language] = false;
      notifyListeners();
      CustomToast.show("$label uploaded successfully!", isSuccess: true);
    } else {
      CustomToast.show("Audio picking cancelled or failed.", isSuccess: false);
    }
  }

  // Methods for managing dynamic audio languages
  void addAudioLanguage(String language) {
    if (!_audioLanguages.contains(language)) {
      _audioLanguages.add(language);
      audioControllers[language] = TextEditingController();
      _isAudioUploading[language] =
          false; // Initialize upload status for new language
      _audioUploadProgress[language] =
          0.0; // Initialize progress for new language
      notifyListeners();
    } else {
      CustomToast.show("$language audio already added.", isWarning: true);
    }
  }

  void removeAudioLanguage(String language) {
    _audioLanguages.remove(language);
    audioControllers[language]
        ?.dispose(); // Dispose controller to prevent memory leaks
    audioControllers.remove(language);
    _isAudioUploading.remove(language); // Remove upload status
    _audioUploadProgress.remove(language); // Remove progress
    notifyListeners();
  }

  // New methods to set multi-select lists
  void setSelectedGeners(List<String> items) {
    _selectedGeners = items;
    notifyListeners();
  }

  void setSelectedAudioFormat(List<String> items) {
    _selectedAudioFormat = items;
    notifyListeners();
  }

  void setSelectedSubLanguages(List<String> items) {
    _selectedSubLanguages = items;
    notifyListeners();
  }

  void setSelectedLanguages(List<String> items) {
    LanguageList languageList = new LanguageList();
    languageList.language = items[0];
    _selectedLanguages = [languageList];
    notifyListeners();
  }

  // Dispose controllers to prevent memory leaks
  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    releaseDateController.dispose();
    runTimeController.dispose();
    priceController.dispose();
    movieUrlController.dispose();
    trailerUrlController.dispose();
    censorCertificateController.dispose();
    poster1Controller.dispose();
    poster2Controller.dispose();
    poster3Controller.dispose();
    castController.dispose();
    directorController.dispose();
    super.dispose();
  }
}
