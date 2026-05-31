# Flutter Firebase Code Standard

This document defines the workflow and coding standard for the app. The project has one application only: a Flutter app with Firebase integrated directly.

## 1. Core Principles

- **Flutter-only app**: All product code lives in the Flutter application.
- **Firebase-first data layer**: Use Firebase services directly from Flutter repositories.
- **Zero-comment policy**: Code must be comment-free and self-documenting.
- **Strict feature layering**: Keep models, repositories, cubits, pages, and components in their proper folders.
- **Type safety**: Maintain strict Dart typing throughout the app.
- **Centralized constants**: Never scatter collection names, storage paths, route paths, status values, user-facing copy, or config keys through feature code.
- **Consistent timestamps**: Use `created_at` and `updated_at` everywhere for stored data models.
- **Initialization-first startup**: App-level services, Firebase, dependency setup, and background services must be initialized before the app starts.

---

## 2. Project Shape

The project should be structured as a Flutter app:

```text
timo/
  context/
    code_standard.md
    ui_standard.md
    flow.md
  lib/
    main.dart
    firebase_options.dart
    core/
      color.dart
      theme.dart
      routes.dart
      di.dart
      config.dart
    constants/
      assets.dart
      firebase.dart
      auth.dart
      session.dart
      notification.dart
    components/
      ui/
      layout/
    services/
      firebase_service.dart
      local_storage.dart
      background_service.dart
      notification_service.dart
    utils/
      error.dart
      try_catch.dart
    features/
      auth/
      session/
      setting/
  android/
  ios/
  pubspec.yaml
  analysis_options.yaml
```

Feature folders must follow this shape:

```text
features/[feature]/
  models/
  repo/
  cubit/
  pages/
  components/
  constants/
```

`components/ui` is only for global reusable primitives such as buttons, inputs, timers, indicators, and common controls. Feature-only widgets must live inside `features/[feature]/components`. Shared services such as Firebase, local storage, background execution, notifications, and device integrations belong in `services`. Cross-feature helpers belong in `utils`. App-wide routing, theme, dependency setup, configuration, and colors belong in `core`.

---

## 3. Application Startup

`main.dart` is responsible for Flutter initialization, Firebase initialization, dependency setup, background service setup, notification setup, and app bootstrapping.

Startup order:

1. Run `WidgetsFlutterBinding.ensureInitialized()`.
2. Initialize Firebase with `Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)`.
3. Initialize local storage if required.
4. Initialize dependency wiring in `core/di.dart`.
5. Initialize background services required for focus sessions.
6. Initialize notification services required for timer/session alerts.
7. Run `runApp(const MyApp())`.

Startup standards:

- Keep `main.dart` small.
- Keep Firebase initialization in startup only.
- Keep Firebase service wrappers in `services`.
- Keep visual configuration in `AppTheme`.
- Keep route configuration in `AppRoutes`.
- Keep dependency wiring in `core/di.dart`.
- Do not put feature logic in `main.dart`.
- If Cubit providers become global, wrap `MaterialApp` with `MultiBlocProvider` from the app root.
- Do not initialize Firebase inside pages, cubits, repositories, or widgets.

Recommended startup shape:

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await setupDependencies();
  await AppDependencies.backgroundService.initialize();
  await AppDependencies.notificationService.initialize();
  runApp(const MyApp());
}
```

---

## 4. Firebase Standard

Firebase is the app data and platform service. Feature repositories talk to Firebase services through injected dependencies.

Allowed Firebase services:

- `FirebaseAuth` for authentication.
- `CloudFirestore` for app data.
- `FirebaseStorage` for uploaded files if the app needs profile images or media.
- `FirebaseMessaging` for push notifications if required.
- `FirebaseAnalytics` for analytics if required.
- `FirebaseCrashlytics` for crash reporting if required.

Firebase standards:

- Initialize Firebase once during app startup.
- Keep Firebase instances centralized in `core/di.dart` or a shared `FirebaseService`.
- Repository classes may depend on Firebase service instances through constructor injection.
- Pages and Cubits must not call Firebase directly.
- Collection names, document paths, field names, and storage folders must live in constants.
- Firestore reads and writes must parse through typed models.
- Firestore timestamps must be converted consistently in models.
- Use batched writes or transactions when multiple writes must succeed together.
- Use Firebase security rules for access control.
- Do not put authorization rules only in Flutter code.
- Do not hardcode Firebase collection names inside pages, Cubits, or widgets.

Firebase constants example:

```dart
class FirebaseConstants {
  static const String usersCollection = 'users';
  static const String sessionsCollection = 'sessions';
  static const String activitiesCollection = 'activities';
  static const String profileImagesPath = 'profile_images';
}
```

---

## 5. Routing Standard

Routes are centralized in `core/routes.dart`.

Pattern:

```dart
class AppRoutes {
  static const String login = '/login';
  static const String home = '/home';
  static const String session = '/session';

