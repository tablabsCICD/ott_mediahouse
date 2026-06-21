import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:media_house/app/core/constant/app_constant.dart';
import 'package:media_house/app/core/constant/prefrense_constant.dart';
import 'package:media_house/app/core/navigation/app_navigator.dart';
import 'package:media_house/app/ui/pages/sign%20in%20page/SignInPage.dart';
import 'package:media_house/domain/entities/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  AuthService._();

  static const List<String> productionHouseRoles = [
    'MediaHouse',
    'Director',
    'Admin',
    'ProductionHouse',
  ];

  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(SharedPreferencesConstant.accessToken) ??
        prefs.getString(SharedPreferencesConstant.token);
  }

  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(SharedPreferencesConstant.refreshToken);
  }

  static Future<Map<String, String>> authHeaders({
    bool includeJson = true,
  }) async {
    final token = await getAccessToken();
    final headers = <String, String>{};
    if (includeJson) {
      headers['Content-Type'] = 'application/json';
    }
    if (token != null && token.trim().isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  static Future<bool> isAuthenticated() async {
    final prefs = await SharedPreferences.getInstance();
    final token = await getAccessToken();
    final userJson = prefs.getString(SharedPreferencesConstant.currentUser);
    if ((prefs.getBool(SharedPreferencesConstant.isLogin) ?? false) != true ||
        token == null ||
        token.trim().isEmpty ||
        userJson == null ||
        userJson.trim().isEmpty) {
      return false;
    }

    try {
      final user = User.fromJson(jsonDecode(userJson));
      return hasProductionHouseAccess(user);
    } catch (_) {
      return false;
    }
  }

  static bool hasProductionHouseAccess(User? user) {
    final roles = user?.role ?? const [];
    return roles.any(
      (role) => productionHouseRoles
          .map((item) => item.toLowerCase())
          .contains(role.toString().toLowerCase()),
    );
  }

  static Future<void> saveLoginSession({
    required String accessToken,
    String? refreshToken,
    String? sessionId,
    required User user,
    List<dynamic>? permissions,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final roles = user.role?.map((role) => role.toString()).toList() ?? [];
    final userName = (user.emailId?.trim().isNotEmpty ?? false)
        ? user.emailId!
        : (user.mobileNumber ?? '');
    final loginTime = DateTime.now().toIso8601String();

    await prefs.setBool(SharedPreferencesConstant.isLogin, true);
    await prefs.setString(SharedPreferencesConstant.accessToken, accessToken);
    await prefs.setString(SharedPreferencesConstant.token, accessToken);
    if (refreshToken != null && refreshToken.trim().isNotEmpty) {
      await prefs.setString(
          SharedPreferencesConstant.refreshToken, refreshToken);
    } else {
      await prefs.remove(SharedPreferencesConstant.refreshToken);
    }
    if (sessionId != null && sessionId.trim().isNotEmpty) {
      await prefs.setString(SharedPreferencesConstant.sessionId, sessionId);
    }
    if (user.id != null) {
      await prefs.setInt(SharedPreferencesConstant.userId, user.id!);
    }
    await prefs.setString(SharedPreferencesConstant.userName, userName);
    await prefs.setString(SharedPreferencesConstant.role, jsonEncode(roles));
    await prefs.setString(
      SharedPreferencesConstant.permissions,
      jsonEncode(permissions ?? const []),
    );
    await prefs.setString(SharedPreferencesConstant.loginTime, loginTime);
    await prefs.setString(
      SharedPreferencesConstant.currentUser,
      jsonEncode(user.toJson()),
    );

    debugPrint('JWT Stored');
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(SharedPreferencesConstant.isLogin, false);
    await prefs.remove(SharedPreferencesConstant.currentUser);
    await prefs.remove(SharedPreferencesConstant.currentMediaHouse);
    await prefs.remove(SharedPreferencesConstant.accessToken);
    await prefs.remove(SharedPreferencesConstant.token);
    await prefs.remove(SharedPreferencesConstant.refreshToken);
    await prefs.remove(SharedPreferencesConstant.sessionId);
    await prefs.remove(SharedPreferencesConstant.userId);
    await prefs.remove(SharedPreferencesConstant.userName);
    await prefs.remove(SharedPreferencesConstant.role);
    await prefs.remove(SharedPreferencesConstant.permissions);
    await prefs.remove(SharedPreferencesConstant.loginTime);
  }

  static Future<void> logout({
    bool sessionExpired = false,
    bool navigateToLogin = true,
  }) async {
    debugPrint(sessionExpired ? 'JWT Expired' : 'Logout Triggered');
    await clearSession();

    if (!navigateToLogin) return;

    final context = navigatorKey.currentContext;
    if (context == null) return;

    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      SnackBar(
        content: Text(sessionExpired
            ? 'Session expired. Please login again.'
            : 'Logged out.'),
      ),
    );
    navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const SignInPage()),
      (_) => false,
    );
  }

  static Future<String> getOrCreateDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getString(SharedPreferencesConstant.deviceId);
    if (existing != null && existing.trim().isNotEmpty) {
      return existing;
    }

    final random = Random.secure();
    final randomPart = [
      random.nextInt(0x7fffffff).toRadixString(16),
      random.nextInt(0x7fffffff).toRadixString(16),
    ].join();
    final deviceId = 'web-${DateTime.now().microsecondsSinceEpoch}-$randomPart';
    await prefs.setString(SharedPreferencesConstant.deviceId, deviceId);
    return deviceId;
  }

  static Future<Map<String, dynamic>> buildDevicePayload({
    required String username,
    required String otp,
  }) async {
    final deviceId = await getOrCreateDeviceId();
    final platform = defaultTargetPlatform.name;
    final deviceName = kIsWeb ? 'Browser' : platform;

    return {
      'appVersion': AppConstant.appVersion,
      'deviceId': deviceId,
      'deviceMetadata':
          kIsWeb ? 'Flutter Web - $platform' : 'Flutter - $platform',
      'deviceName': deviceName,
      'deviceToken': '',
      'deviceType': 'WEB',
      'osName': platform,
      'otp': otp,
      'username': username,
    };
  }
}
