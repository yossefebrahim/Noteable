import 'package:get_it/get_it.dart';
import 'package:noteable_app/data/repositories/in_memory_notes_feature_repository.dart';
import 'package:noteable_app/domain/repositories/notes_feature_repository.dart';
import 'package:noteable_app/domain/usecases/feature_usecases.dart';
import 'package:noteable_app/presentation/providers/app_provider.dart';
import 'package:noteable_app/presentation/providers/note_detail_view_model.dart';
import 'package:noteable_app/presentation/providers/notes_view_model.dart';

final GetIt sl = GetIt.instance;

Future<void> setupServiceLocator() async {
  sl.registerLazySingleton<AppProvider>(AppProvider.new);
  sl.registerLazySingleton<NotesFeatureRepository>(InMemoryNotesFeatureRepository.new);

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

Future<void> resetServiceLocator() async {
  await sl.reset();
}
