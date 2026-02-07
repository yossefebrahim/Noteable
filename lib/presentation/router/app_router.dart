import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../services/di/service_locator.dart';
import '../providers/note_detail_view_model.dart';
import '../screens/folders/folders_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/note_detail/note_detail_screen.dart';
import '../screens/search/search_screen.dart';
import '../screens/settings/settings_screen.dart';

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
        pageBuilder: (BuildContext context, GoRouterState state) {
          // Handle internal navigation with extra parameter (for creating new notes or editing)
          final String? noteId = state.extra as String?;
          return _animatedPage(
            state: state,
            child: ChangeNotifierProvider<NoteEditorViewModel>(
              create: (_) => sl<NoteEditorViewModel>(),
              child: NoteDetailScreen(noteId: noteId),
            ),
          );
        },
      ),
      GoRoute(
        path: '/note-detail/:id',
        pageBuilder: (BuildContext context, GoRouterState state) {
          // Handle deep links with note ID in the path (for widget-to-app navigation)
          final String? noteId = state.pathParameters['id'];
          return _animatedPage(
            state: state,
            child: ChangeNotifierProvider<NoteEditorViewModel>(
              create: (_) => sl<NoteEditorViewModel>(),
              child: NoteDetailScreen(noteId: noteId),
            ),
          );
        },
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