  static Map<String, WidgetBuilder> get routes => {
    login: (context) => const LoginPage(),
    home: (context) => const HomePage(),
    session: (context) => const SessionPage(),
  };
}
```

Route standards:

- Every route path is a `static const String`.
- Every registered screen is added to `routes`.
- Route names use kebab-case paths, for example `/edit-profile`.
- Page classes use PascalCase and end with `Page`.
- Use `Navigator.pushNamed`, `Navigator.pushReplacementNamed`, and `Navigator.pop` unless a flow requires typed arguments.
- If a route accepts arguments, validate the type at the page boundary and fail gracefully with a user-safe fallback.
- Do not create anonymous route strings inside pages.

---

## 6. Theme, Color, and UI Tokens

`core/color.dart` owns app colors. `core/theme.dart` owns `ThemeData`.

UI standards:

- Use `AppColors` instead of raw color values.
- Use `Theme.of(context).textTheme` for text whenever the target style already exists.
- Use `GoogleFonts.outfit` only when a local style is genuinely different from the theme.
- Use `flutter_screenutil` on dimensions:
  - Horizontal sizes and widths use `.w`.
  - Vertical sizes and heights use `.h`.
  - Font sizes use `.sp`.
  - Radii use `.r`.
- Follow `context/ui_standard.md` for visual style.
- Do not introduce hardcoded spacing systems that conflict with the existing rhythm.

---

## 7. Constants Standard

Constants are grouped by domain.

Recommended constant groups:

- `FirebaseConstants` owns collection names, storage paths, and common field names.
- `AppAssets` owns image and icon paths.
- `AuthConstants` owns auth provider labels and auth copy.
- `SessionConstants` owns focus session statuses, timer defaults, and session labels.
- `NotificationConstants` owns notification channel names, ids, and payload keys.

Standards:

- Never duplicate route paths, collection names, document paths, storage paths, asset paths, status values, or notification keys in feature code.
- Firebase collection constants live in `constants/firebase.dart`.
- Feature-specific copy, statuses, workflow labels, and defaults live in `features/[feature]/constants/[feature].dart`.
- Constants must stay module-scoped.
- Prefer Dart-style lowerCamelCase constant names.
- Preserve external enum string values exactly when Firebase data already stores them.

---

## 8. Environment and Configuration

Flutter configuration must stay centralized and typed.

Standards:

- Firebase platform configuration lives in `firebase_options.dart`.
- Any `.env` values must be loaded before dependency setup in `main.dart`.
- `.env` files used by Flutter must be registered under `flutter.assets` in `pubspec.yaml`.
- Read environment values through `core/config.dart`.
- Repositories, pages, and Cubits must not read `dotenv` directly.
- Firebase collection names must not come from pages or Cubits.

---

## 9. Models

Models live in `features/[feature]/models`.

Model pattern:

- Immutable class with `final` fields.
- `const` constructor.
- `copyWith`.
- `factory Model.fromJson(Map<String, dynamic> json)`.
- `Map<String, dynamic> toJson()`.
- Optional Firestore helpers when useful, such as `fromFirestore` and `toFirestore`.

Model standards:

- Model classes end with `Model`, for example `UserModel` or `FocusSessionModel`.
- Use immutable `final` fields.
- Use `const` constructors when all fields are final.
- Use `copyWith` for state updates.
- Keep serialization inside the model.
- Parse arrays with explicit typing, for example `map<String>((x) => x.toString()).toList()`.
- Use default fallback values when optional Firebase fields can be missing.
- Avoid putting UI labels, formatting, storage calls, Firebase calls, or Cubit logic inside models.
- Stored data fields should use snake_case names, for example `user_id`, `session_id`, `started_at`, `ended_at`, `created_at`, and `updated_at`.
- Do not expose stored snake_case fields as lowerCamelCase aliases.

Preferred model style:

```dart
class FocusSessionModel {
  final String id;
  final String user_id;
  final int duration_seconds;
  final String status;
  final DateTime started_at;
  final DateTime? ended_at;
  final DateTime created_at;
  final DateTime updated_at;

