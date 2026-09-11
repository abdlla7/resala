import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:go_router/go_router.dart';

import 'blocs/auth/auth_bloc.dart';
import 'blocs/settings/settings_cubit.dart';
import 'blocs/settings/settings_state.dart';
import 'blocs/subscription/subscription_cubit.dart';
import 'firebase_options.dart';
import 'router/app_router.dart';
import 'services/firestore_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

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

  // When auth resolves to Authenticated, immediately evaluate subscription.
  authBloc.stream.listen((state) {
    if (state is Authenticated) {
      subscriptionCubit.checkSubscriptionStatus(state.user);
    } else if (state is Unauthenticated) {
      subscriptionCubit.reset();
    }
  });

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
      child: ResalaApp(router: router),
    ),
  );
}

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