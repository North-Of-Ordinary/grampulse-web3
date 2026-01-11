# GramPulse - Rural Grievance Management System

A comprehensive mobile application designed to connect rural citizens with government authorities for efficient issue reporting and resolution tracking.

## Overview

GramPulse is a role-based civic engagement platform that streamlines rural governance through structured issue reporting, tracking, and collaborative resolution. The system supports four distinct user roles with tailored workflows and interfaces.

**Key Users:**
- Citizens: Report issues and track resolution
- Volunteers: Verify reports and assist citizens
- Officers: Process and resolve reported issues
- Administrators: Manage system and analytics

## Features

### Citizen Portal
- GPS-enabled issue reporting with automatic location capture
- Multi-category issue submission (Water, Electricity, Roads, Sanitation, etc.)
- Real-time status tracking with timeline view
- Photo/document attachment for evidence
- Comment system for updates and clarifications
- Nearby issues discovery on interactive map

### Volunteer Interface
- Report verification and validation workflow
- Direct communication with citizens
- Coordination tools for officer assignment
- Community issue monitoring dashboard
- Performance metrics and contribution tracking

### Officer Dashboard
- Assigned issue management queue
- Priority-based sorting and filtering
- Status update workflows (In Progress, Resolved, etc.)
- Communication history with citizens
- Work order generation and tracking

### Admin Panel
- User and role management
- System analytics and reporting
- Category and configuration management
- Performance metrics dashboard
- System-wide issue monitoring

### Additional Capabilities
- Multi-language support (English, Hindi, Tamil, Malayalam, Kannada)
- Offline functionality with local caching
- Real-time notifications for status updates
- Advanced map visualization with clustering
- Structured form validation
- JWT-based secure authentication

## Technology Stack

### Frontend
| Component | Technology |
|-----------|-----------|
| Framework | Flutter 3.7+ |
| Language | Dart |
| State Management | BLoC Pattern (flutter_bloc) |
| Navigation | Go Router |
| Network | Dio, HTTP |
| Local Storage | Hive, SharedPreferences |
| Maps | Flutter Map |
| Location Services | Geolocator, Geocoding |
| Media | Camera, Image Picker |

### Backend
| Component | Technology |
|-----------|-----------|
| Runtime | Node.js |
| Framework | Express 5.x |
| Database | MongoDB |
| Authentication | JWT (jsonwebtoken) |
| Password Security | bcryptjs |
| File Upload | Multer |
| Validation | Express Validator |

## Project Structure

```
lib/
├── main.dart                          # Application entry point
├── app/
│   ├── app.dart                       # Main app widget
│   └── router.dart                    # Route configuration
├── core/
│   ├── components/                    # Reusable UI components
│   ├── constants/                     # Application constants
│   ├── services/                      # Core services
│   │   ├── api_service.dart           # HTTP client
│   │   ├── auth_service.dart          # Authentication
│   │   └── report_service.dart        # Report management
│   ├── theme/                         # Application theming
│   ├── utils/                         # Utility functions
│   └── widgets/                       # Shared widgets
├── features/
│   ├── auth/                          # Authentication feature
│   │   ├── bloc/                      # State management
│   │   ├── domain/                    # Business logic
│   │   └── presentation/              # UI components
│   ├── citizen/                       # Citizen dashboard
│   │   ├── bloc/                      # State management
│   │   ├── domain/                    # Business logic
│   │   └── presentation/              # UI components
│   ├── officer/                       # Officer portal
│   │   ├── bloc/                      # State management
│   │   ├── domain/                    # Business logic
│   │   └── presentation/              # UI components
│   ├── volunteer/                     # Volunteer interface
│   │   ├── bloc/                      # State management
│   │   ├── domain/                    # Business logic
│   │   └── presentation/              # UI components
│   ├── report/                        # Report management
│   │   ├── bloc/                      # State management
│   │   └── presentation/              # UI components
│   └── map/                           # Map visualization
│       ├── domain/                    # Business logic
│       └── presentation/              # UI components
└── l10n/                              # Localization files

android/                               # Android-specific files
ios/                                   # iOS-specific files
web/                                   # Web support files
pubspec.yaml                           # Dependencies and metadata
```

## Prerequisites

### Required
- Flutter SDK 3.7.0 or higher
- Dart SDK
- Android Studio or Xcode (for platform-specific development)
- Git
- Visual Studio Code or Android Studio

### Optional
- Node.js and npm (for backend development)
- MongoDB (for local backend setup)
- Postman (for API testing)

## Installation

### 1. Clone Repository
```bash
git clone https://github.com/naveen-astra/grampulse-icsrf.git
cd GramPulse
```

### 2. Install Flutter Dependencies
```bash
flutter pub get
```

