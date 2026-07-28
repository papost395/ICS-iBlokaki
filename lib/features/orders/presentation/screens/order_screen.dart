import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:order/core/theme/app_colors.dart';
import 'package:order/features/auth/presentation/providers/auth_providers.dart';
import 'package:order/features/orders/domain/entities/order.dart';
import 'package:order/features/orders/domain/entities/order_item.dart';
import 'package:order/features/orders/presentation/providers/order_providers.dart';
import 'package:order/features/products/domain/entities/product.dart';
import 'package:order/features/products/presentation/providers/product_providers.dart';
import 'package:order/features/tables/presentation/providers/table_providers.dart';
import 'package:order/features/printing/domain/entities/print_job.dart';
import 'package:order/features/printing/presentation/providers/printer_providers.dart';
import 'package:order/features/settings/presentation/providers/settings_providers.dart';
import 'package:order/features/tables/domain/entities/table_status.dart';
import 'package:logger/logger.dart';


class OrderScreen extends ConsumerStatefulWidget {
  const OrderScreen({
    required this.tableId,
    super.key,
  });

  final String tableId;

  @override
  ConsumerState<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends ConsumerState<OrderScreen> {
  String? _selectedCategoryId;
  bool _isCreatingOrder = false;
  bool _hasDeletedItems = false;  // Εμφανίζει το πορτοκαλί εκτυπωτακάκι διορθωτικής

  var logger = Logger(
    printer: PrettyPrinter(
        methodCount: 2,
        errorMethodCount: 8,
        lineLength: 120,
        colors: true,
        printEmojis: true,
        dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final tables = ref.watch(tablesStreamProvider).valueOrNull ?? [];
    final table = tables.firstWhereOrNull((t) => t.id == widget.tableId);

    final activeOrders = ref.watch(activeOrdersStreamProvider).valueOrNull ?? [];
    final activeOrder = activeOrders.firstWhereOrNull(
          (o) => o.tableId == widget.tableId && o.status == OrderStatus.pending,
        ) ??
        activeOrders.firstWhereOrNull(
          (o) => o.tableId == widget.tableId && o.status == OrderStatus.inProgress,
        );

    final categories = ref.watch(categoriesStreamProvider).valueOrNull ?? [];
    final allProducts = ref.watch(productsStreamProvider).valueOrNull ?? [];
    
    ref.watch(printersStreamProvider);
    ref.watch(shopConfigStreamProvider);

    if (_selectedCategoryId == null && categories.isNotEmpty) {
      _selectedCategoryId = categories.first.id;
    }

    final filteredProducts = allProducts.where((p) => p.categoryId == _selectedCategoryId).toList();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isLargeScreen = MediaQuery.of(context).size.width >= 900;

    return Scaffold(
      appBar: AppBar(
        title: Text(table != null ? 'Τραπέζι: ${table.name}' : 'Παραγγελία'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/tables'),
        ),
      ),
      body: activeOrder == null
          ? Center(
              child: _isCreatingOrder
                  ? const CircularProgressIndicator()
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        const Text(
                          'Δεν υπάρχει ενεργή παραγγελία',
                          style: TextStyle(fontSize: 18),
                        ),
                        const SizedBox(height: 24),
                        FilledButton.icon(
                          onPressed: () async {
                            setState(() {
                              _isCreatingOrder = true;
                            });
                            try {
                              await ref.read(orderActionsProvider.notifier).createOrder(
                                    tableId: widget.tableId,
                                  );
                              ref.read(tableActionsProvider.notifier).updateStatus(tableId: widget.tableId, status: const Occupied());
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Σφάλμα δημιουργίας παραγγελίας: $e'),
                                    backgroundColor: AppColors.error,
                                  ),
                                );
                              }
                            } finally {
                              if (mounted) {
                                setState(() {
                                  _isCreatingOrder = false;
                                });
                              }
                            }
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Νέα Παραγγελία'),
                        ),
                      ],
                    ),
            )
          : isLargeScreen
              ? Row(
                  children: [
                    // Left Pane: Cart/Order Details
                    Expanded(
                      flex: 4,
                      child: _buildCartPane(activeOrder, table?.name ?? 'Τραπέζι', isDark, categories, allProducts),
                    ),
                    const VerticalDivider(width: 1, thickness: 1),
                    // Right Pane: Products Menu
                    Expanded(
                      flex: 6,
                      child: _buildMenuPane(categories, allProducts, activeOrder, isDark),
                    ),
                  ],
                )
              : _buildCartPane(activeOrder, table?.name ?? 'Τραπέζι', isDark, categories, allProducts),
    );
  }

  Widget _buildCartPane(Order order, String tableName, bool isDark, [List<dynamic>? categories, List<Product>? allProducts]) {
    final bgColor = isDark ? AppColors.surfaceDarkElevated : AppColors.surfaceLightElevated;
    final isMobile = MediaQuery.of(context).size.width < 900;

    // Pending items (όλα τα pending εκτυπώνονται κανονικά)
    final hasPendingKitchenItems = order.items.any((i) => i.printStatus == 'pending');

    return Container(
      color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Header ──────────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: bgColor,
            child: Row(
              children: [
                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: order.status == OrderStatus.pending
                        ? AppColors.warning.withOpacity(0.15)
                        : AppColors.success.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    order.status == OrderStatus.pending ? 'ΕΚΚΡΕΜΕΊ' : 'ΣΕ ΕΞΕΛΙΞΗ',
                    style: TextStyle(
                      color: order.status == OrderStatus.pending ? AppColors.warning : AppColors.success,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${order.items.fold(0, (sum, i) => sum + i.quantity)} τεμ.',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.history, color: AppColors.primary, size: 26),
                  tooltip: 'Ιστορικό Εκτυπώσεων',
                  onPressed: () {
                    ref.invalidate(orderHistoryProvider(tableId: widget.tableId));
                    _showOrderHistoryDialog(context, tableName, order);
                  },
                ),
                const SizedBox(width: 4),
                Text(
                  '€${order.calculatedTotal.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),

          // ── Item List ────────────────────────────────────────────────────
          Expanded(
            child: order.items.isEmpty
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
                    itemCount: order.items.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final item = order.items[index];
                      return _buildOrderItemTile(item, isDark, tableName);
                    },
                  ),
          ),

          // ── Action Bar ───────────────────────────────────────────────────
          Container(
            color: bgColor,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                // 🖨️ Εκτυπωτής (kitchen/bar)
                Expanded(
                  child: FilledButton.icon(
                    onPressed: hasPendingKitchenItems
                        ? () async {
                            logger.i('BTN: Εκτυπωτής pressed. Pending items: ${order.items.where((i) => i.printStatus == "pending" && !i.receiptOnly).length}');
                            final success = await _printToKitchen(order, tableName);
                            if (success) {
                              final batchId = 'printed_${DateTime.now().toLocal().toIso8601String()}';
                              for (final item in order.items) {
                                // Μόνο τα NON-receiptOnly items αλλάζουν status — αυτά που πήγαν στην κουζίνα
                                if (item.printStatus == 'pending' && !item.receiptOnly) {
                                  try {
                                    await ref.read(orderActionsProvider.notifier).updateItemPrintStatus(
                                      itemId: item.id,
                                      printStatus: batchId,
                                    );
                                  } catch (e) {
                                    debugPrint('Failed to update print status for ${item.id}: $e');
                                  }
                                }
                              }
                            }
                          }
                        : null,
                    style: FilledButton.styleFrom(
                      backgroundColor: hasPendingKitchenItems ? Colors.lightBlue : null,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.print_outlined, size: 20),
                    label: const Text('Εκτυπωτής', style: TextStyle(fontSize: 13)),
                  ),
                ),
                const SizedBox(width: 8),
                // 🧾 Απόδειξη (cashier only)
                Expanded(
                  child: FilledButton.icon(
                    onPressed: order.items.isNotEmpty
                        ? () {
                            logger.i('BTN: Απόδειξη pressed. Total items: ${order.items.length}');
                            _printReceipt(order, tableName);
                          }
                        : null,
                    style: FilledButton.styleFrom(
                      backgroundColor: order.items.any((i) => i.receiptOnly) ? Colors.green.shade600 : null,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.receipt_long_outlined, size: 20),
                    label: const Text('Απόδειξη', style: TextStyle(fontSize: 13)),
                  ),
                ),
                // Πορτοκαλί εκτυπωτακάκι Διορθωτικής — εμφανίζεται μόνο αφού διαγραφεί item
                if (_hasDeletedItems) ...[
                  const SizedBox(width: 8),
                  IconButton.filledTonal(
                    onPressed: () async {
                      final success = await _printCorrective(order, tableName);
                      if (success) setState(() => _hasDeletedItems = false);
                    },
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.orange.withValues(alpha: 0.15),
                      foregroundColor: Colors.orange,
                      padding: const EdgeInsets.all(12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.print, size: 22),
                    tooltip: 'Διορθωτική Εκτύπωση',
                  ),
                ],
                // ➕ Προσθήκη
                if (categories != null && allProducts != null) ...[
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () {
                      _showMenuBottomSheet(context, categories, allProducts, order, isDark);
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Icon(Icons.add, size: 22),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItemTile(OrderItem item, bool isDark, String tableName) {
    final isReceiptOnly = item.receiptOnly;
    final isPrinted = item.printStatus != 'pending';

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      leading: CircleAvatar(
        backgroundColor: AppColors.primary.withOpacity(0.1),
        child: Text(
          'x${item.quantity}',
          style: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
      title: Text(
        item.productName,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: isPrinted
              ? (isDark ? AppColors.textLightSecondary : AppColors.textDarkSecondary)
              : null,
        ),
      ),
      subtitle: item.notes.isNotEmpty
          ? Text(item.notes, style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 12))
          : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '€${(item.priceAtOrder * item.quantity).toStringAsFixed(2)}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(width: 4),
          // 🧾 Toggle: Απόδειξη
          IconButton(
            icon: Icon(
              isReceiptOnly ? Icons.receipt : Icons.receipt_outlined,
              size: 20,
              color: isReceiptOnly
                  ? Colors.green
                  : Colors.grey,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            tooltip: isReceiptOnly ? 'Θα κοπεί απόδειξη' : 'ΔΕΝ θα κοπεί απόδειξη',
            onPressed: () async {
              try {
                await ref.read(orderActionsProvider.notifier).updateItemReceiptOnly(
                  itemId: item.id,
                  receiptOnly: !isReceiptOnly,
                );
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Σφάλμα: $e'), backgroundColor: AppColors.error),
                  );
                }
              }
            },
          ),
          const SizedBox(width: 4),
          // 📝 Notes
          IconButton(
            icon: const Icon(Icons.info_outline, color: AppColors.primary, size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            tooltip: 'Σχόλια',
            onPressed: () {
              _showEditNotesDialog(context, item);
            },
          ),
          const SizedBox(width: 4),
          // ✕ Remove
          IconButton(
            icon: const Icon(Icons.close, color: AppColors.error, size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () async {
              await ref.read(orderRepositoryProvider).removeItem(item.id);
              ref.invalidate(activeOrdersStreamProvider);
              setState(() => _hasDeletedItems = true);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuPane(
    List<dynamic> categories,
    List<Product> allProducts,
    Order order,
    bool isDark,
    ) {
    final inactiveBgColor = isDark ? AppColors.surfaceDarkElevated : AppColors.surfaceLightElevated;

    return categories.isEmpty
        ? const Center(child: Text('Δεν υπάρχουν κατηγορίες'))
        : LayoutBuilder(
            builder: (context, constraints) {
              int crossAxisCount = 2;
              if (constraints.maxWidth >= 1200) {
                crossAxisCount = 6;
              } else if (constraints.maxWidth >= 900) {
                crossAxisCount = 5;
              } else if (constraints.maxWidth >= 600) {
                crossAxisCount = 4;
              } else if (constraints.maxWidth >= 450) {
                crossAxisCount = 3;
              }

              return GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 3.0,
                ),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final cat = categories[index];

                  return Card(
                color: inactiveBgColor,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () {
                    final categoryProducts = allProducts.where((p) => p.categoryId == cat.id).toList();
                    _showMultiSelectDialog(context, cat, categoryProducts, order);
                  },
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        cat.name,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      );
  }

  // ── Ανίχνευση καφέ κατηγορίας ──────────────────────────────────────────────
  bool _isCoffeeCategory(String categoryName) {
    final name = categoryName.toLowerCase();
    return name.contains('καφ') ||
           name.contains('coffee') ||
           name.contains('espresso') ||
           name.contains('cappuccino');
  }

  // Ομάδες επιλογών καφέ
  static const _coffeeGroups = [
    ('Γλυκύτητα', ['Σκέτο', 'Ολίγη', 'Μέτριο', 'Γλυκό', 'Πολύ Γλυκό']),
    ('Πάγος',     ['Λίγο Πάγο', 'Πολύ Πάγο']),
    ('Γάλα',      ['Γάλα Φρέσκο', 'Γάλα Εβαποράτ']),
    ('Ζάχαρη',    ['Κανονική Ζάχαρη', 'Μαύρη Ζάχαρη']),
  ];

  // Διάλογος προσαρμογής καφέ με FilterChips
  Future<String?> _showCoffeeCustomizationDialog(BuildContext context, String productName) async {
    final selected = <String>{};
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateDialog) {
          return AlertDialog(
            backgroundColor: isDark ? AppColors.surfaceDarkElevated : AppColors.surfaceLightElevated,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: [
                const Text('☕', style: TextStyle(fontSize: 22)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    productName,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            contentPadding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            content: SizedBox(
              width: 320,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final group in _coffeeGroups) ...[
                      Padding(
                        padding: const EdgeInsets.only(top: 10, bottom: 4),
                        child: Text(
                          group.$1,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          for (final opt in group.$2)
                            FilterChip(
                              label: Text(opt, style: const TextStyle(fontSize: 13)),
                              selected: selected.contains(opt),
                              onSelected: (val) => setStateDialog(() {
                                if (val) {
                                  if (group.$1 == 'Γλυκύτητα' || group.$1 == 'Ζάχαρη') {
                                    selected.removeWhere((s) => group.$2.contains(s));
                                  }
                                  selected.add(opt);
                                } else {
                                  selected.remove(opt);
                                }
                              }),
                              selectedColor: AppColors.primary.withValues(alpha: 0.2),
                              checkmarkColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: BorderSide(
                                  color: selected.contains(opt)
                                      ? AppColors.primary
                                      : Colors.grey.withValues(alpha: 0.3),
                                ),
                              ),
                              backgroundColor: Colors.transparent,
                              showCheckmark: false,
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
            actionsPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, ''),
                child: const Text('Χωρίς επιλογές'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, selected.join(', ')),
                child: const Text('Εντάξει'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _showMultiSelectDialog(
    BuildContext context,
    dynamic category,
    List<Product> categoryProducts,
    Order order,
    ) async {
    final selectedQuantities = <String, int>{};
    final productNotes = <String, String>{};  // productId → coffee notes
    bool isAdding = false;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dialogBgColor = isDark ? AppColors.surfaceDarkElevated : AppColors.surfaceLightElevated;
    final titleColor = isDark ? Colors.white : AppColors.textLight;
    final isCoffee = _isCoffeeCategory(category.name as String);

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setState) {
            final totalSelected = selectedQuantities.values.fold(0, (sum, q) => sum + q);

            return PopScope(
              canPop: !isAdding,
              child: AlertDialog(
                backgroundColor: dialogBgColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                title: Text('Προσθήκη από ${category.name}', style: TextStyle(color: titleColor)),
                contentPadding: const EdgeInsets.only(top: 16),
              content: SizedBox(
                width: double.maxFinite,
                child: categoryProducts.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(24.0),
                        child: Text('Δεν υπάρχουν προϊόντα', textAlign: TextAlign.center),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        itemCount: categoryProducts.length,
                        separatorBuilder: (context, index) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final product = categoryProducts[index];
                          final qty = selectedQuantities[product.id] ?? 0;
                          final notes = productNotes[product.id] ?? '';

                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product.name,
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '€${product.price.toStringAsFixed(2)}',
                                        style: const TextStyle(color: AppColors.primary, fontSize: 13),
                                      ),
                                      // Εμφανίζει τις επιλεγμένες προσαρμογές καφέ
                                      if (isCoffee && notes.isNotEmpty)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 3),
                                          child: Row(
                                            children: [
                                              const Icon(Icons.coffee, size: 11, color: Colors.brown),
                                              const SizedBox(width: 3),
                                              Expanded(
                                                child: Text(
                                                  notes,
                                                  style: const TextStyle(
                                                    fontSize: 11,
                                                    color: Colors.brown,
                                                    fontStyle: FontStyle.italic,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle_outline),
                                    color: qty > 0 ? AppColors.error : Colors.grey,
                                    onPressed: (qty > 0 && !isAdding)
                                        ? () => setState(() {
                                            selectedQuantities[product.id] = qty - 1;
                                            if (selectedQuantities[product.id] == 0) {
                                              productNotes.remove(product.id);
                                            }
                                          })
                                        : null,
                                  ),
                                  SizedBox(
                                    width: 24,
                                    child: Text(
                                      '$qty',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add_circle_outline),
                                    color: isAdding ? Colors.grey : AppColors.primary,
                                    onPressed: isAdding
                                        ? null
                                        : () async {
                                            // Αν είναι καφέ, δείξε το customization dialog
                                            if (isCoffee) {
                                              final coffeeNotes = await _showCoffeeCustomizationDialog(
                                                dialogContext,
                                                product.name,
                                              );
                                              if (coffeeNotes != null) {
                                                setState(() {
                                                  selectedQuantities[product.id] = qty + 1;
                                                  if (coffeeNotes.isNotEmpty) {
                                                    productNotes[product.id] = coffeeNotes;
                                                  }
                                                });
                                              }
                                            } else {
                                              setState(() => selectedQuantities[product.id] = qty + 1);
                                            }
                                          },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
              ),
              actionsPadding: const EdgeInsets.all(16),
              actions: [
                TextButton(
                  onPressed: isAdding ? null : () => Navigator.pop(dialogContext),
                  child: const Text('Ακύρωση'),
                ),
                FilledButton.icon(
                  onPressed: (totalSelected > 0 && !isAdding)
                      ? () async {
                          if (isAdding) return;

                          setState(() {
                            isAdding = true;
                          });
                          
                          for (final product in categoryProducts) {
                            final qty = selectedQuantities[product.id] ?? 0;
                            if (qty > 0) {
                              final item = OrderItem(
                                id: '',
                                orderId: order.id,
                                productId: product.id,
                                productName: product.name,
                                quantity: qty,
                                priceAtOrder: product.price,
                                department: product.department,
                                notes: productNotes[product.id] ?? '',  // Προσαρμογές καφέ ή κενό
                                receiptOnly: false,
                              );
                              try {
                                await ref.read(orderActionsProvider.notifier).addItem(
                                      orderId: order.id,
                                      item: item,
                                    );
                              } catch (e) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Σφάλμα: ${product.name}: $e')),
                                  );
                                }
                              }
                            }
                          }

                          if (dialogContext.mounted) {
                            final isCurrent = ModalRoute.of(dialogContext)?.isCurrent == true;
                            if (isCurrent) {
                              Navigator.pop(dialogContext);
                            }
                          }
                        }
                      : null,
                  icon: isAdding
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.check),
                  label: Text(isAdding ? 'Προσθήκη...' : 'Προσθήκη $totalSelected τεμ.'),
                ),
              ],
          ),
            );
          },
        );
      },
    );
  }

  // ── Print: Ακύρωση Είδους ──────────────────────────────────────────────
  Future<bool> _printCancellation(OrderItem item, String tableName) async {
    final printers = ref.read(printersStreamProvider).valueOrNull ?? [];
    final shopConfig = ref.read(shopConfigStreamProvider).valueOrNull;
    final localAuth = ref.read(localAuthNotifierProvider);
    final waiterName = localAuth.waiterName ?? 'Σερβιτόρος';

    if (printers.isEmpty) return false;

    final jobs = <PrintJob>[];
    for (final printer in printers) {
      if (shopConfig != null && !shopConfig.isSplitPrintingEnabled) {
        if (printer.role.name != 'cashier') continue;
      }

      bool matches = false;
      if (printer.role.name == 'kitchen' && item.department.name == 'kitchen') matches = true;
      if (printer.role.name == 'bar' && item.department.name == 'bar') matches = true;
      if (printer.role.name == 'cashier') matches = true;

      if (matches) {
        jobs.add(PrintJob(
          printer: printer,
          items: [item],
          tableName: tableName,
          waiterName: waiterName,
          header: '*** ΔΙΟΡΘΩΤΙΚΗ ***\n*** ΑΚΥΡΩΣΗ ΕΙΔΟΥΣ ***\n${shopConfig?.receiptHeader ?? ""}',
          footer: shopConfig?.receiptFooter,
          logoPath: shopConfig?.logoPath,
          stationName: shopConfig?.stationName,
          timestamp: DateTime.now(),
        ));
      }
    }

    if (jobs.isEmpty) return true;
    return await _runPrintJobs(jobs);
  }

  // ── Print: Διορθωτική — εκτυπώνει ΟΛΑ τα υπάρχοντα items με header ΔΙΟΡΘΩΤΙΚΗ ───────────
  // Εμφανίζεται ως πορτοκαλί icon μετά από διαγραφή item.
  Future<bool> _printCorrective(Order order, String tableName) async {
    final printers = ref.read(printersStreamProvider).valueOrNull ?? [];
    final shopConfig = ref.read(shopConfigStreamProvider).valueOrNull;
    final localAuth = ref.read(localAuthNotifierProvider);
    final waiterName = localAuth.waiterName ?? 'Σερβιτόρος';

    if (printers.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Δεν υπάρχουν εκτυπωτές')),
        );
      }
      return false;
    }

    // Εκτυπώνει ΟΛΟΥΣ τους non-receiptOnly items (αυτούς που πάνε κουζίνα)
    final kitchenItems = order.items.where((i) => !i.receiptOnly).toList();
    if (kitchenItems.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Δεν υπάρχουν είδη για διορθωτική')),
        );
      }
      return false;
    }

    final jobs = <PrintJob>[];
    for (final printer in printers) {
      if (shopConfig != null && !shopConfig.isSplitPrintingEnabled) {
        if (printer.role.name != 'cashier') continue;
      }

      final matchingItems = kitchenItems.where((i) {
        if (printer.role.name == 'kitchen' && i.department.name == 'kitchen') return true;
        if (printer.role.name == 'bar' && i.department.name == 'bar') return true;
        if (printer.role.name == 'cashier') return true;
        return false;
      }).toList();

      if (matchingItems.isNotEmpty) {
        jobs.add(PrintJob(
          printer: printer,
          items: matchingItems,
          tableName: tableName,
          waiterName: waiterName,
          header: shopConfig?.receiptHeader,
          footer: shopConfig?.receiptFooter,
          logoPath: shopConfig?.logoPath,
          stationName: shopConfig?.stationName,
          timestamp: DateTime.now(),
        ));
      }
    }

    if (jobs.isEmpty) return true;
    return await _runPrintJobs(jobs);
  }

  // ── Print: Εκτυπωτής (kitchen/bar) — ΔΕΝ στέλνει receiptOnly items ──────────────────────
  // Τα receiptOnly items πηγαίνουν ΜΟΝΟ στην απόδειξη, ΟΧΙ στην κουζίνα.
  Future<bool> _printToKitchen(Order order, String tableName, {bool isReprint = false}) async {
    final printers = ref.read(printersStreamProvider).valueOrNull ?? [];
    final shopConfig = ref.read(shopConfigStreamProvider).valueOrNull;
    final localAuth = ref.read(localAuthNotifierProvider);
    final waiterName = localAuth.waiterName ?? 'Σερβιτόρος';

    logger.i('_printToKitchen: printers=${printers.length}, isReprint=$isReprint, splitPrinting=${shopConfig?.isSplitPrintingEnabled}');
    for (final p in printers) {
      logger.i('  Printer: ${p.name}, role=${p.role.name}, type=${p.connectionType.name}, addr=${p.address}');
    }

    if (printers.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Δεν υπάρχουν εκτυπωτές')),
        );
      }
      return false;
    }

    // Εκτυπωτής: ΜΟΝΟ pending items που ΔΕΝ είναι receiptOnly
    // isReprint = εκτύπωσε ξανά συγκεκριμένα items που ήδη τυπώθηκαν
    final itemsForKitchen = isReprint
        ? order.items  // Επανεκτύπωση: στέλνουμε όλα τα items της παρτίδας
        : order.items.where((i) => i.printStatus == 'pending' && !i.receiptOnly).toList();

    logger.i('_printToKitchen: itemsForKitchen=${itemsForKitchen.length}');
    for (final i in itemsForKitchen) {
      logger.i('  Item: ${i.productName}, dept=${i.department.name}, status=${i.printStatus}, receiptOnly=${i.receiptOnly}');
    }

    if (itemsForKitchen.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Δεν υπάρχουν νέα στοιχεία για εκτύπωση')),
        );
      }
      return false;
    }

    final jobs = <PrintJob>[];
    for (final printer in printers) {
      if (shopConfig != null && !shopConfig.isSplitPrintingEnabled) {
        if (printer.role.name != 'cashier') {
          logger.i('  SKIP printer ${printer.name} (role=${printer.role.name}, splitPrinting=false → only cashier)');
          continue;
        }
      }

      final matchingItems = itemsForKitchen.where((i) {
        if (printer.role.name == 'kitchen' && i.department.name == 'kitchen') return true;
        if (printer.role.name == 'bar' && i.department.name == 'bar') return true;
        if (printer.role.name == 'cashier') return true;
        return false;
      }).toList();

      logger.i('  Printer ${printer.name} (role=${printer.role.name}): ${matchingItems.length} matching items');

      if (matchingItems.isNotEmpty) {
        jobs.add(PrintJob(
          printer: printer,
          items: matchingItems,
          tableName: tableName,
          waiterName: waiterName,
          header: shopConfig?.receiptHeader,
          footer: shopConfig?.receiptFooter,
          logoPath: shopConfig?.logoPath,
          stationName: shopConfig?.stationName,
          timestamp: DateTime.now(),
        ));
      }
    }

    logger.i('_printToKitchen: ${jobs.length} jobs created');

    if (jobs.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Δεν βρέθηκε εκτυπωτής — ελέγξτε τις ρυθμίσεις'), backgroundColor: Colors.orange),
        );
      }
      return false;
    }

    return await _runPrintJobs(jobs);
  }

  // ── Print: Απόδειξη (cashier only, ΟΛΑ τα items) ───────────────────────
  // Εκτυπώνει ΟΛΑ τα items στον cashier, ανεξάρτητα αν έχουν πάει κουζίνα ή όχι.
  Future<bool> _printReceipt(Order order, String tableName) async {
    final printers = ref.read(printersStreamProvider).valueOrNull ?? [];
    final shopConfig = ref.read(shopConfigStreamProvider).valueOrNull;
    final localAuth = ref.read(localAuthNotifierProvider);
    final waiterName = localAuth.waiterName ?? 'Σερβιτόρος';

    if (printers.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Δεν υπάρχουν εκτυπωτές')),
        );
      }
      return false;
    }

    // Απόδειξη: ΜΟΝΟ cashier printer, ΟΛΑ τα items (τόσο receiptOnly όσο και μη)
    final cashierPrinters = printers.where((p) => p.role.name == 'cashier').toList();

    if (cashierPrinters.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Δεν υπάρχει εκτυπωτής ταμείου')),
        );
      }
      return false;
    }

    if (order.items.isEmpty) return true;

    final jobs = cashierPrinters.map((printer) => PrintJob(
      printer: printer,
      items: order.items,  // ΟΛΑ τα items στην απόδειξη
      tableName: tableName,
      waiterName: waiterName,
      header: shopConfig?.receiptHeader,
      footer: shopConfig?.receiptFooter,
      logoPath: shopConfig?.logoPath,
      stationName: shopConfig?.stationName,
      timestamp: DateTime.now(),
    )).toList();

    return await _runPrintJobs(jobs);
  }

  // ── Common print runner ──────────────────────────────────────────────────
  Future<bool> _runPrintJobs(List<PrintJob> jobs) async {
    logger.i('_runPrintJobs: ${jobs.length} jobs to send');
    for (int i = 0; i < jobs.length; i++) {
      logger.i('  Job $i: printer=${jobs[i].printer.name}, type=${jobs[i].printer.connectionType.name}, items=${jobs[i].items.length}');
    }
    final errors = List<Object?>.filled(jobs.length, null);
    await Future.wait([
      for (int i = 0; i < jobs.length; i++)
        () async {
          try {
            await ref.read(printerRepositoryProvider).printJob(jobs[i]);
          } catch (e) {
            errors[i] = e;
          }
        }(),
    ]);

    bool success = true;
    for (int i = 0; i < errors.length; i++) {
      if (errors[i] != null) {
        success = false;
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Σφάλμα εκτύπωσης ${jobs[i].printer.name}: ${errors[i]}')),
          );
        }
      }
    }

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Εστάλη στον εκτυπωτή'), backgroundColor: AppColors.success),
      );
    }
    return success;
  }

  void _showOrderHistoryDialog(BuildContext context, String tableName, Order? activeOrder) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        final groupedItems = <String, List<OrderItem>>{};
        if (activeOrder != null) {
          for (final item in activeOrder.items) {
            groupedItems.putIfAbsent(item.printStatus, () => []).add(item);
          }
        }

        final sortedKeys = groupedItems.keys.toList()
          ..sort((a, b) {
            if (a == 'pending') return -1;
            if (b == 'pending') return 1;
            return b.compareTo(a);
          });

        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.history, color: AppColors.primary),
              const SizedBox(width: 8),
              Text('Ιστορικό: $tableName'),
            ],
          ),
          contentPadding: EdgeInsets.zero,
          content: SizedBox(
            width: 500,
            height: 450,
            child: activeOrder == null || activeOrder.items.isEmpty
                            ? const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(24.0),
                                  child: Text(
                                    'Δεν υπάρχουν προϊόντα στην τρέχουσα παραγγελία.',
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.all(12),
                                itemCount: sortedKeys.length,
                                itemBuilder: (context, idx) {
                                  final printStatus = sortedKeys[idx];
                                  final itemsInBatch = groupedItems[printStatus]!;

                                  String label = '';
                                  bool isPending = printStatus == 'pending';
                                  if (isPending) {
                                    label = 'Μη εκτυπωμένα';
                                  } else {
                                    final isoStr = printStatus.substring(8);
                                    try {
                                      final dateTime = DateTime.parse(isoStr);
                                      label = 'Εκτύπωση - ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
                                    } catch (_) {
                                      label = 'Προηγούμενη Εκτύπωση';
                                    }
                                  }

                                  return Card(
                                    margin: const EdgeInsets.symmetric(vertical: 6),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.stretch,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      isPending
                                                          ? Icons.pending_outlined
                                                          : Icons.print_disabled_outlined,
                                                      color: isPending
                                                          ? AppColors.warning
                                                          : AppColors.success,
                                                      size: 18,
                                                    ),
                                                    const SizedBox(width: 6),
                                                    Expanded(
                                                      child: Text(
                                                        label,
                                                        style: TextStyle(
                                                          fontWeight: FontWeight.bold,
                                                          color: isPending
                                                              ? AppColors.warning
                                                              : AppColors.success,
                                                        ),
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              if (!isPending)
                                                IconButton(
                                                  icon: const Icon(
                                                    Icons.print,
                                                    color: Colors.orange,
                                                  ),
                                                  tooltip: 'Επανεκτύπωση',
                                                  onPressed: () async {
                                                    // Επανεκτύπωση: στέλνει όλα τα items της παρτίδας με τίτλο ΕΠΑΝΕΚΤΥΠΩΣΗ
                                                    final tempOrder = activeOrder.copyWith(items: itemsInBatch);
                                                    await _printToKitchen(tempOrder, tableName, isReprint: true);
                                                  },
                                                ),
                                            ],
                                          ),
                                          const Divider(height: 8),
                                          ...itemsInBatch.map((item) => Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Row(
                                                    children: [
                                                      if (item.receiptOnly)
                                                        const Padding(
                                                          padding: EdgeInsets.only(right: 4),
                                                          child: Icon(Icons.receipt_outlined, size: 14, color: Colors.grey),
                                                        ),
                                                      Expanded(
                                                        child: Text(
                                                          '${item.quantity}x ${item.productName}',
                                                          style: const TextStyle(fontSize: 13),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Text(
                                                  '€${(item.priceAtOrder * item.quantity).toStringAsFixed(2)}',
                                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                          )),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Κλείσιμο'),
            ),
          ],
        );
      },
    );
  }

  void _showMenuBottomSheet(
    BuildContext context,
    List<dynamic> categories,
    List<Product> allProducts,
    Order order,
    bool isDark,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: _buildMenuPane(categories, allProducts, order, isDark),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showEditNotesDialog(BuildContext context, OrderItem item) async {
    final controller = TextEditingController(text: item.notes);
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Σχόλια για ${item.productName}'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Σχόλιο / Επισήμανση',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Ακύρωση'),
          ),
          FilledButton(
            onPressed: () async {
              try {
                await ref.read(orderActionsProvider.notifier).updateItemNotes(
                      itemId: item.id,
                      notes: controller.text,
                    );
                if (context.mounted) Navigator.pop(context);
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Σφάλμα: $e')),
                  );
                }
              }
            },
            child: const Text('Αποθήκευση'),
          ),
        ],
      ),
    );
  }
}
