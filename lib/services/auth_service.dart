import 'package:petpedia/database/database_handler.dart';
import 'package:petpedia/models/user_model.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class AuthService {
  final DatabaseHandler _dbHelper = DatabaseHandler();

  // Hash password for security
  String _hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Add this method to your AuthService class
  Future<bool> checkEmailExists(String email) async {
    return await _dbHelper.checkUserExists(email);
  }

  // Register a new user
  Future<bool> registerUser({
    required String name,
    required String email,
    required String password,
    String? phone,
    String? country,
  }) async {
    try {
      // Check if user already exists
      bool exists = await _dbHelper.checkUserExists(email);
      if (exists) {
        return false;
      }

      // Create user object
      User newUser = User(
        name: name,
        email: email,
        password: _hashPassword(password),
        phone: phone,
        country: country,
      );

      // Insert user into database
      await _dbHelper.insertUser(newUser.toMap());
      return true;
    } catch (e) {
      print('Error registering user: $e');
      return false;
    }
  }

  // Login user
  Future<User?> loginUser({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    try {
      // Get user by email
      Map<String, dynamic>? userData = await _dbHelper.getUserByEmail(email);
      if (userData == null) {
        return null; // User not found
      }

      // Check password
      String hashedPassword = _hashPassword(password);
      if (userData['password'] != hashedPassword) {
        return null; // Invalid password
      }

      // Update remember me status if needed
      await _dbHelper.updateRememberMe(email, rememberMe);

      // Return user object
      return User.fromMap(userData);
    } catch (e) {
      print('Error logging in: $e');
      return null;
    }
  }

  // Check if a user is remembered
  Future<User?> getRememberedUser() async {
    try {
      Map<String, dynamic>? userData = await _dbHelper.getRememberedUser();
      if (userData == null) {
        return null;
      }
      return User.fromMap(userData);
    } catch (e) {
      print('Error getting remembered user: $e');
      return null;
    }
  }

  Future<bool> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    try {
      // Check if user exists
      bool exists = await _dbHelper.checkUserExists(email);
      if (!exists) {
        return false; // User not found
      }

      // Update user with new hashed password
      return await _dbHelper.updateUserPassword(
        email,
        _hashPassword(newPassword),
      );
    } catch (e) {
      print('Error resetting password: $e');
      return false;
    }
  }

  // Logout user
  Future<bool> logoutUser(String email) async {
    try {
      await _dbHelper.updateRememberMe(email, false);
      return true;
    } catch (e) {
      print('Error logging out: $e');
      return false;
    }
  }
}
