import 'package:flutter/foundation.dart';
import 'package:media_house/app/core/utils/sharepreferences.dart';
import 'package:media_house/data/models/response/media_house_settlement.dart';
import 'package:media_house/data/services/settlement_service.dart';

class SettelementProvider extends ChangeNotifier {
  final SettlementService _service;
  SettelementProvider({SettlementService? service})
      : _service = service ?? SettlementService();

  List<MediaHouseSettlement> _settlements = const [];
  List<MediaHouseSettlement> get settlements => _settlements;
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  bool _isLoadingMore = false;
  bool get isLoadingMore => _isLoadingMore;
  String? _errorMessage;
  String? get errorMessage => _errorMessage;
  int _page = 0;
  int get page => _page;
  int _pageSize = 10;
  int get pageSize => _pageSize;
  int _totalElements = 0;
  int get totalElements => _totalElements;
  int _totalPages = 0;
  int get totalPages => _totalPages;
  bool _first = true;
  bool get first => _first;
  bool _last = true;
  bool get last => _last;
  int? _mediaHouseId;
  int _requestGeneration = 0;

  Future<void> fetchForCurrentMediaHouse({int? page, int? size}) async {
    final mediaHouse = await LocalSharePreferences().getMediaHouse();
    final id = mediaHouse?.id;
    if (id == null || id <= 0) {
      _requestGeneration++;
      _settlements = const [];
      _errorMessage =
          'Media house ID is unavailable. Please refresh your profile.';
      _isLoading = false;
      notifyListeners();
      return;
    }
    _mediaHouseId = id;
    await fetchPage(page ?? _page, size: size ?? _pageSize);
  }

  Future<void> fetchPage(int requestedPage, {int? size}) async {
    final id = _mediaHouseId;
    if (id == null || id <= 0) {
      return fetchForCurrentMediaHouse(page: requestedPage, size: size);
    }
    final requestedSize = size ?? _pageSize;
    final generation = ++_requestGeneration;
    if (_isLoading || _isLoadingMore) return;
    final append = requestedPage > 0;
    if (append && (_last || requestedPage <= _page)) return;
    if (append) {
      _isLoadingMore = true;
    } else {
      _isLoading = true;
      _settlements = const [];
    }
    _errorMessage = null;
    notifyListeners();
    try {
      final response = await _service.getMediaHouseSettlements(
        id,
        page: requestedPage,
        size: requestedSize,
      );
      if (generation != _requestGeneration) return;
      final data = response.data;
      if (append) {
        final seen = _settlements
            .map((item) => item.settlementId)
            .whereType<String>()
            .toSet();
        _settlements = [
          ..._settlements,
          ...data.content.where((item) =>
              item.settlementId == null || seen.add(item.settlementId!)),
        ];
      } else {
        _settlements = data.content;
      }
      _page = data.number;
      _pageSize = data.size > 0 ? data.size : requestedSize;
      _totalElements = data.totalElements;
      _totalPages = data.totalPages;
      _first = data.first;
      _last = data.last || data.content.length < requestedSize;
    } on SettlementServiceException catch (error) {
      if (generation != _requestGeneration) return;
      if (!append) _settlements = const [];
      _errorMessage = error.message;
      _page = requestedPage;
      _pageSize = requestedSize;
      _totalElements = 0;
      _totalPages = 0;
      _first = requestedPage == 0;
      _last = true;
    } finally {
      if (generation == _requestGeneration) {
        _isLoading = false;
        _isLoadingMore = false;
        notifyListeners();
      }
    }
  }

  Future<void> changePageSize(int size) => fetchPage(0, size: size);
  Future<void> retry() => fetchPage(_page, size: _pageSize);
  Future<void> refresh() => fetchForCurrentMediaHouse(page: 0, size: _pageSize);
  Future<void> loadMore() => fetchPage(_page + 1, size: _pageSize);
}