  const FocusSessionModel({
    required this.id,
    required this.user_id,
    required this.duration_seconds,
    required this.status,
    required this.started_at,
    required this.ended_at,
    required this.created_at,
    required this.updated_at,
  });

  factory FocusSessionModel.fromJson(Map<String, dynamic> json) {
    return FocusSessionModel(
      id: json['id'] ?? '',
      user_id: json['user_id'] ?? '',
      duration_seconds: json['duration_seconds'] ?? 0,
      status: json['status'] ?? '',
      started_at: _readDate(json['started_at']),
      ended_at: json['ended_at'] == null ? null : _readDate(json['ended_at']),
      created_at: _readDate(json['created_at']),
      updated_at: _readDate(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': user_id,
      'duration_seconds': duration_seconds,
      'status': status,
      'started_at': started_at,
      'ended_at': ended_at,
      'created_at': created_at,
      'updated_at': updated_at,
    };
  }
}
```

Firestore timestamp parsing must be handled consistently through shared helpers or model-local parsing.

---

## 10. Local Storage

`services/local_storage.dart` wraps device-local persistence.

Storage standards:

- Sensitive values use secure local storage.
- Non-sensitive app preferences may use shared preferences.
- Storage keys are private static constants.
- Repositories or session services may use storage.
- UI pages must not read local storage directly.
- If adding active session, user, timer, or notification context, add explicit typed methods.
- Do not scatter raw storage keys across the codebase.

---

## 11. Error and Result Handling

`utils/error.dart` defines app-level failures, exceptions, and operation status.

Recommended failure classes:

- `FirebaseFailure`
- `CacheFailure`
- `NetworkFailure`
- `AuthFailure`
- `ValidationFailure`
- `PermissionFailure`

Recommended exception classes:

- `FirebaseAppException`
- `CacheException`
- `NetworkException`
- `AuthException`
- `ValidationException`
- `PermissionException`

`utils/try_catch.dart` defines:

```dart
typedef TaskResult<T> = Future<Either<Failure, T>>;
typedef SyncResult<T> = Either<Failure, T>;
```

Standards:

- Repository methods return `TaskResult<T>` for async work.
- Repository methods wrap work with `tryCatchAsync`.
- Synchronous risky parsing helpers can use `tryCatchSync`.
- Cubits consume `Either` with `fold`.
- Pages render state based on `OperationStatus`.
- Map `FirebaseAuthException` to `AuthFailure`.
- Map `FirebaseException` to `FirebaseFailure`.
- Map permission-related failures to `PermissionFailure` when the UI needs distinct handling.
- Do not throw raw strings.
- Do not return nullable data and a separate error value when `TaskResult<T>` fits.
- Add new failure types only when the UI or flow needs different behavior.

---

## 12. Repository Layer

Repositories live in `features/[feature]/repo`.

Repository pattern:

```dart
class SessionRepo {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final LocalStorage _localStorage;

  SessionRepo({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
    required LocalStorage localStorage,
  })  : _firestore = firestore,
        _auth = auth,
        _localStorage = localStorage;

