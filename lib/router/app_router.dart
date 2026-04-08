import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../screens/learning/lesson_screen.dart';
// استيراد الشاشات الخاصة بك
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/learning/learning_path_screen.dart';
import '../screens/learning/quiz_screen.dart';
import '../screens/welcome_screen.dart';
import '../screens/settings/settings_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',

  // 1. مراقبة حالة تسجيل الدخول: تجعل الراوتر يعيد بناء نفسه فور تغير حالة المستخدم
  refreshListenable: GoRouterRefreshStream(
    FirebaseAuth.instance.authStateChanges(),
  ),

  // 2. منطق التوجيه التلقائي (Redirect)
  redirect: (context, state) {
    final bool loggedIn = FirebaseAuth.instance.currentUser != null;

    // تحديد إذا كان المستخدم حالياً في إحدى شاشات المصادقة
    final bool isAuthPage =
        state.matchedLocation == '/' ||
        state.matchedLocation == '/login' ||
        state.matchedLocation == '/signup';

    // الحالة أ: مستخدم غير مسجل دخول ويحاول دخول صفحة داخلية -> ارجعه للترحيب
    if (!loggedIn && !isAuthPage) {
      return '/';
    }

    // الحالة ب: مستخدم مسجل دخول بالفعل ويحاول فتح شاشة الترحيب أو اللوج إن -> واديه الداشبورد
    if (loggedIn && isAuthPage) {
      return '/dashboard';
    }

    // الحالة ج: اترك المستخدم يكمل لمساره المختار (لا يوجد توجيه إجباري)
    return null;
  },

  routes: [
    GoRoute(path: '/', builder: (context, state) => const WelcomeScreen()),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/signup', builder: (context, state) => const SignupScreen()),
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const DashboardScreen(),
    ),
    GoRoute(
      path: '/learning-path',
      builder: (context, state) => const LearningPathScreen(),
    ),
    GoRoute(path: '/quiz', builder: (context, state) => const QuizScreen()),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(path: '/lesson', builder: (context, state) => const LessonScreen()),
  ],
);

/// كلاس مساعد لتحويل [Stream] إلى [Listenable]
/// لكي يفهمه الـ GoRouter ويقوم بتحديث المسارات فوراً
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
