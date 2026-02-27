// Imports Firebase Realtime Database package
import 'package:firebase_database/firebase_database.dart';

// Imports user model
import '../models/user.dart';

// UsersService class for user-related operations with Firebase
class UsersService {
  // Creates a single instance of UsersService that can be used across the app
  static final UsersService _instance = UsersService._internal();
  factory UsersService() => _instance;
  UsersService._internal();

// Creates one single reference for all pages to the users model
  final DatabaseReference _ref = FirebaseDatabase.instance.ref('users');

// Fetches all users from Firebase and converts them to a list of AppUser objects
  Future<List<AppUser>> getAllUsers() async {
    // Retrieves users node from Firebase
    final snap = await _ref.get();
    // If no users exist, return an empty list
    if (!snap.exists) return [];
    // Coverts users data to a map
    final data = snap.value as Map<dynamic, dynamic>;
    // Populates that map and covnerts it to Appuser objects
    return data.entries.map((e) {
      // Goes through each user entry and extracts its data
      final id = e.key.toString();
      // extracs user data and converts it to a map
      final map = Map<String, dynamic>.from(e.value as Map);
      // returns a AppUser object with data
      return AppUser.fromMap(map, id);
      // Converts the map of users to a list of AppUser objects
    }).toList();
  }

// Creates a new user in Firebase with the provided AppUser data
  Future<bool> createUser(AppUser user) async {
    // Saves the users as JSON data in the Firebase Database
    await _ref.child(user.id).set(user.toJson());
    return true;
  }

// Searches through database for a user with mathching credentials
  Future<AppUser?> findByCredentials(String username, String password) async {
    // Retrives all users from the database
    final snap = await _ref.get();
    // If no users exist, return null
    if (!snap.exists) return null;
    // Converts user data to a Map
    final data = snap.value as Map<dynamic, dynamic>;
    // For loop to go through each user and find matches
    for (final e in data.entries) {
      // converts user id to string so it can be compared
      final id = e.key.toString();
      // Converts data to a mao
      final map = Map<String, dynamic>.from(e.value as Map);
      // Compares username and passwords with database
      if ((map['username'] ?? '') == username &&
          (map['password'] ?? '') == password) {
        // Returns user if credentials match
        return AppUser.fromMap(map, id);
      }
    }
    return null;
  }
}
