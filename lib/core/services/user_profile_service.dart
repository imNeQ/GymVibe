import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';

/// Service for managing user profile data.
/// Stores user profile in local storage using SharedPreferences.
class UserProfileService {
  static const String _key = 'user_profile';

  /// Get user profile from local storage.
  static Future<UserProfile> getProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);

    if (jsonString == null || jsonString.isEmpty) {
      return const UserProfile();
    }

    try {
      final Map<String, dynamic> json = jsonDecode(jsonString);
      return UserProfile.fromJson(json);
    } catch (e) {
      return const UserProfile();
    }
  }

  /// Save user profile to local storage.
  static Future<void> saveProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(profile.toJson());
    await prefs.setString(_key, jsonString);
  }

  /// Clear user profile data.
  static Future<void> clearProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
