import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'language_event.dart';
part 'language_state.dart';

// Bloc
class LanguageBloc extends Bloc<LanguageEvent, LanguageState> {
  LanguageBloc() : super(const LanguageInitial()) {
    on<LanguageSelectedEvent>((event, emit) {
      emit(LanguageUpdating());
      emit(LanguageUpdated(languageCode: event.languageCode));
    });
  }
}
