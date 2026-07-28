import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:order/core/theme/app_colors.dart';
import 'package:order/features/products/domain/entities/product.dart';
import 'package:order/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:order/core/database/database_helper.dart';
import 'package:order/features/products/domain/entities/category.dart';
import 'package:order/features/products/presentation/providers/product_providers.dart';
import 'package:order/features/printing/presentation/providers/printer_providers.dart';
import 'package:order/features/orders/presentation/providers/takeaway_providers.dart';
import 'package:order/features/settings/presentation/providers/ecr_config_provider.dart';
import 'package:matcashmachine/matcashmachine.dart';
import 'package:order/features/printing/domain/entities/printer_device.dart';
import 'package:order/features/printing/domain/entities/print_job.dart';
import 'package:order/features/orders/domain/entities/order_item.dart';
import 'package:order/features/settings/presentation/providers/settings_providers.dart';
import 'package:order/features/auth/presentation/providers/auth_providers.dart';

class TakeawayScreen extends ConsumerStatefulWidget {
  const TakeawayScreen({super.key});

  @override
  ConsumerState<TakeawayScreen> createState() => _TakeawayScreenState();
}

class _TakeawayScreenState extends ConsumerState<TakeawayScreen> {
  String? _selectedCategoryId;
  bool _isPrinting = false;

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesStreamProvider).valueOrNull ?? [];
    final allProducts = ref.watch(productsStreamProvider).valueOrNull ?? [];
    final cartItems = ref.watch(takeawayCartProvider);
    final cartTotal = ref.read(takeawayCartProvider.notifier).total;

    if (_selectedCategoryId == null && categories.isNotEmpty) {
      _selectedCategoryId = categories.first.id;
    }

    final filteredProducts = allProducts.where((p) => p.categoryId == _selectedCategoryId).toList();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isLargeScreen = MediaQuery.of(context).size.width >= 900;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Λιανική / Πακέτο'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: isLargeScreen
          ? Row(
              children: [
                Expanded(
                  flex: 4,
                  child: _buildCartPane(cartItems, cartTotal, isDark),
                ),
                const VerticalDivider(width: 1, thickness: 1),
                Expanded(
                  flex: 6,
                  child: _buildMenuPane(categories, filteredProducts, isDark),
                ),
              ],
            )
          : Column(
              children: [
                Expanded(
                  flex: 4,
                  child: _buildMenuPane(categories, filteredProducts, isDark),
                ),
                Expanded(
                  flex: 6,
                  child: _buildCartPane(cartItems, cartTotal, isDark),
                ),
              ],
            ),
    );
  }

  Widget _buildCartPane(List<TakeawayCartItem> items, double total, bool isDark) {
    final bgColor = isDark ? AppColors.surfaceDarkElevated : AppColors.surfaceLightElevated;

    return Container(
      color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: bgColor,
            child: Row(
              children: [
                const Icon(Icons.shopping_bag_outlined, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  '${items.fold(0, (sum, i) => sum + i.quantity)} τεμ.',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const Spacer(),
                Text(
                  '€${total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          
          // Item List
          Expanded(
            child: items.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_shopping_cart_outlined, size: 48, color: Colors.grey.withOpacity(0.5)),
                        const SizedBox(height: 12),
                        const Text(
                          'Προσθέστε προϊόντα',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    itemCount: items.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return ListTile(
                        title: Text(item.product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('€${item.product.price.toStringAsFixed(2)} x ${item.quantity}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline),
                              color: AppColors.error,
                              onPressed: () {
                                ref.read(takeawayCartProvider.notifier).removeProduct(item.product);
                              },
                            ),
                            Text('${item.quantity}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline),
                              color: AppColors.success,
                              onPressed: () {
                                ref.read(takeawayCartProvider.notifier).addProduct(item.product);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          
          // Action Bar
          Container(
            color: bgColor,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: items.isEmpty || _isPrinting
                        ? null
                        : () {
                            ref.read(takeawayCartProvider.notifier).clear();
                          },
                    icon: const Icon(Icons.delete_sweep, color: AppColors.error),
                    label: const Text('ΑΚΥΡΩΣΗ', style: TextStyle(color: AppColors.error)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.error),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: FilledButton.icon(
                    onPressed: items.isEmpty || _isPrinting ? null : () => _printReceipt(items, total),
                    icon: _isPrinting 
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Icon(Icons.receipt),
                    label: Text(_isPrinting ? 'ΕΚΤΥΠΩΣΗ...' : 'ΕΚΔΟΣΗ ΑΠΟΔΕΙΞΗΣ'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.success,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuPane(List<Category> categories, List<Product> filteredProducts, bool isDark) {
    return Column(
      children: [
        // Categories
        SizedBox(
          height: 60,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final cat = categories[index];
              final isSelected = cat.id == _selectedCategoryId;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(
                    cat.name,
                    style: TextStyle(
                      color: isSelected ? Colors.white : (isDark ? Colors.white : Colors.black),
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: AppColors.primary,
                  onSelected: (selected) {
                    if (selected) setState(() => _selectedCategoryId = cat.id);
                  },
                ),
              );
            },
          ),
        ),
        
        // Products Grid
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 140,
              childAspectRatio: 1.2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: filteredProducts.length,
            itemBuilder: (context, index) {
              final product = filteredProducts[index];
              return Card(
                elevation: 2,
                color: isDark ? AppColors.surfaceDarkElevated : AppColors.surfaceLightElevated,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: InkWell(
                  onTap: () {
                    ref.read(takeawayCartProvider.notifier).addProduct(product);
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          product.name,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '€${product.price.toStringAsFixed(2)}',
                          style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _printReceipt(List<TakeawayCartItem> items, double total) async {
    setState(() => _isPrinting = true);
    
    try {
      final ecrConfig = ref.read(ecrConfigNotifierProvider);
      
      if (!ecrConfig.enabled) {
        // Fallback to thermal printer if ECR is disabled
        await _printToThermalPrinter(items, total);
        
        ref.read(takeawayCartProvider.notifier).clear();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Η παραγγελία εκτυπώθηκε!'), backgroundColor: AppColors.success),
          );
        }
        return;
      }
      
      if (ecrConfig.ipAddress.isEmpty) {
        throw Exception('Δεν έχει οριστεί IP διεύθυνση ταμειακής.');
      }
      
      final host = ecrConfig.ipAddress;
      final port = ecrConfig.port;
      
      final mat = MatProtocol(host: host, port: port);
      
      await mat.connect();
      
      final status = await mat.getStatus();
      if (status.deviceStatus.printerOffline || 
          status.deviceStatus.printerPaperEnd || 
          status.deviceStatus.deviceBusy || 
          status.deviceStatus.cutterError) {
        throw Exception('Η ταμειακή δεν είναι έτοιμη για πώληση (Έλεγχος χαρτιού/σύνδεσης).');
      }
      
      for (final item in items) {
        for (int i = 0; i < item.quantity; i++) {
          await mat.itemSale(item.product.price, description: item.product.name, department: 1);
        }
      }
      
      await mat.sendPayment(total);
      
      await mat.disconnect();
      await mat.dispose();
      
      // Save sales locally upon successful print
      try {
        final shopId = ref.read(currentShopIdProvider) ?? 'local';
        final nowMs = DateTime.now().millisecondsSinceEpoch;
        final salesRecords = items.asMap().entries.map((e) => {
          'id': 'sale_${DateTime.now().microsecondsSinceEpoch}_${e.key}_${e.value.product.id}',
          'shopId': shopId,
          'productId': e.value.product.id,
          'productName': e.value.product.name,
          'quantity': e.value.quantity,
          'price': e.value.product.price,
          'timestamp': nowMs,
          'orderType': 'takeaway',
        }).toList();
        await DatabaseHelper.instance.addSalesRecords(salesRecords);
      } catch (e) {
        debugPrint('Failed to save sales records locally after ECR print: $e');
      }

      ref.read(takeawayCartProvider.notifier).clear();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Η απόδειξη εκδόθηκε επιτυχώς!'), backgroundColor: AppColors.success),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Σφάλμα: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isPrinting = false);
      }
    }
  }

  Future<void> _printToThermalPrinter(List<TakeawayCartItem> cartItems, double total) async {
    final shopId = ref.read(currentShopIdProvider);
    if (shopId == null) throw Exception('Δεν βρέθηκε κατάστημα.');

    final repo = ref.read(printerRepositoryProvider);
    final printers = await repo.getPrinters(shopId);
    
    final cashierPrinters = printers.where((p) => p.role == PrinterRole.cashier).toList();
    if (cashierPrinters.isEmpty) {
      throw Exception('Δεν βρέθηκε εκτυπωτής ταμείου για την εκτύπωση.');
    }


    // Fetch settings for header/footer
    final settingsRepo = ref.read(settingsRepositoryProvider);
    final config = await settingsRepo.getShopConfig(shopId);

    final localAuth = ref.read(localAuthNotifierProvider);
    final waiterName = localAuth.waiterName ?? 'Σερβιτόρος';

    // Convert TakeawayCartItem to OrderItem
    final List<OrderItem> printItems = cartItems.map((c) => OrderItem(
      id: 'item_${DateTime.now().microsecondsSinceEpoch}',
      orderId: 'takeaway',
      productId: c.product.id,
      productName: c.product.name,
      quantity: c.quantity,
      priceAtOrder: c.product.price,
      department: c.product.department,
      notes: '',
      printStatus: 'printed_${DateTime.now().toIso8601String()}',
    )).toList();

    final jobs = cashierPrinters.map((printer) => PrintJob(
      printer: printer,
      tableName: 'ΠΑΚΕΤΟ',
      waiterName: waiterName,
      items: printItems,
      timestamp: DateTime.now(),
      header: config?.receiptHeader ?? 'ΠΑΚΕΤΟ',
      footer: config?.receiptFooter,
      logoPath: config?.logoPath,
      stationName: config?.stationName,
    )).toList();

    await Future.wait(jobs.map((j) => repo.printJob(j)));

    // Save sales locally upon successful print
    try {
      final nowMs = DateTime.now().millisecondsSinceEpoch;
      final salesRecords = cartItems.asMap().entries.map((e) => {
        'id': 'sale_${DateTime.now().microsecondsSinceEpoch}_${e.key}_${e.value.product.id}',
        'shopId': shopId,
        'productId': e.value.product.id,
        'productName': e.value.product.name,
        'quantity': e.value.quantity,
        'price': e.value.product.price,
        'timestamp': nowMs,
        'orderType': 'takeaway',
      }).toList();
      await DatabaseHelper.instance.addSalesRecords(salesRecords);
    } catch (e) {
      debugPrint('Failed to save sales records locally: $e');
    }
  }
}
