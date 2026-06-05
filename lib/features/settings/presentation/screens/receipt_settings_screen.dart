import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:order/core/theme/app_colors.dart';
import 'package:order/features/settings/domain/entities/shop_config.dart';
import 'package:order/features/settings/presentation/providers/settings_providers.dart';

class ReceiptSettingsScreen extends ConsumerStatefulWidget {
  const ReceiptSettingsScreen({super.key});

  @override
  ConsumerState<ReceiptSettingsScreen> createState() => _ReceiptSettingsScreenState();
}

class _ReceiptSettingsScreenState extends ConsumerState<ReceiptSettingsScreen> {
  final _headerController = TextEditingController();
  final _footerController = TextEditingController();
  bool _isSplitPrinting = false;
  bool _isSaving = false;
  ShopConfig? _loadedConfig;

  @override
  void dispose() {
    _headerController.dispose();
    _footerController.dispose();
    super.dispose();
  }

  void _initializeFields(ShopConfig config) {
    if (_loadedConfig?.id != config.id) {
      _loadedConfig = config;
      _headerController.text = config.receiptHeader;
      _footerController.text = config.receiptFooter;
      _isSplitPrinting = config.isSplitPrintingEnabled;
    }
  }

  Future<void> _saveConfig() async {
    final current = _loadedConfig;
    if (current == null) return;

    setState(() => _isSaving = true);

    final updated = current.copyWith(
      receiptHeader: _headerController.text.trim(),
      receiptFooter: _footerController.text.trim(),
      isSplitPrintingEnabled: _isSplitPrinting,
    );

    try {
      await ref.read(settingsRepositoryProvider).updateShopConfig(updated);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Οι ρυθμίσεις απόδειξης αποθηκεύτηκαν!'), backgroundColor: AppColors.success),
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
  Widget build(BuildContext context) {
    final shopConfig = ref.watch(shopConfigStreamProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBgColor = isDark ? AppColors.surfaceDarkElevated : AppColors.surfaceLightElevated;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ρυθμίσεις Απόδειξης'),
      ),
      body: SafeArea(
        child: shopConfig.when(
          data: (config) {
            _initializeFields(config);
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Card(
                    color: cardBgColor,
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Εμφάνιση Απόδειξης & Εκτύπωση',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary),
                          ),
                          const SizedBox(height: 24),
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Split Printing', style: TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: const Text('Διαχωρισμός εκτυπώσεων Μπαρ / Κουζίνα'),
                            value: _isSplitPrinting,
                            onChanged: (val) => setState(() => _isSplitPrinting = val),
                            activeColor: AppColors.primary,
                          ),
                          const Divider(height: 32),
                          TextFormField(
                            controller: _headerController,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              labelText: 'Κεφαλίδα Απόδειξης (Header)',
                              hintText: 'π.χ. Όνομα καταστήματος, ΑΦΜ...',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _footerController,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              labelText: 'Υποσέλιδο Απόδειξης (Footer)',
                              hintText: 'π.χ. Ευχαριστούμε που μας προτιμήσατε!',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 32),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              FilledButton.icon(
                                onPressed: _isSaving ? null : _saveConfig,
                                icon: _isSaving
                                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                    : const Icon(Icons.save),
                                label: const Text('Αποθήκευση'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err')),
        ),
      ),
    );
  }
}
