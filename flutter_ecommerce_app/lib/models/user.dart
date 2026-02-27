// Class for every user
class AppUser {
  final String id;
  final String username;
  final String password;
  final String email;
  final String displayName;
  final bool isAdmin;

  AppUser({
    required this.id,
    required this.username,
    required this.password,
    required this.email,
    required this.displayName,
    required this.isAdmin,
  });

// Coverts user data to a JSON for storage in Firebase
  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
      'email': email,
      'displayName': displayName,
      'isAdmin': isAdmin,
    };
  }

// Converts data from Firebase into an AppUser object
  factory AppUser.fromMap(Map<String, dynamic> map, String id) {
    return AppUser(
      id: id,
      username: map['username'] as String? ?? '',
      password: map['password'] as String? ?? '',
      email: map['email'] as String? ?? '',
      displayName: map['displayName'] as String? ?? '',
      isAdmin: map['isAdmin'] as bool? ?? false,
    );
  }

// Overrides the default toString method
  @override
  String toString() {
    return 'AppUser(id: $id, username: $username, email: $email, displayName: $displayName, isAdmin: $isAdmin)';
  }
}
