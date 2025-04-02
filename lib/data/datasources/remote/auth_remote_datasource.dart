import 'dart:math';

import 'package:selfie_video_app/core/errors/app_exceptions.dart';
import 'package:selfie_video_app/data/models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login({
    required String email,
    required String password,
  });

  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Random _random = Random();

  // Mock user data
  final List<Map<String, dynamic>> _users = [
    {
      'id': '1',
      'name': 'John Doe',
      'email': 'john@example.com',
      'password': 'password123',
    },
    {
      'id': '2',
      'name': 'Jane Smith',
      'email': 'jane@example.com',
      'password': 'password123',
    },
  ];

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 300 + _random.nextInt(700)));

    // Simulate random errors (10% chance)
    if (_random.nextInt(10) == 0) {
      final errorType = _random.nextInt(3);
       if (errorType == 1) {
        throw ServerException('Server unavailable. Please try again later.', 503);
      } else {
        throw ServerException('Internal server error. Please try again later.', 500);
      }
    }

    // Find user
    final user = _users.firstWhere(
      (user) => user['email'] == email && user['password'] == password,
      orElse: () => {},
    );

    if (user.isNotEmpty) {
      return UserModel.fromJson({
        'id': user['id'],
        'name': user['name'],
        'email': user['email'],
      });
    } else {
      throw AuthException('Invalid email or password', 401);
    }
  }

  @override
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 300 + _random.nextInt(700)));

    // Simulate random errors (10% chance)
    if (_random.nextInt(10) == 0) {
      final errorType = _random.nextInt(3);
      if (errorType == 1) {
        throw ServerException('Server unavailable. Please try again later.', 503);
      } else {
        throw ServerException('Internal server error. Please try again later.', 500);
      }
    }

    // Check if email already exists
    final existingUser = _users.firstWhere(
      (user) => user['email'] == email,
      orElse: () => {},
    );

    if (existingUser.isNotEmpty) {
      throw AuthException('Email already in use', 409);
    }

    // Create new user
    final newUser = {
      'id': (_users.length + 1).toString(),
      'name': name,
      'email': email,
      'password': password,
    };

    _users.add(newUser);

    return UserModel.fromJson({
      'id': newUser['id'],
      'name': newUser['name'],
      'email': newUser['email'],
    });
  }
}
