import 'package:dartz/dartz.dart';
import 'package:selfie_video_app/core/errors/app_exceptions.dart';
import 'package:selfie_video_app/domain/repositories/auth_repository.dart';

class LogoutUser {
  final AuthRepository repository;

  LogoutUser(this.repository);

  Future<Either<AppException, void>> call() async {
    return await repository.logout();
  }
}

