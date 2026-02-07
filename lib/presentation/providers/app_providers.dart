import 'package:noteable_app/presentation/providers/app_provider.dart';
import 'package:noteable_app/presentation/providers/notes_view_model.dart';
import 'package:noteable_app/services/di/service_locator.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

class AppProviders {
  AppProviders._();

  static final List<SingleChildWidget> providers = <SingleChildWidget>[
    ChangeNotifierProvider<AppProvider>(create: (_) => sl<AppProvider>()),
    ChangeNotifierProvider<NotesViewModel>(create: (_) => sl<NotesViewModel>()),
  ];
}
