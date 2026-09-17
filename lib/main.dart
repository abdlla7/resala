import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'blocs/auth/auth_bloc.dart';
import 'blocs/settings/settings_cubit.dart';
import 'blocs/settings/settings_state.dart';
import 'blocs/subscription/subscription_cubit.dart';
import 'constants/app_strings.dart';
import 'firebase_options.dart';
import 'router/app_router.dart';
import 'services/firestore_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── Firebase initialisation with error boundary ───────────────────────────
  // If Firebase fails to initialise (e.g. missing google-services.json,
  // network issue on first launch) we render a retryable error screen instead
  // of silently crashing or hanging on a white screen.
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e, st) {
    debugPrint('[main] Firebase.initializeApp failed: $e\n$st');
    runApp(const _FirebaseErrorApp());
    return;
  }

  // Initialise settings (loads theme preference from SharedPreferences).
  final settingsCubit = SettingsCubit();
  await settingsCubit.loadSettings();

  // Create AuthBloc and immediately kick off the cold-start auth check.
  final authBloc = AuthBloc()..add(const CheckAuthStatusRequested());

  // SubscriptionCubit is global so the dashboard banner AND the playlist
  // locking guards share one cubit instance without prop-drilling.
  final subscriptionCubit = SubscriptionCubit(
    firestoreService: FirestoreService(),
  );

  // Build the router — holds a reference to authBloc for the redirect guard.
  final router = createRouter(authBloc);

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<SettingsCubit>.value(value: settingsCubit),
        // AuthBloc is global so any screen can read the current UserEntity.
        BlocProvider<AuthBloc>.value(value: authBloc),
        // SubscriptionCubit is global so lock guards work on any screen.
        BlocProvider<SubscriptionCubit>.value(value: subscriptionCubit),
      ],
      child: _AppLifecycle(
        authBloc: authBloc,
        subscriptionCubit: subscriptionCubit,
        child: ResalaApp(router: router),
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Lifecycle owner for global BLoC subscriptions
// ─────────────────────────────────────────────────────────────────────────────

/// Owns the cross-cubit [StreamSubscription] that bridges [AuthBloc] state
/// changes to [SubscriptionCubit] actions.
///
/// Placing this in a [StatefulWidget] ensures the subscription is
/// **cancelled** when the widget tree is unmounted, preventing the memory
/// leak that would occur if the subscription were held at the top-level
/// [main] function with no cancel path.
class _AppLifecycle extends StatefulWidget {
  const _AppLifecycle({
    required this.authBloc,
    required this.subscriptionCubit,
    required this.child,
  });

  final AuthBloc authBloc;
  final SubscriptionCubit subscriptionCubit;
  final Widget child;

  @override
  State<_AppLifecycle> createState() => _AppLifecycleState();
}

class _AppLifecycleState extends State<_AppLifecycle> {
  late final StreamSubscription<AuthState> _authSubscription;

  @override
  void initState() {
    super.initState();
    // When auth resolves to Authenticated, immediately evaluate subscription.
    // This subscription is cancelled in dispose(), preventing memory leaks.
    _authSubscription = widget.authBloc.stream.listen((state) {
      if (state is Authenticated) {
        widget.subscriptionCubit.checkSubscriptionStatus(state.user);
      } else if (state is Unauthenticated) {
        widget.subscriptionCubit.reset();
      }
    });
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

// ─────────────────────────────────────────────────────────────────────────────
// Main application widget
// ─────────────────────────────────────────────────────────────────────────────

class ResalaApp extends StatelessWidget {
  const ResalaApp({super.key, required this.router});

  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, settings) {
        return MaterialApp.router(
          title: 'أكاديمية التميز',
          debugShowCheckedModeBanner: false,

          theme: settings.currentThemeData,

          // Hardcoded Arabic locale & RTL layout.
          locale: const Locale('ar'),
          supportedLocales: const [Locale('ar')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],

          builder: (context, child) => Directionality(
            textDirection: TextDirection.rtl,
            child: child!,
          ),

          routerConfig: router,
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Firebase initialisation error boundary
// ─────────────────────────────────────────────────────────────────────────────

/// Shown when [Firebase.initializeApp] throws, giving the user a clear
/// message and a retry button instead of a blank / crashed screen.
class _FirebaseErrorApp extends StatelessWidget {
  const _FirebaseErrorApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: _FirebaseErrorScreen(),
    );
  }
}

class _FirebaseErrorScreen extends StatelessWidget {
  const _FirebaseErrorScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.cloud_off_rounded,
                size: 72,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 24),
              Text(
                AppStrings.errorOccurred,
                style: GoogleFonts.lexend(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                AppStrings.networkError,
                style: const TextStyle(fontSize: 15),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              FilledButton.icon(
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('إعادة المحاولة'),
                onPressed: () {
                  // Restart the app by re-invoking main.
                  // On mobile this is the lightest restart without killing
                  // the process; the user can also force-restart manually.
                  main();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
