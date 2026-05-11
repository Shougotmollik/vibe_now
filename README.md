# Vibe Now

A social networking mobile application built with Flutter that connects people around events, communities, and meetups ("vibes"). The app enables users to discover nearby activities, create and join events and communities, chat with other users, and organize meetups.

---

## Table of Contents

- [Project Overview](#project-overview)
- [Features](#features)
- [Tech Stack](#tech-stack)
- [Architecture](#architecture)
- [Project Structure](#project-structure)
- [Getting Started](#getting-started)
- [Design System](#design-system)
- [API Endpoints](#api-endpoints)
- [Data Models](#data-models)
- [Navigation](#navigation)
- [State Management](#state-management)
- [Local Storage](#local-storage)
- [Screens Overview](#screens-overview)
- [Contributing](#contributing)
- [License](#license)

---

## Project Overview

**Vibe Now** is a social discovery platform that helps users find and create local events, communities, and spontaneous meetups. The app focuses on connecting people with similar interests through location-based features and real-time communication.

### Key Value Propositions

- **Event Discovery** - Find and join local events based on interests and location
- **Community Building** - Create and manage communities with shared interests
- **Spontaneous Meetups** - Connect with nearby users through the "Vibe" feature
- **Real-time Chat** - Communicate with event attendees and community members
- **QR Code Check-ins** - Secure event access with QR code verification

---

## Features

### Authentication & Onboarding

- Email sign up with OTP verification
- Sign in with email/password
- Password reset via OTP
- Multi-step onboarding flow:
  - Name selection
  - Profile photo upload
  - Interest selection
  - Location setup
  - Gender selection
  - Birthday verification

### Home & Discovery

- Interactive map with event and community markers
- Filter events by category, date, and distance
- Filter communities by interests
- Location-based recommendations
- Wave feature for nearby user discovery

### Events

- Create public or private events
- Set event date, time, and location
- Add cover images and descriptions
- Set maximum attendee capacity
- QR code generation for event access
- Event check-in functionality
- Event request system for private events
- Event chat rooms for attendees

### Communities

- Create public or private communities
- Community member management
- Community chat rooms
- Plan and organize meetups within communities
- Community event creation
- Invite members to meetups
- QR code based meetup verification

### Chat & Messaging

- Direct messaging between users
- Community group chats
- Event attendee chats
- Wave (broadcast message to nearby users)
- Block and report functionality

### Vibe (Meetups)

- Create spontaneous meetup requests
- Location suggestion feature
- Meetup confirmation workflow
- Reschedule meetups
- View user's vibe history

### Profile & Settings

- View and edit profile information
- Change profile photo
- Lock/unlock profile visibility
- View liked users list
- Theme selection (light/dark mode)
- Language preference
- Privacy settings
- Account management
- Subscription/premium features

---

## Tech Stack

### Framework & Language

- **Flutter** 3.9+
- **Dart** 3.9+

### Key Dependencies

| Package | Purpose |
|---------|---------|
| `get: ^4.7.3` | State management & dependency injection |
| `go_router: ^17.0.1` | Declarative routing/navigation |
| `dio: ^5.9.0` | HTTP client for API requests |
| `flutter_screenutil: ^5.9.3` | Responsive UI scaling |
| `google_maps_flutter: ^2.14.0` | Google Maps integration |
| `flutter_map: ^8.2.2` | OpenStreetMap alternative |
| `geolocator: ^14.0.2` | GPS location services |
| `geocoding: ^4.0.0` | Address to coordinates conversion |
| `shared_preferences: ^2.3.2` | Local key-value storage |
| `image_picker: ^1.2.1` | Camera/gallery image selection |
| `cached_network_image: ^3.4.1` | Image caching |
| `image_cropper: ^8.0.2` | Image cropping |
| `qr_code_scanner_plus: ^2.0.14` | QR code scanning |
| `lottie: ^3.3.2` | Animations |
| `intl: ^0.20.2` | Date/time formatting |
| `connectivity_plus: ^6.0.5` | Network status monitoring |

### Development Dependencies

- `flutter_lints: ^5.0.0` - Linting rules
- `build_runner` - Code generation
- `flutter_gen_runner` - Asset generation

---

## Architecture

The project follows **Clean Architecture** principles with clear separation of concerns:

```
lib/
├── core/                 # Business logic layer
│   ├── constant/         # API endpoints, app constants
│   ├── error/            # Custom exceptions and failures
│   ├── helper/           # Helper utilities
│   ├── network/          # Network configuration
│   ├── routes/           # Navigation configuration
│   └── usecase/          # Use case base classes
├── controller/           # GetX controllers (business logic)
├── model/                # Data models
├── services/             # API client, local storage
├── views/                # UI layer
│   ├── auth/             # Authentication screens
│   ├── chat/             # Chat screens
│   ├── community/        # Community screens
│   ├── event/            # Event screens
│   ├── home/             # Home/map screens
│   ├── notification/      # Notification screens
│   ├── profile/          # Profile screens
│   ├── settings/         # Settings screens
│   ├── subscription/     # Subscription screens
│   ├── vibe/             # Vibe/meetup screens
│   └── common/           # Shared widgets
├── design_system/        # Design tokens and theme
└── utils/                # Utility functions
```

### Layer Responsibilities

| Layer | Responsibility |
|-------|----------------|
| **Core** | Constants, routes, error handling, network config |
| **Controller** | Business logic, API calls, state management |
| **Model** | Data structures and JSON serialization |
| **Services** | HTTP client, local storage, external integrations |
| **Views** | UI components, screens, widgets |
| **Design System** | Theme, colors, typography, reusable components |

---

## Project Structure

```
vibe_now/
├── lib/
│   ├── main.dart                    # App entry point
│   ├── controller_binding.dart       # GetX dependency injection
│   ├── env.dart                     # Environment variables
│   ├── utils.dart                   # Global utilities
│   │
│   ├── core/
│   │   ├── constant/
│   │   │   ├── api_constant.dart     # API endpoint definitions
│   │   │   ├── credential.dart      # API credentials
│   │   │   ├── env_constant.dart    # Environment constants
│   │   │   └── qrcontext_enum.dart  # QR context enum
│   │   ├── error/
│   │   │   ├── exceptions.dart       # Custom exceptions
│   │   │   └── failures.dart        # Failure types
│   │   ├── helper/
│   │   │   ├── app_snackbar.dart    # Snackbar utility
│   │   │   └── helper.dart          # Helper functions
│   │   ├── network/
│   │   │   ├── dio_client.dart      # Dio configuration
│   │   │   └── network_info.dart    # Network status
│   │   ├── routes/
│   │   │   ├── route_names.dart     # Route name constants
│   │   │   └── routes.dart          # Router configuration
│   │   └── usecase/
│   │       └── usecase.dart         # Use case base class
│   │
│   ├── controller/
│   │   ├── auth_controller.dart     # Authentication logic
│   │   ├── community_controller.dart # Community management
│   │   ├── event_controller.dart    # Event management
│   │   ├── home_controller.dart      # Home screen logic
│   │   ├── onboarding_controller.dart # Onboarding flow
│   │   ├── profile_controller.dart   # Profile management
│   │   └── theme_controller.dart    # Theme switching
│   │
│   ├── model/
│   │   ├── category.dart            # Category model
│   │   ├── chat.dart                 # Chat model
│   │   ├── community.dart            # Community model
│   │   ├── event.dart                # Event model
│   │   ├── google_map_location.dart  # Location model
│   │   ├── interest_model.dart       # Interest model
│   │   ├── nearby_user.dart          # Nearby user model
│   │   └── notification.dart        # Notification model
│   │
│   ├── services/
│   │   ├── custom_http.dart         # Custom HTTP client
│   │   ├── http_logger.dart          # HTTP logging
│   │   └── local_storage.dart        # Local storage wrapper
│   │
│   ├── views/
│   │   ├── main_nav_bar_screen.dart  # Main navigation
│   │   ├── auth/
│   │   │   ├── splash_screen.dart
│   │   │   ├── intro_screen.dart
│   │   │   ├── sign_in_screen.dart
│   │   │   ├── sign_up_screen.dart
│   │   │   ├── email_verification_screen.dart
│   │   │   ├── otp_verification_screen.dart
│   │   │   ├── new_password_screen.dart
│   │   │   ├── steps/                 # Onboarding steps
│   │   │   └── widgets/               # Auth widgets
│   │   ├── chat/
│   │   │   ├── chat_screen.dart
│   │   │   ├── chat_inbox_screen.dart
│   │   │   ├── chat_wave_screen.dart
│   │   │   ├── community_chat_inbox_screen.dart
│   │   │   ├── block_screen.dart
│   │   │   └── report_screen.dart
│   │   ├── community/
│   │   │   ├── community_screen.dart
│   │   │   ├── community_details_screen.dart
│   │   │   ├── create_community_screen.dart
│   │   │   ├── edit_community_screen.dart
│   │   │   ├── community_member_screen.dart
│   │   │   ├── meetup_details_screen.dart
│   │   │   └── widgets/
│   │   ├── event/
│   │   │   ├── event_screen.dart
│   │   │   ├── event_details_screen.dart
│   │   │   ├── create_event_screen.dart
│   │   │   ├── edit_event_screen.dart
│   │   │   ├── event_checkin_screen.dart
│   │   │   └── widgets/
│   │   ├── home/
│   │   │   ├── home_screen.dart
│   │   │   └── widgets/
│   │   ├── notification/
│   │   ├── profile/
│   │   ├── settings/
│   │   ├── subscription/
│   │   ├── vibe/
│   │   └── common/
│   │
│   ├── design_system/
│   │   ├── design_system.dart       # Design system exports
│   │   ├── theme/
│   │   │   ├── app_theme.dart        # Theme configuration
│   │   │   ├── light_theme.dart      # Light theme
│   │   │   └── dark_theme.dart       # Dark theme
│   │   ├── tokens/
│   │   │   ├── colors.dart            # Color palette
│   │   │   ├── typography.dart       # Text styles
│   │   │   ├── shadows.dart          # Shadow definitions
│   │   │   └── tokens.dart           # Design tokens
│   │   ├── foundations/             # Foundation components
│   │   └── components/              # Reusable components
│   │
│   ├── utils/
│   │   ├── audio_picker.dart
│   │   ├── check_for_internet.dart
│   │   ├── ffmpeg.dart
│   │   ├── image_picker.dart
│   │   ├── image_viewer.dart
│   │   ├── number_magnitude.dart
│   │   ├── pretty_date.dart
│   │   ├── print_helper.dart
│   │   ├── report_widget.dart
│   │   ├── rich_text.dart
│   │   ├── short_name.dart
│   │   ├── simple_text_updater.dart
│   │   ├── validation.dart
│   │   └── video_picker.dart
│   │
│   └── gen/
│       └── assets.gen.dart          # Generated assets
│
├── assets/
│   ├── icons/
│   ├── images/
│   ├── images/onbording/
│   ├── flags/
│   ├── map_theme/
│   └── lottie/
│
├── android/
├── ios/
├── linux/
├── macos/
├── windows/
└── web/
```

---

## Getting Started

### Prerequisites

- Flutter SDK 3.9 or higher
- Dart SDK 3.9 or higher
- Android SDK (for Android builds)
- Xcode (for iOS builds, macOS only)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd vibe_now
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure environment**
   
   Create a `.env` file in the project root:
   ```env
   API_BASE_URL=https://your-api-endpoint.com
   MAP_API_KEY=your_google_maps_api_key
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

### Build Commands

```bash
# Debug build
flutter build apk --debug

# Release build (Android)
flutter build apk --release

# iOS build
flutter build ios --release

# Web build
flutter build web
```

---

## Design System

### Theme System

The app supports both light and dark themes with seamless switching:

- **Light Theme** - Default light mode with white backgrounds
- **Dark Theme** - Dark mode with optimized contrast

Theme switching is handled by `ThemeController` using GetX reactive state.

### Design Tokens

| Token | Description |
|-------|-------------|
| Colors | Primary, secondary, accent, error, surface colors |
| Typography | Font families, sizes, weights, line heights |
| Spacing | Margins, padding, gaps |
| Border Radius | Standard corner radii |
| Shadows | Elevation levels |

### Responsive Design

The app uses `flutter_screenutil` for responsive design with a base design size of 375x812 (iPhone X dimensions).

---

## API Endpoints

### Authentication Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/auth/sign-up` | POST | Register new user |
| `/auth/verify-email` | POST | Verify email with OTP |
| `/auth/resend-verification-code` | POST | Resend OTP |
| `/auth/sign-in` | POST | User login |
| `/auth/refresh` | POST | Refresh access token |
| `/auth/forgot-password` | POST | Request password reset |
| `/auth/verify-reset-code` | POST | Verify password reset OTP |
| `/auth/reset-password` | POST | Set new password |

### Onboarding Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/onboarding/complete` | POST | Complete onboarding |
| `/onboarding/upload-photos` | POST | Upload profile photos |
| `/onboarding/location-setup` | POST | Set user location |

### Event Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/events/create` | POST | Create new event |
| `/events` | GET | Get events list |

---

## Data Models

### Event Model

```dart
class Event {
  final int? id;
  final String? coverImage;
  final String? title;
  final List<Category>? categories;
  final String? accessLevel;
  final double? latitude;
  final double? longitude;
  final String? address;
  final String? eventDate;
  final String? eventTime;
  final int? maxAttendees;
  final String? status;
  final String? qrCodeValue;
  final String? qrCodeImage;
  final CreatedBy? createdBy;
  final int? joinedCount;
  final int? interestedCount;
  final bool? isJoined;
  final bool? isRequested;
  final bool? isInterested;
  final String? chatId;
  final String? createdAt;
}
```

### Community Model

```dart
class Community {
  String name;
  String description;
  String location;
  String distance;
  String dateTime;
  String attending;
  String totalAttending;
  String image;
  List<String> avatars;
  int extraCount;
  bool isMyCommunity;
  bool isJoined;
  bool isInterested;
  CommunityStatus? userStatus;
  CommunityAccessType accessType;
  bool isFavorite;
}
```

### Other Models

- **Category** - Event/community categories
- **CreatedBy** - User who created an event
- **Chat** - Chat conversation data
- **Notification** - Push notification data
- **InterestModel** - User interests
- **NearbyUser** - Nearby user data

---

## Navigation

The app uses **Go Router** for declarative routing with the following structure:

### Route Names

| Route Name | Path | Description |
|------------|------|-------------|
| `splashScreen` | `/` | App splash |
| `introScreen` | `/intro` | App introduction |
| `signInScreen` | `/signin` | Login screen |
| `signUpScreen` | `/signup` | Registration screen |
| `emailVerificationScreen` | `/email-verification` | Email verification |
| `otpVerificationScreen` | `/otp-verification` | OTP verification |
| `newPasswordScreen` | `/new-password` | Password reset |
| `stepNameScreen` | `/step-name` | Onboarding - name |
| `stepPhotoUploadScreen` | `/step-photo-upload` | Onboarding - photo |
| `mainNavBar` | `/main-nav-bar` | Main app navigation |
| `communityScreen` | `/community-screen` | Communities list |
| `communityDetailsScreen` | `/community-details-screen` | Community details |
| `createCommunityScreen` | `/create-community-screen` | Create community |
| `eventScreen` | `/event-screen` | Events list |
| `eventDetailsScreen` | `/event-details-screen` | Event details |
| `createEventScreen` | `/create-event-screen` | Create event |
| `editEventScreen` | `/edit-event-screen` | Edit event |
| `qrVerificationScreen` | `/qr-verification-screen` | QR verification |
| `subscriptionScreen` | `/subscription-screen` | Subscription |
| `notificationScreen` | `/notification-screen` | Notifications |
| `chatScreen` | `/chat-screen` | Chat room |
| `chatInboxScreen` | `/chat-inbox-screen` | Chat list |
| `profileScreen` | `/profile-screen` | User profile |
| `settingsScreen` | `/setting-screen` | Settings |
| `waveScreen` | `/wave-screen` | Wave feature |

### Navigation Flow

1. **App Start** → Splash Screen → (Check auth) → Main Nav or Intro
2. **New User** → Intro → Sign Up → OTP Verification → Onboarding → Main Nav
3. **Returning User** → Splash → Main Nav (Events, Communities, Vibe, Profile)

---

## State Management

The app uses **GetX** for state management, dependency injection, and routing.

### Controllers

| Controller | Purpose |
|------------|---------|
| `ThemeController` | Manages light/dark theme switching (permanent) |
| `AuthController` | Authentication state and operations |
| `HomeController` | Home screen data and filters |
| `EventController` | Event CRUD operations |
| `CommunityController` | Community management |
| `ProfileController` | User profile operations |
| `OnBoardingController` | Onboarding step management |

### Dependency Injection

Controllers are registered in `ControllerBinding`:

```dart
class ControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(ThemeController(), permanent: true);
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<ProfileController>(() => ProfileController());
    Get.lazyPut<EventController>(() => EventController());
    Get.lazyPut<CommunityController>(() => CommunityController());
    Get.lazyPut<AuthController>(() => AuthController());
    Get.lazyPut<OnBoardingController>(() => OnBoardingController());
  }
}
```

---

## Local Storage

The app uses **SharedPreferences** for local key-value storage via a custom wrapper class `LocalStorage`.

### Storage Keys

| Key | Type | Description |
|-----|------|-------------|
| `access_token` | String | JWT access token |
| `refresh_token` | String | JWT refresh token |
| `access_token_valid_till` | Int | Token expiration timestamp |
| `role` | String | User role |
| `user_id` | String | User ID |
| `full_name` | String | User's full name |
| `cookie` | String | Session cookie |

### Usage Example

```dart
// Save token
await LocalStorage.access_token.set('your_token');

// Retrieve token
String? token = await LocalStorage.access_token.get();

// Clear all storage
await LocalStorage.clear();
```

---

## Screens Overview

### Authentication Screens

- **Splash Screen** - App branding and initialization
- **Intro Screen** - App features introduction
- **Sign In Screen** - Email/password login
- **Sign Up Screen** - New user registration
- **Email Verification Screen** - Verify email address
- **OTP Verification Screen** - OTP entry for verification
- **New Password Screen** - Password reset

### Onboarding Steps

1. **Step Name Screen** - Enter display name
2. **Step Upload Image Screen** - Upload profile photo
3. **Step Interest Selection Screen** - Select interests
4. **Step Location Screen** - Set location
5. **Step Gender Screen** - Select gender
6. **Step Birthday Screen** - Set birthday
7. **Step Looking For Screen** - Set preferences

### Main App Screens

- **Main Nav Bar** - Bottom navigation with 4 tabs
- **Home Screen** - Map with events/communities
- **Event Screen** - Event listing
- **Community Screen** - Community listing
- **Vibe Screen** - Meetup feature
- **Profile Screen** - User profile

### Feature Screens

- **Event Details** - Event information and actions
- **Create/Edit Event** - Event form
- **Community Details** - Community information
- **Create/Edit Community** - Community form
- **Meetup Details** - Meetup information
- **Chat Screen** - Messaging interface
- **Chat Inbox** - Conversation list
- **Notifications** - Push notifications
- **Settings** - App settings
- **Edit Profile** - Profile editing

---

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/your-feature`)
3. Commit your changes (`git commit -m 'Add some feature'`)
4. Push to the branch (`git push origin feature/your-feature`)
5. Create a Pull Request

### Code Standards

- Follow Flutter and Dart style guides
- Use meaningful variable and function names
- Add comments for complex logic
- Write responsive UI code using ScreenUtil
- Follow the project architecture structure

---

## License

This project is proprietary and confidential. All rights reserved.

---

## Support

For issues or questions, please contact the development team.

---

## Acknowledgments

- Flutter team for the amazing framework
- GetX for state management
- Go Router for navigation
- All open source package maintainers