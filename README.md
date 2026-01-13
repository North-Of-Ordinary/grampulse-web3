# GramPulse - Rural Grievance Management System

GramPulse is a comprehensive mobile application designed to bridge the gap between rural citizens and government authorities. It provides a platform for citizens to report local issues, track resolution progress, and engage with community volunteers and government officials.


## Shardeum Smart Contract Url
https://explorer-mezame.shardeum.org/address/0x5ff04cbCB3F80dfE59143e994f8e63009d7f2fA1?tab=txs

## ThinkRoot Deployment url
https://grampulse-az05rp.thinkroot.app/



## Table of Contents

- [Project Overview](#project-overview)
- [Technology Stack](#technology-stack)
- [Project Structure](#project-structure)
- [Key Features](#key-features)
- [Authentication Flow](#authentication-flow)
- [Role-Based System](#role-based-system)
- [State Management](#state-management)
- [API Integration](#api-integration)
- [Installation and Setup](#installation-and-setup)
- [Running the Application](#running-the-application)
- [Backend Integration](#backend-integration)
- [Contributing](#contributing)

## Project Overview

GramPulse is a multi-role platform designed to streamline rural governance and citizen issue reporting. The application targets four primary user roles:

1. **Citizens**: Report issues, track resolution progress, and engage with the community
2. **Volunteers**: Verify reports, assist citizens, and coordinate with officials
3. **Officers**: Receive, process, and resolve citizen reports
4. **Administrators**: Oversee the system, manage users, and access analytics

The application uses a Flutter frontend with a Node.js/Express backend and MongoDB database.

## Technology Stack

### Frontend
- **Flutter**: UI framework for cross-platform development
- **Dart**: Programming language for Flutter
- **BLoC Pattern**: State management architecture
- **Go Router**: Navigation and routing
- **HTTP/Dio**: API integration
- **SharedPreferences**: Local storage for authentication tokens
- **Hive**: Local database for offline support
- **Flutter Map**: Map integration for location-based features

### Backend
- **Node.js**: JavaScript runtime
- **Express**: Web framework
- **MongoDB**: NoSQL database
- **JWT**: Authentication
- **Multer**: File uploads
- **Express Validator**: Request validation

## Project Structure

```
grampulse/
├── android/                  # Android-specific files
├── ios/                      # iOS-specific files
├── lib/                      # Main Flutter code
│   ├── app/                  # App-level configurations
│   │   ├── app.dart          # Main app widget
│   │   └── router.dart       # Routing configuration
│   ├── core/                 # Core functionality
│   │   ├── components/       # Reusable UI components
│   │   ├── constants/        # App constants
│   │   ├── presentation/     # Shared presentation logic
│   │   ├── services/         # App services
│   │   │   ├── api_service.dart     # HTTP client for API calls
│   │   │   ├── auth_service.dart    # Authentication service
│   │   │   └── report_service.dart  # Report management service
│   │   ├── theme/            # App theming
│   │   ├── utils/            # Utility functions
│   │   └── widgets/          # Shared widgets
│   ├── features/             # App features
│   │   ├── auth/             # Authentication feature
│   │   │   ├── bloc/         # Authentication state management
│   │   │   │   └── auth_bloc.dart   # Auth BLoC
│   │   │   ├── domain/       # Business logic
│   │   │   └── presentation/ # UI components
│   │   │       └── screens/  # Authentication screens
│   │   ├── citizen/          # Citizen feature
│   │   │   ├── domain/       # Business logic
│   │   │   └── presentation/ # UI components
│   │   │       ├── bloc/     # Citizen state management
│   │   │       └── screens/  # Citizen screens
│   │   ├── map/              # Map feature
│   │   │   ├── domain/       # Business logic
│   │   │   └── presentation/ # UI components
│   │   ├── officer/          # Officer feature
│   │   │   ├── blocs/        # Officer state management
│   │   │   ├── data/         # Data sources
│   │   │   ├── domain/       # Business logic
│   │   │   ├── models/       # Data models
│   │   │   └── presentation/ # UI components
│   │   ├── report/           # Report feature
│   │   │   ├── bloc/         # Report state management
│   │   │   │   └── report_bloc.dart  # Report BLoC
│   │   │   ├── domain/       # Business logic
│   │   │   └── presentation/ # UI components
│   │   └── volunteer/        # Volunteer feature
│   │       ├── bloc/         # Volunteer state management
│   │       ├── domain/       # Business logic
│   │       ├── models/       # Data models
│   │       ├── presentation/ # UI components
│   │       ├── screens/      # Volunteer screens
│   │       └── widgets/      # Volunteer-specific widgets
│   ├── l10n/                 # Localization
│   │   ├── arb/              # Translation files
│   │   ├── app_localizations.dart
│   │   └── l10n.dart
│   ├── patches/              # Custom patches
│   └── main.dart             # Entry point
├── web/                      # Web-specific files
├── pubspec.yaml              # Dependencies
└── README.md                 # This file
```

## Key Features

### 1. Authentication System
- Phone number-based authentication with OTP verification
- JWT token-based session management
- Profile setup with role selection
- Secure token storage with SharedPreferences

### 2. Issue Reporting
- Multi-category issue reporting (Water, Electricity, Roads, etc.)
- Location-based reporting with map integration
- Image upload capability for visual evidence
- Structured form with validation

### 3. Report Tracking
- Status updates on reported issues
- Timeline view of resolution progress
- Comment system for updates and clarifications
- Push notifications for status changes

### 4. Map Integration
- Location-based issue visualization
- Nearby issues discovery
- Geographical clustering of reports
- Interactive map with filters

### 5. Role-Specific Dashboards
- Citizen dashboard for personal reports
- Volunteer dashboard for verification tasks
- Officer dashboard for assigned cases
- Admin dashboard for system oversight and analytics

### 6. Multi-language Support
- English, Hindi, Tamil, Malayalam, and Kannada languages
- Dynamic language switching
- Localized content throughout the app

## Authentication Flow

GramPulse implements a secure authentication flow:

1. **Language Selection**: Users first select their preferred language
2. **Phone Number Input**: Users enter their phone number
3. **OTP Verification**: A 6-digit OTP is sent to the user's phone
4. **OTP Validation**: User enters the OTP to verify identity
5. **Profile Setup**: First-time users set up their profile (name, role, optional email)
6. **Role Selection**: Users select their role (citizen, volunteer, officer)
7. **Home Screen**: Users are directed to role-specific home screens

The `AuthBloc` manages this entire flow, handling state transitions and API calls through the `AuthService`.

### Key Authentication Files

- `lib/core/services/auth_service.dart`: Handles authentication API calls
- `lib/features/auth/bloc/auth_bloc.dart`: Manages authentication state
- `lib/features/auth/presentation/screens/login_screen.dart`: Phone input UI
- `lib/features/auth/presentation/screens/otp_verification_screen.dart`: OTP verification UI
- `lib/features/auth/presentation/screens/profile_setup_screen.dart`: Profile setup UI

## Role-Based System

GramPulse implements a comprehensive role-based system that determines user access, UI, and functionality:

### 1. Citizen
- Report new issues
- Track report status
- Comment on reports
- View nearby issues
- Access community resources

### 2. Volunteer
- Verify citizen reports
- Assist citizens with reporting
- Coordinate with officials
- Monitor community issues
- Update report status

### 3. Officer
- Receive assigned reports
- Update report status
- Resolve issues
- Communicate with citizens
- Generate work orders

### 4. Administrator
- Manage users and roles
- Assign reports to officers
- Access system analytics
- Configure system settings
- Monitor overall performance

The router (`lib/app/router.dart`) enforces role-based access control, preventing unauthorized access to role-specific routes.

## State Management

GramPulse uses the BLoC (Business Logic Component) pattern for state management:

### 1. AuthBloc
- Manages authentication state
- Handles OTP requests and verification
- Manages profile completion
- Controls user sessions

**Key files**:
- `lib/features/auth/bloc/auth_bloc.dart`: Authentication state management
- `lib/features/auth/bloc/auth_event.dart`: Authentication events
- `lib/features/auth/bloc/auth_state.dart`: Authentication states

### 2. ReportBloc
- Manages report creation, updates, and deletion
- Handles report filtering and searching
- Manages comments and status updates
- Controls report assignment

**Key files**:
- `lib/features/report/bloc/report_bloc.dart`: Report state management
- `lib/features/report/bloc/report_event.dart`: Report events
- `lib/features/report/bloc/report_state.dart`: Report states

### 3. Other Feature-Specific BLoCs
- CitizenHomeBloc: Manages citizen dashboard
- NearbyIssuesBloc: Handles map and nearby issues
- OfficerDashboardBloc: Manages officer dashboard

The BLoC pattern provides clear separation of UI, business logic, and data, making the codebase maintainable and testable.

## API Integration

GramPulse communicates with a RESTful backend API:

### 1. ApiService
- HTTP client for API calls
- Token management
- Request/response handling
- Error handling

**Key file**: `lib/core/services/api_service.dart`

### 2. AuthService
- Authentication API calls
- Token storage
- User profile management

**Key file**: `lib/core/services/auth_service.dart`

### 3. ReportService
- Report CRUD operations
- Comment management
- Status updates
- File uploads

**Key file**: `lib/core/services/report_service.dart`

### API Response Format
All API responses follow a standardized format:
```json
{
  "success": true|false,
  "message": "Response message",
  "data": {...},
  "statusCode": 200
}
```

## Installation and Setup

### Prerequisites
- Flutter 3.7.0 or higher
- Dart SDK
- Android Studio or VS Code
- Node.js and npm (for backend)
- MongoDB (for backend)

### Flutter Setup
1. Clone the repository
   ```
   git clone https://github.com/your-username/grampulse.git
   cd grampulse
   ```

2. Install dependencies
   ```
   flutter pub get
   ```

3. Configure backend URL
   Open `lib/core/services/api_service.dart` and update the `baseUrl`:
   ```dart
   // For Android emulator
   static const String baseUrl = 'http://10.0.2.2:3000/api';
   
   // For iOS simulator
   // static const String baseUrl = 'http://localhost:3000/api';
   
   // For physical device (replace with your computer's IP)
   // static const String baseUrl = 'http://192.168.1.xxx:3000/api';
   ```

## Running the Application

### Starting the Backend
1. Navigate to the backend directory
   ```
   cd path/to/GramPulse-Backend
   ```

2. Install dependencies
   ```
   npm install
   ```

3. Start the server
   ```
   npm start
   ```

### Running the Flutter App
1. Start an emulator or connect a physical device

2. Run the Flutter app
   ```
   flutter run
   ```

## Backend Integration

The Flutter frontend integrates with a Node.js/Express backend:

### API Endpoints

#### Authentication
- `POST /api/auth/request-otp`: Request OTP for phone verification
- `POST /api/auth/verify-otp`: Verify OTP and get JWT token
- `GET /api/users/me`: Get current user profile
- `POST /api/users/complete-profile`: Complete user profile

#### Reports
- `GET /api/reports`: Get all reports (with optional filters)
- `GET /api/reports/me`: Get reports created by current user
- `GET /api/reports/:id`: Get a specific report
- `POST /api/reports`: Create a new report
- `PUT /api/reports/:id`: Update a report
- `DELETE /api/reports/:id`: Delete a report
- `POST /api/reports/:id/comments`: Add a comment to a report
- `PUT /api/reports/:id/status`: Update report status
- `PUT /api/reports/:id/assign`: Assign report to an officer

### Authentication Flow
1. The app sends a phone number to `/api/auth/request-otp`
2. The backend generates and sends a 6-digit OTP
3. The app sends the OTP to `/api/auth/verify-otp`
4. If valid, the backend returns a JWT token and user info
5. The app stores the token in SharedPreferences
6. Subsequent API calls include the token in the Authorization header

## Detailed File Descriptions

### Core Services

#### 1. `lib/core/services/api_service.dart`
This file implements a generic HTTP client for communicating with the backend API. Key components include:

- **ApiResponse<T> class**: A generic wrapper for standardized API responses
- **ApiService class**: Handles HTTP requests with proper error handling
- **Token Management**: Automatically adds authentication tokens to requests
- **HTTP Methods**: Implementation of GET, POST, PUT, DELETE methods
- **File Upload**: Support for multipart requests with file uploads
- **Response Processing**: Standardized handling of API responses

Usage example:
```dart
final apiService = ApiService();
final response = await apiService.get<User>(
  '/users/me',
  (data) => User.fromJson(data),
);
```

#### 2. `lib/core/services/auth_service.dart`
This service handles all authentication-related operations:

- **User Model**: Defines the user data structure
- **Authentication Methods**: OTP request, verification, and profile completion
- **Session Management**: Token storage and retrieval
- **Profile Management**: User profile updates and retrieval
- **Authentication State**: Checks if the user is authenticated

Usage example:
```dart
final authService = AuthService();
final response = await authService.requestOtp('1234567890');
```

#### 3. `lib/core/services/report_service.dart`
This service manages all report-related operations:

- **Report Models**: Defines data structures for reports, comments, and locations
- **Report Management**: CRUD operations for reports
- **Comment System**: Adding and retrieving comments
- **Status Updates**: Updating report status
- **Assignment**: Assigning reports to officers
- **Filtering**: Getting reports with various filters

Usage example:
```dart
final reportService = ReportService();
final response = await reportService.createReport(
  title: 'Water shortage',
  description: 'No water supply for 3 days',
  category: 'WATER',
  // Other required fields
);
```

### State Management (BLoC)

#### 1. `lib/features/auth/bloc/auth_bloc.dart`
This file implements the authentication BLoC pattern:

- **AuthEvent**: Abstract class for auth events (RequestOtp, VerifyOtp, etc.)
- **AuthState**: Abstract class for auth states (Authenticated, Unauthenticated, etc.)
- **AuthBloc**: Handles state transitions based on events
- **Event Handlers**: Implementation of event handlers for auth flow

The AuthBloc coordinates the entire authentication flow, from OTP request to login to logout.

Usage example:
```dart
// Request OTP
context.read<AuthBloc>().add(RequestOtp('1234567890'));

// Verify OTP
context.read<AuthBloc>().add(VerifyOtp('1234567890', '123456'));

// Complete profile
context.read<AuthBloc>().add(CompleteProfile(
  name: 'John Doe',
  role: 'citizen',
));

// Logout
context.read<AuthBloc>().add(Logout());
```

#### 2. `lib/features/report/bloc/report_bloc.dart`
This file implements the report management BLoC pattern:

- **ReportEvent**: Abstract class for report events (CreateReport, UpdateReport, etc.)
- **ReportState**: Abstract class for report states (ReportsLoaded, ReportError, etc.)
- **ReportBloc**: Handles state transitions based on events
- **Event Handlers**: Implementation of event handlers for report operations

The ReportBloc manages all report-related state, from creation to updates to filtering.

Usage example:
```dart
// Load all reports
context.read<ReportBloc>().add(LoadAllReports());

// Create a new report
context.read<ReportBloc>().add(CreateReport(
  title: 'Road damage',
  description: 'Pothole on main street',
  category: 'ROAD',
  // Other required fields
));

// Update report status
context.read<ReportBloc>().add(UpdateReportStatus(
  reportId: 'report-id',
  status: 'IN_PROGRESS',
));
```

### Screens

#### 1. Authentication Screens

- **SplashScreen**: Initial loading screen with app logo
- **LanguageSelectionScreen**: Allows users to select their preferred language
- **LoginScreen**: Phone number input for OTP authentication
- **OtpVerificationScreen**: OTP input and verification
- **ProfileSetupScreen**: User profile creation with name, email, and role
- **RoleSelectionScreen**: Role selection with descriptions

#### 2. Citizen Screens

- **CitizenShellScreen**: Main shell with bottom navigation
- **CitizenHomeScreen**: Dashboard showing reports summary and quick actions
- **ExploreScreen**: Map view of nearby issues
- **MyReportsScreen**: List of user's reported issues
- **ReportIssueScreen**: Form for creating new reports
- **ProfileScreen**: User profile management

#### 3. Volunteer Screens

- **VolunteerShellScreen**: Main shell with bottom navigation
- **VolunteerDashboardScreen**: Overview of volunteer tasks
- **VerificationQueueScreen**: List of reports needing verification
- **AssistCitizenScreen**: Interface for helping citizens create reports
- **PerformanceScreen**: Volunteer performance metrics

#### 4. Officer Screens

- **OfficerShellScreen**: Main shell with bottom navigation
- **OfficerDashboardScreen**: Overview of assigned cases
- **InboxScreen**: New reports assigned to the officer
- **WorkOrdersScreen**: Active work orders and resolutions
- **AnalyticsScreen**: Performance and resolution metrics

#### 5. Report Screens

- **ReportDetailScreen**: Detailed view of a report with status timeline
- **ReportMapScreen**: Map view of a specific report location
- **CommentSectionScreen**: Comments and updates on a report
- **StatusUpdateScreen**: Interface for updating report status

### Navigation & Routing

The app uses Go Router for declarative routing:

#### `lib/app/router.dart`

This file defines the app's routing structure:

- **Route Definitions**: Path, name, and builder for each route
- **Nested Routes**: Shell routes with nested child routes
- **Authentication Guards**: Redirects based on authentication state
- **Role-Based Access**: Route protection based on user role
- **Parameter Passing**: Passing parameters between routes

The router implements sophisticated logic for:
1. Redirecting unauthenticated users to login
2. Directing authenticated users to appropriate role-specific screens
3. Handling deep links and navigation history
4. Enforcing role-based access control

### Main Application

#### `lib/app/app.dart`

The main application widget that:

- Sets up the global providers (AuthBloc, ReportBloc)
- Configures the router
- Sets up the theme
- Initializes localization
- Configures system UI settings

#### `lib/main.dart`

The entry point of the application that:

- Initializes services (Hive, SharedPreferences)
- Sets up platform-specific configurations
- Launches the main app widget

## Data Models

### User Model

```dart
class User {
  final String id;
  final String phone;
  final String? name;
  final String? email;
  final String role;
  final String? profilePicture;
  final bool isProfileComplete;
  
  // Constructor and fromJson implementation
}
```

### Report Model

```dart
class Report {
  final String id;
  final String title;
  final String description;
  final String category;
  final String status;
  final String address;
  final String district;
  final String state;
  final String pincode;
  final Location? location;
  final List<String>? images;
  final String userId;
  final String? userName;
  final List<Comment> comments;
  final String? assignedOfficerId;
  final String? assignedOfficerName;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Constructor and fromJson implementation
}
```

### Comment Model

```dart
class Comment {
  final String id;
  final String text;
  final String userId;
  final String? userName;
  final String? userRole;
  final String? userProfilePicture;
  final DateTime createdAt;
  
  // Constructor and fromJson implementation
}
```

### Location Model

```dart
class Location {
  final double latitude;
  final double longitude;
  
  // Constructor and fromJson/toJson implementation
}
```

## Usage Scenarios

### 1. Citizen Reporting an Issue

1. Citizen logs in with phone number and OTP
2. Navigates to "Report Issue" screen
3. Fills out report form with issue details
4. Attaches photos and pinpoints location on map
5. Submits report
6. ReportBloc processes the creation event
7. ReportService sends API request to backend
8. Citizen receives confirmation and is redirected to report details

### 2. Officer Processing a Report

1. Officer logs in with phone number and OTP
2. Views assigned reports in inbox
3. Selects a report to view details
4. Updates report status (e.g., "IN_PROGRESS")
5. Adds comments for citizen visibility
6. Marks report as resolved when complete
7. ReportBloc processes status update events
8. ReportService sends API requests to backend

### 3. Volunteer Verifying Reports

1. Volunteer logs in with phone number and OTP
2. Views verification queue
3. Selects a report to verify
4. Checks report details and location
5. Marks report as verified or flags it for more information
6. Adds comments with verification notes
7. ReportBloc processes verification events
8. ReportService sends API requests to backend

## Technical Implementation Details

### Authentication Flow

1. **OTP Request**:
   ```dart
   // AuthBloc handles the RequestOtp event
   Future<void> _onRequestOtp(RequestOtp event, Emitter<AuthState> emit) async {
     emit(AuthLoading());
     try {
       final response = await _authService.requestOtp(event.phone);
       if (response.success) {
         emit(OtpRequested(event.phone));
       } else {
         emit(AuthError(response.message));
       }
     } catch (e) {
       emit(AuthError(e.toString()));
     }
   }
   ```

2. **OTP Verification**:
   ```dart
   // AuthBloc handles the VerifyOtp event
   Future<void> _onVerifyOtp(VerifyOtp event, Emitter<AuthState> emit) async {
     emit(AuthLoading());
     try {
       final response = await _authService.verifyOtp(event.phone, event.otp);
       if (response.success && response.data != null) {
         final user = response.data!;
         emit(Authenticated(user, isProfileComplete: user.isProfileComplete));
       } else {
         emit(OtpVerificationFailed(response.message));
       }
     } catch (e) {
       emit(AuthError(e.toString()));
     }
   }
   ```

### API Request/Response Handling

```dart
// ApiService processes HTTP responses
ApiResponse<T> _processResponse<T>(
  http.Response response,
  T Function(dynamic)? fromJson,
) {
  try {
    final responseBody = json.decode(response.body);
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      // Successful response
      return ApiResponse(
        success: responseBody['success'] ?? true,
        message: responseBody['message'] ?? 'Success',
        data: responseBody['data'] != null && fromJson != null 
            ? fromJson(responseBody['data']) 
            : null,
        statusCode: response.statusCode,
      );
    } else {
      // Error response
      return ApiResponse(
        success: false,
        message: responseBody['message'] ?? 'Server error',
        statusCode: response.statusCode,
      );
    }
  } catch (e) {
    // Invalid JSON or other parsing error
    return ApiResponse(
      success: false,
      message: 'Failed to parse response: ${e.toString()}',
      statusCode: response.statusCode,
    );
  }
}
```

### Role-Based Routing

```dart
// Router handles role-based redirects
if (authState is Authenticated) {
  // If authenticated with complete profile but in auth path, redirect to home
  if (inAuthPath) {
    switch (authState.user.role) {
      case 'citizen':
        return '/citizen';
      case 'volunteer':
        return '/volunteer';
      case 'officer':
        return '/officer';
      case 'admin':
        return '/admin';
      default:
        return '/citizen';
    }
  }
  
  // Verify role-specific access
  if (location.startsWith('/citizen') && authState.user.role != 'citizen') {
    // Redirect to appropriate role-specific home
  }
  
  // Similar checks for other roles
}
```

## Conclusion

GramPulse is a comprehensive mobile application designed to bridge the gap between rural citizens and government authorities. With its multi-role approach, secure authentication, and robust feature set, it provides an effective platform for citizens to report issues, volunteers to verify them, and officials to resolve them.

The application showcases modern Flutter development practices, including:

- Clean architecture with separation of concerns
- BLoC pattern for state management
- Service-oriented design for API integration
- Declarative routing with Go Router
- Multi-language support
- Responsive UI design

By connecting citizens directly with officials and enabling volunteer participation, GramPulse aims to improve rural governance and address local issues more efficiently.

## Contributing

GramPulse is open to contributions. To contribute:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run tests
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.
