import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:media_house/app/core/constant/api_constant.dart';
import 'package:media_house/data/models/shorts.dart';

class ShortProvider extends ChangeNotifier {
  List<ShortModel> shorts = [];
  ShortDetailModel? shortDetail;
  bool isLoading = false;

  Future<void> fetchShorts() async {
    try {
      isLoading = true;
      notifyListeners();

      var url = Uri.parse(ApiConstant.shortsMaster);
      var response = await http.get(url);
      final data = jsonDecode(response.body);

      shorts =
          (data["data"] as List).map((e) => ShortModel.fromJson(e)).toList();
    } catch (e) {
      print("Shorts Fetch Error → $e");
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> fetchShortDetail(int id, int userId) async {
    try {
      isLoading = true;
      notifyListeners();

      var url = Uri.parse(ApiConstant.shortsDetails(id, userId));
      var response = await http.get(url);
      final data = jsonDecode(response.body);

      shortDetail = ShortDetailModel.fromJson(data["data"]);
    } catch (e) {
      print("Short Detail Error → $e");
    }

    isLoading = false;
    notifyListeners();
  }

  Future<bool> addShortMaster(Map<String, dynamic> body) async {
    try {
      isLoading = true;
      notifyListeners();

      final url = Uri.parse(ApiConstant.addShortMaster);

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data["success"] == true) {
        /// If API returns created short detail
        if (data["data"] != null) {
          shortDetail = ShortDetailModel.fromJson(data["data"]);
        }

        /// Re-fetch list to update UI
        await fetchShorts();

        isLoading = false;
        notifyListeners();
        return true; // success
      } else {
        print("Add Short Error → ${data["message"]}");
      }
    } catch (e) {
      print("Add Short Exception → $e");
    }

    isLoading = false;
    notifyListeners();
    return false; // failed
  }
}
