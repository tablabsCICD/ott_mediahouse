import 'dart:convert';

import 'package:http/http.dart';
import 'package:http/http.dart' as http;

import '../../../data/models/api_response.dart';
import '../auth/auth_service.dart';
import '../constant/api_constant.dart';
import '../storage/storage_service.dart';

class ApiHelper {
  static Future<bool>? _refreshInFlight;

  Future<dynamic> getApi(String URL) async {
    final request = await _send(
      URL,
      () async => http
          .get(Uri.parse(URL), headers: await AuthService.authHeaders())
          .timeout(const Duration(seconds: 10)),
    );
    return request;
  }

  Future<dynamic> deleteApi(String URL) async {
    final request = await _send(
      URL,
      () async => http.delete(
        Uri.parse(URL),
        headers: await AuthService.authHeaders(),
      ),
    );
    return request;
  }

  Future<dynamic> postApi(String URL) async {
    final request = await _send(
      URL,
      () async => http.post(
        Uri.parse(URL),
        headers: await AuthService.authHeaders(),
      ),
    );
    return request;
  }

  Future<dynamic> postApiWithBody(String url, Map<String, dynamic> data) async {
    final body = json.encode(data);
    final response = await _send(
      url,
      () async => http.post(
        Uri.parse(url),
        headers: await AuthService.authHeaders(),
        body: body,
      ),
    );
    return response;
  }

  Future<dynamic> putApi(String URL) async {
    final request = await _send(
      URL,
      () async => http.put(
        Uri.parse(URL),
        headers: await AuthService.authHeaders(),
      ),
    );
    return request;
  }

  Future<dynamic> putApiWithBody(String url, Map<String, dynamic> data) async {
    final body = json.encode(data);
    final response = await _send(
      url,
      () async => http.put(
        Uri.parse(url),
        headers: await AuthService.authHeaders(),
        body: body,
      ),
    );
    return response;
  }

  Future<dynamic> postApiWithoutAuthToken(String URL) async {
    final request = await http.post(Uri.parse(URL));
    return request;
  }

  Future<dynamic> postApiWithoutBodyAndToken(
      String url, Map<String, dynamic> data) async {
    final body = json.encode(data);
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: body,
    );
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
    if (response.statusCode == 403) {
      await StorageService.instance.cacheInvalidation.clearAllProtectedCache();
      return response;
    }
    if (response.statusCode != 401 || _isAuthUrl(url)) {
      return response;
    }

    final refreshed = await _refreshOnce();
    if (refreshed) {
      return request();
    }

    await AuthService.logout(sessionExpired: true);
    return response;
  }

  Future<bool> _refreshOnce() {
    final running = _refreshInFlight;
    if (running != null) return running;
    final refresh = _tryRefreshToken();
    _refreshInFlight = refresh;
    return refresh.whenComplete(() => _refreshInFlight = null);
  }

  bool _isAuthUrl(String url) {
    return url == ApiConstant.twoStepLogin ||
        url == ApiConstant.twoStepVerifyOtp ||
        url == ApiConstant.refreshAuthToken;
  }

  Future<bool> _tryRefreshToken() async {
    final refreshToken = await AuthService.getRefreshToken();
    if (refreshToken == null || refreshToken.trim().isEmpty) {
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

      await AuthService.updateTokens(
        accessToken: accessToken,
        refreshToken: newRefreshToken,
      );
      return true;
    } catch (_) {
      return false;
    }
  }
}
