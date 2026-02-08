import 'package:noteable_app/domain/common/result.dart';
import 'package:noteable_app/domain/entities/template_entity.dart';
import 'package:noteable_app/domain/repositories/template_repository.dart';

class GetTemplatesUseCase {
  final TemplateRepository _templateRepository;

  GetTemplatesUseCase({required TemplateRepository templateRepository})
    : _templateRepository = templateRepository;

  Future<Result<List<TemplateEntity>>> call() async {
    try {
      final templates = await _templateRepository.getTemplates();
      return Result.success(templates);
    } catch (e) {
      return Result.failure('Failed to fetch templates: $e');
    }
  }
}
