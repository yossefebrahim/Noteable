# Fix Tracker — Widget Rebuild Cycle / Provider Integration

## Date
2026-02-07

## Scope
Stabilize Provider wiring and reduce unnecessary widget rebuilds causing framework rebuild/mount noise on iOS simulator.

## Root Cause
1. **Provider graph mismatch in `main.dart`**
   - App was registering legacy view models (`NoteListViewModel`, `NoteDetailViewModel`, etc.)
   - UI screens were consuming `NotesViewModel` (new architecture) in multiple routes.
   - This mismatch caused unstable dependency resolution and repeated provider element mounting behavior.

2. **DI setup not initialized at app startup**
   - `setupServiceLocator()` was defined but not executed before `runApp`.
   - Some providers expected DI-created dependencies, but app boot used direct constructors.

3. **Over-broad rebuild subscriptions**
   - Top-level `Consumer` and detail-screen full `watch` patterns rebuilt large trees frequently.

## Fixes Applied
- Bootstrapped DI at startup in `main.dart` (`WidgetsFlutterBinding.ensureInitialized` + `setupServiceLocator`).
- Switched app provider registration to centralized `AppProviders.providers` (single source of truth).
- Replaced top-level `Consumer<AppProvider>` with `Selector<AppProvider, ThemeMode>`.
- Updated router note-detail route to provide a **route-scoped** `NoteEditorViewModel` via `ChangeNotifierProvider`.
- Migrated `NoteDetailScreen` to consume `NoteEditorViewModel` and use `context.select` for granular rebuilds.
- Extended `NoteEditorViewModel` with:
  - `isSaving` state
  - `updateDraft({title, content, isPinned})` for pin toggle + partial updates
  - save lifecycle notifications around `saveNow()`

## Verification
- `flutter analyze lib` ✅ no issues.
- `flutter run -d iPhone 17 --debug` ✅ app launches and runs; no repeating framework rebuild loop logs observed in session output.
