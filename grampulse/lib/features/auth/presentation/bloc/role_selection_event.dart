part of 'role_selection_bloc.dart';

abstract class RoleSelectionEvent extends Equatable {
  const RoleSelectionEvent();

  @override
  List<Object?> get props => [];
}

class RoleSelectionRoleChanged extends RoleSelectionEvent {
  final String role;

  const RoleSelectionRoleChanged(this.role);

  @override
  List<Object?> get props => [role];
}

class RoleSelectionSubmitted extends RoleSelectionEvent {
  const RoleSelectionSubmitted();
}
