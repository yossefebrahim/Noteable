import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:noteable_app/domain/entities/template_entity.dart';
import 'package:noteable_app/domain/entities/template_variable.dart';
import 'package:noteable_app/domain/repositories/template_repository.dart';
import 'package:noteable_app/domain/usecases/template/create_template_usecase.dart';

@GenerateNiceMocks([MockSpec<TemplateRepository>()])
import 'create_template_usecase_test.mocks.dart';

void main() {
  late MockTemplateRepository mockRepository;
  late CreateTemplateUseCase useCase;

  setUp(() {
    mockRepository = MockTemplateRepository();
  });

  test('returns success with created template when repository succeeds', () async {
    final template = TemplateEntity(
      id: 'ignored',
      name: 'New Template',
      title: 'New',
      content: 'Content',
      variables: <TemplateVariable>[],
    );
    final created = TemplateEntity(
      id: 'custom_123',
      name: 'New Template',
      title: 'New',
      content: 'Content',
      variables: <TemplateVariable>[],
    );
    when(mockRepository.createTemplate(template)).thenAnswer((_) async => created);

    useCase = CreateTemplateUseCase(
      templateRepository: mockRepository,
      template: template,
    );

    final result = await useCase();

    expect(result.isSuccess, isTrue);
    expect(result.data!.id, 'custom_123');
    expect(result.data!.name, 'New Template');
  });

  test('returns failure when repository throws exception', () async {
    final template = TemplateEntity(
      id: 'ignored',
      name: 'New Template',
      title: 'New',
      content: 'Content',
      variables: <TemplateVariable>[],
    );
    when(mockRepository.createTemplate(template)).thenThrow(Exception('Creation failed'));

    useCase = CreateTemplateUseCase(
      templateRepository: mockRepository,
      template: template,
    );

    final result = await useCase();

    expect(result.isSuccess, isFalse);
    expect(result.error, contains('Failed to create template'));
  });

  test('calls repository createTemplate exactly once', () async {
    final template = TemplateEntity(
      id: 'ignored',
      name: 'New Template',
      title: 'New',
      content: 'Content',
      variables: <TemplateVariable>[],
    );
    when(mockRepository.createTemplate(template)).thenAnswer(
      (_) async => template.copyWith(id: 'custom_123'),
    );

    useCase = CreateTemplateUseCase(
      templateRepository: mockRepository,
      template: template,
    );

    await useCase();

    verify(mockRepository.createTemplate(template)).called(1);
  });

  test('preserves template variables through creation', () async {
    final variables = <TemplateVariable>[
      TemplateVariable(name: 'date', type: 'date'),
      TemplateVariable(name: 'title', type: 'text'),
    ];
    final template = TemplateEntity(
      id: 'ignored',
      name: 'Template with Variables',
      title: 'T',
      content: 'C',
      variables: variables,
    );
    when(mockRepository.createTemplate(template)).thenAnswer(
      (_) async => template.copyWith(id: 'custom_123'),
    );

    useCase = CreateTemplateUseCase(
      templateRepository: mockRepository,
      template: template,
    );

    final result = await useCase();

    expect(result.isSuccess, isTrue);
    expect(result.data!.variables.length, 2);
    expect(result.data!.variables[0].name, 'date');
    expect(result.data!.variables[1].name, 'title');
  });
}
