# Folder Structure - Notebook App

**Project Root:** `notebook_app/`

---

## Clean Architecture Structure

```
notebook_app/
├── lib/
│   ├── main.dart                    # App entry point
│   ├── core/                      # Core utilities & configs
│   │   ├── config/
│   │   │   └── app_config.dart
│   │   ├── constants/
│   │   │   └── app_constants.dart
│   │   ├── theme/
│   │   │   ├── app_colors.dart
│   │   │   ├── app_text_styles.dart
│   │   │   └── app_theme.dart
│   │   └── utils/
│   │       ├── date_utils.dart
│   │       └── validators.dart
│   ├── data/                      # Data layer
│   │   ├── datasources/
│   │   │   └── local/
│   │   │       └── isar_datasource.dart
│   │   ├── models/
│   │   │   ├── note_model.dart
│   │   │   └── folder_model.dart
│   │   └── repositories/
│   │       ├── note_repository_impl.dart
│   │       └── folder_repository_impl.dart
│   ├── domain/                    # Domain layer
│   │   ├── entities/
│   │   │   ├── note.dart
│   │   │   └── folder.dart
│   │   ├── repositories/
│   │   │   ├── note_repository.dart
│   │   │   └── folder_repository.dart
│   │   └── usecases/
│   │       ├── note/
│   │       │   ├── get_note_list_usecase.dart
│   │       │   ├── get_note_by_id_usecase.dart
│   │       │   ├── create_note_usecase.dart
│   │       │   ├── update_note_usecase.dart
│   │       │   ├── delete_note_usecase.dart
│   │       │   ├── toggle_pin_note_usecase.dart
│   │       │   └── search_notes_usecase.dart
│   │       └── folder/
│   │           ├── get_folders_usecase.dart
│   │           └── create_folder_usecase.dart
│   ├── presentation/               # Presentation layer
│   │   ├── providers/
│   │   │   ├── note_provider.dart
│   │   │   ├── folder_provider.dart
│   │   │   └── app_provider.dart
│   │   ├── screens/
│   │   │   ├── home/
│   │   │   │   ├── home_screen.dart
│   │   │   │   └── widgets/
│   │   │   │       ├── note_card.dart
│   │   │   │       └── empty_state.dart
│   │   │   ├── note_detail/
│   │   │   │   ├── note_detail_screen.dart
│   │   │   │   └── widgets/
│   │   │   │       ├── note_editor.dart
│   │   │   │       └── toolbar.dart
│   │   │   ├── folders/
│   │   │   │   └── folders_screen.dart
│   │   │   ├── search/
│   │   │   │   └── search_screen.dart
│   │   │   └── settings/
│   │   │       └── settings_screen.dart
│   │   ├── widgets/
│   │   │   ├── app_button.dart
│   │   │   ├── app_text_field.dart
│   │   │   ├── folder_card.dart
│   │   │   └── loading_indicator.dart
│   │   └── router/
│   │       └── app_router.dart
│   └── services/
│       ├── di/
│       │   └── service_locator.dart
│       └── storage/
│           └── isar_service.dart
├── test/
│   ├── unit/
│   │   ├── domain/
│   │   │   └── usecases/
│   │   └── presentation/
│   │       └── providers/
│   ├── widget/
│   │   └── screens/
│   └── integration/
│       └── app_test.dart
├── pubspec.yaml
├── analysis_options.yaml
├── README.md
└── Create Docs/                 # Documentation (as requested)
    ├── 01-brd/
    │   └── BRD.md
    ├── 02-system-design/
    │   └── System-Design.md
    ├── 03-architecture/
    │   └── Folder-Structure.md
    ├── 04-implementation-plan/
    │   └── Implementation-Plan.md
    └── 05-mockups/
        └── wireframes.md
```

---

## Layer Responsibilities Summary

| Layer | Purpose | Contains |
|--------|----------|----------|
| **core** | Shared utilities | Config, theme, utils |
| **data** | Data access | DB entities, repositories, datasources |
| **domain** | Business logic | Entities, use cases, repository interfaces |
| **presentation** | UI & State | Screens, widgets, providers, routing |
| **services** | DI & Services | GetIt setup, database initialization |

---

## File Naming Conventions

- **Files:** `snake_case.dart`
- **Classes:** `PascalCase`
- **Variables:** `camelCase`
- **Constants:** `camelCase` or `SCREAMING_SNAKE_CASE`
- **Private:** `_leadingUnderscore`

---

## Import Guidelines

```dart
// Dart core first
import 'dart:async';

// Flutter SDK
import 'package:flutter/material.dart';

// External packages
import 'package:provider/provider.dart';

// Internal - same layer
import '../../widgets/app_button.dart';

// Internal - other layers (absolute from lib/)
import 'package:notebook_app/domain/entities/note.dart';
```

---

## Code Generation Files

Generated files in same directory with suffixes:
- `.freezed.dart` (Freezed models)
- `.g.dart` (Isar entities, GetIt registration)
- `.mocks.dart` (Mockito mocks)

**Note:** These are gitignored and regenerated.

---

**Status:** Structure Defined
**Next:** Begin Project Initialization (Phase 1)
