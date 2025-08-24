part of 'role_selection_bloc.dart';

enum UserRole { citizen, volunteer, officer }

abstract class RoleSelectionEvent extends Equatable {
  const RoleSelectionEvent();

  @override
  List<Object?> get props => [];
}

class RoleSelectionRoleChanged extends RoleSelectionEvent {
  final UserRole role;

  const RoleSelectionRoleChanged(this.role);

  @override
  List<Object?> get props => [role];
}

class RoleSelectionSubmitted extends RoleSelectionEvent {
  const RoleSelectionSubmitted();
}
