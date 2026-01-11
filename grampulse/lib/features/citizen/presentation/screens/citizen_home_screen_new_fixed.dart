import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/domain/auth_events_states.dart';
import '../../../auth/presentation/blocs/auth_bloc.dart';

class CitizenHomeScreenNew extends StatefulWidget {
  const CitizenHomeScreenNew({Key? key}) : super(key: key);

  @override
  State<CitizenHomeScreenNew> createState() => _CitizenHomeScreenNewState();
}

class _CitizenHomeScreenNewState extends State<CitizenHomeScreenNew> {
  @override
  void initState() {
    super.initState();
    // Redirect to new citizen dashboard immediately
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.go('/citizen');
    });
  }

  void _logout() {
    context.read<AuthBloc>().add(LogoutEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthInitial) {
          context.go('/auth');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('GramPulse'),
          backgroundColor: Colors.blue.shade600,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              onPressed: _logout,
              icon: const Icon(Icons.logout),
              tooltip: 'Logout',
            ),
          ],
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Redirecting to dashboard...'),
            ],
          ),
        ),
      ),
    );
  }
}
