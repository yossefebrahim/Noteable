import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:noteable_app/domain/entities/note.dart';
import 'package:noteable_app/domain/repositories/note_repository.dart';
import 'package:noteable_app/domain/usecases/note/restore_note_usecase.dart';

class MockNoteRepository extends Mock implements NoteRepository {}

void main() {
  late MockNoteRepository mockRepository;
  late RestoreNoteUseCase useCase;

  setUp(() {
    mockRepository = MockNoteRepository();
  });

  test('returns success when repository restores successfully', () async {
    const noteId = 'note_123';
    final restoredNote = Note(
      id: noteId,
      title: 'Restored Note',
      content: 'Content',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    when(mockRepository.restoreNote(noteId)).thenAnswer((_) async => restoredNote);

    useCase = RestoreNoteUseCase(
      noteRepository: mockRepository,
      noteId: noteId,
    );

    final result = await useCase();

    expect(result.isSuccess, isTrue);
  });

  test('returns failure when repository throws exception', () async {
    const noteId = 'note_456';
    when(mockRepository.restoreNote(noteId)).thenThrow(
      Exception('Note not found'),
    );

    useCase = RestoreNoteUseCase(
      noteRepository: mockRepository,
      noteId: noteId,
    );

    final result = await useCase();

    expect(result.isSuccess, isFalse);
    expect(result.error, contains('Failed to restore note'));
  });

  test('calls repository restoreNote exactly once', () async {
    const noteId = 'note_789';
    final restoredNote = Note(
      id: noteId,
      title: 'Restored Note',
      content: 'Content',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    when(mockRepository.restoreNote(noteId)).thenAnswer((_) async => restoredNote);

    useCase = RestoreNoteUseCase(
      noteRepository: mockRepository,
      noteId: noteId,
    );

    await useCase();

    verify(mockRepository.restoreNote(noteId)).called(1);
  });

  test('handles non-existent note restoration gracefully', () async {
    const noteId = 'non_existent';
    when(mockRepository.restoreNote(noteId)).thenThrow(
      ArgumentError('Note not found'),
    );

    useCase = RestoreNoteUseCase(
      noteRepository: mockRepository,
      noteId: noteId,
    );

    final result = await useCase();

    expect(result.isSuccess, isFalse);
    expect(result.error, contains('Failed to restore note'));
  });

  test('handles database error during restoration', () async {
    const noteId = 'note_error';
    when(mockRepository.restoreNote(noteId)).thenThrow(
      Exception('Database connection failed'),
    );

    useCase = RestoreNoteUseCase(
      noteRepository: mockRepository,
      noteId: noteId,
    );

    final result = await useCase();

    expect(result.isSuccess, isFalse);
    expect(result.error, contains('Failed to restore note'));
    expect(result.error, contains('Database connection failed'));
  });
}
