// Imports flutter design widgets
import 'package:flutter/material.dart';

// Imports authentication.dart (adds login and logout functionality)
import '../auth/authentication.dart';

// Import user model and users data
import '../models/user.dart';
import '../services/users_service.dart';

// Profile that adapts to Login/Logout changes (use statefulwidget instead of stateless)
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

// State class holds variables and logic for this page
class _ProfilePageState extends State<ProfilePage> {
  // Creates an instance of AuthService
  final auth = AuthService();

  // shows login form by default, changes when user interacts with login and logout buttons as a toggle
  bool showLogin = true;

  // Controllers read input text from each corresponding field
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final nameControlller = TextEditingController();
  final emailController = TextEditingController();

  // Error message if login fails
  String errorMessage = "";

  // Variables to detect authentication status and information
  bool get isLoggedIn => auth.isLoggedIn;
  String get userName => auth.userName ?? "";
  String get email => auth.email ?? "";

// Create account function
  void _createAccount() {
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();
    final email = emailController.text.trim();
    final displayName = nameControlller.text.trim();

// Checks for missing inputs
    if (username.isEmpty ||
        password.isEmpty ||
        email.isEmpty ||
        displayName.isEmpty) {
      setState(() => errorMessage = "Please fill in all fields");
      return;
    }
    // Create new user to Firebase
    final newUser = AppUser(
      // Generates a random id based on current time
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      username: username,
      password: password,
      email: email,
      displayName: displayName,
      isAdmin: false,
    );

    // Check for existing username in Firebase and then create
    UsersService().getAllUsers().then((list) async {
      // Checks if user already exists
      final exists = list.any((u) => u.username == username);
      if (exists) {
        // Returns error message if user already exists
        setState(() => errorMessage = "Username already taken");
        return;
      }
      // creates new user
      await UsersService().createUser(newUser);
      setState(() {
        // Displays success message and clears input fields
        errorMessage = "Account created successfully! You can now log in.";
        usernameController.clear();
        passwordController.clear();
        emailController.clear();
        nameControlller.clear();
      });
    }).catchError((e) {
      // Displays error message if account creation fails
      setState(() => errorMessage = "Failed to create account: $e");
    });
  }

  // Removes widget from memory, (prevents memory leaks)
  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    nameControlller.dispose();
    emailController.dispose();
    super.dispose();
  }

  // Page UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Top AppBar
      appBar: AppBar(title: const Text('Profile'), centerTitle: true),
      // Padding and content
      body: Padding(
        padding: const EdgeInsets.all(16),

        // Chooses different UI for each login status
        child: isLoggedIn ? _loggedInView() : _loggedOutView(),
      ),
    );
  }

  // Logged In UI starts here
  Widget _loggedInView() {
    return ListView(
      children: [
        // Displays user information in profile header
        _ProfileHeader(userName: userName, email: email),
        const SizedBox(height: 24),

        // Placeholder options (subject to change)
        const _ProfileOption(title: 'Edit Profile', icon: Icons.edit),
        const _ProfileOption(title: 'Orders', icon: Icons.shopping_bag),
        const _ProfileOption(title: 'Settings', icon: Icons.settings),
        const _ProfileOption(title: 'Help & Support', icon: Icons.help_outline),
        const SizedBox(height: 24),

        // Logout button
        _LogoutButton(
          onLogout: () async {
            await auth.logout(); // Logs out user
            setState(() {}); // Rebuilds UI
          },
        ),
      ],
    );
  }

  // Logged Out UI starts here
  Widget _loggedOutView() {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Default lock icon
            const Icon(Icons.lock_outline, size: 70, color: Colors.grey),
            const SizedBox(height: 16),

            // Title
            const Text(
              "Login",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            // Username input field
            TextField(
              controller:
                  usernameController, // This is where username text is read
              decoration: const InputDecoration(
                labelText: "Username",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            // Password input field (hides input text)
            TextField(
              controller:
                  passwordController, // This is where password text is read
              obscureText: true, // Hides input
              decoration: const InputDecoration(
                labelText: "Password",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            Visibility(
              visible: !showLogin,
              child: Column(
                children: [
                  TextField(
                    controller: nameControlller,
                    decoration: const InputDecoration(
                      labelText: "Name",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),

            Visibility(
              visible: !showLogin,
              child: Column(
                children: [
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: "Email",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),

            // Display error message
            if (errorMessage.isNotEmpty)
              Text(errorMessage, style: const TextStyle(color: Colors.red)),

            const SizedBox(height: 16),

            // Login button
            Visibility(
              visible: showLogin,
              child: ElevatedButton(
                onPressed: () async {
                  final success = await auth.login(
                    username: usernameController.text.trim(),
                    password: passwordController.text.trim(),
                  );

                  if (success) {
                    setState(() => errorMessage = "");
                  } else {
                    setState(
                        () => errorMessage = "Invalid username or password");
                  }
                },
                child: const Text("Log In"),
              ),
            ),

            const SizedBox(height: 8),

// Create Account button
            Visibility(
              visible: !showLogin,
              child: ElevatedButton(
                onPressed: _createAccount,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                child: const Text("Create Account"),
              ),
            ),

            TextButton(
              onPressed: () {
                setState(() {
                  showLogin = !showLogin;
                  errorMessage = "";
                });
              },
              child: Text(
                showLogin ? "Create an account" : "Back to login",
              ),
            )
          ],
        ),
      ),
    );
  }
}

// Profile UI

// Displays user information
class _ProfileHeader extends StatelessWidget {
  final String userName;
  final String email;

  const _ProfileHeader({required this.userName, required this.email});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Placeholder for profile image
        const CircleAvatar(
          radius: 40,
          backgroundImage: AssetImage('assets/profile_placeholder.png'),
        ),
        const SizedBox(height: 12),

        // User name
        Text(
          userName,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),

        // Email
        Text(email, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}

class _ProfileOption extends StatelessWidget {
  final String title;
  final IconData icon;

  const _ProfileOption({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {}, // Needs navigation logic (not added yet)
      ),
    );
  }
}

// Logout button
class _LogoutButton extends StatelessWidget {
  final VoidCallback onLogout;

  const _LogoutButton({required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onLogout,
      child: const Text('Log Out'),
    ); // Calls onLogout function here
  }
}
