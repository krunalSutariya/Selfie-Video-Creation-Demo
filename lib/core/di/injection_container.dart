import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:selfie_video_app/data/datasources/local/auth_local_datasource.dart';
import 'package:selfie_video_app/data/datasources/local/video_local_datasource.dart';
import 'package:selfie_video_app/data/datasources/remote/auth_remote_datasource.dart';
import 'package:selfie_video_app/data/datasources/remote/video_remote_datasource.dart';
import 'package:selfie_video_app/data/repositories/auth_repository_impl.dart';
import 'package:selfie_video_app/data/repositories/video_repository_impl.dart';
import 'package:selfie_video_app/domain/repositories/auth_repository.dart';
import 'package:selfie_video_app/domain/repositories/video_repository.dart';
import 'package:selfie_video_app/domain/usecases/auth/check_auth_status.dart';
import 'package:selfie_video_app/domain/usecases/auth/login_user.dart';
import 'package:selfie_video_app/domain/usecases/auth/logout_user.dart';
import 'package:selfie_video_app/domain/usecases/auth/register_user.dart';
import 'package:selfie_video_app/domain/usecases/video/create_video.dart';
import 'package:selfie_video_app/domain/usecases/video/delete_video.dart';
import 'package:selfie_video_app/domain/usecases/video/get_videos.dart';
import 'package:selfie_video_app/presentation/bloc/auth/auth_bloc.dart';
import 'package:selfie_video_app/presentation/bloc/video/video_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  // Data sources
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(sharedPreferences: sl()),
  );
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(),
  );
  sl.registerLazySingleton<VideoLocalDataSource>(
    () => VideoLocalDataSourceImpl(sharedPreferences: sl()),
  );
  sl.registerLazySingleton<VideoRemoteDataSource>(
    () => VideoRemoteDataSourceImpl(),
  );

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
    ),
  );
  sl.registerLazySingleton<VideoRepository>(
    () => VideoRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => LoginUser(sl()));
  sl.registerLazySingleton(() => RegisterUser(sl()));
  sl.registerLazySingleton(() => LogoutUser(sl()));
  sl.registerLazySingleton(() => CheckAuthStatus(sl()));
  sl.registerLazySingleton(() => GetVideos(sl()));
  sl.registerLazySingleton(() => CreateVideo(sl()));
  sl.registerLazySingleton(() => DeleteVideo(sl()));

  // BLoCs
  sl.registerFactory(
    () => AuthBloc(
      loginUser: sl(),
      registerUser: sl(),
      logoutUser: sl(),
      checkAuthStatus: sl(),
    ),
  );
  sl.registerFactory(
    () => VideoBloc(
      getVideos: sl(),
      createVideo: sl(),
      deleteVideo: sl(),
    ),
  );
}

