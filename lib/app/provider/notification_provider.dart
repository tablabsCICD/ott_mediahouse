import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:media_house/app/core/constant/api_constant.dart';
import 'package:media_house/app/core/constant/prefrense_constant.dart';
import 'package:media_house/app/core/network/api_helper.dart';
import 'package:media_house/app/core/utils/sharepreferences.dart';
import 'package:media_house/data/models/response/getMediaHouseResponse.dart';
import 'package:media_house/data/models/response/notification_response_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationProvider extends ChangeNotifier {
  static const int pageSize = 20;

  final List<NotificationItemModel> _notifications = [];
  List<NotificationItemModel> get notifications =>
      List.unmodifiable(_notifications);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isLoadingMore = false;
  bool get isLoadingMore => _isLoadingMore;

  bool _hasMore = true;
  bool get hasMore => _hasMore;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  int _pageNo = 0;

  Future<void> getNotifications() async {
    if (_isLoading) return;
    _pageNo = 0;
    _hasMore = true;
    _errorMessage = null;
    _isLoading = true;
    notifyListeners();

    try {
      final items = await _fetchPage(_pageNo);
      _notifications
        ..clear()
        ..addAll(items);
      _hasMore = items.length >= pageSize;
    } catch (error) {
      _errorMessage = _friendlyError(error);
      _notifications.clear();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMoreNotifications() async {
    if (_isLoading || _isLoadingMore || !_hasMore) return;
    _isLoadingMore = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final nextPage = _pageNo + 1;
      final items = await _fetchPage(nextPage);
      _notifications.addAll(items);
      _pageNo = nextPage;
      _hasMore = items.length >= pageSize;
    } catch (error) {
      _errorMessage = _friendlyError(error);
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> refreshNotifications() async {
    _pageNo = 0;
    _hasMore = true;
    _errorMessage = null;

    try {
      final items = await _fetchPage(_pageNo);
      _notifications
        ..clear()
        ..addAll(items);
      _hasMore = items.length >= pageSize;
    } catch (error) {
      _errorMessage = _friendlyError(error);
    }
    notifyListeners();
  }

  Future<List<NotificationItemModel>> _fetchPage(int pageNo) async {
    final localPrefs = LocalSharePreferences();
    final user = await localPrefs.getUser();
    final sharedPrefs = await SharedPreferences.getInstance();
    final userId =
        user?.id ?? sharedPrefs.getInt(SharedPreferencesConstant.userId);

    if (userId == null) {
      throw Exception('Production house user session was not found.');
    }

    final mediaHouseId = await _resolveMediaHouseId(userId);

    final url = ApiConstant.productionHouseNotifications(
      userId: userId,
      mediaHouseId: mediaHouseId,
      pageNo: pageNo,
      pageSize: pageSize,
    );
    final response = await ApiHelper().getApi(url);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Request failed with status ${response.statusCode}.');
    }

    final decoded = jsonDecode(response.body);
    if (decoded is List) {
      return NotificationDataModel.fromAny(decoded).items;
    }
    if (decoded is! Map<String, dynamic>) {
      throw Exception('Invalid notification response.');
    }

    final parsed = NotificationResponseModel.fromJson(decoded);
    final success = parsed.success;
    if (success == false) {
      throw Exception(parsed.message ?? 'Unable to load notifications.');
    }
    final data = parsed.data;
    if (data != null) {
      if (data.last == true) _hasMore = false;
      if (data.totalPages != null) _hasMore = pageNo + 1 < data.totalPages!;
    }
    return data?.items ?? const [];
  }

  Future<int> _resolveMediaHouseId(int userId) async {
    final localPrefs = LocalSharePreferences();
    final cachedMediaHouse = await localPrefs.getMediaHouse();
    final cachedMediaHouseId = cachedMediaHouse?.id;
    if (cachedMediaHouseId != null && cachedMediaHouseId > 0) {
      return cachedMediaHouseId;
    }

    final response =
        await ApiHelper().getApi(ApiConstant.getMediaHouseByUserId(userId));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Unable to load production house. Status ${response.statusCode}.',
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw Exception('Invalid production house response.');
    }

    final parsed = GetMediaHouse.fromJson(decoded);
    if (parsed.success == false) {
      throw Exception(parsed.message ?? 'Unable to load production house.');
    }

    final mediaHouse = parsed.data?.mediaHouse;
    final mediaHouseId = mediaHouse?.id;
    if (mediaHouse == null || mediaHouseId == null || mediaHouseId <= 0) {
      throw Exception('Production house was not found for this user.');
    }

    await localPrefs.setString(
      SharedPreferencesConstant.currentMediaHouse,
      jsonEncode(mediaHouse.toJson()),
    );
    return mediaHouseId;
  }

  String _friendlyError(Object error) {
    final text = error.toString().replaceFirst(RegExp(r'^Exception:\s*'), '');
    return text.isEmpty ? 'Unable to load notifications.' : text;
  }
}
