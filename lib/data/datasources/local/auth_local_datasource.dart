import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:selfie_video_app/core/errors/app_exceptions.dart';
import 'package:selfie_video_app/data/models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<UserModel?> getUser();
  Future<void> cacheUser(UserModel user);
  Future<void> clearUser();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences sharedPreferences;
  static const String userKey = 'CACHED_USER';

  AuthLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<UserModel?> getUser() async {
    try {
      final jsonString = sharedPreferences.getString(userKey);
      if (jsonString != null) {
        return UserModel.fromJson(json.decode(jsonString));
      }
      return null;
    } catch (e) {
      throw CacheException('Failed to get cached user: $e');
    }
  }

  @override
  Future<void> cacheUser(UserModel user) async {
    try {
      await sharedPreferences.setString(
        userKey,
        json.encode(user.toJson()),
      );
    } catch (e) {
      throw CacheException('Failed to cache user: $e');
    }
  }

  @override
  Future<void> clearUser() async {
    try {
      await sharedPreferences.remove(userKey);
    } catch (e) {
      throw CacheException('Failed to clear user: $e');
    }
  }
}

