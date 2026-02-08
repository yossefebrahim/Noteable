import 'package:noteable_app/domain/common/result.dart';
import 'package:noteable_app/domain/repositories/template_repository.dart';

class DeleteTemplateUseCase {
  final TemplateRepository _templateRepository;

  DeleteTemplateUseCase({required TemplateRepository templateRepository})
    : _templateRepository = templateRepository;

  Future<Result<void>> call(String templateId) async {
    try {
      await _templateRepository.deleteTemplate(templateId);
      return const Result.success(null);
    } catch (e) {
      return Result.failure('Failed to delete template: $e');
    }
  }
}
