part of 'language_bloc.dart';

abstract class LanguageState extends Equatable {
  const LanguageState();
  
  @override
  List<Object> get props => [];
}

class LanguageInitial extends LanguageState {
  const LanguageInitial();
}

class LanguageUpdating extends LanguageState {}

class LanguageUpdated extends LanguageState {
  final String languageCode;
  
  const LanguageUpdated({required this.languageCode});
  
  @override
  List<Object> get props => [languageCode];
}

class LanguageError extends LanguageState {
  final String message;
  
  const LanguageError({required this.message});
  
  @override
  List<Object> get props => [message];
}
