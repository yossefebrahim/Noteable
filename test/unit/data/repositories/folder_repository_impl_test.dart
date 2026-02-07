import 'package:flutter_test/flutter_test.dart';
import 'package:noteable_app/data/models/folder_model.dart';
import 'package:noteable_app/data/repositories/folder_repository_impl.dart';
import 'package:noteable_app/domain/entities/folder.dart';
import 'package:noteable_app/services/storage/isar_service.dart';

class FakeIsarService extends IsarService {
  FolderModel? stored;

  @override
  Future<int> putFolder(FolderModel folder) async {
    stored = folder;
    return folder.id == 0 ? 1 : folder.id;
  }

  @override
  Future<FolderModel?> getFolderById(int id) async =>
      stored == null ? null : FolderModel(id: id, name: stored!.name, createdAt: stored!.createdAt);

  @override
  Future<List<FolderModel>> getFolders() async => stored == null ? [] : [stored!];
}

void main() {
  late FakeIsarService fake;
  late FolderRepositoryImpl repository;

  setUp(() {
    fake = FakeIsarService();
    repository = FolderRepositoryImpl(fake);
  });

  test('create/get folders flow works', () async {
    final folder = Folder(id: '0', name: 'Work', createdAt: DateTime(2026, 1, 1));

    final created = await repository.createFolder(folder);
    final list = await repository.getFolders();

    expect(created.name, 'Work');
    expect(list.length, 1);
  });
}
