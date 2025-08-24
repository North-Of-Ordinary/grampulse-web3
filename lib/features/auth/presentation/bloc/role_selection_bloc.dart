import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'role_selection_event.dart';
part 'role_selection_state.dart';

class RoleSelectionBloc extends Bloc<RoleSelectionEvent, RoleSelectionState> {
  RoleSelectionBloc() : super(const RoleSelectionState()) {
    on<RoleSelectionRoleChanged>(_onRoleChanged);
    on<RoleSelectionSubmitted>(_onSubmitted);
  }

  FutureOr<void> _onRoleChanged(
    RoleSelectionRoleChanged event,
    Emitter<RoleSelectionState> emit,
  ) {
    emit(state.copyWith(selectedRole: event.role));
  }

  FutureOr<void> _onSubmitted(
    RoleSelectionSubmitted event,
    Emitter<RoleSelectionState> emit,
  ) async {
    emit(state.copyWith(status: RoleSelectionStatus.submitting));
    
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));
      
      // In a real app, we would call repository to save user role
      
      emit(state.copyWith(status: RoleSelectionStatus.success));
    } catch (e) {
      emit(state.copyWith(
        status: RoleSelectionStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }
}
