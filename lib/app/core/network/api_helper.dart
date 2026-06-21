import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../data/models/api_response.dart';
import '../auth/auth_service.dart';
import '../constant/api_constant.dart';
import '../constant/prefrense_constant.dart';

class ApiHelper {
  Future<dynamic> getApi(String URL) async {
    debugPrint('API GET $URL');
    final request = await _send(
      URL,
      () async => http
          .get(Uri.parse(URL), headers: await AuthService.authHeaders())
          .timeout(const Duration(seconds: 10)),
    );
    debugPrint(request.body);
    return request;
  }

  Future<dynamic> deleteApi(String URL) async {
    debugPrint('API DELETE $URL');
    final request = await _send(
      URL,
      () async => http.delete(
        Uri.parse(URL),
        headers: await AuthService.authHeaders(),
      ),
    );
    debugPrint(request.body);
    return request;
  }

  Future<dynamic> postApi(String URL) async {
    debugPrint('API POST $URL');
    final request = await _send(
      URL,
      () async => http.post(
        Uri.parse(URL),
        headers: await AuthService.authHeaders(),
      ),
    );
    debugPrint(request.body);
    return request;
  }

  Future<dynamic> postApiWithBody(String url, Map<String, dynamic> data) async {
    debugPrint('API POST $url');
    final body = json.encode(data);
    debugPrint(body);
    final response = await _send(
      url,
      () async => http.post(
        Uri.parse(url),
        headers: await AuthService.authHeaders(),
        body: body,
      ),
    );
    debugPrint(response.body);
    return response;
  }

  Future<dynamic> putApi(String URL) async {
    debugPrint('API PUT $URL');
    final request = await _send(
      URL,
      () async => http.put(
        Uri.parse(URL),
        headers: await AuthService.authHeaders(),
      ),
    );
    debugPrint(request.body);
    return request;
  }

  Future<dynamic> putApiWithBody(String url, Map<String, dynamic> data) async {
    debugPrint('API PUT $url');
    final body = json.encode(data);
    debugPrint(body);
    final response = await _send(
      url,
      () async => http.put(
        Uri.parse(url),
        headers: await AuthService.authHeaders(),
        body: body,
      ),
    );
    debugPrint(response.body);
    return response;
  }

  Future<dynamic> postApiWithoutAuthToken(String URL) async {
    debugPrint('API POST PUBLIC $URL');
    final request = await http.post(Uri.parse(URL));
    debugPrint(request.body);
    return request;
  }

  Future<dynamic> postApiWithoutBodyAndToken(
      String url, Map<String, dynamic> data) async {
    debugPrint('API POST PUBLIC $url');
    final body = json.encode(data);
    debugPrint(body);
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: body,
    );
    debugPrint(response.body);
    return response;
  }

  Future<http.MultipartRequest> multipartRequest(
    String method,
    Uri uri,
  ) async {
    final request = http.MultipartRequest(method, uri);
    request.headers.addAll(await AuthService.authHeaders(includeJson: false));
    return request;
  }

  ApiResponse returnResponse<T>(Response request) {
    if (request.statusCode == 200 ||
        request.statusCode == 400 ||
        request.statusCode == 201) {
      debugPrint('API response ${request.body}');
      final response = jsonDecode(request.body);
      return ApiResponse(request.statusCode, response);
    } else {
      return ApiResponse(request.statusCode, null);
    }
  }

  Future<http.Response> _send(
    String url,
    Future<http.Response> Function() request,
  ) async {
    final response = await request();
    if (response.statusCode != 401 || _isAuthUrl(url)) {
      return response;
    }

    final refreshed = await _tryRefreshToken();
    if (refreshed) {
      return request();
    }

    await AuthService.logout(sessionExpired: true);
    return response;
  }

  bool _isAuthUrl(String url) {
    return url == ApiConstant.twoStepLogin ||
        url == ApiConstant.twoStepVerifyOtp ||
        url == ApiConstant.refreshAuthToken;
  }

  Future<bool> _tryRefreshToken() async {
    final refreshToken = await AuthService.getRefreshToken();
    if (refreshToken == null || refreshToken.trim().isEmpty) {
      debugPrint('JWT Expired');
      return false;
    }

    try {
      final response = await http.post(
        Uri.parse(ApiConstant.refreshAuthToken),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': refreshToken}),
      );

      if (response.statusCode != 200) {
        return false;
      }

      final body = jsonDecode(response.body);
      final data = body is Map<String, dynamic> ? body['data'] : null;
      final accessToken = data is Map<String, dynamic>
          ? (data['token'] ?? data['accessToken'])?.toString()
          : null;
      final newRefreshToken = data is Map<String, dynamic>
          ? data['refreshToken']?.toString()
          : null;

      if (accessToken == null || accessToken.trim().isEmpty) {
        return false;
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(SharedPreferencesConstant.accessToken, accessToken);
      await prefs.setString(SharedPreferencesConstant.token, accessToken);
      if (newRefreshToken != null && newRefreshToken.trim().isNotEmpty) {
        await prefs.setString(
          SharedPreferencesConstant.refreshToken,
          newRefreshToken,
        );
      }
      debugPrint('JWT Stored');
      return true;
    } catch (error) {
      debugPrint('Refresh token failed: $error');
      return false;
    }
  }
}
