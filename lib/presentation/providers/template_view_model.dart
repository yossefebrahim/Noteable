import 'package:flutter/foundation.dart';
import 'package:noteable_app/domain/entities/template_entity.dart';
import 'package:noteable_app/domain/repositories/template_repository.dart';
import 'package:noteable_app/domain/usecases/template/create_template_usecase.dart';
import 'package:noteable_app/domain/usecases/template/delete_template_usecase.dart';
import 'package:noteable_app/domain/usecases/template/get_templates_usecase.dart';
import 'package:noteable_app/domain/usecases/template/import_export_templates_usecase.dart';
import 'package:noteable_app/domain/usecases/template/update_template_usecase.dart';

class TemplateViewModel extends ChangeNotifier {
  TemplateViewModel({
    required TemplateRepository templateRepository,
  }) : _templateRepository = templateRepository;

  final TemplateRepository _templateRepository;

  List<TemplateEntity> _templates = <TemplateEntity>[];

  List<TemplateEntity> get templates => _templates;

  Future<void> load() async {
    final getTemplates = GetTemplatesUseCase(templateRepository: _templateRepository);
    final result = await getTemplates();
    if (result.isSuccess) {
      _templates = result.data ?? [];
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    final getTemplates = GetTemplatesUseCase(templateRepository: _templateRepository);
    final result = await getTemplates();
    if (result.isSuccess) {
      _templates = result.data ?? [];
      notifyListeners();
    }
  }

  Future<void> createTemplate(TemplateEntity template) async {
    final createTemplate = CreateTemplateUseCase(
      templateRepository: _templateRepository,
      template: template,
    );
    await createTemplate();
    await refresh();
  }

  Future<void> updateTemplate(TemplateEntity template) async {
    final updateTemplate = UpdateTemplateUseCase(
      templateRepository: _templateRepository,
      template: template,
    );
    await updateTemplate();
    await refresh();
  }

  Future<void> deleteTemplate(String id) async {
    final deleteTemplate = DeleteTemplateUseCase(
      templateRepository: _templateRepository,
      templateId: id,
    );
    await deleteTemplate();
    await refresh();
  }

  Future<String> exportTemplates() async {
    final importExport = ImportExportTemplatesUseCase(
      templateRepository: _templateRepository,
    );
    final result = await importExport.exportTemplates();
    if (result.isSuccess && result.data != null) {
      await refresh();
      return result.data!;
    }
    throw Exception(result.error ?? 'Failed to export templates');
  }

  Future<List<TemplateEntity>> importTemplates(String jsonString) async {
    final importExport = ImportExportTemplatesUseCase(
      templateRepository: _templateRepository,
    );
    final result = await importExport.importTemplates(jsonString);
    if (result.isSuccess && result.data != null) {
      await refresh();
      return result.data!;
    }
    throw Exception(result.error ?? 'Failed to import templates');
  }

  TemplateEntity? getTemplateById(String id) {
    try {
      return _templates.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  List<TemplateEntity> getBuiltInTemplates() {
    return _templates.where((t) => t.isBuiltIn).toList();
  }

  List<TemplateEntity> getCustomTemplates() {
    return _templates.where((t) => !t.isBuiltIn).toList();
  }
}
