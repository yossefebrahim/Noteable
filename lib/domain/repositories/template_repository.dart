import 'package:noteable_app/domain/entities/template_entity.dart';
import 'package:noteable_app/domain/repositories/base_repository.dart';

abstract interface class TemplateRepository implements BaseRepository {
  Future<List<TemplateEntity>> getTemplates();

  Future<TemplateEntity?> getTemplateById(String id);

  Future<TemplateEntity> createTemplate(TemplateEntity template);

  Future<TemplateEntity> updateTemplate(TemplateEntity template);

  Future<void> deleteTemplate(String id);
}
