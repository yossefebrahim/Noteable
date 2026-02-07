# System Design - Notebook App (Flutter + MVVM)

**Version:** 1.0
**Date:** 2026-02-07

---

## 1. Architecture Overview

### 1.1 High-Level Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    Presentation Layer                │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐ │
│  │  Views   │←→│ ViewModels│←→│  Models  │ │
│  └──────────┘  └──────────┘  └──────────┘ │
└─────────────────────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────────────────────┐
│                  Domain Layer                     │
│  ┌──────────────┐  ┌──────────────┐          │
│  │ Repositories │←→│   Use Cases  │          │
│  └──────────────┘  └──────────────┘          │
└─────────────────────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────────────────────┐
│                  Data Layer                       │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐ │
│  │  Local   │  │  API     │  │  Cache   │ │
│  │   DB     │  │ (future) │  │          │ │
│  └──────────┘  └──────────┘  └──────────┘ │
└─────────────────────────────────────────────────────────┘
```

---

## 2. Layer Responsibilities

### 2.1 Presentation Layer
- **Views:** Flutter widgets (screens, components)
- **ViewModels:** Business logic, state management
- **Navigation:** GoRouter configuration

### 2.2 Domain Layer
- **Repositories:** Abstract data access contracts
- **Use Cases:** Single responsibility business logic
- **Entities:** Core domain models

### 2.3 Data Layer
- **Local DB:** Isar/SQLite implementation
- **Data Sources:** Concrete repository implementations
- **Mappers:** Convert between entities and DTOs

---

## 3. MVVM Pattern Implementation

### 3.1 Model
```dart
class Note {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isPinned;
  final String? folderId;
}
```

### 3.2 ViewModel
```dart
class NoteViewModel extends ChangeNotifier {
  final GetNoteListUseCase _getNotes;
  final CreateNoteUseCase _createNote;
  // ... state variables
}
```

### 3.3 View
```dart
class NoteListView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<NoteViewModel>(
      builder: (context, viewModel, child) { ... }
    );
  }
}
```

---

## 4. State Management Strategy

### 4.1 Provider Setup
```dart
void main() {
  setupDependencies();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NoteViewModel()),
        // ... other providers
      ],
      child: MyApp(),
    ),
  );
}
```

### 4.2 Provider Selection Rationale
- **Simplicity:** Easy to implement and maintain for this scope
- **Performance:** Efficient rebuilds with `Consumer` and `Selector`
- **Community:** Widely adopted, well-documented
- **Learning Curve:** Low barrier for onboarding

---

## 5. Data Flow

### 5.1 Note Creation Flow
```
User Input → View → ViewModel → Use Case → Repository → DB
                    ↓
                  State Update → View Rebuild
```

### 5.2 Note Loading Flow
```
View Init → ViewModel → Use Case → Repository → DB
                ↓
              State Update → View Rebuild
```

---

## 6. Database Design

### 6.1 Note Entity (Isar)
```dart
@Collection()
class NoteEntity {
  @Id()
  int id;

  late String title;
  late String content;

  @Index()
  late DateTime createdAt;

  DateTime? updatedAt;

  bool isPinned = false;

  String? folderId;
}
```

### 6.2 Folder Entity
```dart
@Collection()
class FolderEntity {
  @Id()
  int id;

  late String name;
  late DateTime createdAt;

  @Index()
  String colorHex;
}
```

---

## 7. Navigation Structure

```
MyApp
├── HomeScreen (Note list)
│   ├── NoteDetailScreen (Create/Edit)
│   ├── FolderScreen (Folder list)
│   └── SearchScreen
└── SettingsScreen (Themes, Preferences)
```

### 7.1 Routes Definition
```dart
final router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (_, __) => HomeScreen()),
    GoRoute(path: '/note/:id', builder: (_, state) => NoteDetailScreen()),
    GoRoute(path: '/folders', builder: (_, __) => FolderScreen()),
  ],
);
```

---

## 8. Design System (Untitled UI-Inspired)

### 8.1 Colors
```dart
class AppColors {
  static const background = Color(0xFFFFFFFF);
  static const surface = Color(0xFFF5F5F7);
  static const text = Color(0xFF1A1A1A);
  static const textSecondary = Color(0xFF6B6B6B);
  static const accent = Color(0xFF007AFF);
  static const border = Color(0xFFE5E5E5);
}
```

### 8.2 Typography
```dart
class AppTextStyles {
  static const heading = TextStyle(fontSize: 24, fontWeight: FontWeight.w600);
  static const body = TextStyle(fontSize: 16, fontWeight: FontWeight.w400);
  static const caption = TextStyle(fontSize: 14, color: AppColors.textSecondary);
}
```

### 8.3 Components
- **Card:** Elevated surface with subtle shadow
- **Button:** Minimal, outlined or filled accent
- **Input:** No borders, underline on focus
- **ListItem:** 16px padding, 8px vertical spacing

---

## 9. Dependency Injection

### 9.1 GetIt Setup
```dart
final getIt = GetIt.instance;

void setupDependencies() {
  // Data Layer
  getIt.registerSingleton<NoteRepository>(
    NoteRepositoryImpl(getIt<Isar>()),
  );

  // Domain Layer
  getIt.registerFactory<GetNoteListUseCase>(
    () => GetNoteListUseCase(getIt<NoteRepository>()),
  );

  // Presentation Layer
  getIt.registerFactory<NoteViewModel>(
    () => NoteViewModel(
      getIt<GetNoteListUseCase>(),
      getIt<CreateNoteUseCase>(),
    ),
  );
}
```

---

## 10. Testing Strategy

### 10.1 Unit Tests
- ViewModels: Business logic validation
- Use Cases: Input/output verification
- Repositories: Mock database interactions

### 10.2 Widget Tests
- View rendering
- User interaction flows
- State changes

### 10.3 Integration Tests
- Full user journeys
- Database operations

---

## 11. Performance Optimizations

### 11.1 List Rendering
- Use `ListView.builder` for large lists
- Implement item recycling

### 11.2 Database
- Index frequently queried fields (title, createdAt)
- Lazy loading for large content

### 11.3 State
- Minimize rebuilds with `Selector`
- Dispose unused controllers

---

## 12. Security & Privacy

### 12.1 Data Protection
- All data stored locally
- No external API calls in MVP
- Optional: Biometric lock (future)

### 12.2 Error Handling
- Graceful degradation
- User-friendly error messages
- Crash reporting integration (Sentry)

---

## 13. Deployment Strategy

### 13.1 iOS
- TestFlight for beta
- App Store for production

### 13.2 Android
- Internal test track
- Play Store production

### 13.3 CI/CD
- GitHub Actions for automated builds
- Automated testing on push

---

**Status:** Ready for Implementation Phase
**Next:** Detailed Implementation Plan
