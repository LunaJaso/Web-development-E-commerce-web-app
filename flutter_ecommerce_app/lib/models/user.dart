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
}
