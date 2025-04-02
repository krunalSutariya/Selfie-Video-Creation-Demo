import 'package:dartz/dartz.dart';
import 'package:selfie_video_app/core/errors/app_exceptions.dart';
import 'package:selfie_video_app/domain/entities/user.dart';

abstract class AuthRepository {
  Future<Either<AppException, User>> login({
    required String email,
    required String password,
  });

  Future<Either<AppException, User>> register({
    required String name,
    required String email,
    required String password,
  });

  Future<Either<AppException, void>> logout();

  Future<Either<AppException, User?>> getCurrentUser();
}

