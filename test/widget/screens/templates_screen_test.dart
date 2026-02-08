import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noteable_app/data/repositories/template_repository_impl.dart';
import 'package:noteable_app/domain/entities/template_entity.dart';
import 'package:noteable_app/domain/entities/template_variable.dart';
import 'package:noteable_app/presentation/providers/template_view_model.dart';
import 'package:noteable_app/presentation/screens/templates/templates_screen.dart';
import 'package:provider/provider.dart';

Future<TemplateViewModel> _buildVm() async {
  final repo = TemplateRepositoryImpl();
  final vm = TemplateViewModel(templateRepository: repo);
  await vm.load();
  return vm;
}

void main() {
  testWidgets('TemplatesScreen displays title', (tester) async {
    final vm = await _buildVm();
    await tester.pumpWidget(
      ChangeNotifierProvider<TemplateViewModel>.value(
        value: vm,
        child: const MaterialApp(home: TemplatesScreen()),
      ),
    );

    expect(find.text('Templates'), findsOneWidget);
  });

  testWidgets('TemplatesScreen shows built-in templates', (tester) async {
    final vm = await _buildVm();
    await tester.pumpWidget(
      ChangeNotifierProvider<TemplateViewModel>.value(
        value: vm,
        child: const MaterialApp(home: TemplatesScreen()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Blank Note'), findsOneWidget);
    expect(find.text('Meeting Notes'), findsOneWidget);
    expect(find.text('Daily Journal'), findsOneWidget);
    expect(find.text('Weekly Plan'), findsOneWidget);
    expect(find.text('Book Notes'), findsOneWidget);
  });

  testWidgets('TemplatesScreen shows FAB', (tester) async {
    final vm = await _buildVm();
    await tester.pumpWidget(
      ChangeNotifierProvider<TemplateViewModel>.value(
        value: vm,
        child: const MaterialApp(home: TemplatesScreen()),
      ),
    );

    expect(find.byType(FloatingActionButton), findsOneWidget);
    expect(find.byIcon(Icons.add_outlined), findsOneWidget);
  });

  testWidgets('TemplatesScreen shows lock icon for built-in templates', (tester) async {
    final vm = await _buildVm();
    await tester.pumpWidget(
      ChangeNotifierProvider<TemplateViewModel>.value(
        value: vm,
        child: const MaterialApp(home: TemplatesScreen()),
      ),
    );

    await tester.pumpAndSettle();

    // Built-in templates should have lock icons
    final lockIcons = find.byIcon(Icons.lock_outlined);
    expect(lockIcons, findsWidgets);

    // Built-in templates should NOT have edit or delete buttons
    expect(find.byIcon(Icons.edit_outlined), findsNothing);
    expect(find.byIcon(Icons.delete_outline), findsNothing);
  });

  testWidgets('TemplatesScreen shows edit and delete for custom templates', (tester) async {
    final repo = TemplateRepositoryImpl();
    final vm = TemplateViewModel(templateRepository: repo);

    // Create a custom template
    final custom = TemplateEntity(
      id: 'ignored',
      name: 'Custom Template',
      title: 'Custom',
      content: 'Content',
      variables: <TemplateVariable>[],
    );
    await vm.createTemplate(custom);

    await tester.pumpWidget(
      ChangeNotifierProvider<TemplateViewModel>.value(
        value: vm,
        child: const MaterialApp(home: TemplatesScreen()),
      ),
    );

    await tester.pumpAndSettle();

    // Custom template should have edit and delete icons
    expect(find.text('Custom Template'), findsOneWidget);
    expect(find.byIcon(Icons.edit_outlined), findsOneWidget);
    expect(find.byIcon(Icons.delete_outline), findsOneWidget);
  });

  testWidgets('TemplatesScreen templates are sorted', (tester) async {
    final repo = TemplateRepositoryImpl();
    final vm = TemplateViewModel(templateRepository: repo);

    // Create custom templates with specific names to test sorting
    await vm.createTemplate(
      TemplateEntity(
        id: 'ignored',
        name: 'Zebra Template',
        title: 'Z',
        content: 'C',
        variables: <TemplateVariable>[],
      ),
    );
    await vm.createTemplate(
      TemplateEntity(
        id: 'ignored',
        name: 'Apple Template',
        title: 'A',
        content: 'C',
        variables: <TemplateVariable>[],
      ),
    );

    await tester.pumpWidget(
      ChangeNotifierProvider<TemplateViewModel>.value(
        value: vm,
        child: const MaterialApp(home: TemplatesScreen()),
      ),
    );

    await tester.pumpAndSettle();

    // Get all list tiles
    final listTiles = tester.widgetList<ListTile>(find.byType(ListTile)).toList();

    // Find indices of custom templates
    int? appleIndex;
    int? zebraIndex;
    for (int i = 0; i < listTiles.length; i++) {
      final tile = listTiles[i];
      if (tile.title is Text) {
        final text = (tile.title as Text).data ?? '';
        if (text == 'Apple Template') appleIndex = i;
        if (text == 'Zebra Template') zebraIndex = i;
      }
    }

    // Apple should come before Zebra (alphabetical)
    expect(appleIndex, isNotNull);
    expect(zebraIndex, isNotNull);
    expect(appleIndex!, lessThan(zebraIndex!));
  });

  testWidgets('TemplatesScreen shows template title as subtitle', (tester) async {
    final vm = await _buildVm();
    await tester.pumpWidget(
      ChangeNotifierProvider<TemplateViewModel>.value(
        value: vm,
        child: const MaterialApp(home: TemplatesScreen()),
      ),
    );

    await tester.pumpAndSettle();

    // Blank Note should have empty title
    final blankNoteFinder = find.ancestor(
      of: find.text('Blank Note'),
      matching: find.byType(ListTile),
    );
    final blankNoteTile = tester.widget<ListTile>(blankNoteFinder);

    expect(blankNoteTile.subtitle, isNotNull);
  });
}
