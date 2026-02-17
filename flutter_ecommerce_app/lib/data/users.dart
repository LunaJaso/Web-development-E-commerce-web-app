import '../models/user.dart';

// User data
final List<AppUser> users = [
  AppUser(
    id: '1',
    username: 'test',
    password: '1234',
    email: 'test@email.com',
    displayName: 'Test',
    isAdmin: false,
  ),
  AppUser(
    id: '2',
    username: 'admin',
    password: '1234',
    email: 'admin@email.com',
    displayName: 'Admin',
    isAdmin: true,
  ),
  AppUser(
    id: '3',
    username: 'customer',
    password: 'password',
    email: 'customer@email.com',
    displayName: 'Customer',
    isAdmin: false,
  ),
];
