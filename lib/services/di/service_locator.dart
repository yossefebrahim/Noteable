import 'package:get_it/get_it.dart';
import 'package:noteable_app/data/repositories/audio_repository_impl.dart';
import 'package:noteable_app/data/repositories/in_memory_notes_feature_repository.dart';
import 'package:noteable_app/data/repositories/note_repository_impl.dart';
import 'package:noteable_app/data/repositories/transcription_repository_impl.dart';
import 'package:noteable_app/data/services/export_service.dart';
import 'package:noteable_app/domain/repositories/audio_repository.dart';
import 'package:noteable_app/domain/repositories/note_repository.dart';
import 'package:noteable_app/domain/repositories/transcription_repository.dart';
import 'package:noteable_app/domain/repositories/notes_feature_repository.dart';
import 'package:noteable_app/domain/usecases/audio/create_audio_attachment_usecase.dart';
import 'package:noteable_app/domain/usecases/audio/transcribe_audio_usecase.dart';
import 'package:noteable_app/domain/usecases/feature_usecases.dart';
import 'package:noteable_app/presentation/providers/app_provider.dart';
import 'package:noteable_app/presentation/providers/audio_player_provider.dart';
import 'package:noteable_app/presentation/providers/audio_recorder_provider.dart';
import 'package:noteable_app/presentation/providers/export_view_model.dart';
import 'package:noteable_app/presentation/providers/note_detail_view_model.dart';
import 'package:noteable_app/presentation/providers/notes_view_model.dart';
import 'package:noteable_app/services/audio/audio_player_service.dart';
import 'package:noteable_app/services/audio/audio_recorder_service.dart';
import 'package:noteable_app/services/audio/transcription_service.dart';
import 'package:noteable_app/services/platform/channels/widget_channel.dart';
import 'package:noteable_app/services/platform/data_sync_service.dart';
import 'package:noteable_app/services/storage/file_storage_service.dart';
import 'package:noteable_app/services/storage/isar_service.dart';

final GetIt sl = GetIt.instance;

Future<void> setupServiceLocator() async {
  sl.registerLazySingleton<WidgetChannel>(WidgetChannel.new);
  sl.registerLazySingleton<DataSyncService>(DataSyncService.new);
  sl.registerLazySingleton<AppProvider>(AppProvider.new);
  sl.registerLazySingleton<NotesFeatureRepository>(InMemoryNotesFeatureRepository.new);
  sl.registerLazySingleton<ExportService>(ExportService.new);

  // Audio services
  sl.registerLazySingleton<FileStorageService>(FileStorageService.new);
  sl.registerLazySingleton<AudioRecorderService>(AudioRecorderService.new);
  sl.registerLazySingleton<AudioPlayerService>(AudioPlayerService.new);
  sl.registerLazySingleton<TranscriptionService>(TranscriptionService.new);

  // Isar service (shared by repositories)
  sl.registerLazySingleton<IsarService>(IsarService.new);

  // Audio repositories
  sl.registerLazySingleton<AudioRepository>(() => AudioRepositoryImpl(sl()));
  sl.registerLazySingleton<TranscriptionRepository>(() => TranscriptionRepositoryImpl(sl()));

  // Note repository (if not already handled by NotesFeatureRepository)
  if (!sl.isRegistered<NoteRepository>()) {
    sl.registerLazySingleton<NoteRepository>(() => NoteRepositoryImpl(sl(), sl()));
  }

  // Audio use cases
  sl.registerLazySingleton<CreateAudioAttachmentUseCase>(() => CreateAudioAttachmentUseCase(sl()));
  sl.registerLazySingleton<TranscribeAudioUseCase>(() => TranscribeAudioUseCase(sl()));

  sl.registerLazySingleton<GetNotesUseCase>(() => GetNotesUseCase(sl()));
  sl.registerLazySingleton<CreateNoteUseCase>(() => CreateNoteUseCase(sl()));
  sl.registerLazySingleton<UpdateNoteUseCase>(() => UpdateNoteUseCase(sl()));
  sl.registerLazySingleton<DeleteNoteUseCase>(() => DeleteNoteUseCase(sl()));
  sl.registerLazySingleton<TogglePinUseCase>(() => TogglePinUseCase(sl()));
  sl.registerLazySingleton<SearchNotesUseCase>(() => SearchNotesUseCase(sl()));
  sl.registerLazySingleton<RestoreNoteUseCase>(() => RestoreNoteUseCase(sl()));

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
      restoreNote: sl(),
    )..load(),
  );

  sl.registerFactory<NoteEditorViewModel>(
    () => NoteEditorViewModel(
      createNote: sl(),
      updateNote: sl(),
      getNotes: sl(),
      audioRepository: sl(),
    ),
  );

  // Audio providers
  sl.registerLazySingleton<AudioRecorderProvider>(AudioRecorderProvider.new);
  sl.registerFactory<AudioPlayerProvider>(() => AudioPlayerProvider(audioPlayerService: sl()));

  sl.registerFactory<ExportViewModel>(() => ExportViewModel(noteRepository: sl()));
}

Future<void> resetServiceLocator() async {
  await sl.reset();
}
