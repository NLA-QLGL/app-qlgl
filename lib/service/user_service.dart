import 'dart:async';
import '../models/user.dart';

class UserService {
  // Singleton pattern
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  // In-memory user data (in a real app, this would be stored in a database or API)
  User _currentUser = User.getSampleUser();

  // Get the current user
  User get currentUser => _currentUser;

  // Update user profile
  Future<bool> updateProfile({
    required String name,
    required String email,
    required String phone,
    required String address,
  }) async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      // Update the user data
      _currentUser = _currentUser.copyWith(
        name: name,
        email: email,
        phone: phone,
        address: address,
      );

      return true;
    } catch (e) {
      print('Error updating profile: $e');
      return false;
    }
  }

  // Update user avatar
  Future<bool> updateAvatar(String avatarPath) async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // Update the avatar
      _currentUser = _currentUser.copyWith(avatar: avatarPath);

      return true;
    } catch (e) {
      print('Error updating avatar: $e');
      return false;
    }
  }
}