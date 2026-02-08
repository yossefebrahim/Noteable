import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:noteable_app/domain/entities/template_entity.dart';
import 'package:noteable_app/domain/entities/template_variable.dart';
import 'package:noteable_app/domain/repositories/template_repository.dart';
import 'package:noteable_app/domain/usecases/template/update_template_usecase.dart';

@GenerateNiceMocks([MockSpec<TemplateRepository>()])
import 'update_template_usecase_test.mocks.dart';

void main() {
  late MockTemplateRepository mockRepository;
  late UpdateTemplateUseCase useCase;

  setUp(() {
    mockRepository = MockTemplateRepository();
  });

  test('returns success with updated template when repository succeeds', () async {
    final template = TemplateEntity(
      id: 'custom_123',
      name: 'Updated Name',
      title: 'Updated',
      content: 'Updated Content',
      variables: <TemplateVariable>[],
    );
    when(mockRepository.updateTemplate(template)).thenAnswer((_) async => template);

    useCase = UpdateTemplateUseCase(
      templateRepository: mockRepository,
      template: template,
    );

    final result = await useCase();

    expect(result.isSuccess, isTrue);
    expect(result.data!.name, 'Updated Name');
  });

  test('returns failure when repository throws exception', () async {
    final template = TemplateEntity(
      id: 'custom_123',
      name: 'Template',
      title: 'T',
      content: 'C',
      variables: <TemplateVariable>[],
    );
    when(mockRepository.updateTemplate(template)).thenThrow(ArgumentError('Cannot update built-in templates'));

    useCase = UpdateTemplateUseCase(
      templateRepository: mockRepository,
      template: template,
    );

    final result = await useCase();

    expect(result.isSuccess, isFalse);
    expect(result.error, contains('Failed to update template'));
  });

  test('calls repository updateTemplate exactly once', () async {
    final template = TemplateEntity(
      id: 'custom_123',
      name: 'Template',
      title: 'T',
      content: 'C',
      variables: <TemplateVariable>[],
    );
    when(mockRepository.updateTemplate(template)).thenAnswer((_) async => template);

    useCase = UpdateTemplateUseCase(
      templateRepository: mockRepository,
      template: template,
    );

    await useCase();

    verify(mockRepository.updateTemplate(template)).called(1);
  });

  test('handles built-in template update error', () async {
    final builtIn = TemplateEntity(
      id: 'builtin_meeting',
      name: 'Meeting Notes',
      title: 'Meeting',
      content: 'Content',
      variables: <TemplateVariable>[],
      isBuiltIn: true,
    );
    when(mockRepository.updateTemplate(builtIn)).thenThrow(
      ArgumentError('Cannot update built-in templates'),
    );

    useCase = UpdateTemplateUseCase(
      templateRepository: mockRepository,
      template: builtIn,
    );

    final result = await useCase();

    expect(result.isSuccess, isFalse);
    expect(result.error, contains('Failed to update template'));
  });

  test('preserves template variables through update', () async {
    final variables = <TemplateVariable>[
      TemplateVariable(name: 'date', type: 'date'),
      TemplateVariable(name: 'title', type: 'text'),
    ];
    final template = TemplateEntity(
      id: 'custom_123',
      name: 'Template',
      title: 'T',
      content: 'C',
      variables: variables,
    );
    when(mockRepository.updateTemplate(template)).thenAnswer((_) async => template);

    useCase = UpdateTemplateUseCase(
      templateRepository: mockRepository,
      template: template,
    );

    final result = await useCase();

    expect(result.isSuccess, isTrue);
    expect(result.data!.variables.length, 2);
  });
}
