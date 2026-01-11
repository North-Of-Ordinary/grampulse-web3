part of 'language_bloc.dart';

abstract class LanguageEvent extends Equatable {
  const LanguageEvent();

  @override
  List<Object> get props => [];
}

class LanguageSelectedEvent extends LanguageEvent {
  final String languageCode;
  
  const LanguageSelectedEvent({required this.languageCode});
  
  @override
  List<Object> get props => [languageCode];
}
