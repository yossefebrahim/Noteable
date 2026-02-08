import 'package:get_it/get_it.dart';
import 'package:noteable_app/data/repositories/in_memory_notes_feature_repository.dart';
import 'package:noteable_app/data/repositories/note_repository_impl.dart';
import 'package:noteable_app/data/services/export_service.dart';
import 'package:noteable_app/domain/repositories/note_repository.dart';
import 'package:noteable_app/domain/repositories/notes_feature_repository.dart';
import 'package:noteable_app/domain/usecases/feature_usecases.dart';
import 'package:noteable_app/domain/usecases/export/export_note_usecase.dart';
import 'package:noteable_app/domain/usecases/export/export_folder_usecase.dart';
import 'package:noteable_app/domain/usecases/export/export_all_notes_usecase.dart';
import 'package:noteable_app/domain/usecases/export/share_note_usecase.dart';
import 'package:noteable_app/presentation/providers/app_provider.dart';
import 'package:noteable_app/presentation/providers/note_detail_view_model.dart';
import 'package:noteable_app/presentation/providers/notes_view_model.dart';

final GetIt sl = GetIt.instance;

Future<void> setupServiceLocator() async {
  sl.registerLazySingleton<AppProvider>(AppProvider.new);
  sl.registerLazySingleton<NotesFeatureRepository>(InMemoryNotesFeatureRepository.new);
  sl.registerLazySingleton<ExportService>(ExportService.new);

  sl.registerLazySingleton<GetNotesUseCase>(() => GetNotesUseCase(sl()));
  sl.registerLazySingleton<CreateNoteUseCase>(() => CreateNoteUseCase(sl()));
  sl.registerLazySingleton<UpdateNoteUseCase>(() => UpdateNoteUseCase(sl()));
  sl.registerLazySingleton<DeleteNoteUseCase>(() => DeleteNoteUseCase(sl()));
  sl.registerLazySingleton<TogglePinUseCase>(() => TogglePinUseCase(sl()));
  sl.registerLazySingleton<SearchNotesUseCase>(() => SearchNotesUseCase(sl()));

  sl.registerLazySingleton<GetFoldersUseCase>(() => GetFoldersUseCase(sl()));
  sl.registerLazySingleton<CreateFolderUseCase>(() => CreateFolderUseCase(sl()));
  sl.registerLazySingleton<RenameFolderUseCase>(() => RenameFolderUseCase(sl()));
  sl.registerLazySingleton<DeleteFolderUseCase>(() => DeleteFolderUseCase(sl()));

  // Export use cases
  // Note: ExportNoteUseCase, ExportFolderUseCase, ExportAllNotesUseCase,
  // and ShareNoteUseCase require runtime parameters (noteId, folderId, format)
  // and are instantiated directly where needed with those parameters.
  //
  // Example usage:
  // final exportUseCase = ExportNoteUseCase(
  //   noteRepository: sl<NoteRepository>(),
  //   noteId: 'note-123',
  //   format: 'markdown',
  // );
  //
  // These use cases are imported and available for use throughout the app.

  sl.registerFactory<NotesViewModel>(
    () => NotesViewModel(
      getNotes: sl(),
      deleteNote: sl(),
      togglePin: sl(),
      getFolders: sl(),
      createFolder: sl(),
      renameFolder: sl(),
      deleteFolder: sl(),
      searchNotes: sl(),
    )..load(),
  );

  sl.registerFactory<NoteEditorViewModel>(
    () => NoteEditorViewModel(
      createNote: sl(),
      updateNote: sl(),
      getNotes: sl(),
    ),
  );
}