### 3. Code Generation (if required)
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 4. Configuration

#### Update API Endpoint
Edit `lib/core/services/api_service.dart`:
```dart
class ApiService {
  static const String baseUrl = 'https://your-api-endpoint.com/api';
  // ...
}
```

#### Platform-Specific Setup

**Android:**
- Configure Android build settings in `android/app/build.gradle.kts`
- Update API endpoint for ADB connections if running locally:
  ```bash
  adb reverse tcp:3000 tcp:3000
  ```

**iOS:**
- Update deployment target in Xcode
- Configure location permissions in `ios/Runner/Info.plist`

## Running the Application

### Development Mode
```bash
flutter run
```

### Release Build
```bash
# iOS
flutter build ios --release

# Android
flutter build apk --release
```

### Testing
```bash
flutter test
```

## Authentication Flow

1. **Language Selection**: User selects preferred language
2. **Phone Authentication**: User enters phone number
3. **OTP Verification**: System sends 6-digit OTP to phone
4. **Account Setup**: New users create profile and select role
5. **Dashboard**: User directed to role-specific dashboard

**Key Files:**
- [lib/features/auth/presentation/screens](lib/features/auth/presentation/screens)
- [lib/core/services/auth_service.dart](lib/core/services/auth_service.dart)

## API Integration

### Base Configuration
```dart
// API Service Setup
const String baseUrl = 'https://api.grampulse.local/api';
const Duration timeout = Duration(seconds: 30);
```

### Authentication Headers
All authenticated requests include JWT token:
```
Authorization: Bearer {token}
```

### Standard Response Format
```json
{
  "success": true,
  "message": "Operation successful",
  "data": {},
  "statusCode": 200
}
```

## State Management Architecture

GramPulse uses the BLoC pattern for clean separation of concerns:

- **BLoC**: Handles business logic and state transitions
- **Events**: Trigger BLoC operations
- **States**: Represent current UI state
- **Services**: Encapsulate external operations (API, database)

### Key BLoCs
- **AuthBloc**: Authentication and session management
- **CitizenBloc**: Citizen dashboard and report listing
- **ReportBloc**: Report creation and updates
- **OfficerBloc**: Officer task management

## Localization

Supported languages: English, Hindi, Tamil, Malayalam, Kannada

Localization files located in `lib/l10n/`. Add new strings in ARB files and regenerate:
```bash
flutter gen-l10n
```

## Build Configuration

### Environment Variables
Create `.env` file in project root:
```
API_BASE_URL=https://your-api-endpoint.com/api
FIREBASE_PROJECT_ID=your-project-id
ENABLE_DEBUG_LOGGING=false
```

### Gradle Configuration (Android)
- Minimum SDK: 21
- Target SDK: 34
- Build tools: Latest

## Contributing

### Code Standards
- Follow Dart style guide
- Use meaningful variable and function names
- Add documentation for public APIs
- Keep methods focused and concise
- Write tests for new features

### Submission Process
1. Create feature branch: `git checkout -b feature/your-feature`
2. Commit changes: `git commit -m 'Add feature description'`
3. Push to branch: `git push origin feature/your-feature`
4. Open Pull Request with detailed description

### Branch Naming
- Features: `feature/feature-name`
- Bug fixes: `bugfix/bug-description`
- Improvements: `improvement/improvement-name`

## File Descriptions

### Key Configuration Files
- **pubspec.yaml**: Dependencies, version, and project metadata
- **analysis_options.yaml**: Dart analyzer configuration
- **devtools_options.yaml**: Development tools configuration

### Important Documentation
- **IMPLEMENTATION_COMPLETE.md**: Feature implementation status
- **CITIZEN_FEATURES_TESTING.md**: Testing guidelines for citizen features

## Performance Optimization

- Image compression before upload
- Lazy loading of list items
- Offline caching with Hive
- Efficient state management with BLoC
- Network request optimization with HTTP caching

## Security Considerations

- JWT tokens stored securely with SharedPreferences
- SSL/TLS for all API communications
- Input validation on all forms
- Secure password hashing on backend
- Role-based access control implementation

## Troubleshooting

### Common Issues

**API Connection Failed**
- Verify backend is running
- Check network connectivity
- Validate API endpoint in configuration
- For local development: `adb reverse tcp:3000 tcp:3000`

**Location Permission Denied**
- Verify permissions in platform-specific settings
- iOS: Check `Info.plist` for location permissions
- Android: Verify runtime permissions granted

**Build Failures**
- Run `flutter clean && flutter pub get`
- Update Flutter: `flutter upgrade`
- Check Dart version compatibility


## Support

For issues, questions, or contributions, please contact the development team or open an issue in the repository.

## Project Status

Development Status: Active

Latest Version: 1.0.0

Last Updated: December 2025
