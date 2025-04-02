import 'package:dartz/dartz.dart';
import 'package:selfie_video_app/core/errors/app_exceptions.dart';
import 'package:selfie_video_app/data/datasources/local/auth_local_datasource.dart';
import 'package:selfie_video_app/data/datasources/remote/auth_remote_datasource.dart';
import 'package:selfie_video_app/data/models/user_model.dart';
import 'package:selfie_video_app/domain/entities/user.dart';
import 'package:selfie_video_app/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<AppException, User>> login({
    required String email,
    required String password,
  }) async {
    try {
      final user = await remoteDataSource.login(
        email: email,
        password: password,
      );
      
      await localDataSource.cacheUser(user);
      
      return Right(user);
    } on AppException catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerException('An unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<AppException, User>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final user = await remoteDataSource.register(
        name: name,
        email: email,
        password: password,
      );
      
      await localDataSource.cacheUser(user);
      
      return Right(user);
    } on AppException catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerException('An unexpected error occurred: $e'));
    }
  }

  @override
  Future<Either<AppException, void>> logout() async {
    try {
      await localDataSource.clearUser();
      return const Right(null);
    } on AppException catch (e) {
      return Left(e);
    } catch (e) {
      return Left(CacheException('Failed to logout: $e'));
    }
  }

  @override
  Future<Either<AppException, User?>> getCurrentUser() async {
    try {
      final user = await localDataSource.getUser();
      return Right(user);
    } on AppException catch (e) {
      return Left(e);
    } catch (e) {
      return Left(CacheException('Failed to get current user: $e'));
    }
  }
}

