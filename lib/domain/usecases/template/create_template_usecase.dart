import 'package:noteable_app/domain/common/result.dart';
import 'package:noteable_app/domain/entities/template_entity.dart';
import 'package:noteable_app/domain/repositories/template_repository.dart';

class CreateTemplateUseCase {
  final TemplateRepository _templateRepository;
  final TemplateEntity _template;

  CreateTemplateUseCase({
    required TemplateRepository templateRepository,
    required TemplateEntity template,
  })  : _templateRepository = templateRepository,
        _template = template;

  Future<Result<TemplateEntity>> call() async {
    try {
      final created = await _templateRepository.createTemplate(_template);
      return Result.success(created);
    } catch (e) {
      return Result.failure('Failed to create template: $e');
    }
  }
}
