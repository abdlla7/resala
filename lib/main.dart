import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'router/app_router.dart';
import 'controllers/settings_controller.dart';
import 'l10n/app_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final settingsController = SettingsController();
  await settingsController.loadSettings();

  runApp(
    ChangeNotifierProvider.value(
      value: settingsController,
      child: const ResalaApp(),
    ),
  );
}

class ResalaApp extends StatelessWidget {
  const ResalaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsController>(
      builder: (context, settings, child) {
        return MaterialApp.router(
          title: 'Resala Volunteer',
          debugShowCheckedModeBanner: false,

          // Theme Configuration
          theme: settings.currentThemeData,

          // Localization Configuration
          locale: settings.currentLocale,
          supportedLocales: const [Locale('en'), Locale('ar')],
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],

          routerConfig: appRouter,
        );
      },
    );
  }
}
