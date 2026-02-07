import 'package:flutter_test/flutter_test.dart';
import 'package:noteable_app/data/models/note_model.dart';
import 'package:noteable_app/data/repositories/note_repository_impl.dart';
import 'package:noteable_app/domain/entities/note.dart';
import 'package:noteable_app/services/storage/isar_service.dart';

class FakeIsarService extends IsarService {
  NoteModel? stored;
  bool deleteCalled = false;

  @override
  Future<int> putNote(NoteModel note) async {
    stored = note;
    return note.id == 0 ? 1 : note.id;
  }

  @override
  Future<NoteModel?> getNoteById(int id) async =>
      stored == null ? null : NoteModel(
        id: id,
        title: stored!.title,
        content: stored!.content,
        createdAt: stored!.createdAt,
        updatedAt: stored!.updatedAt,
        isPinned: stored!.isPinned,
        folderId: stored!.folderId,
      );

  @override
  Future<List<NoteModel>> getNotes() async => stored == null ? [] : [stored!];

  @override
  Future<bool> deleteNote(int id) async {
    deleteCalled = true;
    return true;
  }
}

void main() {
  late FakeIsarService fake;
  late NoteRepositoryImpl repository;

  setUp(() {
    fake = FakeIsarService();
    repository = NoteRepositoryImpl(fake);
  });

  test('create/get/delete flow works', () async {
    final now = DateTime(2026, 1, 1);
    final note = Note(
      id: '0',
      title: 'Title',
      content: 'Content',
      createdAt: now,
      updatedAt: now,
    );

    final created = await repository.createNote(note);
    final list = await repository.getNoteList();
    await repository.deleteNote(created.id);

    expect(created.title, 'Title');
    expect(list, isNotEmpty);
    expect(fake.deleteCalled, isTrue);
  });
}
