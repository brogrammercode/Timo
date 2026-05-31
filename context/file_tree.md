# Timo App File Tree

This document outlines the complete folder and file structure for the Timo app, based on the defined code standards, UI standards, and app flow requirements.

## Root Directory

```text
timo/
├── .env ✅                      # Environment variables (e.g., secrets, API keys)
├── pubspec.yaml ✅              # Flutter dependencies, fonts (Outfit), and assets configuration
├── analysis_options.yaml       # Dart analyzer rules (strict linting)
├── android/                    # Android native project files
├── ios/                        # iOS native project files
├── context/                    # Project documentation and standards
│   ├── code_standard.md        # Architecture and coding rules
│   ├── ui_standard.md          # UI/UX design tokens and standards
│   ├── flow.md                 # App logic and flow description
│   └── file_tree.md            # This file
└── lib/                        # Main Flutter application code
```

## `lib/` Directory

```text
lib/
├── main.dart ✅                   # App entry point, initializes Firebase, dependencies, background/notification services, and bootstraps the app
├── firebase_options.dart ✅       # Generated Firebase configuration
│
├── core/                       # App-wide core configurations
│   ├── color.dart ✅            # AppColors (Primary Indigo, Pure White, Deep Onyx, Soft Grey, etc.)
│   ├── theme.dart ✅            # ThemeData, text themes (Outfit font setup), UI themes using flutter_screenutil
│   ├── routes.dart ✅           # AppRoutes (static const string routes and app routing map)
│   ├── di.dart ✅               # Dependency injection (GetIt locator, registering repos, services, cubits)
│   └── config.dart ✅           # Environment configuration loader (reading .env values safely)
│
├── constants/                  # Global constant values
│   ├── assets.dart ✅           # AppAssets (image, icon, and 3D illustration paths)
│   ├── firebase.dart ✅         # FirebaseConstants (collection names, shared field names)
│   └── notification.dart ✅     # Notification constants (channels, IDs)
│
├── components/                 # Global shared UI components
│   ├── ui/                     # Generic UI primitives
│   │   ├── app_button.dart ✅     # Standardized buttons (Primary, Secondary) with 16.r radius
│   │   ├── app_text_field.dart ✅ # Standardized text inputs with Soft Grey backgrounds
│   │   ├── app_card.dart ✅       # Card containers with defined border radius (32.r/16.r) and shadow
│   │   └── page_indicator.dart ✅ # Dots for onboarding or pagination
│   └── layout/                 # Layout wrappers
│       └── safe_scaffold.dart ✅  # Standardized scaffold with safe areas and default 24.w / 40.h padding
│
├── services/                   # Shared infrastructure services
│   ├── firebase_service.dart ✅   # Firebase instance wrappers and initializations
│   ├── local_storage.dart ✅      # Device-local persistence (secure storage for tokens/session recovery)
│   ├── background_service.dart ✅ # Background execution service for session handling when app is paused
│   └── notification_service.dart ✅ # Local notifications for session alerts and daily reminders
│
├── utils/                      # Cross-feature utility functions
│   ├── error.dart ✅            # App-level failures and exceptions (e.g., FirebaseFailure, AuthException)
│   └── try_catch.dart ✅        # typedef TaskResult and tryCatchAsync functional helpers
│
└── features/                   # Feature modules
    │
    ├── auth/                   # Authentication Feature
    │   ├── models/
    │   │   └── user_model.dart ✅ # UserModel (id, user_name, avatar_url, created_at, updated_at)
    │   ├── repo/
    │   │   └── auth_repo.dart ✅  # AuthRepo (Google sign-in, user profile creation in Firestore)
    │   ├── cubit/
    │   │   ├── auth_cubit.dart ✅ # Auth logic (login, logout, state management)
    │   │   └── auth_state.dart ✅ # AuthState (holds current UserModel and operation info)
    │   ├── pages/
    │   │   ├── splash_page.dart ✅    # Initial routing logic (checks auth & local session, routes to home or login)
    │   │   ├── login_page.dart ✅     # Google login screen
    │   │   └── profile_setup_page.dart ✅ # Setup unique user_name and generates random funky avatar
    │   ├── components/
    │   │   └── auth_social_button.dart ✅ # Specific social auth buttons (Google Red Button)
    │   └── constants/
    │       └── auth_constants.dart ✅ # Auth copy, provider labels, error messages
    │
    ├── session/                # Focus Timer & Session Feature
    │   ├── models/
    │   │   └── focus_session_model.dart ✅ # FocusSessionModel (id, user_id, duration_seconds, status, started_at, ended_at)
    │   ├── repo/
    │   │   └── session_repo.dart ✅   # SessionRepo (syncing active session, pausing, saving to Firestore, local offline caching)
    │   ├── cubit/
    │   │   ├── session_cubit.dart ✅  # Timer logic, app lifecycle observation (resume/pause logic per day)
    │   │   └── session_state.dart ✅  # SessionState (duration, active status, daily limits)
    │   ├── pages/
    │   │   └── home_page.dart ✅      # Main timer screen showing today's focus time
    │   ├── components/
    │   │   ├── timer_display.dart ✅  # Large typography timer display component
    │   │   └── session_status_indicator.dart ✅ # Visual indicator of active vs paused state
    │   └── constants/
    │       └── session_constants.dart ✅ # Status strings (active, paused, completed)
    │
    └── history/                # Session History Feature
        ├── repo/
        │   └── history_repo.dart ✅   # HistoryRepo (fetch completed sessions from Firestore)
        ├── cubit/
        │   ├── history_cubit.dart ✅  # Logic to fetch and paginate history
        │   └── history_state.dart ✅  # HistoryState (list of FocusSessionModel)
        ├── pages/
        │   └── history_page.dart ✅   # Displays list of completed sessions
        ├── components/
        │   ├── history_list_item.dart ✅ # Card displaying past session details
        │   └── empty_history.dart ✅  # Empty state illustration and text
        └── constants/
            └── history_constants.dart ✅ # Strings for history tabnd date formatting constants
```

## Implementation Details

- **Offline & Sync:** The app uses Firebase's built-in offline persistence paired with `local_storage.dart`. The `session_repo.dart` ensures the timer data continues to track and updates Firestore whenever internet connectivity is restored.
- **Background State Handling:** `background_service.dart` and `session_cubit.dart` work together to hook into the `WidgetsBindingObserver` lifecycle to automatically pause the focus session when the app is backgrounded, and resume or reset (if it's a new day) when the app comes back to the foreground.
- **Strict Layering:** As defined in `code_standard.md`, UI pages (in `pages/`) will never contain Firebase queries or local storage logic. They only listen to `Cubits` and emit events to them, preserving a clean separation of concerns.
- **Responsive UI:** Following `ui_standard.md`, all UI components make extensive use of `flutter_screenutil` (using `.w`, `.h`, `.sp`, `.r`) to ensure the modern layout and typography scales beautifully across all devices.
