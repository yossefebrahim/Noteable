import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noteable_app/presentation/providers/folder_provider.dart';
import 'package:noteable_app/presentation/widgets/folder_card.dart';

void main() {
  testWidgets('FolderCard shows folder name and note count', (tester) async {
    final folder = FolderItem(id: '1', name: 'Work', noteCount: 5, colorHex: '#007AFF');
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: FolderCard(folder: folder)),
      ),
    );

    expect(find.text('Work'), findsOneWidget);
    expect(find.text('5 notes'), findsOneWidget);
  });
}