  TaskResult<FocusSessionModel> createSession() async {
    return tryCatchAsync(() async {
      final user = _auth.currentUser;
      if (user == null) {
        throw const AuthException('User is not signed in');
      }

      final doc = _firestore
          .collection(FirebaseConstants.sessionsCollection)
          .doc();

      final now = DateTime.now().toUtc();
      final session = FocusSessionModel(
        id: doc.id,
        user_id: user.uid,
        duration_seconds: 0,
        status: SessionConstants.activeStatus,
        started_at: now,
        ended_at: null,
        created_at: now,
        updated_at: now,
      );

      await doc.set(session.toJson());
      await _localStorage.saveActiveSessionId(session.id);
      return session;
    });
  }
}
```

Repository standards:

- Constructor dependencies are required and injected.
- Keep dependencies private and final.
- Use Firebase constants for collection names and storage paths.
- Build Firebase payloads in the repo or in typed request/input models.
- Parse Firebase documents into models in the repo.
- Save or clear local data in the repo only when it is part of the operation contract.
- Return domain models, lists, streams, or `void` wrapped in `TaskResult` where appropriate.
- Use `Stream<T>` only when the UI genuinely needs live updates.
- Do not import Flutter widgets into repositories.
- Do not navigate from repositories.
- Do not emit Cubit state from repositories.
- Do not call Firebase from pages or Cubits.

Use these method names:

- `getCurrentUser`, `getById`, `getList`, `create`, `update`, `delete` for CRUD.
- `signInWithGoogle`, `signInAnonymously`, `logout`, `refreshSession` for auth/session actions.
- `startSession`, `pauseSession`, `resumeSession`, `completeSession`, `syncActiveSession` for focus timer actions.
- `markAsRead`, `accept`, `reject`, `assign`, `complete` for workflow actions.

---

## 13. Cubit and State Layer

Cubits live in `features/[feature]/cubit`.

Cubit standards:

- Cubit class ends with `Cubit`.
- State class ends with `State`.
- Cubits own feature interaction logic.
- Cubits do not perform direct Firebase calls.
- Cubits do not parse JSON or Firestore documents.
- Cubits do not use `BuildContext`.
- Cubits do not navigate.
- Cubits emit loading before async operations when the UI needs progress.
- Cubits store one `OperationInfo` per independent operation, such as `loginInfo`, `loadInfo`, `saveInfo`, or `deleteInfo`.
- Success updates the relevant data and operation status.
- Failure updates only the relevant operation status and error.

Standard Cubit method flow:

```dart
Future<void> startSession() async {
  emit(
    state.copyWith(
      startInfo: const OperationInfo(status: OperationStatus.loading),
    ),
  );

  final result = await _sessionRepo.startSession();

  result.fold(
    (failure) => emit(
      state.copyWith(
        startInfo: OperationInfo(
          status: OperationStatus.error,
          error: failure,
        ),
      ),
    ),
    (session) => emit(
      state.copyWith(
        activeSession: session,
        startInfo: const OperationInfo(status: OperationStatus.success),
      ),
    ),
  );
}
```

State standards:

- State classes are immutable.
- Use `const` constructors.
- Keep entity data separate from operation metadata.
- Implement `copyWith`.
- If equality is manual, update `operator ==` and `hashCode` whenever fields change.
- For nullable fields that need to be explicitly cleared, add a clear flag or a dedicated reset method.

---

## 14. Page and Widget Layer

Pages live in `features/[feature]/pages`.

Page standards:

- Page classes end with `Page`.
- Use `StatelessWidget` by default.
- Use `StatefulWidget` only for local controllers, focus nodes, animations, tab controllers, timers, or lifecycle-sensitive UI state.
- Dispose every `TextEditingController`, `FocusNode`, `AnimationController`, `ScrollController`, and timer controller created by a page.
- Use Cubit for feature state and business logic.
- Use local private widget methods for repeated layout blocks inside a single page.
- Promote repeated blocks used by multiple pages into `features/[feature]/components` or `components/ui`.
- Keep build methods readable by extracting sections when a screen grows.
- Do not call repositories from pages except for route-level provider construction.
- Do not parse Firebase documents in pages.
- Do not store auth, user, or session context in pages.

Responsive layout standards:

- Wrap full-screen scrolling layouts in `SafeArea`.
- Use `LayoutBuilder` plus `ConstrainedBox(minHeight: constraints.maxHeight)` when a vertically centered screen also needs to scroll on small devices.
- Use `SingleChildScrollView` for forms and content that can overflow.
- Use `Spacer` only inside bounded columns.
- Use `SizedBox(height: value.h)` and `SizedBox(width: value.w)` for spacing.
- Keep horizontal page padding at `24.w` unless the design standard says otherwise.
- Avoid fixed pixel dimensions without ScreenUtil.

Navigation standards:

- Use route constants from `AppRoutes`.
- Use `pushReplacementNamed` for one-way onboarding transitions.
- Use `pop` for app-bar back behavior.
- Do not navigate from Cubits or repositories.

---

## 15. Shared UI Components

Global components belong in `components/ui`.

Component standards:

- Global components must be generic and reusable.
- Feature-specific components must not be placed in `components/ui`.
- Components should receive values and callbacks through constructors.
- Components should not read repositories or services.
- Components may use `Theme.of(context)`, `AppColors`, and ScreenUtil.
- Keep text overflow safe in buttons, tiles, cards, timers, and app bars.

---

## 16. Dependency Injection

`core/di.dart` is the standard location for shared dependency creation.

DI standards:

- Create shared Firebase service instances in `core/di.dart`.
- Keep constructor injection for repositories and cubits.
- Pages should receive Cubits through `BlocProvider` or route-level providers.
- Avoid creating Firebase service instances in multiple widgets.
- Avoid hidden global mutable state.
- New repositories, Cubits, and shared services must be registered in `setupDependencies`.
- Use `registerLazySingleton` for shared services such as `FirebaseFirestore`, `FirebaseAuth`, `FirebaseStorage`, `LocalStorage`, `BackgroundService`, and `NotificationService`.
- Use `registerFactory` for repositories and Cubits unless a feature has a clear need for a long-lived instance.
- Keep app root providers in `main.dart` limited to Cubits that are needed across startup, auth, routing, or multiple feature flows.

Recommended direction:

```dart
class AppDependencies {
  static FirebaseAuth get firebaseAuth => serviceLocator<FirebaseAuth>();
  static FirebaseFirestore get firestore => serviceLocator<FirebaseFirestore>();
  static LocalStorage get localStorage => serviceLocator<LocalStorage>();
  static BackgroundService get backgroundService => serviceLocator<BackgroundService>();
  static NotificationService get notificationService => serviceLocator<NotificationService>();

