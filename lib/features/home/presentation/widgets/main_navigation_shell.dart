import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:order/core/theme/app_colors.dart';
import 'package:order/features/auth/presentation/providers/auth_providers.dart';
import 'package:order/features/settings/presentation/providers/settings_providers.dart';
import 'package:flutter_svg/flutter_svg.dart';

final scaffoldKeyProvider = Provider<GlobalKey<ScaffoldState>>((ref) {
  return GlobalKey<ScaffoldState>();
});

class MainNavigationShell extends ConsumerWidget {
  const MainNavigationShell({
    required this.child,
    super.key,
  });

  final Widget child;

  int _getSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/tables')) return 1;
    if (location.startsWith('/products')) return 2;
    if (location.startsWith('/csv-upload')) return 2;
    if (location.startsWith('/settings')) return 3;
    if (location.startsWith('/printers')) return 3;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/tables');
        break;
      case 2:
        context.go('/products');
        break;
      case 3:
        context.go('/settings');
        break;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localAuth = ref.watch(localAuthNotifierProvider);
    final selectedIndex = _getSelectedIndex(context);
    final scaffoldKey = ref.watch(scaffoldKeyProvider);
    final shopConfig = ref.watch(shopConfigStreamProvider);

    final businessName = shopConfig.whenOrNull(
      data: (config) => config.receiptHeader.trim().isNotEmpty
          ? config.receiptHeader.split('\n').first.trim()
          : null,
    ) ?? 'Κατάστημα';

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final drawerBg = isDark ? AppColors.surfaceDarkElevated : AppColors.surfaceLightElevated;
    final headerBg = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final textColor = isDark ? Colors.white : AppColors.textDark;
    final textSecondary = isDark ? Colors.white70 : AppColors.textDarkSecondary;

    return Scaffold(
      key: scaffoldKey,
      drawer: SizedBox(
        width: 240,
        child: Drawer(
          backgroundColor: drawerBg,
          child: Column(
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: headerBg,
                  border: Border(
                    bottom: BorderSide(
                      color: isDark ? Colors.white10 : Colors.black12,
                      width: 1,
                    ),
                  ),
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          SvgPicture.asset(
                            'assets/images/logo.svg',
                            width: 32,
                            height: 32,
                            colorFilter: ColorFilter.mode(
                              isDark ? Colors.white.withOpacity(0.9) : Colors.black.withOpacity(0.8),
                              BlendMode.srcIn,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'iBlokaki',
                            style: TextStyle(
                              color: textColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Text(
                        businessName,
                        style: TextStyle(
                          color: textColor.withOpacity(0.9),
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        localAuth.waiterName?.toUpperCase() ?? '',
                        style: TextStyle(
                          color: textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              ListTile(
                leading: Icon(Icons.home_outlined, color: selectedIndex == 0 ? AppColors.primary : textSecondary),
                title: Text('Αρχική', style: TextStyle(color: selectedIndex == 0 ? AppColors.primary : textColor, fontWeight: selectedIndex == 0 ? FontWeight.bold : FontWeight.normal)),
                selected: selectedIndex == 0,
                selectedTileColor: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.04),
                onTap: () {
                  Navigator.pop(context);
                  _onItemTapped(0, context);
                },
              ),
              ListTile(
                leading: Icon(Icons.table_restaurant_outlined, color: selectedIndex == 1 ? AppColors.primary : textSecondary),
                title: Text('Τραπέζια', style: TextStyle(color: selectedIndex == 1 ? AppColors.primary : textColor, fontWeight: selectedIndex == 1 ? FontWeight.bold : FontWeight.normal)),
                selected: selectedIndex == 1,
                selectedTileColor: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.04),
                onTap: () {
                  Navigator.pop(context);
                  _onItemTapped(1, context);
                },
              ),
              ListTile(
                leading: Icon(Icons.shopping_bag_outlined, color: selectedIndex == 2 ? AppColors.primary : textSecondary),
                title: Text('Προϊόντα', style: TextStyle(color: selectedIndex == 2 ? AppColors.primary : textColor, fontWeight: selectedIndex == 2 ? FontWeight.bold : FontWeight.normal)),
                selected: selectedIndex == 2,
                selectedTileColor: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.04),
                onTap: () {
                  Navigator.pop(context);
                  _onItemTapped(2, context);
                },
              ),
              ListTile(
                leading: Icon(Icons.settings_outlined, color: selectedIndex == 3 ? AppColors.primary : textSecondary),
                title: Text('Ρυθμίσεις', style: TextStyle(color: selectedIndex == 3 ? AppColors.primary : textColor, fontWeight: selectedIndex == 3 ? FontWeight.bold : FontWeight.normal)),
                selected: selectedIndex == 3,
                selectedTileColor: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.04),
                onTap: () {
                  Navigator.pop(context);
                  _onItemTapped(3, context);
                },
              ),
              const Spacer(),
              Divider(color: isDark ? Colors.white10 : Colors.black12, height: 1),
              ListTile(
                leading: const Icon(Icons.lock_outline, color: AppColors.error),
                title: const Text('Κλείδωμα', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w500)),
                onTap: () async {
                  Navigator.pop(context);
                  ref.read(localAuthNotifierProvider.notifier).logout();
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      body: child,
    );
  }
}
