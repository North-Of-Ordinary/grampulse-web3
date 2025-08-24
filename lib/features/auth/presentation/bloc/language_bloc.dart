import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'language_event.dart';
part 'language_state.dart';

class LanguageBloc extends Bloc<LanguageEvent, LanguageState> {
  LanguageBloc() : super(const LanguageInitial()) {
    on<LanguageSelectedEvent>(_onLanguageSelected);
  }

  Future<void> _onLanguageSelected(
    LanguageSelectedEvent event,
    Emitter<LanguageState> emit,
  ) async {
    emit(LanguageUpdating());
    
    try {
      // Save selected language to shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('languageCode', event.languageCode);
      
      // Emit success state
      emit(LanguageUpdated(languageCode: event.languageCode));
    } catch (e) {
      emit(LanguageError(message: e.toString()));
    }
  }
}
