import 'package:noteable_app/domain/common/result.dart';
import 'package:noteable_app/domain/entities/template_entity.dart';
import 'package:noteable_app/domain/repositories/template_repository.dart';

class UpdateTemplateUseCase {
  final TemplateRepository _templateRepository;
  final TemplateEntity _template;

  UpdateTemplateUseCase({
    required TemplateRepository templateRepository,
    required TemplateEntity template,
  })  : _templateRepository = templateRepository,
        _template = template;

  Future<Result<TemplateEntity>> call() async {
    try {
      final updated = await _templateRepository.updateTemplate(_template);
      return Result.success(updated);
    } catch (e) {
      return Result.failure('Failed to update template: $e');
    }
  }
}
