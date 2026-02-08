import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:noteable_app/domain/repositories/template_repository.dart';
import 'package:noteable_app/domain/usecases/template/delete_template_usecase.dart';

@GenerateNiceMocks([MockSpec<TemplateRepository>()])
import 'delete_template_usecase_test.mocks.dart';

void main() {
  late MockTemplateRepository mockRepository;
  late DeleteTemplateUseCase useCase;

  setUp(() {
    mockRepository = MockTemplateRepository();
  });

  test('returns success when repository deletes successfully', () async {
    const templateId = 'custom_123';
    when(mockRepository.deleteTemplate(templateId)).thenAnswer((_) async {});

    useCase = DeleteTemplateUseCase(
      templateRepository: mockRepository,
      templateId: templateId,
    );

    final result = await useCase();

    expect(result.isSuccess, isTrue);
  });

  test('returns failure when repository throws exception', () async {
    const templateId = 'builtin_meeting';
    when(mockRepository.deleteTemplate(templateId)).thenThrow(
      ArgumentError('Cannot delete built-in templates'),
    );

    useCase = DeleteTemplateUseCase(
      templateRepository: mockRepository,
      templateId: templateId,
    );

    final result = await useCase();

    expect(result.isSuccess, isFalse);
    expect(result.error, contains('Failed to delete template'));
  });

  test('calls repository deleteTemplate exactly once', () async {
    const templateId = 'custom_123';
    when(mockRepository.deleteTemplate(templateId)).thenAnswer((_) async {});

    useCase = DeleteTemplateUseCase(
      templateRepository: mockRepository,
      templateId: templateId,
    );

    await useCase();

    verify(mockRepository.deleteTemplate(templateId)).called(1);
  });

  test('handles built-in template deletion error', () async {
    const templateId = 'builtin_blank';
    when(mockRepository.deleteTemplate(templateId)).thenThrow(
      ArgumentError('Cannot delete built-in templates'),
    );

    useCase = DeleteTemplateUseCase(
      templateRepository: mockRepository,
      templateId: templateId,
    );

    final result = await useCase();

    expect(result.isSuccess, isFalse);
    expect(result.error, contains('Failed to delete template'));
  });

  test('handles non-existent template deletion gracefully', () async {
    const templateId = 'non_existent';
    when(mockRepository.deleteTemplate(templateId)).thenAnswer((_) async {});

    useCase = DeleteTemplateUseCase(
      templateRepository: mockRepository,
      templateId: templateId,
    );

    final result = await useCase();

    expect(result.isSuccess, isTrue);
  });
}
