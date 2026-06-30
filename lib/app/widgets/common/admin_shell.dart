import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:learning_management_system_trainer/app/routing/app_router.dart';
import 'package:learning_management_system_trainer/domain/entities/admin_role.dart';
import 'package:learning_management_system_trainer/domain/repositories/admin_auth_repository.dart';
import 'package:learning_management_system_trainer/domain/services/service_locator.dart';

class AdminShell extends ConsumerWidget {
  final Widget child;

  const AdminShell({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDesktop = MediaQuery.of(context).size.width >= 1100;
    final isTablet = MediaQuery.of(context).size.width >= 700 && MediaQuery.of(context).size.width < 1100;

    return Scaffold(
      appBar: !isDesktop
          ? AppBar(
              title: const Text('Civil Entrepreneurship Admin'),
            )
          : null,
      drawer: !isDesktop ? const AppDrawer() : null,
      body: Row(
        children: [
          if (isDesktop) const AppDrawer(isPermanent: true),
          Expanded(
            child: Column(
              children: [
                if (isDesktop) const _AdminTopBar(),
                Expanded(child: child),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AppDrawer extends ConsumerWidget {
  final bool isPermanent;

  const AppDrawer({super.key, this.isPermanent = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final user = authState.value;
    final isSuperAdmin = user?.role == AdminRole.superAdmin;

    return Drawer(
      elevation: isPermanent ? 0 : 16,
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'CE ADMIN',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  if (user != null)
                    Text(
                      user.role.displayName,
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                ],
              ),
            ),
          ),
          _DrawerItem(
            icon: Icons.dashboard,
            label: 'Dashboard',
            route: '/dashboard',
          ),
          _DrawerItem(
            icon: Icons.book,
            label: 'Courses',
            route: '/courses',
          ),
          if (isSuperAdmin)
            _DrawerItem(
              icon: Icons.people,
              label: 'Trainers',
              route: '/trainers',
            ),
          const Spacer(),
          _DrawerItem(
            icon: Icons.logout,
            label: 'Logout',
            onTap: () {
              getIt<AdminAuthRepository>().logout();
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? route;
  final VoidCallback? onTap;

  const _DrawerItem({
    required this.icon,
    required this.label,
    this.route,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final currentRoute = GoRouterState.of(context).matchedLocation;
    final isSelected = route != null && currentRoute.startsWith(route!);

    return ListTile(
      leading: Icon(icon, color: isSelected ? Theme.of(context).colorScheme.primary : null),
      title: Text(
        label,
        style: TextStyle(
          color: isSelected ? Theme.of(context).colorScheme.primary : null,
          fontWeight: isSelected ? FontWeight.bold : null,
        ),
      ),
      selected: isSelected,
      onTap: () {
        if (onTap != null) {
          onTap!();
        } else if (route != null) {
          context.go(route!);
          if (Scaffold.of(context).isDrawerOpen) {
            Navigator.pop(context);
          }
        }
      },
    );
  }
}

class _AdminTopBar extends ConsumerWidget {
  const _AdminTopBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final user = authState.value;

    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                user?.name ?? 'Admin Name',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              if (user != null)
                Text(
                  user.role.displayName,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
            ],
          ),
          const SizedBox(width: 12),
          CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: Text(
              user?.name[0].toUpperCase() ?? 'A',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
