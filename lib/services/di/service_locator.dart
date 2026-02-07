import 'package:get_it/get_it.dart';
import 'package:noteable_app/data/repositories/in_memory_notes_feature_repository.dart';
import 'package:noteable_app/data/repositories/template_repository_impl.dart';
import 'package:noteable_app/domain/repositories/notes_feature_repository.dart';
import 'package:noteable_app/domain/repositories/template_repository.dart';
import 'package:noteable_app/domain/usecases/feature_usecases.dart';
import 'package:noteable_app/domain/usecases/template/apply_template_usecase.dart';
import 'package:noteable_app/domain/usecases/template/create_template_usecase.dart';
import 'package:noteable_app/domain/usecases/template/delete_template_usecase.dart';
import 'package:noteable_app/domain/usecases/template/get_templates_usecase.dart';
import 'package:noteable_app/domain/usecases/template/import_export_templates_usecase.dart';
import 'package:noteable_app/domain/usecases/template/update_template_usecase.dart';
import 'package:noteable_app/presentation/providers/app_provider.dart';
import 'package:noteable_app/presentation/providers/folder_provider.dart';
import 'package:noteable_app/presentation/providers/note_detail_view_model.dart';
import 'package:noteable_app/presentation/providers/notes_view_model.dart';
import 'package:noteable_app/presentation/providers/template_view_model.dart';

final GetIt sl = GetIt.instance;

Future<void> setupServiceLocator() async {
  sl.registerLazySingleton<AppProvider>(AppProvider.new);
  sl.registerLazySingleton<NotesFeatureRepository>(InMemoryNotesFeatureRepository.new);
  sl.registerLazySingleton<TemplateRepository>(TemplateRepositoryImpl.new);

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

  sl.registerLazySingleton<GetTemplatesUseCase>(() => GetTemplatesUseCase(sl()));
  sl.registerLazySingleton<CreateTemplateUseCase>(() => CreateTemplateUseCase(sl()));
  sl.registerLazySingleton<UpdateTemplateUseCase>(() => UpdateTemplateUseCase(sl()));
  sl.registerLazySingleton<DeleteTemplateUseCase>(() => DeleteTemplateUseCase(sl()));
  sl.registerLazySingleton<ApplyTemplateUseCase>(() => ApplyTemplateUseCase(sl()));
  sl.registerLazySingleton<ImportExportTemplatesUseCase>(() => ImportExportTemplatesUseCase(sl()));

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

  sl.registerFactory<TemplateViewModel>(
    () => TemplateViewModel(
      templateRepository: sl(),
    )..load(),
  );
}
