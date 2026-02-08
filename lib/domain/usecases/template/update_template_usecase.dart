import 'package:noteable_app/domain/common/result.dart';
import 'package:noteable_app/domain/entities/template_entity.dart';
import 'package:noteable_app/domain/repositories/template_repository.dart';

class UpdateTemplateUseCase {
  final TemplateRepository _templateRepository;

  UpdateTemplateUseCase({required TemplateRepository templateRepository})
    : _templateRepository = templateRepository;

  Future<Result<TemplateEntity>> call(TemplateEntity template) async {
    try {
      final updated = await _templateRepository.updateTemplate(template);
      return Result.success(updated);
    } catch (e) {
      return Result.failure('Failed to update template: $e');
    }
  }
}
