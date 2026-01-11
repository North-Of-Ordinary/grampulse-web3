import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:grampulse/app/router.dart';
import 'package:grampulse/core/theme/app_theme.dart';
import 'package:grampulse/core/presentation/theme/theme_cubit.dart';
import 'package:grampulse/features/auth/bloc/auth_bloc.dart';
import 'package:grampulse/features/auth/bloc/auth_event.dart';
import 'package:grampulse/core/utils/l10n/app_localizations.dart';
import 'package:grampulse/features/citizen/presentation/bloc/incident/incident_bloc.dart';
import 'package:grampulse/features/citizen/domain/repositories/incident_repository.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    // Set preferred orientations
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeCubit>(
          create: (context) => ThemeCubit(),
        ),
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc()..add(const CheckAuthStatusEvent()),
        ),
        BlocProvider<IncidentBloc>(
          create: (context) => IncidentBloc(
            repository: IncidentRepository(),
          ),
        ),
        RepositoryProvider<IncidentRepository>(
          create: (context) => IncidentRepository(),
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          // Update system UI overlay style based on theme
          final isDark = themeMode == ThemeMode.dark;
          SystemChrome.setSystemUIOverlayStyle(
            SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
              systemNavigationBarColor: isDark ? const Color(0xFF000000) : Colors.white,
              systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
            ),
          );

          return MaterialApp.router(
            title: 'GramPulse',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: themeMode,
            themeAnimationDuration: const Duration(milliseconds: 200),
            routerConfig: appRouter,
            // Performance optimizations
            showPerformanceOverlay: false,
            checkerboardRasterCacheImages: false,
            checkerboardOffscreenLayers: false,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en', ''), // English
              Locale('ta', ''), // Tamil
              Locale('ml', ''), // Malayalam
              Locale('kn', ''), // Kannada
              Locale('hi', ''), // Hindi
            ],
          );
        },
      ),
    );
  }
}
