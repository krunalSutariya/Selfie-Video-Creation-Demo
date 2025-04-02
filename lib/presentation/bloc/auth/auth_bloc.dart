import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:selfie_video_app/domain/entities/user.dart';
import 'package:selfie_video_app/domain/usecases/auth/check_auth_status.dart';
import 'package:selfie_video_app/domain/usecases/auth/login_user.dart';
import 'package:selfie_video_app/domain/usecases/auth/logout_user.dart';
import 'package:selfie_video_app/domain/usecases/auth/register_user.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUser loginUser;
  final RegisterUser registerUser;
  final LogoutUser logoutUser;
  final CheckAuthStatus checkAuthStatus;

  AuthBloc({
    required this.loginUser,
    required this.registerUser,
    required this.logoutUser,
    required this.checkAuthStatus,
  }) : super(AuthInitial()) {
    on<LoginEvent>(_onLogin);
    on<RegisterEvent>(_onRegister);
    on<LogoutEvent>(_onLogout);
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
  }

  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    
    final result = await loginUser(
      email: event.email,
      password: event.password,
    );
    
    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (user) => emit(Authenticated(user: user)),
    );
  }

  Future<void> _onRegister(RegisterEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    
    final result = await registerUser(
      name: event.name,
      email: event.email,
      password: event.password,
    );
    
    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (user) => emit(Authenticated(user: user)),
    );
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    
    final result = await logoutUser();
    
    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (_) => emit(Unauthenticated()),
    );
  }

  Future<void> _onCheckAuthStatus(CheckAuthStatusEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    
    final result = await checkAuthStatus();
    
    result.fold(
      (failure) => emit(Unauthenticated()),
      (user) => user != null ? emit(Authenticated(user: user)) : emit(Unauthenticated()),
    );
  }
}

