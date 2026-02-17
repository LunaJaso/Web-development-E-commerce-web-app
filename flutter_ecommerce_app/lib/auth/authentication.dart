// Imports local users
import '../data/users.dart';
// Imports user model
import '../models/user.dart';

class AuthService {
  // These three lines create an internal static instance of AuthService that can be used across each page
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // Indicates whether a user is logged in
  bool _isLoggedIn = false;
  // Holds the currently logged in user
  AppUser? _currentUser;

  // Checks if current user is an admin
  bool get isAdmin => _currentUser?.isAdmin ?? false;
  // Checks if user is logged in (updates UI)
  bool get isLoggedIn => _isLoggedIn;
  // Returns currentUser's displayName
  String? get userName => _currentUser?.displayName;
  // Returns currentUser's email
  String? get email => _currentUser?.email;

  // Login function, username and password input, true if correct false if incorrect
  Future<bool> login({
    required String username,
    required String password,
  }) async {
    try {
      // Searches for a user model that matches the information in data
      final user = users.firstWhere(
        (u) => u.username == username && u.password == password,
      );

      // Stores current user
      _currentUser = user;
      // Sets login to true
      _isLoggedIn = true;
      // returns login is true, otherwise false
      return true;
    }
    // Catches any errors, returns false if no matches found
    catch (_) {
      return false;
    }
  }

  // Set current user to null and sets isLoggedIn to false
  Future<void> logout() async {
    _currentUser = null;
    _isLoggedIn = false;
  }
}
