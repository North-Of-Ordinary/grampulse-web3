# GramPulse Project Context for LLM Interaction

## Project Overview

**GramPulse** is a comprehensive Rural Grievance Management System built with Flutter. It's a role-based civic engagement platform that connects rural citizens with government authorities for efficient issue reporting and resolution tracking.

**Current Status**: Successfully integrated from two separate applications (grampulse-citizen and grampulse-volunteer) into a unified multi-role application. The app is fully functional and running on Android devices.

## Core Purpose

Enable rural citizens to report civic issues (water, electricity, roads, sanitation, etc.) with GPS location, photos, and track resolution progress. The system supports collaborative resolution through volunteers, officers, and administrators.

## Technology Stack

### Frontend
- **Framework**: Flutter 3.7+
- **Language**: Dart (SDK ^3.7.0)
- **State Management**: BLoC Pattern (flutter_bloc ^8.1.3)
- **Navigation**: Go Router ^12.1.3
- **Network**: Dio ^5.3.3, HTTP ^1.5.0
- **Local Storage**: Hive ^2.2.3, SharedPreferences ^2.5.3, Floor ^1.4.2
- **Maps**: Flutter Map ^6.0.1, Geolocator ^14.0.2, Geocoding ^2.1.1
- **Media**: Camera ^0.10.5+5, Image Picker ^1.0.4
- **UI Components**: Flutter SVG, Shimmer, Lottie, FL Chart

### Backend (Reference)
- **Runtime**: Node.js
- **Framework**: Express 5.x
- **Database**: MongoDB
- **Authentication**: JWT (jsonwebtoken)

## User Roles & Capabilities

### 1. Citizen
- Report issues with GPS location and photos
- Track issue status in real-time
- View nearby issues on map
- Comment on reports
- Multi-category submissions

### 2. Volunteer
- Verify and validate citizen reports
- Assist citizens with issue reporting
- Coordinate with officers
- Monitor community issues
- Track performance metrics

### 3. Officer
- Manage assigned issues queue
- Update issue status (In Progress, Resolved, etc.)
- Priority-based sorting
- Communication with citizens
- Generate work orders

### 4. Admin
- User and role management
- System analytics and reporting
- Category configuration
- Performance metrics dashboard
- System-wide monitoring

## Project Structure

```
grampulse/
├── lib/
│   ├── main.dart                          # Entry point
│   ├── app/
│   │   ├── app.dart                       # Main app widget with BLoC providers
│   │   └── router.dart                    # Role-based navigation (GoRouter)
│   ├── core/
│   │   ├── services/                      # Shared services
│   │   │   ├── api_service.dart           # HTTP client (Dio)
│   │   │   ├── auth_service.dart          # Authentication logic
│   │   │   ├── location_service.dart      # GPS operations
│   │   │   └── report_service.dart        # Report management
│   │   ├── theme/                         # App theming
│   │   │   └── app_theme.dart             # Material 3 theme
│   │   ├── widgets/                       # Reusable widgets
│   │   ├── constants/                     # App constants
│   │   └── utils/                         # Utility functions
│   ├── features/                          # Feature-based organization
│   │   ├── auth/                          # Authentication (shared)
│   │   │   ├── bloc/                      # AuthBloc, AuthEvent, AuthState
│   │   │   ├── domain/                    # Services, models
│   │   │   └── presentation/              # Screens (splash, login, OTP, etc.)
│   │   ├── citizen/                       # Citizen features
│   │   │   ├── domain/                    # Entities, repositories, models
│   │   │   └── presentation/              # Screens, BLoCs, widgets
│   │   ├── volunteer/                     # Volunteer features
│   │   │   └── presentation/              # Screens (dashboard, verification, etc.)
│   │   ├── officer/                       # Officer features
│   │   │   └── presentation/              # Screens (dashboard, inbox, etc.)
│   │   ├── admin/                         # Admin features
│   │   │   └── presentation/              # Screens (control room, analytics, etc.)
│   │   ├── report/                        # Report management (shared)
│   │   ├── map/                           # Map visualization (shared)
│   │   └── profile/                       # Profile management (shared)
│   └── l10n/                              # Localization files
├── android/                               # Android configuration
├── ios/                                   # iOS configuration
├── web/                                   # Web support
├── assets/                                # Images, icons, animations
└── pubspec.yaml                           # Dependencies
```

