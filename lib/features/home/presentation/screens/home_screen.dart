import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:order/core/theme/app_colors.dart';
import 'package:order/features/home/presentation/widgets/main_navigation_shell.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.surfaceDarkElevated : AppColors.surfaceLightElevated;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Αρχική'),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            ref.read(scaffoldKeyProvider).currentState?.openDrawer();
          },
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildBigButton(
                  context: context,
                  title: 'ΤΡΑΠΕΖΙΑ',
                  icon: Icons.table_restaurant,
                  color: Colors.blueAccent,
                  cardColor: cardColor,
                  onTap: () {
                    context.go('/tables');
                  },
                ),
                const SizedBox(height: 32),
                _buildBigButton(
                  context: context,
                  title: 'ΠΑΚΕΤΟ / ΛΙΑΝΙΚΗ',
                  icon: Icons.takeout_dining,
                  color: Colors.orangeAccent,
                  cardColor: cardColor,
                  onTap: () {
                    context.go('/takeaway');
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBigButton({
    required BuildContext context,
    required String title,
    String? badge,
    required IconData icon,
    required Color color,
    required Color cardColor,
    bool enabled = true,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Opacity(
        opacity: enabled ? 1.0 : 0.4,
        child: Card(
          color: cardColor,
          elevation: enabled ? 4 : 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: color.withOpacity(0.5), width: 2),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: enabled ? onTap : null,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, size: 80, color: color),
                    const SizedBox(height: 16),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ],
                ),
                if (badge != null)
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: color.withOpacity(0.5)),
                      ),
                      child: Text(
                        badge,
                        style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
