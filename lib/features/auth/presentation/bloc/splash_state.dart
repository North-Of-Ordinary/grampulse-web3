part of 'splash_bloc.dart';

abstract class SplashState extends Equatable {
  const SplashState();
  
  @override
  List<Object> get props => [];
}

class SplashInitial extends SplashState {}

class SplashLoading extends SplashState {}

class SplashAuthenticated extends SplashState {}

class SplashUnauthenticated extends SplashState {}

class SplashUpdateRequired extends SplashState {
  final String currentVersion;
  final String requiredVersion;
  
  const SplashUpdateRequired({
    required this.currentVersion,
    required this.requiredVersion,
  });
  
  @override
  List<Object> get props => [currentVersion, requiredVersion];
}

class SplashError extends SplashState {
  final String message;
  
  const SplashError({required this.message});
  
  @override
  List<Object> get props => [message];
}
