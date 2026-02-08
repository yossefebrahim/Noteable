import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:noteable_app/domain/entities/template_entity.dart';
import 'package:noteable_app/domain/entities/template_variable.dart';
import 'package:noteable_app/domain/repositories/template_repository.dart';
import 'package:noteable_app/domain/usecases/template/get_templates_usecase.dart';

@GenerateNiceMocks([MockSpec<TemplateRepository>()])
import 'get_templates_usecase_test.mocks.dart';

void main() {
  late MockTemplateRepository mockRepository;
  late GetTemplatesUseCase useCase;

  setUp(() {
    mockRepository = MockTemplateRepository();
    useCase = GetTemplatesUseCase(templateRepository: mockRepository);
  });

  test('returns success with templates when repository succeeds', () async {
    final templates = <TemplateEntity>[
      TemplateEntity(
        id: '1',
        name: 'Template 1',
        title: 'T1',
        content: 'C1',
        variables: <TemplateVariable>[],
      ),
      TemplateEntity(
        id: '2',
        name: 'Template 2',
        title: 'T2',
        content: 'C2',
        variables: <TemplateVariable>[],
      ),
    ];
    when(mockRepository.getTemplates()).thenAnswer((_) async => templates);

    final result = await useCase();

    expect(result.isSuccess, isTrue);
    expect(result.data, equals(templates));
    expect(result.data!.length, 2);
  });

  test('returns success with empty list when no templates exist', () async {
    when(mockRepository.getTemplates()).thenAnswer((_) async => <TemplateEntity>[]);

    final result = await useCase();

    expect(result.isSuccess, isTrue);
    expect(result.data, isEmpty);
  });

  test('returns failure when repository throws exception', () async {
    when(mockRepository.getTemplates()).thenThrow(Exception('Database error'));

    final result = await useCase();

    expect(result.isSuccess, isFalse);
    expect(result.error, contains('Failed to fetch templates'));
  });

  test('calls repository getTemplates exactly once', () async {
    when(mockRepository.getTemplates()).thenAnswer((_) async => <TemplateEntity>[]);

    await useCase();

    verify(mockRepository.getTemplates()).called(1);
  });
}
