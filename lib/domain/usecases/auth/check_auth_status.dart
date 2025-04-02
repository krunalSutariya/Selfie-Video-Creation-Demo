import 'package:dartz/dartz.dart';
import 'package:selfie_video_app/core/errors/app_exceptions.dart';
import 'package:selfie_video_app/domain/entities/user.dart';
import 'package:selfie_video_app/domain/repositories/auth_repository.dart';

class CheckAuthStatus {
  final AuthRepository repository;

  CheckAuthStatus(this.repository);

  Future<Either<AppException, User?>> call() async {
    return await repository.getCurrentUser();
  }
}

