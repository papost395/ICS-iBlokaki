import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:order/core/theme/app_colors.dart';
import 'package:order/features/settings/presentation/providers/settings_providers.dart';

class AppSettingsScreen extends ConsumerStatefulWidget {
  const AppSettingsScreen({super.key});

  @override
  ConsumerState<AppSettingsScreen> createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends ConsumerState<AppSettingsScreen> {
  final _appIdController = TextEditingController();
  final _appKeyController = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCloudKeys();
    });
  }

  Future<void> _loadCloudKeys() async {
    final keys = await ref.read(settingsRepositoryProvider).getCloudKeys();
    if (mounted) {
      setState(() {
        _appIdController.text = keys['appId'] ?? '';
        _appKeyController.text = keys['appKey'] ?? '';
      });
    }
  }

  Future<void> _saveCloudKeys() async {
    setState(() => _isSaving = true);
    try {
      await ref.read(settingsRepositoryProvider).setCloudKeys(
        _appIdController.text.trim(),
        _appKeyController.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Τα κλειδιά API αποθηκεύτηκαν!'), backgroundColor: AppColors.success),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Σφάλμα: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _appIdController.dispose();
    _appKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeNotifierProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBgColor = isDark ? AppColors.surfaceDarkElevated : AppColors.surfaceLightElevated;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ρυθμίσεις Εφαρμογής'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // API Keys Card
                  Card(
                    color: cardBgColor,
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Sunmi Cloud Credentials',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
                          ),
                          const SizedBox(height: 24),
                          TextFormField(
                            controller: _appIdController,
                            decoration: const InputDecoration(
                              labelText: 'Sunmi App ID',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _appKeyController,
                            obscureText: true,
                            decoration: const InputDecoration(
                              labelText: 'Sunmi App Key',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              FilledButton.icon(
                                onPressed: _isSaving ? null : _saveCloudKeys,
                                icon: _isSaving
                                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                    : const Icon(Icons.save),
                                label: const Text('Αποθήκευση Κλειδιών'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Device Preferences Card
                  Card(
                    color: cardBgColor,
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                iconSize: 32,
                                icon: Icon(themeMode == ThemeMode.light || (themeMode == ThemeMode.system && !isDark) ? Icons.dark_mode : Icons.light_mode),
                                tooltip: 'Αλλαγή Εμφάνισης (Theme)',
                                onPressed: () {
                                  final isCurrentlyLight = themeMode == ThemeMode.light || (themeMode == ThemeMode.system && !isDark);
                                  ref.read(themeModeNotifierProvider.notifier).setThemeMode(isCurrentlyLight ? ThemeMode.dark : ThemeMode.light);
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
