import 'package:flutter_bloc/flutter_bloc.dart';
import 'citizen_home_event.dart';
import 'citizen_home_state.dart';

class CitizenHomeBloc extends Bloc<CitizenHomeEvent, CitizenHomeState> {
  CitizenHomeBloc() : super(const CitizenHomeInitial()) {
    on<LoadDashboard>((event, emit) {
      emit(const CitizenHomeLoading());
      emit(const CitizenHomeLoaded(
        userName: 'Test User',
        statistics: {},
      ));
    });
    
    on<RefreshDashboard>((event, emit) {
      emit(const CitizenHomeLoading());
      emit(const CitizenHomeLoaded(
        userName: 'Test User',
        statistics: {},
      ));
    });
  }
}
