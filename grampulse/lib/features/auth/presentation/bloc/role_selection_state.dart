part of 'role_selection_bloc.dart';

enum RoleSelectionStatus { initial, submitting, success, failure }

class RoleSelectionState extends Equatable {
  final String? selectedRole;
  final RoleSelectionStatus status;
  final String? errorMessage;

  const RoleSelectionState({
    this.selectedRole,
    this.status = RoleSelectionStatus.initial,
    this.errorMessage,
  });

  RoleSelectionState copyWith({
    String? selectedRole,
    RoleSelectionStatus? status,
    String? errorMessage,
  }) {
    return RoleSelectionState(
      selectedRole: selectedRole ?? this.selectedRole,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [selectedRole, status, errorMessage];
}
