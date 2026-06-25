# 🧠 trivia_pulse

A modern, high-performance, and visually stunning Flutter trivia game powered by the **[Open Trivia Database (OpenTDB)](https://opentdb.com)** and integrated with **Firebase** for cloud features.

Built using a robust **MVVM architecture**, **Provider** for state management, **GoRouter** for declarative navigation, and a customized **Material 3 Design System** with native light/dark mode support.

> [!TIP]
> **📲 Try the App**: You can download and install the latest compiled Android APK directly from the [GitHub Releases](https://github.com/minhazul73/trivia_pulse/releases) page!

---

## ✨ Features

- **🔐 Robust Authentication**:
  - Email/Password registration & login.
  - One-tap Google Sign-In integration.
  - Reactive session tracking and automatic redirection guards.
  
- **🎯 Dynamic Quiz Customization**:
  - Live category fetching from OpenTDB.
  - Custom selector for question counts, difficulty levels (Easy, Medium, Hard), and question types (Multiple Choice, True/False).

- **⚡ Rich Trivia Experience**:
  - Real-time question progress and scoring system.
  - Fluid micro-animations and custom transitions.
  - Interactive result screens detailing accuracy, correct/incorrect/skipped question counts, and total points.

- **🏆 Real-time Leaderboard**:
  - Global leaderboard synced directly with Cloud Firestore.
  - Live ranking lists showing top-performing players.

- **👤 Profile & History Tracking**:
  - Secure offline caching of results using high-performance NoSQL database **Hive CE**.
  - Local score summaries, accuracy graphs, and history logs of all played games.

- **🎨 Premium Material 3 Design System**:
  - Custom tokens for spacing, borders, shadows, durations, and curves.
  - Full support for light and dark modes following system brightness.
  - Responsive screen scaling via `flutter_screenutil`.
  - Elegant shimmers and loading skeletons powered by `skeletonizer`.

---

## 🏗️ Architecture

The project strictly follows the **MVVM (Model-View-ViewModel)** architectural pattern to ensure separation of concerns, scalability, and ease of testing.

```text
lib/src/
├── core/
│   ├── config/       # App initialization, Dio and client setup
│   ├── extensions/   # BuildContext context extensions for theme, layout, etc.
│   ├── imports/      # Unified export barrels for cleaner imports
│   ├── routing/      # GoRouter configuration, central routes list, and navigation helpers
│   ├── services/     # Core services (Auth, Firestore, Hive, DeviceInfo, Share, Permission, etc.)
│   ├── shared/       # Global assets, enums, reusable widgets, and wrappers
│   └── theme/        # Color schemes, text themes, and structural layout tokens
├── data/
│   ├── models/       # Data models and entities (UserModel, QuestionModel, ResultModel, etc.)
│   └── repositories/ # Data access abstraction interfaces and concrete implementations
└── ui/
    ├── auth/         # Login, signup, forgot password screens and auth state providers
    ├── bottom_nav/   # App scaffold with bottom navigation switcher
    ├── home/         # Home screen with trivia category selectors
    ├── leaderboard/  # Real-time ranking and scoreboard tabs
    ├── profile/      # User profile page showing stats and local history
    ├── quiz/         # Quiz customization, active quiz gameplay, and quiz result pages
    └── splash/       # Animated app launching and initialization gate screen
```

### Key Architectural Guidelines
- **UI & Presentation**: Binds directly to ViewModels or Providers. No business logic lives in widget `build()` methods.
- **Data & Business Logic**: Interacts exclusively through repositories (`lib/src/data/repositories/`) and decoupled background services (`lib/src/core/services/`).
- **Routing**: `GoRouter` configuration in `app_router.dart` is the single source of truth for routing, incorporating session-based auth guards.

---

## 🛠️ Tech Stack & Key Libraries

- **Navigation**: `go_router` (Declarative path-based routing)
- **State Management**: `provider` (Scoped ChangeNotifiers)
- **Networking**: `dio` (With built-in logging interceptors)
- **Local Storage**: `hive_ce` (NoSQL database), `flutter_secure_storage`, and `shared_preferences`
- **Backend / DB**: `firebase_core`, `firebase_auth`, `cloud_firestore`, `google_sign_in`
- **Animations**: `flutter_animate` (Chained transitions), `smooth_page_indicator`
- **Responsiveness**: `flutter_screenutil` (Design baseline: 390x844 iPhone 14)
- **UI Enhancements**: `skeletonizer` (Skeleton loading), `cached_network_image`, `flutter_svg`
- **Logging**: `logger` (Structured console outputs)

---

## 🔌 API Endpoints Used

The app fetches all trivia data from the **[Open Trivia Database (OpenTDB)](https://opentdb.com)** API using the following endpoints:

- **Fetch Categories** (`GET /api_category.php`): Retrieves the list of available trivia categories with their names and IDs.
- **Fetch Category Question Count** (`GET /api_count.php`): Fetches the count details of questions for a specific category (query parameter: `?category={id}`).
- **Fetch Questions** (`GET /api.php`): Retrieves the actual list of trivia questions matching user preferences:
  - `amount`: Number of questions to retrieve.
  - `category`: Category ID.
  - `difficulty` (optional): `easy` | `medium` | `hard`.
  - `type` (optional): `multiple` (Multiple Choice) | `boolean` (True/False).

---

## 🚀 Getting Started

### 📋 Prerequisites

Ensure you have the following installed on your local machine:
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (compatible with environment SDK version `>=3.10.0 <4.0.0`)
- [Firebase CLI](https://firebase.google.com/docs/cli) (required for setting up cloud database options)

### 📥 Setup Instructions

1. **Clone the repository and install dependencies**:
   ```bash
   flutter pub get
   ```

2. **Generate necessary code files**:
   This project relies on code generation (Hive adapters, Firebase configs, serialization, etc.). Run:
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

3. **Configure Environment Variables**:
   Create a `.env` file in the root folder of the project. Include the following keys:
   ```env
   API_BASE_URL=https://opentdb.com
   CLIENT_ID=your_google_client_id_for_ios
   SERVER_CLIENT_ID=your_google_server_client_id_for_web_android
   ```

4. **Initialize Firebase (Native Setup)**:
   Authenticate with the Firebase CLI and run the configuration script:
   ```bash
   flutterfire configure
   ```
   This will auto-generate `lib/firebase_options.dart` containing target project credentials.

5. **Permissions & Platform Configurations**:
   - **Android**: Ensure Internet permissions are enabled in `android/app/src/main/AndroidManifest.xml`.

6. **Run the App**:
   - **Launch the application**:
     ```bash
     flutter run
     ```
