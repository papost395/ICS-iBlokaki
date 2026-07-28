import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:order/core/theme/app_colors.dart';
import 'package:order/features/auth/presentation/providers/auth_providers.dart';
import 'package:order/features/products/presentation/providers/product_providers.dart';
import 'package:order/features/home/presentation/widgets/main_navigation_shell.dart';
import 'package:order/features/products/presentation/screens/edit_product_screen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:order/core/database/database_helper.dart';
import 'package:order/core/providers/storage_mode_provider.dart';

class ProductsScreen extends ConsumerStatefulWidget {
  const ProductsScreen({super.key});

  @override
  ConsumerState<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends ConsumerState<ProductsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isImporting = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _importCsv() async {
    final shopId = ref.read(currentShopIdProvider);
    if (shopId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Σφάλμα: Δεν βρέθηκε ενεργό κατάστημα')),
      );
      return;
    }

    setState(() => _isImporting = true);

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
              content: Text('Δεν βρέθηκε αρχείο:\n$expectedPath'),
              backgroundColor: AppColors.error,
            ),
          );
        }
        setState(() => _isImporting = false);
        return;
      }

      await ref.read(productRepositoryProvider).uploadCsv(
            shopId: shopId,
            filePath: expectedPath,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Το CSV εισήχθη επιτυχώς!'),
            backgroundColor: AppColors.success,
          ),
        );
        ref.invalidate(productsStreamProvider);
        ref.invalidate(categoriesStreamProvider);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Αποτυχία εισαγωγής CSV: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isImporting = false);
    }
  }

  Future<void> _deleteAllProducts() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Διαγραφή Όλων'),
        content: const Text('Είστε σίγουροι ότι θέλετε να διαγράψετε ΟΛΑ τα προϊόντα και τις κατηγορίες; Αυτή η ενέργεια δεν αναιρείται.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Ακύρωση')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true), 
            child: const Text('Διαγραφή')
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isImporting = true);
      await DatabaseHelper.instance.clearProductsAndCategories();
      ref.invalidate(categoriesStreamProvider);
      ref.invalidate(productsStreamProvider);
      setState(() => _isImporting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Τα προϊόντα διαγράφηκαν')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesStream = ref.watch(categoriesStreamProvider);
    final productsStream = ref.watch(productsStreamProvider);
    final isLocalMode = ref.watch(storageModeNotifierProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Μενού και Προϊόντα'),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            ref.read(scaffoldKeyProvider).currentState?.openDrawer();
          },
        ),
        actions: [
          if (isLocalMode)
            IconButton(
              icon: const Icon(Icons.delete_sweep, color: AppColors.error),
              tooltip: 'Διαγραφή Όλων',
              onPressed: _isImporting ? null : _deleteAllProducts,
            ),
          if (_isImporting)
            const Padding(
              padding: EdgeInsets.all(12.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.upload_file),
              tooltip: 'Εισαγωγή CSV',
              onPressed: _importCsv,
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(categoriesStreamProvider);
              ref.invalidate(productsStreamProvider);
            },
          ),
        ],
      ),
      body: productsStream.when(
        data: (products) {
          return categoriesStream.when(
            data: (categories) {
              if (categories.isEmpty && products.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.restaurant_menu, size: 48, color: Colors.grey),
                      const SizedBox(height: 12),
                      const Text(
                        'Δεν βρέθηκαν προϊόντα',
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: _isImporting ? null : _importCsv,
                        icon: const Icon(Icons.upload_file, size: 18),
                        label: const Text('Εισαγωγή CSV'),
                      ),
                    ],
                  ),
                );
              }

              final filteredCategories = categories.where((cat) {
                return products.any((p) => p.categoryId == cat.id && p.name.toLowerCase().contains(_searchQuery));
              }).toList();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Search Bar
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Αναζήτηση προϊόντος...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    _searchQuery = '';
                                  });
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: isDark ? AppColors.surfaceDarkElevated : AppColors.surfaceLightElevated,
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value.toLowerCase();
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final cat = categories[index];
                        final catProducts = products.where((p) {
                          final matchesCat = p.categoryId == cat.id;
                          final matchesSearch = p.name.toLowerCase().contains(_searchQuery);
                          return matchesCat && matchesSearch;
                        }).toList();

                        if (catProducts.isEmpty) return const SizedBox.shrink();

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          color: isDark ? AppColors.surfaceDarkElevated : AppColors.surfaceLightElevated,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Theme(
                            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                            child: ExpansionTile(
                              title: Text(
                                cat.name,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              subtitle: Text('${catProducts.length} προϊόντα', style: const TextStyle(fontSize: 12)),
                              initiallyExpanded: _searchQuery.isNotEmpty,
                              children: [
                                const Divider(height: 1),
                                ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: catProducts.length,
                                  separatorBuilder: (context, index) => const Divider(height: 1),
                                  itemBuilder: (context, pIndex) {
                                    final product = catProducts[pIndex];
                                    return ListTile(
                                      dense: true,
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                                      title: Text(
                                        product.name,
                                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                                      ),
                                      subtitle: Text(
                                        _departmentLabel(product.department.name),
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                                        ),
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            '€${product.price.toStringAsFixed(2)}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              color: AppColors.primary,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          IconButton(
                                            icon: const Icon(Icons.edit, size: 18),
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => EditProductScreen(product: product),
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Σφάλμα φόρτωσης. Δοκιμάστε ξανά.')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Σφάλμα φόρτωσης. Δοκιμάστε ξανά.')),
      ),
    );
  }
}

String _departmentLabel(String dept) {
  return switch (dept.toLowerCase()) {
    'kitchen' => 'ΚΟΥΦΑ',
    'bar' => 'ΜΠΑΡ',
    'cashier' => 'ΤΑΜΕΙΟ',
    _ => dept.toUpperCase(),
  };
}
