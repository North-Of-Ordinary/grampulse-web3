part of 'splash_bloc.dart';

abstract class SplashState extends Equatable {
  const SplashState();
  
  @override
  List<Object> get props => [];
}

class SplashInitial extends SplashState {
  const SplashInitial();
}

class SplashLoading extends SplashState {
  const SplashLoading();
}

class SplashAuthenticated extends SplashState {
  const SplashAuthenticated();
}

class SplashUnauthenticated extends SplashState {
  const SplashUnauthenticated();
}

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
