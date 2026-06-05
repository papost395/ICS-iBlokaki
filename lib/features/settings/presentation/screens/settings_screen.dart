import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:order/core/theme/app_colors.dart';
import 'package:order/features/auth/presentation/providers/auth_providers.dart';
import 'package:order/features/home/presentation/widgets/main_navigation_shell.dart';
import 'package:order/features/printing/presentation/screens/manage_printers_screen.dart';
import 'package:order/features/settings/presentation/screens/app_settings_screen.dart';
import 'package:order/features/settings/presentation/screens/receipt_settings_screen.dart';
import 'package:order/features/settings/presentation/screens/ecr_settings_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBgColor = isDark ? AppColors.surfaceDarkElevated : AppColors.surfaceLightElevated;
    final shopId = ref.watch(currentShopIdProvider) ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ρυθμίσεις'),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            ref.read(scaffoldKeyProvider).currentState?.openDrawer();
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [

                  const SizedBox(height: 8),
                  
                  // Printers Card
                  _buildDashboardCard(
                    context: context,
                    title: 'ΕΚΤΥΠΩΤΕΣ',
                    subtitle: 'Διαχείριση εκτυπωτών δικτύου',
                    icon: Icons.print_outlined,
                    cardBgColor: cardBgColor,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ManagePrintersScreen(shopId: shopId)),
                      );
                    },
                  ),
                  const SizedBox(height: 12),

                  // Receipt Settings Card
                  _buildDashboardCard(
                    context: context,
                    title: 'ΡΥΘΜΙΣΕΙΣ ΑΠΟΔΕΙΞΗΣ',
                    subtitle: 'Κεφαλίδα, υποσέλιδα και διαχωριστή εκτύπωση',
                    icon: Icons.receipt_long_outlined,
                    cardBgColor: cardBgColor,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ReceiptSettingsScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 12),

                  // ECR Settings Card
                  _buildDashboardCard(
                    context: context,
                    title: 'ΤΑΜΕΙΑΚΗ ΜΗΧΑΝΗ',
                    subtitle: 'Ρυθμίσεις IP, τύπου και θύρας (POS)',
                    icon: Icons.point_of_sale_outlined,
                    cardBgColor: cardBgColor,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const EcrSettingsScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 12),

                  // App Settings Card
                  _buildDashboardCard(
                    context: context,
                    title: 'ΡΥΘΜΙΣΕΙΣ ΕΦΑΡΜΟΓΗΣ',
                    subtitle: 'Θέμα εμφάνισης, API credentials Sunmi',
                    icon: Icons.settings_applications_outlined,
                    cardBgColor: cardBgColor,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AppSettingsScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color cardBgColor,
    required VoidCallback onTap,
  }) {
    return Card(
      color: cardBgColor,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
          child: Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 28),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