  static SessionRepo sessionRepo() {
    return SessionRepo(
      firestore: firestore,
      auth: firebaseAuth,
      localStorage: localStorage,
    );
  }
}
```

Use a DI package only if the app complexity justifies it.

---

## 17. Feature Development Workflow

For a new Flutter feature, implement in this order:

1. Add feature folder under `features/[feature]`.
2. Add constants in `constants/[feature].dart` when the feature has copy, statuses, defaults, or Firebase keys.
3. Add models in `models`.
4. Add repository in `repo/[feature]_repo.dart`.
5. Add state in `cubit/[feature]_state.dart`.
6. Add Cubit in `cubit/[feature]_cubit.dart`.
7. Add feature components in `components` when needed.
8. Add pages in `pages`.
9. Register routes in `core/routes.dart`.
10. Wire dependencies in `core/di.dart` or route-level `BlocProvider`.
11. Verify Firebase rules and indexes if the feature introduces new collections or queries.
12. Verify UI against `context/ui_standard.md`.
13. Run analysis and tests.

---

## 18. Different Coding Situations

### Read-only screen

Use a page plus Cubit. The Cubit loads data through a repository. State contains the loaded entity or list plus a load operation.

Do:

- Use `loadInfo`.
- Store typed models or typed model lists.
- Show loading, success, empty, and error UI states.

Do not:

- Fetch from inside `build`.
- Call Firebase from the page.
- Store raw Firebase snapshots in state.

### Form screen

Use `StatefulWidget` only when controllers or focus nodes are needed. Keep validation local if it is purely UI-level. Submit through Cubit.

Do:

- Create controllers in `State`.
- Dispose controllers.
- Convert controller values into a typed input or payload.
- Disable submit while the save operation is loading.

Do not:

- Save directly from the page to Firebase.
- Navigate before the Cubit reports success.
- Keep long business rules inside validators.

### Auth/session operation

Use `AuthRepo`, `FirebaseAuth`, `LocalStorage`, and `AuthCubit`.

Do:

- Authenticate with Firebase Auth in the repository.
- Save only the local session context needed for startup recovery.
- Clear local session context on logout.
- Emit a clean auth state after logout.

Do not:

- Store tokens in plain variables.
- Read auth context directly inside widgets.
- Parse Firebase auth responses in pages.

### Returning authenticated user

Use a startup session gate page as the initial route.

Do:

- Read `FirebaseAuth.currentUser` through the auth repository.
- Load the user profile document from Firestore when a Firebase user exists.
- Restore an active focus session from local storage and Firestore when available.
- Redirect signed-in users directly to the main timer/session experience.
- Redirect users without a valid Firebase session to login or onboarding.

Do not:

- Open the login page first when a valid Firebase user can be restored.
- Trust cached session context without checking the current Firebase user.
- Navigate from repositories or Cubits.

### Focus timer/session

Use the session feature end to end.

Do:

- Create a Firestore session document when a focus session starts.
- Store active session id locally for recovery.
- Use background services for session tracking when the app is not foregrounded.
- Sync session duration and status through the repository.
- Use notification services for active timer notifications and completion alerts.
- Keep timer status strings in session constants.

Do not:

- Let pages write session documents directly.
- Hardcode status strings in widgets.
- Rely only on in-memory timer state for active sessions.

### List screen

Use a list model in state and one operation for loading. Add separate operations for item-level actions when needed.

Do:

- Keep immutable list replacement in state.
- Use typed model lists.
- Show empty state when the list is empty after success.

Do not:

- Mutate the existing state list in place.
- Use `dynamic` lists in UI.
- Store `QuerySnapshot` or `DocumentSnapshot` directly in UI state.

### Settings or menu screen

Settings pages may use private builder methods for section headers and setting tiles.

Do:

- Use private methods such as `_buildSectionHeader`.
- Use route constants.
- Use `Switch`, `ListTile`, icons, and theme colors consistently.

Do not:

- Put route strings in tile callbacks.
- Duplicate the same tile design across multiple settings pages.

### Local-only UI component

Keep it in the page as a private method if it is used once. Move it to `features/[feature]/components` if another page needs it.

### Shared UI primitive

Place it in `components/ui` only when it is app-wide, theme-aligned, and not tied to a specific feature domain.

---

## 19. Naming Standard

Files:

- `snake_case.dart`
- `[feature]_repo.dart`
- `[feature]_cubit.dart`
- `[feature]_state.dart`
- `[name]_page.dart`
- `[name]_model.dart`

Classes:

- `PascalCase`
- `AuthRepo`
- `AuthCubit`
- `AuthState`
- `UserModel`
- `FocusSessionModel`
- `LoginPage`
- `AppButton`

Methods and variables:

- `lowerCamelCase`
- Stored data parity fields inside models use snake_case and are the only exception to lowerCamelCase variable naming.
- Private fields and helpers start with `_`.
- Async methods return `Future` or `TaskResult`.
- Boolean names should read naturally, for example `isLoading`, `isAvailable`, `hasSession`, and `canEdit`.

Constants:

- New Dart constants should prefer lowerCamelCase.
- Preserve external stored string values exactly when existing Firebase data requires them.

---

## 20. Import Standard

Use package imports for app files:

```dart
import 'package:timo/core/color.dart';
import 'package:timo/features/session/models/focus_session_model.dart';
```

Standards:

- Flutter and Dart imports first.
- Third-party package imports next.
- App package imports last.
- Avoid relative imports between feature folders.
- Do not import page files into repositories, models, services, or utils.
- Do not create circular imports between Cubit and page files.

---

## 21. Comment Policy

The repository execution rules require comment-free code.

Standards:

- Do not add code comments.
- Use clear names and small methods instead of comments.
- Do not add `ignore_for_file` comments in new code unless there is no clean code alternative.
- If a lint must be suppressed, prefer changing the code so the suppression is unnecessary.
- Markdown documentation can explain architecture and standards.

---

## 22. Current Codebase Direction To Preserve

Preserve these patterns:

- Feature-based organization under `features`.
- Shared primitives under `components/ui`.
- Central route constants in `AppRoutes`.
- Central color tokens in `AppColors`.
- Central theme in `AppTheme`.
- ScreenUtil for all visual sizing.
- Repository methods returning `TaskResult<T>`.
- Cubits using `OperationInfo` and `OperationStatus`.
- Models using `fromJson`, `toJson`, and `copyWith`.
- Firebase initialized once before `runApp`.
- Firebase access contained in repositories and services.

Improve these areas when touching related code:

- Remove remote-service assumptions.
- Move dependency construction into `core/di.dart`.
- Prefer exact snake_case stored field names in models.
- Avoid new analyzer ignore comments.
- Replace hardcoded page copy with constants when reused or business-critical.
- Register every route referenced by pages.
- Keep timer/session recovery reliable across app restarts and background execution.

---

## 23. Verification

Before finishing Flutter work:

1. Run `flutter analyze`.
2. Run targeted Flutter tests when tests exist.
3. Manually check route registration for any page that was added or renamed.
4. Confirm Firebase is initialized only in app startup.
5. Confirm repositories use injected Firebase services.
6. Confirm no page or Cubit calls Firebase directly.
7. Confirm no remote-service constants or remote-service routing assumptions were introduced.
8. Confirm every controller, focus node, timer, or stream subscription is disposed.
9. Confirm dimensions use ScreenUtil.
10. Confirm UI follows `context/ui_standard.md`.
11. Confirm new code is comment-free.
