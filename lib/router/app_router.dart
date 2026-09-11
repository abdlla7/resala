import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../blocs/auth/auth_bloc.dart';
import '../blocs/playlists/playlists_cubit.dart';
import '../models/playlist_model.dart';
import '../repositories/playlists_repository.dart';
import '../screens/auth/complete_profile_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/learning/learning_path_screen.dart';
import '../screens/learning/lesson_screen.dart';
import '../screens/learning/quiz_screen.dart';
import '../screens/playlists/playlist_detail_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/welcome_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Router factory
// ─────────────────────────────────────────────────────────────────────────────

/// Creates the app's [GoRouter] wired to [authBloc].
///
/// The router listens to the bloc's stream and re-evaluates the redirect
/// guard every time [AuthBloc] emits a new state, so navigation is fully
/// driven by the auth state machine.
GoRouter createRouter(AuthBloc authBloc) {
  return GoRouter(
    initialLocation: '/login',

    // Refresh the router whenever AuthBloc emits a new state.
    refreshListenable: _BlocListenerNotifier(stream: authBloc.stream),

    // ── Auth guard ───────────────────────────────────────────────────────────
    redirect: (context, routerState) {
      final authState = authBloc.state;
      final location = routerState.matchedLocation;

      final isOnAuthPage = location == '/' || location == '/login';
      final isOnProfilePage = location == '/complete-profile';

      // While the bloc is initialising / loading, stay put.
      if (authState is AuthInitial || authState is AuthLoading) {
        return null;
      }

      // No user → force to login.
      if (authState is Unauthenticated || authState is AuthFailure) {
        return isOnAuthPage ? null : '/login';
      }

      // Authenticated but profile not complete → force to /complete-profile.
      if (authState is ProfileIncomplete) {
        return isOnProfilePage ? null : '/complete-profile';
      }

      // Fully authenticated → don't let them see the login / profile screens.
      if (authState is Authenticated) {
        if (isOnAuthPage || isOnProfilePage) return '/dashboard';
        return null;
      }

      return null;
    },

    // ── Routes ───────────────────────────────────────────────────────────────
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/complete-profile',
        builder: (context, state) => const CompleteProfileScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) {
          // PlaylistsCubit is scoped to the /dashboard route so it's
          // automatically disposed when the user navigates away.
          // Swap LocalPlaylistsRepository for a network/Firestore
          // implementation here — zero widget changes required.
          return BlocProvider(
            create: (_) => PlaylistsCubit(
              repository: LocalPlaylistsRepository(),
            ),
            child: const DashboardScreen(),
          );
        },
      ),
      GoRoute(
        path: '/playlist-detail',
        // The PlaylistModel is passed via GoRouter's `extra` parameter.
        // Usage: context.push('/playlist-detail', extra: playlistModel);
        builder: (context, state) {
          final playlist = state.extra as PlaylistModel;
          return PlaylistDetailScreen(playlist: playlist);
        },
      ),
      GoRoute(
        path: '/learning-path',
        builder: (context, state) => const LearningPathScreen(),
      ),
      GoRoute(
        path: '/quiz',
        builder: (context, state) => const QuizScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/lesson',
        builder: (context, state) => const LessonScreen(),
      ),
    ],
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// ChangeNotifier adapter for BLoC streams
// ─────────────────────────────────────────────────────────────────────────────

/// Converts any [Stream] into a [ChangeNotifier] so GoRouter's
/// [refreshListenable] can react to BLoC state changes.
class _BlocListenerNotifier extends ChangeNotifier {
  _BlocListenerNotifier({required Stream<dynamic> stream}) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
