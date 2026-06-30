import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:learning_management_system_trainer/app/pages/auth/login_page.dart';
import 'package:learning_management_system_trainer/app/pages/dashboard/dashboard_page.dart';
import 'package:learning_management_system_trainer/app/pages/courses/courses_page.dart';
import 'package:learning_management_system_trainer/app/pages/courses/create_course_page.dart';
import 'package:learning_management_system_trainer/app/pages/courses/edit_course_page.dart';
import 'package:learning_management_system_trainer/app/pages/settings/trainers_page.dart';
import 'package:learning_management_system_trainer/app/widgets/common/admin_shell.dart';
import 'package:learning_management_system_trainer/domain/repositories/admin_auth_repository.dart';
import 'package:learning_management_system_trainer/domain/services/service_locator.dart';

import '../../domain/entities/admin_role.dart';

final authStateProvider = StreamProvider((ref) => getIt<AdminAuthRepository>().authStateChanges);

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/dashboard',
    refreshListenable: GoRouterRefreshStream(getIt<AdminAuthRepository>().authStateChanges),
    redirect: (context, state) {
      final isLoggedIn = authState.value != null;
      final isLoggingIn = state.matchedLocation == '/login';

      if (!isLoggedIn && !isLoggingIn) return '/login';
      if (isLoggedIn && isLoggingIn) return '/dashboard';

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      ShellRoute(
        builder: (context, state, child) => AdminShell(child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const DashboardPage(),
          ),
          GoRoute(
            path: '/courses',
            builder: (context, state) => const CoursesPage(),
            routes: [
              GoRoute(
                path: 'create',
                builder: (context, state) => const CreateCoursePage(),
              ),
              GoRoute(
                path: ':id',
                builder: (context, state) => EditCoursePage(id: state.pathParameters['id']!),
              ),
            ],
          ),
          GoRoute(
            path: '/trainers',
            builder: (context, state) => const TrainersPage(),
            redirect: (context, state) {
              final authState = ref.read(authStateProvider);
              final user = authState.value;
              if (user?.role != AdminRole.superAdmin) {
                return '/dashboard';
              }
              return null;
            },
          ),
        ],
      ),
    ],
  );
});

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
