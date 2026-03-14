// Users service for Firebase-backed user storage
import '../services/users_service.dart';
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

  // Returns the current user's ID
  String? get userId => _currentUser?.id;
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
    // Use UsersService to look up credentials in Firebase
    final user = await UsersService().findByCredentials(username, password);
    if (user != null) {
      _currentUser = user;
      _isLoggedIn = true;
      return true;
    }
    return false;
  }

  // Set current user to null and sets isLoggedIn to false
  Future<void> logout() async {
    _currentUser = null;
    _isLoggedIn = false;
  }
}
