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
import 'package:media_house/domain/entities/cast_crew_model.dart';
import 'package:universal_html/html.dart' as html;

import '../../data/models/response/allContentResponse.dart';
import '../../data/models/response/series_detail_response.dart';
import '../../data/models/response/short_detail_response.dart';
import '../../data/models/response/video_upload_response.dart';
import '../../domain/entities/content.dart';
import '../core/network/api_helper.dart';
import '../core/utils/sharepreferences.dart';

class SeriesProvider extends ChangeNotifier {
  List<ShortModel> shorts = [];
  ShortDetailResponse? shortDetail;
  bool isLoading = false;
  bool _isUploading = false;
  bool _isMovieUploading = false;
  double movieUploadProgress = 0.0;

  bool get isMovieUploading => _isMovieUploading;

  List<Content> _contentList = [];
  List<Content> _filteredContentList = [];
  List<Content> get contentList => _contentList;
  List<Content> get filteredContentList => _filteredContentList;
  int _totalItems = 0;
  int get totalItems => _totalItems;
  static const int _itemsPerPage = 10;
  bool _hasMoreItems = false;
  bool get hasMoreItems => _hasMoreItems;
  bool _isLoadingMore = false;
  bool get isLoadingMore => _isLoadingMore;
  int? _statusMediaHouseIdForPagination;
  String _statusValueForPagination = "APPROVED";
  String _statusTypeForPagination = "SERIES";
  String _statusKeywordForPagination = "";
  String? _statusStartDateForPagination;
  String? _statusEndDateForPagination;
  int _statusCurrentPage = 0;
  int _statusTotalPages = 0;
  bool _hasMoreStatusItems = false;
  bool _isStatusLoadingMore = false;
  bool get isStatusLoadingMore => _isStatusLoadingMore;
  final TextEditingController movieUrlController = TextEditingController();

  SeriesDetailsResponse? _data;
  bool _loading = false;
  String? _error;
  bool _isLoadingCastCrew = false;
  String? _castCrewError;
  int? _activeCastCrewContentId;
  int? _activeCastCrewSeasonId;
  List<CastCrewItem> _activeCastCrewList = [];
  final Map<String, List<CastCrewItem>> _castCrewCache = {};

  SeriesDetailsResponse? get data => _data;
  bool get loading => _loading;
  String? get error => _error;
  bool get isLoadingCastCrew => _isLoadingCastCrew;
  String? get castCrewError => _castCrewError;
  int? get activeCastCrewContentId => _activeCastCrewContentId;
  int? get activeCastCrewSeasonId => _activeCastCrewSeasonId;
  List<CastCrewItem> get activeCastCrewList =>
      List.unmodifiable(_activeCastCrewList);
  List<CastCrewItem> get activeCastList =>
      _activeCastCrewList.where((e) => !e.isCrew).toList(growable: false);
  List<CastCrewItem> get activeCrewList =>
      _activeCastCrewList.where((e) => e.isCrew).toList(growable: false);

  Future<void> loadSeries(int seriesId) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final url = ApiConstant.seriesDetails(seriesId);
      ApiHelper apiHelper = ApiHelper();
      var response = await apiHelper.getApi(url);

