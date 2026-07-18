# Vybin (Vibe Now)

> **A social discovery platform** — Find events, build communities, send waves, and make real-life connections.

Vybin (internally named `vibe_now`) is a Flutter mobile application that connects people through location-based events, communities, spontaneous meetups ("vibes"), and real-time chat. The app features QR code verification, wave-based introductions, trust scoring, and subscription plans — all wrapped in a polished light/dark theme with responsive design.

---

## Table of Contents

- [Features](#features)
- [Screens & Navigation](#screens--navigation)
- [Tech Stack](#tech-stack)
- [Architecture](#architecture)
- [Project Structure](#project-structure)
- [Data Models](#data-models)
- [Controllers (State Management)](#controllers-state-management)
- [Services](#services)
- [Design System](#design-system)
- [Localization](#localization)
- [API Endpoints](#api-endpoints)
- [Getting Started](#getting-started)
- [Build & Deploy](#build--deploy)
- [Contributing](#contributing)

---

## Features

### 🔐 Authentication & Onboarding

- Email sign-up with OTP verification
- Sign-in with email/password
- Password reset flow via OTP
- Multi-step onboarding wizard:
  1. **Name** — Enter display name
  2. **Photo** — Upload profile image (camera or gallery)
  3. **Interests** — Select up to 5 interests from categories
  4. **Location** — Set location via map or current position
  5. **Gender** — Select gender
  6. **Birthday** — Select date of birth (profile only shows age)
  7. **Looking For** — Set connection preferences

### 🏠 Home & Discovery

- **Interactive Map** — Google Maps / OpenStreetMap (`flutter_map`) with event, community, and user markers
- **Grouped Markers** — Clusters of nearby items with count indicators
- **Filters** — Filter by category, distance, date, and interests
- **Nearby Users** — Discover nearby active profiles
- **Location Search** — Google Places-based location search with history
- **Pro Tips** — Contextual onboarding tips for new users

### 📅 Events

- Create public or private events
- Set date, time, location, cover image, description, capacity
- Event categories with sub-categories
- Join / leave / express interest
- Request system for private events (approve/reject)
- QR code generation for event check-in
- Event zone geo-fencing with check-in/check-out
- Event chat rooms (admin-to-member announcements)
- Edit, delete, and archive events

### 👥 Communities

- Create public or private communities
- Community member management (active, requested, invited tabs)
- QR code based membership verification
- Scheduled meetups within communities
- Plan meetups, invite members
- Community-wide announcements
- Awaiting meetup confirmation flow
- Edit community details, manage requests

### 🌊 Waves & Vibes

- **Vibe** — A temporary location-based status that makes you discoverable on the map. Set a title, duration, and location.
- **Wave** — Send a wave to a nearby user to express interest. The recipient can accept, reject, or suggest a meetup.
- **Meetup Flow** — Accept a wave → suggest meeting spot (my location, midpoint, or pick on map) → schedule date/time → confirm → reschedule
- **QR Verification** — In-person QR scanning to verify meetups
- **Wave History** — View incoming/outgoing waves with status

### 💬 Chat & Messaging

- **Private Chats** — Direct messaging between users (initiated via wave or QR)
- **Event Chats** — Admin-to-member announcements for events
- **Community Chats** — Group chat for community members
- **Wave-based Chat** — Chat thread from wave/meetup connection
- **Real-time** — WebSocket-based live messaging
- **Chat Features** — Text, images, voice messages, audio waveforms
- **Moderation** — Block users, report messages, delete chats

### 🔔 Notifications

- Tab-based notifications: **Waves**, **Events**, **Communities**
- Notification actions: approve/reject join requests
- In-app notification display with type-specific cards
- Unread counts per category
- Read state tracking

### 👤 Profile

- View profile (own and others')
- Profile photo, bio, interests, photos gallery
- Locked profile screen for restricted profiles
- Like/liked profiles list
- Trust/respect score display
- Profile completion indicator

### ⚙️ Settings

- Theme: Light / Dark / System
- Language: English / German
- Edit profile (name, bio, photos, interests)
- Change password
- Manage blocked accounts
- Pause / delete account
- Subscription & premium plans
- Terms of service & privacy policy
- Location sharing controls

### 💎 Subscription / Premium

- **Free Plan** — 6 waves/day, 3 communities, 1 event/month, 25 members/community, 200 km range
- **Plus Plan** — 12 waves/day, 6 communities, 4 events/month, 50 members/community, 100 participants/event
- **Premium Plan** — Unlimited waves, communities, events, members, and participants
- Stripe / PayPal payment integration
- Subscription management screens

### 🎨 Design System

- Light & dark theme with seamless switching
- Responsive layout via `flutter_screenutil` (375×812 base)
- Custom color tokens, typography, shadows, spacing
- Reusable components: buttons, search bars, dialogs, chips, avatars
- Lottie animations throughout
- Gradient tab bars with custom icons

---

## Screens & Navigation

The app uses **Go Router** for declarative routing with 40+ named routes.

### Authentication Flow

| Route | Screen | Description |
|-------|--------|-------------|
| `/` | SplashScreen | App branding & auth check |
| `/choose-language` | ChooseLanguageScreen | Language selection |
| `/intro` | IntroScreen | App feature introduction |
| `/signin` | SignInScreen | Email/password login |
| `/signup` | SignUpScreen | Registration form |
| `/signup-otp-verification` | SignupOtpVerificationScreen | Verify sign-up OTP |
| `/otp-verification` | OtpVerificationScreen | Forgot-password OTP |
| `/new-password` | NewPasswordScreen | Reset password |
| `/email-verification` | EmailVerificationScreen | Verify email |

### Onboarding Steps

| Route | Screen | Purpose |
|-------|--------|---------|
| `/step-name` | StepNameScreen | Display name |
| `/step-photo-upload` | StepUploadImageScreen | Profile photo |

Other steps (interest, location, gender, birthday, looking for) are managed within the onboarding flow via `OnBoardingController`.

### Main App

| Route | Screen | Tab |
|-------|--------|-----|
| `/main-nav-bar` | MainNavBarScreen | Bottom nav (4 tabs) |

Bottom tabs: **Home** (map), **Events**, **Communities**, **Chat/Profile**

### Feature Screens

| Route | Screen | Description |
|-------|--------|-------------|
| `/event-screen` | EventScreen | Events list (all/joined/organized/interested) |
| `/event-details-screen` | EventDetailsScreen | Event details & actions |
| `/create-event-screen` | CreateEventScreen | Create new event |
| `/edit-event-screen` | EditEventScreen | Edit existing event |
| `/community-screen` | CommunityScreen | Communities list (all/joined/organized/interested) |
| `/community-details-screen` | CommunityDetailsScreen | Community details & actions |
| `/create-community-screen` | CreateCommunityScreen | Create new community |
| `/member-screen` | CommunityMemberScreen | Community members |
| `/community-manage-member-screen` | CommunityManageMemberScreen | Manage member requests |
| `/community-awaiting-details-screen` | CommunityAwaitingDetailsScreen | Awaiting meetup confirmations |
| `/notification-screen` | NotificationScreen | Notifications (waves/events/communities) |
| `/chat-screen` | ChatScreen | Chat list (waves/private/event/community tabs) |
| `/chat-inbox-screen` | ChatInboxScreen | Private chat conversation |
| `/event-chat-screen` | EventChatInboxScreen | Event chat room |
| `/community-chat-screen` | CommunityChatInboxScreen | Community chat room |
| `/wave-screen` | ChatWaveScreen | Wave requests |
| `/profile-screen` | ProfileScreen | User profile view |
| `/locked-profile-screen` | LockedProfileScreen | Restricted profile |
| `/like-screen` | LikeListScreen | Liked profiles |
| `/qr-verification-screen` | QRVerificationScreen | QR scan & display |
| `/subscription-screen` | SubscriptionScreen | Plans & payment |
| `/setting-screen` | SettingsScreen | App settings |
| `/report-screen` | ReportScreen | Report user |
| `/block-screen` | BlockScreen | Block user |
| `/reason-screen` | DeleteReasonScreen | Deletion reason |
| `/delete-confirm-screen` | DeleteConfirmScreen | Account deletion confirmation |

---

## Tech Stack

### Framework & Language

| Technology | Version |
|------------|---------|
| Flutter | 3.9+ |
| Dart | ^3.9.2 |

### Core Dependencies

| Package | Purpose |
|---------|---------|
| `get: ^4.7.3` | State management, DI, routing helpers |
| `go_router: ^17.0.1` | Declarative routing |
| `dio: ^5.9.0` | HTTP client |
| `flutter_screenutil: ^5.9.3` | Responsive scaling |
| `google_maps_flutter: ^2.14.0` | Google Maps |
| `flutter_map: ^8.2.2` | OpenStreetMap fallback |
| `geolocator: ^14.0.2` | GPS location |
| `geocoding: ^4.0.0` | Address ↔ coordinates |
| `shared_preferences: ^2.3.2` | Local key-value storage |
| `web_socket_channel: ^3.0.3` | Real-time messaging |
| `flutter_svg: ^2.2.3` | SVG rendering |
| `lottie: ^3.3.2` | Animations |
| `cached_network_image: ^3.4.1` | Image caching |
| `qr_code_scanner_plus: ^2.0.14` | QR scanning |
| `image_picker: ^1.2.1` | Camera/gallery |
| `image_cropper: ^8.0.2` | Image cropping |
| `intl: ^0.20.2` | Date/time formatting |
| `timeago: ^3.7.1` | Relative time display |
| `connectivity_plus: ^6.0.5` | Network monitoring |
| `record: ^6.1.1` | Voice recording |
| `audio_waveforms: ^1.1.0` | Voice waveform UI |
| `audioplayers: ^6.5.1` | Audio playback |
| `permission_handler: ^11.3.1` | Runtime permissions |
| `skeletonizer: ^2.1.3` | Shimmer loading |
| `shimmer: ^3.0.0` | Shimmer effects |
| `carousel_slider: ^5.1.2` | Image carousels |
| `photo_view: ^0.15.0` | Image pinch-to-zoom |
| `pinput: ^6.0.1` | OTP input fields |

### Development Dependencies

| Package | Purpose |
|---------|---------|
| `flutter_lints: ^5.0.0` | Lint rules |
| `build_runner` | Code generation |
| `flutter_gen_runner: ^5.12.0` | Asset code-gen |

---

## Architecture

The project follows **Clean Architecture** principles with clear separation of concerns across layers:

```
lib/
├── core/              # Business logic: constants, routes, network, errors
├── controller/        # GetX controllers — business logic & state
├── model/             # Data models with JSON serialization
├── services/          # External integrations: HTTP, WebSocket, storage
├── views/             # UI layer: screens, widgets
├── design_system/     # Theme, colors, typography, components
├── localization/      # i18n (English, German)
├── utils/             # Utility functions
└── gen/               # Generated code (assets)
```

### Layer Responsibilities

| Layer | Responsibility |
|-------|---------------|
| **Core** | API constants, route definitions, Dio network client, error/failure types, helpers |
| **Controller** | Business logic, API orchestration, reactive state via GetX `Rx` variables |
| **Model** | Dart data classes with `fromJson` factory constructors and `toJson` methods |
| **Services** | HTTP client, WebSocket registry & socket service, SharedPreferences wrapper |
| **Views** | Screens organized by feature, reusable widget components |
| **Design System** | Theme configuration, color tokens, typography scales, shared UI components |
| **Localization** | `AppLocalizations` abstract class with English and German implementations |

---

## Project Structure

```
vibe_now/
├── lib/
│   ├── main.dart                          # App entry point
│   ├── controller_binding.dart            # GetX dependency injection
│   ├── env.dart                           # Environment config
│   ├── utils.dart                         # Barrel export for utils
│   │
│   ├── core/
│   │   ├── constant/
│   │   │   ├── api_constant.dart          # API endpoint paths
│   │   │   ├── credential.dart            # Credential helpers
│   │   │   ├── env_constant.dart          # Environment keys
│   │   │   └── qrcontext_enum.dart        # QR context enum
│   │   ├── error/
│   │   │   ├── exceptions.dart            # Custom exceptions
│   │   │   └── failures.dart              # Failure types
│   │   ├── helper/
│   │   │   ├── app_snackbar.dart          # Snackbar utility
│   │   │   └── helper.dart                # General helpers
│   │   ├── network/
│   │   │   ├── dio_client.dart            # Dio HTTP client config
│   │   │   └── network_info.dart          # Connectivity check
│   │   ├── routes/
│   │   │   ├── route_names.dart           # Named route constants
│   │   │   └── routes.dart                # GoRouter configuration
│   │   └── usecase/
│   │       └── usecase.dart               # Use case base class
│   │
│   ├── controller/
│   │   ├── auth_controller.dart           # Auth: sign-up, sign-in, OTP, reset
│   │   ├── chat_controller.dart           # Chat list, messages, sockets
│   │   ├── community_controller.dart      # Community CRUD, members
│   │   ├── event_controller.dart          # Event CRUD, participants
│   │   ├── home_controller.dart           # Map data, filters, discovery
│   │   ├── meetup_controller.dart         # Meetup scheduling & management
│   │   ├── notification_controller.dart   # Notifications list, actions
│   │   ├── onboarding_controller.dart     # Multi-step onboarding flow
│   │   ├── profile_controller.dart        # Profile editing, photos
│   │   ├── theme_controller.dart          # Light/dark theme switching
│   │   ├── vibe_controller.dart           # Vibe CRUD, active vibes
│   │   └── wave_controller.dart           # Wave send/accept/reject/meetup
│   │
│   ├── model/
│   │   ├── blocked_user.dart              # Blocked user data
│   │   ├── category.dart                  # Category & sub-category
│   │   ├── chat.dart                      # Chat conversation
│   │   ├── chat_message.dart              # Individual message
│   │   ├── community.dart                 # Community data
│   │   ├── community_member.dart          # Community membership
│   │   ├── event.dart                     # Event data
│   │   ├── event_participants.dart        # Event attendance
│   │   ├── google_map_location.dart       # Map location with place details
│   │   ├── incoming_wave.dart             # Wave request data
│   │   ├── interest_model.dart            # User interests
│   │   ├── map_item.dart                  # Map marker data
│   │   ├── meetup.dart                    # Meetup scheduling
│   │   ├── nearby_user.dart               # Nearby discoverable user
│   │   ├── notification.dart              # Notification + NotificationStats
│   │   ├── profile_model.dart             # User profile
│   │   ├── scan_result.dart               # QR scan result
│   │   └── vibe_model.dart                # Vibe status data
│   │
│   ├── services/
│   │   ├── custom_http.dart               # Http package client
│   │   ├── http_logger.dart               # HTTP request/response logging
│   │   ├── local_storage.dart             # SharedPreferences typed wrapper
│   │   ├── map_socket_service.dart        # Map location WebSocket
│   │   └── web_socket_registry.dart       # Chat WebSocket management
│   │
│   ├── views/
│   │   ├── main_nav_bar_screen.dart       # Bottom navigation scaffold
│   │   ├── auth/                          # Auth & onboarding screens
│   │   ├── chat/                          # Chat list, inbox, wave, block, report
│   │   ├── common/                        # Shared widgets: app bar, dialogs, buttons
│   │   ├── community/                     # Community CRUD, members, meetups
│   │   ├── event/                         # Event CRUD, members, check-in
│   │   ├── home/                          # Map, filters, pins, location search
│   │   ├── notification/                  # Notification tabs with type-specific cards
│   │   ├── profile/                       # Profile view, locked profile, likes
│   │   ├── qr_verification/              # QR display, scanner, success
│   │   ├── settings/                      # Theme, language, password, blocked, delete
│   │   ├── subscription/                  # Plans, payment, success
│   │   └── vibe/                          # Vibe CRUD, meetup confirm, reschedule
│   │
│   ├── design_system/
│   │   ├── design_system.dart             # Barrel export
│   │   ├── theme/
│   │   │   ├── app_theme.dart             # Theme factory (light/dark)
│   │   │   ├── dark_theme.dart            # Dark theme definition
│   │   │   ├── light_theme.dart           # Light theme definition
│   │   │   └── theme_extensions.dart      # Custom theme extensions
│   │   ├── tokens/
│   │   │   ├── colors.dart                # AppColors palette
│   │   │   ├── typography.dart            # AppTypography text styles
│   │   │   ├── shadows.dart               # Elevation shadows
│   │   │   ├── spacing.dart               # Spacing scale
│   │   │   └── tokens.dart                # Token barrel export
│   │   ├── components/
│   │   │   ├── buttons/                   # Primary, text, icon buttons
│   │   │   └── components.dart            # Components barrel export
│   │   └── foundations/
│   │       ├── animations.dart            # Animation durations & curves
│   │       ├── breakpoints.dart           # Responsive breakpoints
│   │       ├── elevations.dart            # Elevation levels
│   │       └── shapes.dart                # Border radius definitions
│   │
│   ├── localization/
│   │   ├── app_localizations.dart         # Localization abstract + delegates
│   │   ├── app_localizations_en.dart      # English strings (~600 keys)
│   │   ├── app_localizations_de.dart      # German translations
│   │   └── language_controller.dart       # Language switching (GetX reactive locale)
│   │
│   └── utils/
│       ├── audio_picker.dart              # Audio file selection
│       ├── check_for_internet.dart        # Internet connectivity check
│       ├── ffmpeg.dart                    # FFmpeg processing
│       ├── image_picker.dart              # Image selection helper
│       ├── image_viewer.dart              # Full-screen image view
│       ├── number_magnitude.dart          # Number formatting (1K, 1M)
│       ├── pretty_date.dart               # Relative date formatting
│       ├── print_helper.dart               # Debug printing
│       ├── report_widget.dart             # Report dialog builder
│       ├── rich_text.dart                 # Rich text parsing
│       ├── short_name.dart                # Name abbreviation
│       ├── simple_text_updater.dart        # Inline text editing
│       ├── title_case.dart                # Title case conversion
│       ├── validation.dart                # Form validation rules
│       └── video_picker.dart              # Video selection
│
├── assets/
│   ├── icons/                 # SVG icons (~60+ icons)
│   ├── images/                # PNG images
│   ├── images/onbording/      # Onboarding illustrations
│   ├── flags/                 # Language flag icons
│   ├── map_theme/             # Map style JSON (light, dark, pink)
│   └── lottie/                # Lottie animation JSON files
│
├── android/                   # Android platform (Kotlin)
├── ios/                       # iOS platform (Swift)
├── linux/                     # Linux desktop
├── macos/                     # macOS desktop
├── windows/                   # Windows desktop
└── web/                       # Web platform
```

---

## Data Models

### Event (`lib/model/event.dart`)
```dart
class Event {
  int? id, maxAttendees, joinedCount, interestedCount;
  String? coverImage, title, description, accessLevel;
  double? latitude, longitude;
  String? address, eventDate, eventTime, status;
  String? qrCodeValue, qrCodeImage, chatId, createdAt;
  List<Category>? categories;
  CreatedBy? createdBy;
  bool? isJoined, isRequested, isInterested;
}
```

### Community (`lib/model/community.dart`)
```dart
class Community {
  int? id, extraCount, memberCount, maxMembers;
  String? title, coverImage, description, chatId;
  double? latitude, longitude, distance;
  String? accessLevel, createdAt;
  List<Category>? categories;
  CreatedBy? createdBy;
  bool? isJoined, isInterested, isFav;
  CommunityStatus? userStatus;
}
```

### IncomingWave (`lib/model/incoming_wave.dart`)
```dart
class IncomingWave {
  int? id;
  String? status, createdAt;
  ProfileModel sender;
  VibeModel? vibe;
  NearbyUser? location;
  Meetup? meetup;
}
```

### Chat (`lib/model/chat.dart`)
```dart
class Chat {
  String id, name, type, lastMessage, lastMessageTime;
  String? avatar;
  List<String> avatars;
  int unreadCount;
  int? eventId;
  CommunityRef? community;
}
```

### Other Key Models

| Model | Fields |
|-------|--------|
| `NotificationModel` | id, type, title, body, isRead, relatedObject, actionStatus |
| `Meetup` | id, locationType, latitude, longitude, address, scheduledAt, status |
| `VibeModel` | id, title, duration, latitude, longitude, status |
| `Category` | id, name, subCategories |
| `ProfileModel` | id, fullName, avatar, bio, email, interests, photos |
| `ScanResult` | type, communityId, eventId, meetupId, waveId, data |
| `MapItem` | id, type, latitude, longitude, name, subtitle, image |
| `ChatMessage` | id, chatId, senderId, message, type, timestamp, isRead |
| `BlockedUser` | id, name, avatar, blockedAt |
| `NearbyUser` | id, name, avatar, distance, latitude, longitude |

---

## Controllers (State Management)

All controllers are **GetX** reactive controllers registered in `ControllerBinding`.

| Controller | Key Responsibilities |
|------------|---------------------|
| `ThemeController` | Light/dark/system theme mode (permanent singleton) |
| `LanguageController` | Locale switching (permanent singleton) |
| `AuthController` | Login, register, OTP verify, password reset, token management |
| `OnBoardingController` | Multi-step onboarding form state |
| `HomeController` | Map markers, location, filters (event/community/vibe), search history |
| `EventController` | Event CRUD, event list by tab, participants, requests |
| `CommunityController` | Community CRUD, member management, meetups |
| `ChatController` | Chat list per type, messages, WebSocket connection |
| `WaveController` | Wave send/accept/reject, meetup suggestion |
| `VibeController` | Vibe create/end, active vibe management |
| `MeetupController` | Meetup plan/create, invite members |
| `ProfileController` | Profile CRUD, photo management, interests |
| `NotificationController` | Notifications by tab, mark read, approve/reject actions |

Controllers use `Rx` reactive variables (`.obs`) and `Obx` / `GetBuilder` widgets for automatic UI updates.

```dart
class ControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(ThemeController(), permanent: true);
    Get.put(LanguageController(), permanent: true);
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<EventController>(() => EventController());
    Get.lazyPut<CommunityController>(() => CommunityController());
    Get.lazyPut<ChatController>(() => ChatController());
    Get.lazyPut<WaveController>(() => WaveController());
    // ... etc
  }
}
```

---

## Services

| Service | Type | Description |
|---------|------|-------------|
| `custom_http.dart` | HTTP | Low-level `package:http` client with auth headers |
| `dio_client.dart` | HTTP | Dio client with interceptors, retry, logging |
| `http_logger.dart` | Utility | HTTP request/response logging |
| `local_storage.dart` | Storage | Typed `SharedPreferences` wrapper (access token, refresh token, user ID, name, location, etc.) |
| `web_socket_registry.dart` | WebSocket | Manages chat WebSocket connections with auto-reconnect |
| `map_socket_service.dart` | WebSocket | Real-time location sharing for map presence |

### Local Storage Keys

| Key | Type | Purpose |
|-----|------|---------|
| `access_token` | String | JWT access token |
| `refresh_token` | String | JWT refresh token |
| `access_token_valid_till` | int | Token expiration timestamp |
| `user_id` | String | Current user ID |
| `full_name` | String | Current user name |
| `role` | String | User role |
| `cookie` | String | Session cookie |
| `last_latitude` | double | Last known latitude |
| `last_longitude` | double | Last known longitude |
| `has_seen_pro_tips` | bool | Pro tips dismissal state |

---

## Design System

### Theme

The app uses a custom `AppTheme` class that extends Material 3 theming:

- **Light Theme**: White backgrounds, primary purple gradient, high contrast
- **Dark Theme**: Dark surfaces, adjusted contrast for readability

Theme switching is reactive via `ThemeController.themeMode` (Rx).

### Color Tokens (`lib/design_system/tokens/colors.dart`)

- `AppColors.primary` — Purple (#8663F6)
- `AppColors.secondary` — Pink
- `AppColors.secondaryText` — Muted text
- Surface colors, error colors, gradient definitions

### Typography (`lib/design_system/tokens/typography.dart`)

- `AppTypography.textTheme` — Custom `TextTheme` with defined sizes, weights, and line heights
- Responsive font scaling via `flutter_screenutil` (`.sp`)

### Components

- **Buttons**: `PrimaryButton`, `AppTextButton`, `IconButton`
- **App Bar**: `CustomAppBar` with gradient support
- **Dialogs**: `ConfirmationDialog`, `RequestSentDialog`, `MemberConfirmationDialog`, `CustomDatePicker`, `CustomTimePicker`
- **Other**: `AvatarStack`, `GradientSwitch`, `CustomSearchBar`, `InterestChip`, `CancelButton`

### Responsive Design

Base design size: **375 × 812** (iPhone X) — configured in `ScreenUtilInit`:
```dart
ScreenUtilInit(
  designSize: const Size(375, 812),
  builder: (context, child) => ...
)
```

---

## Localization

The app supports **English** and **German** with ~600 translated keys.

| File | Language |
|------|----------|
| `app_localizations_en.dart` | English (source of truth) |
| `app_localizations_de.dart` | German translations |
| `app_localizations.dart` | Abstract class + `LocalizationsDelegate` |
| `language_controller.dart` | GetX reactive locale switching |

Usage:
```dart
final loc = AppLocalizations.of(context);
loc.translate('keyName');
```

---

## API Endpoints

All endpoints are defined in `lib/core/constant/api_constant.dart`.

### Authentication

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/auth/sign-up` | POST | Register new user |
| `/auth/verify-email` | POST | Verify email with OTP |
| `/auth/resend-verification-code` | POST | Resend verification OTP |
| `/auth/sign-in` | POST | Sign in with email/password |
| `/auth/refresh` | POST | Refresh JWT access token |
| `/auth/forgot-password` | POST | Request password reset |
| `/auth/verify-reset-code` | POST | Verify reset OTP |
| `/auth/reset-password` | POST | Set new password |
| `/auth/change-password` | POST | Change password (authenticated) |
| `/auth/block-user` | POST | Block a user |
| `/auth/block-user-list` | GET | List blocked users |
| `/auth/unblock-user` | POST | Unblock a user |
| `/auth/me` | GET | Get profile |

### Onboarding

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/onboarding/complete` | POST | Complete onboarding |
| `/onboarding/upload-photos` | POST | Upload profile photos |
| `/onboarding/location-setup` | POST | Set user location |
| `/onboarding/current-location` | POST | Update current location |
| `/onboarding/me/update` | POST | Update profile |
| `/onboarding/upload-profile-photo` | POST | Upload profile photo |

### Events

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/events/create` | POST | Create event |
| `/events` | GET | List events |

### Communities

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/communities/create` | POST | Create community |
| `/communities` | GET | List communities |
| `/communities/{id}/request-status` | GET | Community join request status |

### Vibes & Waves

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/vibes` | — | Vibe CRUD |
| `/vibes/send-wave` | POST | Send wave to user |
| `/vibes/wave-list` | GET | Incoming/outgoing waves |
| `/vibes/wave/{id}/moderate` | POST | Accept/reject wave |
| `/vibes/wave/{id}/suggest-meetup` | POST | Suggest meetup for wave |
| `/vibes/scan-wave-meetup-qr` | POST | Scan wave meetup QR |

### Notifications

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/notifications` | GET | List notifications |
| `/notifications/mark-as-read` | POST | Mark notifications as read |
| `/notifications/{id}/action` | POST | Approve/reject notification action |

### Chat

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/chats` | GET | List chats |
| `/ws/chat/{chatId}` | WebSocket | Real-time chat messages |
| `/ws/chat/list/` | WebSocket | Real-time chat list updates |

---

## Getting Started

### Prerequisites

- Flutter SDK 3.9+ (`flutter --version`)
- Dart SDK 3.9+
- Android Studio or Xcode (for platform builds)
- Chrome (for web builds)

### Installation

```bash
# 1. Clone the repository
git clone <repository-url>
cd vibe_now

# 2. Install dependencies
flutter pub get

# 3. Create .env file in project root
# (see Environment Variables below)

# 4. Run the app
flutter run
```

### Environment Variables

Create a `.env` file in the project root:

```env
API_BASE_URL=https://your-api-server.com
MAP_API_KEY=your_google_maps_api_key
```

### Code Generation

```bash
# Generate assets (icons, images)
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## Build & Deploy

```bash
# Debug APK
flutter build apk --debug

# Release APK (Android)
flutter build apk --release

# App Bundle (Google Play)
flutter build appbundle --release

# iOS (requires macOS + Xcode)
flutter build ios --release

# Web
flutter build web

# Desktop (Linux)
flutter build linux

# Desktop (macOS)
flutter build macos

# Desktop (Windows)
flutter build windows
```

---

## Design Patterns & Conventions

### Naming

- **Files**: `snake_case` (e.g., `event_details_screen.dart`)
- **Classes**: `PascalCase` (e.g., `EventDetailsScreen`)
- **Variables/Methods**: `camelCase` (e.g., `_buildEmptyState`)
- **Constants**: `lowerCamelCase` (Dart convention)
- **Private members**: prefixed with `_`

### State Management

- Controllers use `Rx` variables for reactive state
- UI uses `Obx` for automatic rebuilds
- `Get.find<T>()` for dependency resolution
- `Get.lazyPut<T>(() => T())` in controller bindings

### API Calls

- Dio client with interceptors for auth headers
- Error handling via `try/catch` with `AppSnackbar` for user feedback
- Loading states tracked per-controller with `RxBool`

---

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/your-feature`)
3. Commit your changes (`git commit -m 'Add some feature'`)
4. Push to the branch (`git push origin feature/your-feature`)
5. Create a Pull Request

### Code Standards

- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart) style guide
- Use meaningful variable and function names
- Add comments for complex business logic
- Write responsive UI using `flutter_screenutil` (`.w`, `.h`, `.sp`, `.r`)
- Follow the existing project architecture
- Run `flutter analyze` before committing

---

## License

This project is proprietary and confidential. All rights reserved.

---

## Acknowledgments

- [Flutter](https://flutter.dev/) — UI toolkit
- [GetX](https://github.com/jonataslaw/getx) — State management
- [Go Router](https://gorouter.dev/) — Declarative routing
- [Dio](https://pub.dev/packages/dio) — HTTP client
- [flutter_screenutil](https://pub.dev/packages/flutter_screenutil) — Responsive design
- All open-source package maintainers whose work made this project possible
