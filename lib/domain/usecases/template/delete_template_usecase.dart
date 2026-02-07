import 'package:noteable_app/domain/common/result.dart';
import 'package:noteable_app/domain/repositories/template_repository.dart';

class DeleteTemplateUseCase {
  final TemplateRepository _templateRepository;
  final String _templateId;

  DeleteTemplateUseCase({
    required TemplateRepository templateRepository,
    required String templateId,
  }) : _templateRepository = templateRepository,
       _templateId = templateId;

  Future<Result<void>> call() async {
    try {
      await _templateRepository.deleteTemplate(_templateId);
      return const Result.success(null);
    } catch (e) {
      return Result.failure('Failed to delete template: $e');
    }
  }
}