      if (response.statusCode == 200) {
        final decoded = jsonDecode(utf8.decode(response.bodyBytes));
        final Map<String, dynamic> jsonMap = decoded is Map<String, dynamic>
            ? decoded
            : decoded is Map
                ? Map<String, dynamic>.from(decoded)
                : {'data': decoded};
        _data = SeriesDetailsResponse.fromJson(jsonMap);
      } else {
        _error = "Failed to load series (${response.statusCode})";
      }
    } catch (e) {
      _error = "Something went wrong while loading series: $e";
      debugPrint("SeriesProvider error: $e");
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void clear() {
    _data = null;
    _error = null;
    _loading = false;
    _castCrewError = null;
    _activeCastCrewList = [];
    _activeCastCrewContentId = null;
    _activeCastCrewSeasonId = null;
    _castCrewCache.clear();
    notifyListeners();
  }

  String _castCrewKey(int contentId, int seasonId) => '$contentId-$seasonId';
  String _castCrewContentOnlyKey(int contentId) => '$contentId-content';

  List<CastCrewItem> _parseCastCrewListFromBody(dynamic body) {
    final jsonMap = body is Map<String, dynamic>
        ? body
        : body is Map
            ? Map<String, dynamic>.from(body)
            : <String, dynamic>{};

    dynamic castRaw = jsonMap['data']?['cast'];
    castRaw ??= jsonMap['data']?['castList'];
    castRaw ??= jsonMap['cast'];
    castRaw ??= jsonMap['castList'];
    castRaw ??= jsonMap['data'];

    if (castRaw is! List) return <CastCrewItem>[];

    return castRaw
        .whereType<Map>()
        .map((e) => CastCrewItem.fromJson(
            Map<String, dynamic>.from(e as Map<dynamic, dynamic>)))
        .toList(growable: false);
  }

  Future<void> ensureCastCrewLoaded({
    required int contentId,
    required int seasonId,
  }) async {
    if (_isLoadingCastCrew &&
        _activeCastCrewContentId == contentId &&
        _activeCastCrewSeasonId == seasonId) {
      return;
    }

    if (_activeCastCrewContentId == contentId &&
        _activeCastCrewSeasonId == seasonId &&
        _activeCastCrewList.isNotEmpty) {
      return;
    }

    final key = _castCrewKey(contentId, seasonId);
    if (_castCrewCache.containsKey(key)) {
      final cached = _castCrewCache[key]!;
      if (cached.isNotEmpty) {
        _activeCastCrewContentId = contentId;
        _activeCastCrewSeasonId = seasonId;
        _activeCastCrewList = cached;
        notifyListeners();
        return;
      }
    }

    await fetchCastCrewByContentAndSeason(
      contentId: contentId,
      seasonId: seasonId,
    );
  }

  Future<void> ensureCastCrewLoadedForSeasonOnly({
    required int contentId,
    required int seasonId,
  }) async {
    if (_isLoadingCastCrew &&
        _activeCastCrewContentId == contentId &&
        _activeCastCrewSeasonId == seasonId) {
      return;
    }

    if (_activeCastCrewContentId == contentId &&
        _activeCastCrewSeasonId == seasonId &&
        _activeCastCrewList.isNotEmpty) {
      return;
    }

    final key = _castCrewKey(contentId, seasonId);
    if (_castCrewCache.containsKey(key)) {
      final cached = _castCrewCache[key]!;
      if (cached.isNotEmpty) {
        _activeCastCrewContentId = contentId;
        _activeCastCrewSeasonId = seasonId;
        _activeCastCrewList = cached;
        notifyListeners();
        return;
      }
    }

    await fetchCastCrewByContentAndSeasonStrict(
      contentId: contentId,
      seasonId: seasonId,
    );
  }

  Future<void> ensureCastCrewLoadedByContent({
    required int contentId,
  }) async {
    if (contentId <= 0) return;

    if (_isLoadingCastCrew &&
        _activeCastCrewContentId == contentId &&
        _activeCastCrewSeasonId == null) {
      return;
    }

    if (_activeCastCrewContentId == contentId &&
        _activeCastCrewSeasonId == null &&
        _activeCastCrewList.isNotEmpty) {
      return;
    }

    final key = _castCrewContentOnlyKey(contentId);
    if (_castCrewCache.containsKey(key)) {
      final cached = _castCrewCache[key]!;
      if (cached.isNotEmpty) {
        _activeCastCrewContentId = contentId;
        _activeCastCrewSeasonId = null;
        _activeCastCrewList = cached;
        notifyListeners();
        return;
      }
    }

    await fetchCastCrewByContentId(contentId: contentId);
  }

  Future<void> fetchCastCrewByContentAndSeason({
    required int contentId,
    required int seasonId,
  }) async {
    if (contentId <= 0 || seasonId <= 0) return;

    _isLoadingCastCrew = true;
    _castCrewError = null;
    _activeCastCrewContentId = contentId;
    _activeCastCrewSeasonId = seasonId;
    notifyListeners();

    try {
      final apiHelper = ApiHelper();
      final url = ApiConstant.getCastByContentIdAndSeasonId(
        contentId: contentId,
        seasonId: seasonId,
      );
      final response = await apiHelper.getApi(url);
      final body = jsonDecode(response.body);
      var castList = _parseCastCrewListFromBody(body);

      // Fallback: some backends return empty for season endpoint.
      if (castList.isEmpty) {
        final fallbackResponse =
            await apiHelper.getApi(ApiConstant.getCastByContentId(contentId));
        final fallbackBody = jsonDecode(fallbackResponse.body);
        final allCast = _parseCastCrewListFromBody(fallbackBody);
        castList = allCast
            .where((item) =>
                item.seasonId == null || item.seasonId == 0 || item.seasonId == seasonId)
            .toList(growable: false);
      }

      _activeCastCrewList = castList;
      _castCrewCache[_castCrewKey(contentId, seasonId)] = castList;
    } catch (e) {
      try {
        final apiHelper = ApiHelper();
        final fallbackResponse =
            await apiHelper.getApi(ApiConstant.getCastByContentId(contentId));
        final fallbackBody = jsonDecode(fallbackResponse.body);
        final allCast = _parseCastCrewListFromBody(fallbackBody);
        final castList = allCast
            .where((item) =>
                item.seasonId == null || item.seasonId == 0 || item.seasonId == seasonId)
            .toList(growable: false);
        _activeCastCrewList = castList;
        _castCrewCache[_castCrewKey(contentId, seasonId)] = castList;
      } catch (_) {
        _castCrewError = 'Failed to load cast and crew';
        _activeCastCrewList = [];
      }
      debugPrint("Cast/Crew load error: $e");
    } finally {
      _isLoadingCastCrew = false;
      notifyListeners();
    }
  }

  Future<void> fetchCastCrewByContentAndSeasonStrict({
    required int contentId,
    required int seasonId,
  }) async {
    if (contentId <= 0 || seasonId <= 0) return;

    _isLoadingCastCrew = true;
    _castCrewError = null;
    _activeCastCrewContentId = contentId;
    _activeCastCrewSeasonId = seasonId;
    notifyListeners();

    try {
      final apiHelper = ApiHelper();
      final url = ApiConstant.getCastByContentIdAndSeasonId(
        contentId: contentId,
        seasonId: seasonId,
      );
      final response = await apiHelper.getApi(url);
      final body = jsonDecode(response.body);
      var castList = _parseCastCrewListFromBody(body);

      // Primary call is season-wise API. If backend returns empty for this endpoint,
      // use content-wise list and keep only matching season/unassigned records.
      if (castList.isEmpty) {
        final fallback =
            await apiHelper.getApi(ApiConstant.getCastByContentId(contentId));
        final fallbackBody = jsonDecode(fallback.body);
        final allCast = _parseCastCrewListFromBody(fallbackBody);
        castList = allCast
            .where((item) =>
                item.seasonId == seasonId ||
                item.seasonId == null ||
                item.seasonId == 0)
            .toList(growable: false);
      }

      _activeCastCrewList = castList;
      _castCrewCache[_castCrewKey(contentId, seasonId)] = castList;
    } catch (e) {
      try {
        final apiHelper = ApiHelper();
        final fallback =
            await apiHelper.getApi(ApiConstant.getCastByContentId(contentId));
        final fallbackBody = jsonDecode(fallback.body);
        final allCast = _parseCastCrewListFromBody(fallbackBody);
        final castList = allCast
            .where((item) =>
                item.seasonId == seasonId ||
                item.seasonId == null ||
                item.seasonId == 0)
            .toList(growable: false);
        _activeCastCrewList = castList;
        _castCrewCache[_castCrewKey(contentId, seasonId)] = castList;
      } catch (_) {
        _castCrewError = 'Failed to load cast and crew';
        _activeCastCrewList = [];
      }
      debugPrint("Cast/Crew strict load error: $e");
    } finally {
      _isLoadingCastCrew = false;
      notifyListeners();
    }
  }

  Future<List<CastCrewItem>> fetchCastCrewListForSeason({
    required int contentId,
    required int seasonId,
  }) async {
    if (contentId <= 0 || seasonId <= 0) return <CastCrewItem>[];

    final apiHelper = ApiHelper();
    try {
      final response = await apiHelper.getApi(
        ApiConstant.getCastByContentIdAndSeasonId(
          contentId: contentId,
          seasonId: seasonId,
        ),
      );
      final body = jsonDecode(response.body);
      var castList = _parseCastCrewListFromBody(body);

      if (castList.isEmpty) {
        final fallback =
            await apiHelper.getApi(ApiConstant.getCastByContentId(contentId));
        final fallbackBody = jsonDecode(fallback.body);
        final allCast = _parseCastCrewListFromBody(fallbackBody);
        castList = allCast
            .where((item) =>
                item.seasonId == seasonId ||
                item.seasonId == null ||
                item.seasonId == 0)
            .toList(growable: false);
      }

      return castList;
    } catch (_) {
      return <CastCrewItem>[];
    }
  }

  Future<void> fetchCastCrewByContentId({
    required int contentId,
  }) async {
    if (contentId <= 0) return;

    _isLoadingCastCrew = true;
    _castCrewError = null;
    _activeCastCrewContentId = contentId;
    _activeCastCrewSeasonId = null;
    notifyListeners();

    try {
      final apiHelper = ApiHelper();
      final url = ApiConstant.getCastByContentId(contentId);
      final response = await apiHelper.getApi(url);
      final body = jsonDecode(response.body);
      final castList = _parseCastCrewListFromBody(body);

      _activeCastCrewList = castList;
      _castCrewCache[_castCrewContentOnlyKey(contentId)] = castList;
    } catch (e) {
      _castCrewError = 'Failed to load cast list';
      _activeCastCrewList = [];
      debugPrint("Cast load by contentId error: $e");
    } finally {
      _isLoadingCastCrew = false;
      notifyListeners();
    }
  }

  Future<void> fetchSeriesByMediaHouseId({
    String status = "APPROVED",
    String type = "SERIES",
    String? searchKeyword,
    String? startDate,
    String? endDate,
    int page = 0,
    bool loadMore = false,
  }) async {
    final localSharePreferences = LocalSharePreferences();
    final mediaHouse = await localSharePreferences.getMediaHouse();
    final mediaHouseId = mediaHouse?.id;
    if (mediaHouseId == null) {
      if (!loadMore) {
        _contentList.clear();
        _filteredContentList.clear();
        _totalItems = 0;
      }
      _hasMoreStatusItems = false;
      _hasMoreItems = false;
      isLoading = false;
      notifyListeners();
      return;
    }

    await fetchSeriesByStatusAndMediaHouseId(
      status,
      mediaHouseId,
      type: type,
      searchKeyword: searchKeyword,
      startDate: startDate,
      endDate: endDate,
      page: page,
      loadMore: loadMore,
    );
  }

  Future<void> fetchSeriesByStatusAndMediaHouseId(
    String status,
    int mediaHouseId, {
    String type = "SERIES",
    String? searchKeyword,
    String? startDate,
    String? endDate,
    int page = 0,
    bool loadMore = false,
  }) async {
    final normalizedStatus = status.toUpperCase();
    final normalizedKeyword = (searchKeyword ?? "").trim();
    final normalizedType = type.toUpperCase();
    final effectiveStartDate = startDate?.trim();
    final effectiveEndDate = endDate?.trim();

    if (!loadMore) {
      isLoading = true;
      _statusMediaHouseIdForPagination = mediaHouseId;
      _statusValueForPagination = normalizedStatus;
      _statusTypeForPagination = normalizedType;
      _statusKeywordForPagination = normalizedKeyword;
      _statusStartDateForPagination =
          (effectiveStartDate?.isNotEmpty ?? false) ? effectiveStartDate : null;
      _statusEndDateForPagination =
          (effectiveEndDate?.isNotEmpty ?? false) ? effectiveEndDate : null;
      _statusCurrentPage = 0;
      _statusTotalPages = 0;
      _hasMoreStatusItems = true;
      _isStatusLoadingMore = false;
      _isLoadingMore = false;
      notifyListeners();
    } else {
      _isLoadingMore = true;
      _isStatusLoadingMore = true;
      notifyListeners();
    }

    final apiUrl = ApiConstant.filterAdvancedContent(
      mediaHouseId: mediaHouseId,
      type: normalizedType,
      approvalStatus: normalizedStatus,
      startDate:
          (effectiveStartDate?.isNotEmpty ?? false) ? effectiveStartDate : null,
      endDate:
          (effectiveEndDate?.isNotEmpty ?? false) ? effectiveEndDate : null,
      searchKeyword: normalizedKeyword,
      page: page,
      size: _itemsPerPage,
    );
    debugPrint(apiUrl);

    final apiHelper = ApiHelper();
    try {
      final response = await apiHelper.getApi(apiUrl);
      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body) as Map<String, dynamic>;
        final allContentResponse = AllContentResponse.fromJson(responseBody);
        final data = allContentResponse.data;
        final fetchedContent = data?.contentList ?? [];

        if (allContentResponse.success == true) {
          _statusCurrentPage = data?.currentPage ?? page;
          _statusTotalPages = data?.totalPages ?? 0;
          _hasMoreStatusItems = _statusTotalPages > 0
              ? (_statusCurrentPage + 1) < _statusTotalPages
              : fetchedContent.length >= _itemsPerPage;

          _contentList = loadMore
              ? _mergeContentWithoutDuplicates(_contentList, fetchedContent)
              : List<Content>.from(fetchedContent);
          _filteredContentList = List<Content>.from(_contentList);
          _totalItems = data?.totalItems ?? _filteredContentList.length;
          _hasMoreItems = _hasMoreStatusItems;
          notifyListeners();
        } else {
          if (!loadMore) {
            _contentList.clear();
            _filteredContentList.clear();
            _totalItems = 0;
          }
          _hasMoreStatusItems = false;
          _hasMoreItems = false;
          notifyListeners();
        }
      } else if (response.statusCode == 404 && !loadMore) {
        _contentList.clear();
        _filteredContentList.clear();
        _totalItems = 0;
        _hasMoreStatusItems = false;
        _hasMoreItems = false;
        notifyListeners();
      } else {
        throw Exception(
            'Failed to fetch series. Status code: ${response.statusCode}');
      }
    } catch (error) {
      _hasMoreStatusItems = false;
      _hasMoreItems = false;
      notifyListeners();
      debugPrint("Error: $error");
      throw Exception('An error occurred while fetching series.');
    } finally {
      isLoading = false;
      _isLoadingMore = false;
      _isStatusLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> fetchNextSeriesByStatusPage() async {
    if (_statusMediaHouseIdForPagination == null ||
        _isStatusLoadingMore ||
        !_hasMoreStatusItems) {
      return;
    }
    _isLoadingMore = true;
    _isStatusLoadingMore = true;
    notifyListeners();
    try {
      await fetchSeriesByStatusAndMediaHouseId(
        _statusValueForPagination,
        _statusMediaHouseIdForPagination!,
        type: _statusTypeForPagination,
        searchKeyword: _statusKeywordForPagination,
        startDate: _statusStartDateForPagination,
        endDate: _statusEndDateForPagination,
        page: _statusCurrentPage + 1,
        loadMore: true,
      );
    } finally {
      _isLoadingMore = false;
      _isStatusLoadingMore = false;
      notifyListeners();
    }
  }

  List<Content> _mergeContentWithoutDuplicates(
      List<Content> base, List<Content> incoming) {
    final merged = <Content>[...base];
    final seenIds = <int>{};
    for (final item in merged) {
      if (item.id != null) {
        seenIds.add(item.id!);
      }
    }
    for (final item in incoming) {
      final id = item.id;
      if (id == null || !seenIds.contains(id)) {
        merged.add(item);
        if (id != null) {
          seenIds.add(id);
        }
      }
    }
    return merged;
  }

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
          VideoUploadResponse contentImageUploadResponse =
              VideoUploadResponse.fromJson(response);
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
            VideoUploadResponse contentImageUploadResponse =
                VideoUploadResponse.fromJson(responseJson);
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

  bool isSubmitting = false;

  Future<bool> createEpisodeApi(Map<String, dynamic> body, int seasonId) async {
    try {
      isSubmitting = true;
      notifyListeners();

      String apiUrl =
          '${ApiConstant.baseUrl}series/season/$seasonId/episode/add';

      debugPrint("URL => $apiUrl");
      debugPrint("BODY => ${jsonEncode(body)}");
      ApiHelper apiHelper = ApiHelper();
      var response = await apiHelper.postApiWithBody(apiUrl, body);

      debugPrint("STATUS => ${response.statusCode}");
      debugPrint("RESPONSE => ${response.body}");

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint("Create Episode Error: $e");
      return false;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  bool _isSuccessStatus(int code) =>
      code == 200 || code == 201 || code == 202 || code == 204;

  Future<bool> updateEpisodeApi(
    Map<String, dynamic> body,
    int seasonId,
    int episodeId, {
    int? seriesId,
  }) async {
    try {
      isSubmitting = true;
      notifyListeners();

      final apiHelper = ApiHelper();
      final url = '${ApiConstant.baseUrl}series/episode/$episodeId/update';
      final response = await apiHelper.putApiWithBody(url, body);
      debugPrint('Update Episode URL => $url');
      debugPrint('Update Episode STATUS => ${response.statusCode}');
      return _isSuccessStatus(response.statusCode);
    } catch (e) {
      debugPrint("Update Episode Error: $e");
      return false;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  Future<bool> deleteEpisodeApi(
    int seasonId,
    int episodeId, {
    int? seriesId,
  }) async {
    try {
      isSubmitting = true;
      notifyListeners();

      final apiHelper = ApiHelper();
      final url = '${ApiConstant.baseUrl}series/episode/$episodeId/delete';
      final response = await apiHelper.deleteApi(url);
      debugPrint('Delete Episode URL => $url');
      debugPrint('Delete Episode STATUS => ${response.statusCode}');
      return _isSuccessStatus(response.statusCode);
    } catch (e) {
      debugPrint("Delete Episode Error: $e");
      return false;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  Future<bool> updateSeasonApi(
    Map<String, dynamic> body,
    int seasonId, {
    int? seriesId,
  }) async {
    try {
      isSubmitting = true;
      notifyListeners();

      final apiHelper = ApiHelper();
      final url = '${ApiConstant.baseUrl}series/season/$seasonId/update';
      final response = await apiHelper.putApiWithBody(url, body);
      debugPrint('Update Season URL => $url');
      debugPrint('Update Season STATUS => ${response.statusCode}');
      return _isSuccessStatus(response.statusCode);
    } catch (e) {
      debugPrint("Update Season Error: $e");
      return false;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  Future<bool> deleteSeasonApi(int seasonId) async {
    try {
      isSubmitting = true;
      notifyListeners();

      final apiHelper = ApiHelper();
      final url = '${ApiConstant.baseUrl}series/season/$seasonId/delete';
      final response = await apiHelper.deleteApi(url);
      debugPrint('Delete Season URL => $url');
      debugPrint('Delete Season STATUS => ${response.statusCode}');
      return _isSuccessStatus(response.statusCode);
    } catch (e) {
      debugPrint("Delete Season Error: $e");
      return false;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  Future<bool> saveSeasonCastCrewMembers({
    required int contentId,
    required int seasonId,
    required List<Map<String, dynamic>> members,
  }) async {
    if (contentId <= 0 || seasonId <= 0) return false;
    if (members.isEmpty) return true;

    try {
      isSubmitting = true;
      notifyListeners();
      final apiHelper = ApiHelper();

      for (final member in members) {
        final payload = {
          "castId": 0,
          "contentId": contentId,
          "seasonId": seasonId,
          "name": (member["name"] ?? "").toString().trim(),
          "role": (member["role"] ?? "").toString().trim(),
          "description": (member["description"] ?? "").toString().trim(),
          "image": (member["image"] ?? "").toString().trim(),
        };

        final response =
            await apiHelper.postApiWithBody(ApiConstant.saveCast, payload);
        if (!_isSuccessStatus(response.statusCode)) {
          debugPrint("Save cast/crew failed: ${response.body}");
          return false;
        }
      }
      return true;
    } catch (e) {
      debugPrint("Save season cast/crew error: $e");
      return false;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }
}
