import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noteable_app/data/repositories/in_memory_notes_feature_repository.dart';
import 'package:noteable_app/data/repositories/template_repository_impl.dart';
import 'package:noteable_app/domain/entities/template_entity.dart';
import 'package:noteable_app/domain/entities/template_variable.dart';
import 'package:noteable_app/presentation/providers/folder_provider.dart';
import 'package:noteable_app/presentation/providers/template_view_model.dart';
import 'package:noteable_app/presentation/screens/templates/template_editor_screen.dart';
import 'package:provider/provider.dart';

Future<void> _setupTest(tester, {String? templateId}) async {
  final folderRepo = InMemoryNotesFeatureRepository();
  final templateRepo = TemplateRepositoryImpl();

  // Create a folder for testing
  await folderRepo.createFolder('Work');

  final folderVm = FolderViewModel(
    getFolders: GetFoldersUseCase(folderRepo),
    createFolder: CreateFolderUseCase(folderRepo),
    renameFolder: RenameFolderUseCase(folderRepo),
    deleteFolder: DeleteFolderUseCase(folderRepo),
  );
  await folderVm.load();

  final templateVm = TemplateViewModel(templateRepository: templateRepo);

  // If editing, create a template first
  if (templateId != null) {
    final template = TemplateEntity(
      id: templateId,
      name: 'Test Template',
      title: 'Test Title',
      content: 'Test Content',
      variables: <TemplateVariable>[
        TemplateVariable(name: 'date', type: 'date'),
      ],
    );
    await templateVm.createTemplate(template);
    await templateVm.load();
  }

  await tester.pumpWidget(
    MultiProvider(
      providers: <Provider<dynamic>>[
        ChangeNotifierProvider<FolderViewModel>.value(value: folderVm),
        ChangeNotifierProvider<TemplateViewModel>.value(value: templateVm),
      ],
      child: MaterialApp(
        home: TemplateEditorScreen(templateId: templateId),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('TemplateEditorScreen shows correct title for new template', (tester) async {
    await _setupTest(tester);

    expect(find.text('New Template'), findsOneWidget);
  });

  testWidgets('TemplateEditorScreen shows correct title for editing', (tester) async {
    await _setupTest(tester, templateId: 'custom_test');

    // Note: The template will have a different ID after creation
    // so we need to find it
    expect(find.text('Edit Template'), findsOneWidget);
  });

  testWidgets('TemplateEditorScreen has name field', (tester) async {
    await _setupTest(tester);

    expect(find.text('Template name (e.g., Meeting Notes)'), findsOneWidget);
  });

  testWidgets('TemplateEditorScreen has title field', (tester) async {
    await _setupTest(tester);

    expect(find.text('Note title (e.g., {{date}} Meeting)'), findsOneWidget);
  });

  testWidgets('TemplateEditorScreen has content field', (tester) async {
    await _setupTest(tester);

    expect(find.text('Template content... Use {{variable}} for placeholders'), findsOneWidget);
  });

  testWidgets('TemplateEditorScreen has Variables section', (tester) async {
    await _setupTest(tester);

    expect(find.text('Variables'), findsOneWidget);
    expect(find.text('Add Variable'), findsOneWidget);
  });

  testWidgets('TemplateEditorScreen has Default Folder section', (tester) async {
    await _setupTest(tester);

    expect(find.text('Default Folder'), findsOneWidget);
    expect(find.text('No default folder'), findsOneWidget);
    expect(find.text('Work'), findsOneWidget);
  });

  testWidgets('TemplateEditorScreen has Save button', (tester) async {
    await _setupTest(tester);

    expect(find.text('Save'), findsOneWidget);
  });

  testWidgets('TemplateEditorScreen shows no variables message initially', (tester) async {
    await _setupTest(tester);

    expect(find.text('No variables defined yet.'), findsOneWidget);
    expect(find.text('Tap "Add Variable" to create one.'), findsOneWidget);
  });

  testWidgets('TemplateEditorScreen can add variable', (tester) async {
    await _setupTest(tester);

    await tester.tap(find.text('Add Variable'));
    await tester.pumpAndSettle();

    // After adding, we should see variable name field
    expect(find.text('Variable name'), findsOneWidget);
    expect(find.text('e.g., date, time, attendees'), findsOneWidget);
  });

  testWidgets('TemplateEditorScreen can remove variable', (tester) async {
    await _setupTest(tester);

    await tester.tap(find.text('Add Variable'));
    await tester.pumpAndSettle();

    // Find the delete button and tap it
    final deleteButton = find.byIcon(Icons.delete_outline);
    expect(deleteButton, findsOneWidget);

    await tester.tap(deleteButton);
    await tester.pumpAndSettle();

    // Should be back to no variables state
    expect(find.text('No variables defined yet.'), findsOneWidget);
  });

  testWidgets('TemplateEditorScreen shows existing variables when editing', (tester) async {
    await _setupTest(tester, templateId: 'custom_test');

    // Should find the date variable
    expect(find.text('Variable name'), findsOneWidget);
  });

  testWidgets('TemplateEditorScreen populates fields when editing', (tester) async {
    await _setupTest(tester, templateId: 'custom_test');

    // Name field should have the template name
    final nameField = find.widgetWithText(AppTextField, 'Test Template');
    expect(nameField, findsOneWidget);
  });

  testWidgets('TemplateEditorScreen variable type dropdown has options', (tester) async {
    await _setupTest(tester);

    await tester.tap(find.text('Add Variable'));
    await tester.pumpAndSettle();

    // Should find type dropdown
    expect(find.text('Type'), findsOneWidget);

    // Open the dropdown
    await tester.tap(find.text('Text'));
    await tester.pumpAndSettle();

    // Check for all type options
    expect(find.text('Text'), findsWidgets);
    expect(find.text('Date'), findsOneWidget);
    expect(find.text('Time'), findsOneWidget);
  });

  testWidgets('TemplateEditorScreen variable has default value field', (tester) async {
    await _setupTest(tester);

    await tester.tap(find.text('Add Variable'));
    await tester.pumpAndSettle();

    expect(find.text('Default value (optional)'), findsOneWidget);
    expect(find.text('e.g., today, now'), findsOneWidget);
  });

  testWidgets('TemplateEditorScreen folder dropdown shows folders', (tester) async {
    await _setupTest(tester);

    // Tap the folder dropdown
    await tester.tap(find.text('No default folder'));
    await tester.pumpAndSettle();

    // Should see Work folder
    expect(find.text('Work'), findsOneWidget);
  });
}
