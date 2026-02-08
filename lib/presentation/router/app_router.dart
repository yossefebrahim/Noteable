import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:noteable_app/presentation/providers/folder_provider.dart';
import 'package:noteable_app/presentation/providers/template_view_model.dart';
import 'package:provider/provider.dart';

import '../../services/di/service_locator.dart';
import '../providers/note_detail_view_model.dart';
import '../screens/folders/folders_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/note_detail/note_detail_screen.dart';
import '../screens/search/search_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/templates/template_editor_screen.dart';
import '../screens/templates/templates_screen.dart';

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        pageBuilder: (BuildContext context, GoRouterState state) =>
            _animatedPage(state: state, child: const HomeScreen()),
      ),
      GoRoute(
        path: '/note-detail',
        pageBuilder: (BuildContext context, GoRouterState state) => _animatedPage(
          state: state,
          child: ChangeNotifierProvider<TemplateViewModel>(
            create: (_) => sl<TemplateViewModel>()..load(),
            child: ChangeNotifierProvider<NoteEditorViewModel>(
              create: (_) => sl<NoteEditorViewModel>(),
              child: NoteDetailScreen(noteId: state.extra as String?),
            ),
          ),
        ),
      ),
      GoRoute(
        path: '/folders',
        pageBuilder: (BuildContext context, GoRouterState state) =>
            _animatedPage(state: state, child: const FolderScreen()),
      ),
      GoRoute(
        path: '/search',
        pageBuilder: (BuildContext context, GoRouterState state) =>
            _animatedPage(state: state, child: const SearchScreen()),
      ),
      GoRoute(
        path: '/settings',
        pageBuilder: (BuildContext context, GoRouterState state) =>
            _animatedPage(state: state, child: const SettingsScreen()),
      ),
      GoRoute(
        path: '/templates',
        pageBuilder: (BuildContext context, GoRouterState state) => _animatedPage(
          state: state,
          child: ChangeNotifierProvider<TemplateViewModel>(
            create: (_) => sl<TemplateViewModel>()..load(),
            child: const TemplatesScreen(),
          ),
        ),
      ),
      GoRoute(
        path: '/template-editor',
        pageBuilder: (BuildContext context, GoRouterState state) => _animatedPage(
          state: state,
          child: ChangeNotifierProvider<TemplateViewModel>(
            create: (_) => sl<TemplateViewModel>()..load(),
            child: ChangeNotifierProvider<FolderViewModel>(
              create: (_) => FolderViewModel(),
              child: TemplateEditorScreen(templateId: state.extra as String?),
            ),
          ),
        ),
      ),
    ],
  );

  static CustomTransitionPage<void> _animatedPage({
    required GoRouterState state,
    required Widget child,
  }) {
    return CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 300),
      transitionsBuilder:
          (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) {
            final Animatable<Offset> tween = Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).chain(CurveTween(curve: Curves.easeInOut));

            return SlideTransition(position: animation.drive(tween), child: child);
          },
    );
  }
}
