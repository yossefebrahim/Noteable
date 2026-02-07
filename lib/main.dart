import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'presentation/providers/app_provider.dart';
import 'presentation/providers/app_providers.dart';
import 'presentation/router/app_router.dart';
import 'services/di/service_locator.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupServiceLocator();
  runApp(const NoteableApp());
}

class NoteableApp extends StatelessWidget {
  const NoteableApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: AppProviders.providers,
      child: Selector<AppProvider, ThemeMode>(
        selector: (_, AppProvider provider) => provider.themeMode,
        builder: (BuildContext context, ThemeMode themeMode, _) {
          return MaterialApp.router(
            title: 'Noteable',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeMode,
            routerConfig: AppRouter.router,
          );
        },
      ),
    );
  }
}