## Authentication Flow

1. **Splash Screen** → Check if user is authenticated
2. **Language Selection** → User selects preferred language (EN, HI, TA, ML, KN)
3. **Login Screen** → User enters phone number
4. **OTP Verification** → User enters 6-digit OTP (Demo: 123456)
5. **Profile Setup** → New users create profile
6. **Role Selection** → User selects role (Citizen/Volunteer/Officer/Admin)
7. **Role-Based Dashboard** → User directed to appropriate dashboard

**Demo Credentials**:
- OTP for testing: `123456`
- Any phone number works in demo mode

## Navigation Architecture

### Route Structure
```
/ (splash)
/language-selection
/login
/otp-verification/:phoneNumber
/profile-setup
/role-selection

# Citizen Routes (Shell)
/citizen/home
/citizen/explore
/citizen/my-reports
/citizen/profile
/citizen/report-issue

# Volunteer Routes (Shell)
/volunteer/dashboard
/volunteer/verification-queue
/volunteer/assist-citizen
/volunteer/performance

# Officer Routes (Shell)
/officer/dashboard
/officer/inbox
/officer/work-orders
/officer/analytics

# Admin Routes (Shell)
/admin/control-room
/admin/department-performance
/admin/fund-allocation
/admin/system-configuration
/admin/analytics-reports
```

### Role-Based Guards
- Router automatically redirects users to their role-specific routes
- Unauthorized access attempts redirect to appropriate dashboard
- Authentication state managed by AuthBloc

## State Management Pattern

### BLoC Architecture
```
Event → BLoC → State → UI
```

### Key BLoCs
- **AuthBloc**: Authentication state (Authenticated, Unauthenticated, Loading, Error)
- **CitizenHomeBloc**: Citizen dashboard data
- **NearbyIssuesBloc**: Nearby issues on map
- **MyIssuesBloc**: User's reported issues
- **IncidentBloc**: Incident management
- **OtpVerificationBloc**: OTP verification flow
- **ProfileSetupBloc**: Profile setup flow
- **RoleSelectionBloc**: Role selection flow

### AuthBloc States
```dart
- AuthInitial: Initial state
- AuthLoading: Authentication in progress
- Authenticated: User logged in (includes User model, token, isProfileComplete)
- Unauthenticated: User logged out
- AuthError: Authentication error
```

### User Model
```dart
class User {
  final String id;
  final String phoneNumber;
  final String name;
  final String role; // 'citizen', 'volunteer', 'officer', 'admin'
  final String? email;
  final String? address;
}
```

## Key Implementation Details

### 1. Authentication Storage
- Uses SharedPreferences for token and user data
- Keys: `auth_token`, `user_id`, `phone_number`, `user_name`, `user_role`, `is_profile_complete`

### 2. Role-Based Routing
- Router checks AuthBloc state and user role
- Redirects based on authentication and role permissions
- Shell routes provide consistent navigation UI per role

### 3. Feature Isolation
- Each role has its own feature module
- Shared features: auth, report, map, profile
- Clean separation of concerns

### 4. Localization
- Supported languages: English, Hindi, Tamil, Malayalam, Kannada
- Uses flutter_localizations
- ARB files in `lib/l10n/`

### 5. Asset Management
- Images: `assets/images/`
- Icons: `assets/icons/`
- Animations: `assets/animations/`

## Building and Running

### Development
```bash
# Get dependencies
flutter pub get

# Run on connected device
flutter run

# Run on specific device
flutter run -d <device-id>

# For Android with local backend
adb reverse tcp:3000 tcp:3000
```

### Release Build
```bash
# Android APK
flutter build apk --release

# iOS
flutter build ios --release

# Web
flutter build web --release
```

