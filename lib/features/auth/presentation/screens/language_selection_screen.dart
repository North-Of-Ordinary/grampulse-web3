import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:grampulse/core/theme/spacing.dart';
import 'package:grampulse/features/auth/presentation/bloc/language_bloc.dart';
import 'package:grampulse/l10n/l10n.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({Key? key}) : super(key: key);

  @override
  State<LanguageSelectionScreen> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  String? _selectedLanguage;

  @override
  Widget build(BuildContext context) {
    return BlocListener<LanguageBloc, LanguageState>(
      listener: (context, state) {
        if (state is LanguageUpdated) {
          // Navigate to login screen after language is updated
          context.go('/login');
        } else if (state is LanguageError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Choose Your Language'),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(Spacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Select your preferred language for the app',
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: Spacing.xl),
                Expanded(
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1.2,
                      crossAxisSpacing: Spacing.md,
                      mainAxisSpacing: Spacing.md,
                    ),
                    itemCount: L10n.all.length,
                    itemBuilder: (context, index) {
                      final locale = L10n.all[index];
                      return _buildLanguageCard(
                        context,
                        languageName: L10n.getName(locale.languageCode),
                        languageCode: locale.languageCode,
                        flag: L10n.getFlag(locale.languageCode),
                      );
                    },
                  ),
                ),
                const SizedBox(height: Spacing.md),
                BlocBuilder<LanguageBloc, LanguageState>(
                  builder: (context, state) {
                    return ElevatedButton(
                      onPressed: _selectedLanguage == null || state is LanguageUpdating
                          ? null
                          : () {
                              context.read<LanguageBloc>().add(
                                    LanguageSelectedEvent(
                                      languageCode: _selectedLanguage!,
                                    ),
                                  );
                            },
                      child: state is LanguageUpdating
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Continue'),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageCard(
    BuildContext context, {
    required String languageName,
    required String languageCode,
    required String flag,
  }) {
    final isSelected = _selectedLanguage == languageCode;

    return Card(
      elevation: isSelected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected 
              ? Theme.of(context).colorScheme.primary 
              : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedLanguage = languageCode;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(Spacing.md),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                flag,
                style: const TextStyle(fontSize: 30),
              ),
              const SizedBox(height: Spacing.xs),
              Text(
                languageName,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: Spacing.sm),
              Radio<bool>(
                value: true,
                groupValue: isSelected,
                onChanged: (_) {
                  setState(() {
                    _selectedLanguage = languageCode;
                  });
                },
                activeColor: Theme.of(context).colorScheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
