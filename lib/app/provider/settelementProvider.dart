import 'dart:convert';
import 'package:flutter/cupertino.dart';
import '../../data/models/response/mediaHouseWeeklySettelement.dart';
import '../core/constant/api_constant.dart';
import '../core/network/api_helper.dart';
import '../core/utils/sharepreferences.dart';

class SettelementProvider extends ChangeNotifier {
  List<WeeklySettelementData> _weeklySettelement = [];
  List<WeeklySettelementData> get weeklySettelement => _weeklySettelement;

  List<WeeklySettelementData> _filleterdWeeklySettelement = [];
  List<WeeklySettelementData> get filleterdWeeklySettelement =>
      _filleterdWeeklySettelement;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  int? _loadedUserId;

  Future<void> fetchWeeklySettelementDataForCurrentMediaHouse() async {
    final user = await LocalSharePreferences().getLoginData();
    final userId = user?.id;
    if (userId == null || userId == 0) {
      _weeklySettelement = [];
      _filleterdWeeklySettelement = [];
      _errorMessage = 'Media house not found for settlement.';
      notifyListeners();
      return;
    }
    await fetchWeeklySettelementDataByMediaHouseId(userId);
  }

  Future<void> fetchWeeklySettelementDataByMediaHouseId(
    int userId,
  ) async {
    if (_isLoading) return;
    if (_loadedUserId == userId && _weeklySettelement.isNotEmpty) {
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    String apiUrl = ApiConstant.weeklySettelementData(userId);
    ApiHelper apiHelper = ApiHelper();
    try {
      var response = await apiHelper.getApi(apiUrl);
      if (response.statusCode == 200) {
        Map<String, dynamic> responseBody = json.decode(response.body);
        MediaHouseWeeklySattelment mediaHouseWeeklySattelment =
            MediaHouseWeeklySattelment.fromJson(responseBody);
        if (mediaHouseWeeklySattelment.success == true) {
          _weeklySettelement = mediaHouseWeeklySattelment.data ?? [];
          _filleterdWeeklySettelement = List.from(_weeklySettelement);
          _loadedUserId = userId;
        } else {
          _weeklySettelement = [];
          _filleterdWeeklySettelement = [];
          _errorMessage =
              mediaHouseWeeklySattelment.message ?? 'Settlement API failed.';
        }
      } else {
        _weeklySettelement = [];
        _filleterdWeeklySettelement = [];
        _errorMessage =
            'Failed to fetch settlement. Status code: ${response.statusCode}';
      }
    } catch (error) {
      debugPrint("Settlement fetch error: $error");
      _weeklySettelement = [];
      _filleterdWeeklySettelement = [];
      _errorMessage = 'An error occurred while fetching settlement.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
