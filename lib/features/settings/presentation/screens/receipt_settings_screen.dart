import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
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
  final _stationController = TextEditingController();
  bool _isSplitPrinting = false;
  bool _isSaving = false;
  String? _logoPath;
  ShopConfig? _loadedConfig;

  @override
  void dispose() {
    _headerController.dispose();
    _footerController.dispose();
    _stationController.dispose();
    super.dispose();
  }

  void _initializeFields(ShopConfig config) {
    if (_loadedConfig?.id != config.id) {
      _loadedConfig = config;
      _headerController.text = config.receiptHeader;
      _footerController.text = config.receiptFooter;
      _stationController.text = config.stationName ?? '';
      _isSplitPrinting = config.isSplitPrintingEnabled;
      _logoPath = config.logoPath;
    }
  }

  Future<void> _saveConfig() async {
    final current = _loadedConfig;
    if (current == null) return;

    setState(() => _isSaving = true);

    final updated = current.copyWith(
      receiptHeader: _headerController.text.trim(),
      receiptFooter: _footerController.text.trim(),
      stationName: _stationController.text.trim().isEmpty ? null : _stationController.text.trim(),
      isSplitPrintingEnabled: _isSplitPrinting,
      logoPath: _logoPath,
    );

    try {
      await ref.read(settingsRepositoryProvider).updateShopConfig(updated);
      ref.invalidate(shopConfigStreamProvider);
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

  Future<void> _pickLogo() async {
    final picker = ImagePicker();
    final xfile = await picker.pickImage(source: ImageSource.gallery);
    if (xfile == null) return;

    try {
      final docDir = await getApplicationDocumentsDirectory();
      final ext = p.extension(xfile.path);
      final newPath = p.join(docDir.path, 'receipt_logo$ext');
      
      final file = File(xfile.path);
      await file.copy(newPath);

      setState(() {
        _logoPath = newPath;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Σφάλμα αποθήκευσης λογοτύπου: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  void _removeLogo() {
    setState(() {
      _logoPath = null;
    });
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
                          const Text('Λογότυπο Απόδειξης', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          if (_logoPath != null && File(_logoPath!).existsSync())
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Image.file(
                                  File(_logoPath!),
                                  height: 100,
                                  fit: BoxFit.contain,
                                ),
                                const SizedBox(height: 8),
                                OutlinedButton.icon(
                                  onPressed: _removeLogo,
                                  icon: const Icon(Icons.delete, color: AppColors.error),
                                  label: const Text('Αφαίρεση', style: TextStyle(color: AppColors.error)),
                                ),
                              ],
                            )
                          else
                            OutlinedButton.icon(
                              onPressed: _pickLogo,
                              icon: const Icon(Icons.image),
                              label: const Text('Επιλογή Λογότυπου (Downloads/Photos)'),
                            ),
                          const SizedBox(height: 24),
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
                            controller: _stationController,
                            decoration: const InputDecoration(
                              labelText: 'Όνομα Πόστου / Σταθμού (π.χ. Ταμείο, Κρέας, Πόρτα)',
                              hintText: 'Θα εκτυπώνεται πάνω από τον σερβιτόρο',
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
