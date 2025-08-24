import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:grampulse/core/theme/spacing.dart';
import 'package:grampulse/core/widgets/buttons.dart';
import 'package:grampulse/features/auth/presentation/bloc/role_selection_bloc.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RoleSelectionBloc, RoleSelectionState>(
      listener: (context, state) {
        if (state.status == RoleSelectionStatus.success) {
          context.go('/home');
        } else if (state.status == RoleSelectionStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage ?? 'An error occurred')),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Select Your Role'),
            elevation: 0,
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Choose how you want to use GramPulse',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  const Text(
                    'Select the role that best describes you',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          _RoleCard(
                            title: 'Citizen',
                            description:
                                'Report issues in your area and track their resolution status',
                            icon: Icons.person,
                            isSelected: state.selectedRole == UserRole.citizen,
                            onTap: () {
                              context.read<RoleSelectionBloc>().add(
                                    const RoleSelectionRoleChanged(UserRole.citizen),
                                  );
                            },
                          ),
                          const SizedBox(height: AppSpacing.md),
                          _RoleCard(
                            title: 'Volunteer',
                            description:
                                'Help verify reported issues and assist in coordinating with officials',
                            icon: Icons.volunteer_activism,
                            isSelected: state.selectedRole == UserRole.volunteer,
                            onTap: () {
                              context.read<RoleSelectionBloc>().add(
                                    const RoleSelectionRoleChanged(UserRole.volunteer),
                                  );
                            },
                          ),
                          const SizedBox(height: AppSpacing.md),
                          _RoleCard(
                            title: 'Government Officer',
                            description:
                                'Access and respond to issues reported in your jurisdiction',
                            icon: Icons.account_balance,
                            isSelected: state.selectedRole == UserRole.officer,
                            onTap: () {
                              context.read<RoleSelectionBloc>().add(
                                    const RoleSelectionRoleChanged(UserRole.officer),
                                  );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  PrimaryButton(
                    label: 'Continue',
                    onPressed: state.selectedRole != null
                        ? () {
                            context
                                .read<RoleSelectionBloc>()
                                .add(const RoleSelectionSubmitted());
                          }
                        : () {}, // Provide an empty function for null case to satisfy non-nullable VoidCallback
                    isLoading: state.status == RoleSelectionStatus.submitting,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleCard({
    Key? key,
    required this.title,
    required this.description,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              offset: const Offset(0, 2),
              blurRadius: 8,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue : Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey,
                size: 32,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.blue : Colors.black,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Colors.blue,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}
