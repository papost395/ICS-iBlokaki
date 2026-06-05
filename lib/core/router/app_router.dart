import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:order/core/router/route_names.dart';
import 'package:order/features/auth/presentation/providers/auth_providers.dart';
import 'package:order/features/auth/presentation/screens/login_screen.dart';
import 'package:order/features/home/presentation/widgets/main_navigation_shell.dart';
import 'package:order/features/tables/presentation/screens/tables_screen.dart';
import 'package:order/features/orders/presentation/screens/order_screen.dart';
import 'package:order/features/products/presentation/screens/products_screen.dart';
import 'package:order/core/providers/device_config_provider.dart';
import 'package:order/features/auth/presentation/screens/setup_screen.dart';
import 'package:order/features/home/presentation/screens/home_screen.dart';
import 'package:order/features/products/presentation/screens/csv_upload_screen.dart';
import 'package:order/features/printing/presentation/screens/printers_screen.dart';
import 'package:order/features/settings/presentation/screens/settings_screen.dart';

import 'package:order/features/orders/presentation/screens/takeaway_screen.dart';

part 'app_router.g.dart';

@riverpod
GoRouter appRouter(Ref ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/home',
    redirect: (context, state) {
      final config = ref.watch(deviceConfigNotifierProvider);
      final isConfigured = config.isConfigured;
      final localAuth = ref.watch(localAuthNotifierProvider);
      final isLocalUnlocked = localAuth.role != LocalRole.none;

      final isSetupRoute = state.matchedLocation == '/setup';
      final isLoginRoute = state.matchedLocation == '/login';

      if (!isConfigured && !isSetupRoute) return '/setup';
      if (isConfigured) {
        if (!isLocalUnlocked && !isLoginRoute && !isSetupRoute) return '/login';
        if (isLocalUnlocked && (isLoginRoute || isSetupRoute)) return '/home';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/setup',
        name: RouteNames.setup,
        builder: (context, state) => const SetupScreen(),
      ),
      GoRoute(
        path: '/login',
        name: RouteNames.login,
        builder: (context, state) => const LoginScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => MainNavigationShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            name: RouteNames.home,
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/takeaway',
            name: RouteNames.takeaway,
            builder: (context, state) => const TakeawayScreen(),
          ),
          GoRoute(
            path: '/tables',
            name: RouteNames.tables,
            builder: (context, state) => const TablesScreen(),
            routes: [
              GoRoute(
                path: ':tableId/order',
                name: RouteNames.order,
                builder: (context, state) {
                  final tableId = state.pathParameters['tableId']!;
                  return OrderScreen(key: ValueKey(tableId), tableId: tableId);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/products',
            name: RouteNames.products,
            builder: (context, state) => const ProductsScreen(),
          ),
          GoRoute(
            path: '/printers',
            name: RouteNames.printers,
            builder: (context, state) => const PrintersScreen(),
          ),
          GoRoute(
            path: '/settings',
            name: RouteNames.settings,
            builder: (context, state) => const SettingsScreen(),
          ),
          GoRoute(
            path: '/csv-upload',
            name: RouteNames.csvUpload,
            builder: (context, state) => const CsvUploadScreen(),
          ),
        ],
      ),
    ],
  );
}
