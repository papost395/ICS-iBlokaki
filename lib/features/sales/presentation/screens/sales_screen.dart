import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:order/core/database/database_helper.dart';
import 'package:order/core/theme/app_colors.dart';
import 'package:order/features/auth/presentation/providers/auth_providers.dart';
import 'package:order/features/printing/domain/entities/print_job.dart';
import 'package:order/features/printing/domain/entities/printer_device.dart';
import 'package:order/features/printing/presentation/providers/printer_providers.dart';
import 'package:order/features/orders/domain/entities/order_item.dart';
import 'package:order/features/products/domain/entities/department.dart';
import 'package:order/features/settings/presentation/providers/settings_providers.dart';

class SalesScreen extends ConsumerStatefulWidget {
  const SalesScreen({super.key});

  @override
  ConsumerState<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends ConsumerState<SalesScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _todaySales = [];
  double _todayTotalRevenue = 0.0;
  int _todayTotalItems = 0;

  List<Map<String, dynamic>> _pastDays = [];

  @override
  void initState() {
    super.initState();
    _loadSales();
  }

  Future<void> _loadSales() async {
    setState(() => _isLoading = true);
    final shopId = ref.read(currentShopIdProvider) ?? 'local';
    
    try {
      final records = await DatabaseHelper.instance.getAllSalesRecords(shopId);
      
      final now = DateTime.now();
      final startOfToday = DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;

      final Map<String, Map<String, dynamic>> aggregatedToday = {};
      double todayRev = 0.0;
      int todayItems = 0;

      final Map<String, Map<String, dynamic>> pastDays = {};

      for (var r in records) {
        final int ts = r['timestamp'] as int;
        final String pId = r['productId'] as String;
        final String pName = r['productName'] as String;
        final int qty = r['quantity'] as int;
        final double price = r['price'] as double;
        final String orderType = r['orderType'] as String? ?? 'takeaway';
        
        final aggKey = '${pId}_$orderType';

        if (ts >= startOfToday) {
          todayRev += (qty * price);
          todayItems += qty;
          if (aggregatedToday.containsKey(aggKey)) {
            aggregatedToday[aggKey]!['quantity'] += qty;
            aggregatedToday[aggKey]!['revenue'] += (qty * price);
          } else {
            aggregatedToday[aggKey] = {
              'productName': pName,
              'quantity': qty,
              'revenue': qty * price,
              'price': price,
              'orderType': orderType,
            };
          }
        } else {
          final date = DateTime.fromMillisecondsSinceEpoch(ts);
          final key = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
          
          if (!pastDays.containsKey(key)) {
            pastDays[key] = {
              'dateStr': '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}',
              'startMs': DateTime(date.year, date.month, date.day).millisecondsSinceEpoch,
              'endMs': DateTime(date.year, date.month, date.day, 23, 59, 59, 999).millisecondsSinceEpoch,
              'totalRevenue': 0.0,
              'totalItems': 0,
              'records': <Map<String, dynamic>>[],
            };
          }
          pastDays[key]!['totalRevenue'] += (qty * price);
          pastDays[key]!['totalItems'] += qty;
          pastDays[key]!['records'].add(r);
        }
      }

      final todayList = aggregatedToday.values.toList();
      todayList.sort((a, b) => a['productName'].compareTo(b['productName']));

      final pastList = pastDays.values.toList();
      pastList.sort((a, b) => (b['startMs'] as int).compareTo(a['startMs'] as int));

      setState(() {
        _todaySales = todayList;
        _todayTotalRevenue = todayRev;
        _todayTotalItems = todayItems;
        _pastDays = pastList;
      });
    } catch (e) {
      debugPrint('Error loading sales: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _printSales(List<Map<String, dynamic>> itemsList, double totalRev, int totalItems, String title) async {
    final shopId = ref.read(currentShopIdProvider);
    if (shopId == null) return;

    final repo = ref.read(printerRepositoryProvider);
    final printers = await repo.getPrinters(shopId);
    
    final cashierPrinters = printers.where((p) => p.role == PrinterRole.cashier).toList();
    if (cashierPrinters.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Δεν βρέθηκε ταμειακός εκτυπωτής')),
        );
      }
      return;
    }

    final printer = cashierPrinters.first;
    final settingsRepo = ref.read(settingsRepositoryProvider);
    final config = await settingsRepo.getShopConfig(shopId);

    final List<OrderItem> printItems = [];
    
    final tableItems = itemsList.where((i) => i['orderType'] == 'table').toList();
    final takeawayItems = itemsList.where((i) => i['orderType'] == 'takeaway').toList();

    if (takeawayItems.isNotEmpty) {
      printItems.add(OrderItem(
        id: 'header_takeaway', orderId: 'sales', productId: 'header', productName: '--- ΠΩΛΗΣΕΙΣ ΠΑΚΕΤΟΥ ---',
        quantity: 0, priceAtOrder: 0, department: Department.none, notes: ''
      ));
      printItems.addAll(takeawayItems.map((s) => OrderItem(
        id: 'ds_${DateTime.now().microsecondsSinceEpoch}', orderId: 'sales', productId: 'agg', productName: s['productName'],
        quantity: s['quantity'], priceAtOrder: s['price'], department: Department.none, notes: '',
      )));
    }

    if (tableItems.isNotEmpty) {
      printItems.add(OrderItem(
        id: 'header_table', orderId: 'sales', productId: 'header', productName: '--- ΠΩΛΗΣΕΙΣ ΤΡΑΠΕΖΙΩΝ ---',
        quantity: 0, priceAtOrder: 0, department: Department.none, notes: ''
      ));
      printItems.addAll(tableItems.map((s) => OrderItem(
        id: 'ds_${DateTime.now().microsecondsSinceEpoch}', orderId: 'sales', productId: 'agg', productName: s['productName'],
        quantity: s['quantity'], priceAtOrder: s['price'], department: Department.none, notes: '',
      )));
    }

    final job = PrintJob(
      printer: printer,
      tableName: title,
      waiterName: 'Admin',
      items: printItems,
      timestamp: DateTime.now(),
      header: title,
      footer: 'ΣΥΝΟΛΙΚΑ ΕΣΟΔΑ: ${totalRev.toStringAsFixed(2)} EUR\nΣΥΝΟΛΟ ΤΕΜΑΧΙΩΝ: $totalItems',
      logoPath: config?.logoPath,
    );

    try {
      await repo.printJob(job);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Η εκτύπωση στάλθηκε με επιτυχία!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Σφάλμα εκτύπωσης: $e')),
        );
      }
    }
  }

  Future<void> _printPastDay(Map<String, dynamic> pastDay) async {
    final rawRecords = pastDay['records'] as List<Map<String, dynamic>>;
    final Map<String, Map<String, dynamic>> aggregated = {};

    for (var r in rawRecords) {
      final String pId = r['productId'] as String;
      final String pName = r['productName'] as String;
      final int qty = r['quantity'] as int;
      final double price = r['price'] as double;
      
      final String orderType = r['orderType'] as String? ?? 'takeaway';
      final aggKey = '${pId}_$orderType';
      
      if (aggregated.containsKey(aggKey)) {
        aggregated[aggKey]!['quantity'] += qty;
        aggregated[aggKey]!['revenue'] += (qty * price);
      } else {
        aggregated[aggKey] = {
          'productName': pName,
          'quantity': qty,
          'revenue': qty * price,
          'price': price,
          'orderType': orderType,
        };
      }
    }

    final list = aggregated.values.toList();
    list.sort((a, b) => a['productName'].compareTo(b['productName']));

    await _printSales(
      list, 
      pastDay['totalRevenue'] as double, 
      pastDay['totalItems'] as int, 
      'ΠΩΛΗΣΕΙΣ - ${pastDay['dateStr']}'
    );
  }

  Future<void> _deletePastDay(Map<String, dynamic> pastDay) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Διαγραφή Πωλήσεων'),
        content: Text('Είστε σίγουροι ότι θέλετε να διαγράψετε τις πωλήσεις για την ημερομηνία ${pastDay['dateStr']};'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Ακύρωση'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Διαγραφή'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final shopId = ref.read(currentShopIdProvider) ?? 'local';
        await DatabaseHelper.instance.deleteSalesRecordsForDateRange(
          shopId, 
          pastDay['startMs'] as int, 
          pastDay['endMs'] as int,
        );
        _loadSales(); // Reload after deletion
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Σφάλμα διαγραφής: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Πωλήσεις'),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : CustomScrollView(
            slivers: [
              // Today's Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    'Σήμερα',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              
              // Today's Totals
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          const Text('Σύνολο Εσόδων', style: TextStyle(fontSize: 14)),
                          Text('${_todayTotalRevenue.toStringAsFixed(2)} €', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary)),
                        ],
                      ),
                      Column(
                        children: [
                          const Text('Σύνολο Τεμαχίων', style: TextStyle(fontSize: 14)),
                          Text('$_todayTotalItems', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Today's Print Button
              if (_todaySales.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: FilledButton.icon(
                        onPressed: () => _printSales(_todaySales, _todayTotalRevenue, _todayTotalItems, 'ΠΩΛΗΣΕΙΣ ΗΜΕΡΑΣ'),
                        icon: const Icon(Icons.print),
                        label: const Text('Εκτύπωση Σημερινών Πωλήσεων', style: TextStyle(fontSize: 16)),
                      ),
                    ),
                  ),
                ),

              // Today's List
              if (_todaySales.isNotEmpty)
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final item = _todaySales[index];
                      return ListTile(
                        title: Text(item['productName'], style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('Τεμάχια: ${item['quantity']}'),
                        trailing: Text('${(item['revenue'] as double).toStringAsFixed(2)} €', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      );
                    },
                    childCount: _todaySales.length,
                  ),
                )
              else
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Center(
                      child: Text(
                        'Δεν υπάρχουν πωλήσεις για σήμερα.',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ),
                  ),
                ),

              // Divider
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Divider(thickness: 1),
                ),
              ),

              // Past Days Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Text(
                    'Ιστορικό Πωλήσεων',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),

              // Past Days List
              if (_pastDays.isNotEmpty)
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final day = _pastDays[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        elevation: 1,
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          title: Text(
                            day['dateStr'],
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          subtitle: Text(
                            'Έσοδα: ${(day['totalRevenue'] as double).toStringAsFixed(2)} €  •  Τεμάχια: ${day['totalItems']}',
                            style: const TextStyle(fontSize: 14),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.print, color: AppColors.primary),
                                tooltip: 'Εκτύπωση',
                                onPressed: () => _printPastDay(day),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: AppColors.error),
                                tooltip: 'Διαγραφή',
                                onPressed: () => _deletePastDay(day),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    childCount: _pastDays.length,
                  ),
                )
              else
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Center(
                      child: Text(
                        'Δεν υπάρχουν πωλήσεις προηγούμενων ημερών.',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ),
                  ),
                ),
                
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          ),
    );
  }
}