### Testing
```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage
```

## Common Tasks

### 1. Adding a New Screen
```dart
// 1. Create screen in features/{role}/presentation/screens/
// 2. Add route in lib/app/router.dart
// 3. Add navigation logic in shell screen or other screens
```

### 2. Adding a New BLoC
```dart
// 1. Create bloc, event, state files in features/{role}/presentation/bloc/
// 2. Provide BLoC in router or parent widget
// 3. Use BlocBuilder/BlocListener in UI
```

### 3. Adding a New Service
```dart
// 1. Create service in lib/core/services/
// 2. Inject dependencies if needed
// 3. Use service in BLoCs or repositories
```

### 4. Modifying Theme
```dart
// Edit lib/core/theme/app_theme.dart
// Uses Material 3 design system
```

### 5. Adding Localization
```dart
// 1. Add keys to lib/l10n/arb/app_*.arb files
// 2. Run: flutter gen-l10n
// 3. Use: AppLocalizations.of(context)!.keyName
```

## Important Notes

### Current Limitations
- `image_cropper` temporarily disabled due to dependency conflicts
- `speech_to_text` disabled due to Android compilation issues
- Backend API integration pending (currently uses mock data)

### Demo Mode
- OTP verification accepts `123456` for any phone number
- Authentication creates dummy user data
- No actual API calls in current implementation

### Platform Support
- **Android**: Fully supported (tested on SM A225F)
- **iOS**: Configuration present, needs testing
- **Web**: Configuration present, needs testing

## Integration History

This project was created by integrating two separate applications:
1. **grampulse-citizen**: Citizen-focused app (used as base)
2. **grampulse-volunteer**: Volunteer-focused app

Integration preserved 100% functionality from both apps while creating a unified codebase with role-based navigation.

## Troubleshooting

### Build Issues
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter build apk
```

### Location Permission Issues
- Android: Check AndroidManifest.xml permissions
- iOS: Check Info.plist location permissions

### API Connection Issues
- Verify backend is running
- Check API endpoint in lib/core/services/api_service.dart
- For local dev: `adb reverse tcp:3000 tcp:3000`

## How to Interact with This Project

When working with this codebase:

1. **Understand the role**: Know which user role (citizen/volunteer/officer/admin) you're working with
2. **Follow BLoC pattern**: Events trigger BLoCs, BLoCs emit states, UI reacts to states
3. **Respect feature isolation**: Keep role-specific code in respective feature modules
4. **Use shared services**: Don't duplicate API calls or business logic
5. **Test navigation**: Verify role-based routing works correctly
6. **Check authentication**: Ensure AuthBloc state is properly managed
7. **Maintain consistency**: Follow existing patterns and naming conventions

## Quick Reference

### File Locations
- **Main entry**: `lib/main.dart`
- **Router**: `lib/app/router.dart`
- **AuthBloc**: `lib/features/auth/bloc/auth_bloc.dart`
- **Theme**: `lib/core/theme/app_theme.dart`
- **API Service**: `lib/core/services/api_service.dart`
- **Dependencies**: `pubspec.yaml`

### Key Commands
- Build: `flutter build apk`
- Run: `flutter run`
- Test: `flutter test`
- Clean: `flutter clean`
- Get deps: `flutter pub get`

### Demo Credentials
- Phone: Any number
- OTP: `123456`
- Roles: citizen, volunteer, officer, admin

### Testing Bypass (Debug Only)
A "Skip for Testing" button appears at the bottom-right corner of the login screen in debug builds:
- Controlled by `AppConfig.enableAuthBypass` in `lib/core/config/app_config.dart`
- Only visible when `kDebugMode` is true (automatically hidden in release builds)
- Creates a mock citizen user with complete profile
- To disable: Set `enableAuthBypass = false` or remove `TestAuthBypassButton` widget

---

**Last Updated**: December 24, 2025
**Version**: 1.0.0
**Status**: Active Development - App Successfully Running
