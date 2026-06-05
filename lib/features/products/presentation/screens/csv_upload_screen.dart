import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:order/core/theme/app_colors.dart';
import 'package:order/features/auth/presentation/providers/auth_providers.dart';
import 'package:order/features/products/presentation/providers/product_providers.dart';
import 'package:permission_handler/permission_handler.dart';

class CsvUploadScreen extends ConsumerStatefulWidget {
  const CsvUploadScreen({super.key});

  @override
  ConsumerState<CsvUploadScreen> createState() => _CsvUploadScreenState();
}

class _CsvUploadScreenState extends ConsumerState<CsvUploadScreen> {
  bool _isLoading = false;

  Future<void> _upload() async {
    final shopId = ref.read(currentShopIdProvider);
    if (shopId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: No active shop found')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (Platform.isAndroid) {
        await Permission.storage.request();
        
        if (await Permission.manageExternalStorage.isDenied) {
          await Permission.manageExternalStorage.request();
        }
      }

      String expectedPath = '';
      if (Platform.isAndroid) {
        expectedPath = '/storage/emulated/0/Download/imports/import.csv';
      } else if (Platform.isWindows) {
        expectedPath = '${Platform.environment['USERPROFILE']}\\Downloads\\imports\\import.csv';
      } else {
        expectedPath = '${Platform.environment['HOME']}/Downloads/imports/import.csv';
      }

      final file = File(expectedPath);
      if (!await file.exists()) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('File not found at:\n$expectedPath'),
              backgroundColor: AppColors.error,
            ),
          );
        }
        setState(() { _isLoading = false; });
        return;
      }

      await ref.read(productRepositoryProvider).uploadCsv(
            shopId: shopId,
            filePath: expectedPath,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('CSV imported successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
        ref.invalidate(productsStreamProvider);
        ref.invalidate(categoriesStreamProvider);
        context.go('/products');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to import CSV: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBgColor = isDark ? AppColors.surfaceDarkElevated : AppColors.surfaceLightElevated;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Import Menu via CSV'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/products'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Info Card
                Card(
                  color: cardBgColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.description, color: AppColors.primary, size: 28),
                            SizedBox(width: 12),
                            Text(
                              'CSV Format Instructions',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Your CSV file should contain a header row and follow this column structure:',
                          style: TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 16),
                        // Table representation
                        Table(
                          border: TableBorder.all(
                            color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          children: const [
                            TableRow(
                              decoration: BoxDecoration(color: Colors.black12),
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text('Column', style: TextStyle(fontWeight: FontWeight.bold)),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text('Type', style: TextStyle(fontWeight: FontWeight.bold)),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text('Description', style: TextStyle(fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                            TableRow(
                              children: [
                                Padding(padding: EdgeInsets.all(8.0), child: Text('Product_Name')),
                                Padding(padding: EdgeInsets.all(8.0), child: Text('Text')),
                                Padding(padding: EdgeInsets.all(8.0), child: Text('e.g. Espresso Freddo')),
                              ],
                            ),
                            TableRow(
                              children: [
                                Padding(padding: EdgeInsets.all(8.0), child: Text('Price')),
                                Padding(padding: EdgeInsets.all(8.0), child: Text('Decimal')),
                                Padding(padding: EdgeInsets.all(8.0), child: Text('e.g. 2.50')),
                              ],
                            ),
                            TableRow(
                              children: [
                                Padding(padding: EdgeInsets.all(8.0), child: Text('Category_Name')),
                                Padding(padding: EdgeInsets.all(8.0), child: Text('Text')),
                                Padding(padding: EdgeInsets.all(8.0), child: Text('e.g. Coffees, Appetizers')),
                              ],
                            ),
                            TableRow(
                              children: [
                                Padding(padding: EdgeInsets.all(8.0), child: Text('Department')),
                                Padding(padding: EdgeInsets.all(8.0), child: Text('Text')),
                                Padding(padding: EdgeInsets.all(8.0), child: Text('e.g. kitchen, bar, none')),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Form Card
                Card(
                  color: cardBgColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.folder_special, color: AppColors.primary),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'The app will automatically look for the file at:\nDownloads/imports/import.csv',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        FilledButton.icon(
                          onPressed: _isLoading ? null : _upload,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          icon: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Icon(Icons.upload_rounded),
                          label: Text(
                            _isLoading ? 'Importing...' : 'Upload & Import Menu',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
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
    );
  }
}
