import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:order/core/theme/app_colors.dart';
import 'package:order/features/tables/domain/entities/table_status.dart';
import 'package:order/features/tables/presentation/providers/table_providers.dart';
import 'package:order/features/home/presentation/widgets/main_navigation_shell.dart';

import 'package:order/features/orders/presentation/providers/order_providers.dart';

class TablesScreen extends ConsumerWidget {
  const TablesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tablesStream = ref.watch(tablesStreamProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Τραπέζια'),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            ref.read(scaffoldKeyProvider).currentState?.openDrawer();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(tablesStreamProvider),
          ),
        ],
      ),
      body: tablesStream.when(
        data: (tables) {
          if (tables.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.table_bar_outlined, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'Δεν βρέθηκαν τραπέζια',
                    style: TextStyle(
                      fontSize: 18,
                      color: isDark ? AppColors.textLightSecondary : AppColors.textDarkSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(24),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 180,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.8,
            ),
            itemCount: tables.length,
            itemBuilder: (context, index) {
              final table = tables[index];
              Color statusColor;
              IconData statusIcon;

              switch (table.status) {
                case Free():
                  statusColor = AppColors.tableFree;
                  statusIcon = Icons.check_circle_outline;
                  break;
                case Occupied():
                  statusColor = AppColors.tableOccupied;
                  statusIcon = Icons.people_outline;
                  break;
                case Reserved():
                  statusColor = AppColors.tableReserved;
                  statusIcon = Icons.bookmark_border;
                  break;
                case Paid():
                  statusColor = AppColors.primary;
                  statusIcon = Icons.euro_symbol;
                  break;
                case Cancelled():
                  statusColor = AppColors.error;
                  statusIcon = Icons.cancel_outlined;
                  break;
              }

              final itemBgColor = isDark ? AppColors.surfaceDarkElevated : AppColors.surfaceLightElevated;

              return Card(
                color: itemBgColor,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: statusColor.withOpacity(0.5),
                    width: 2,
                  ),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    if (table.status is Reserved) {
                      final res = table.status as Reserved;
                      final parts = res.description.split('|');
                      final resName = parts.isNotEmpty ? parts[0].trim() : '';
                      final resGuests = parts.length > 1 ? parts[1].trim() : '';
                      final timeStr = '${res.reservationTime.hour.toString().padLeft(2, '0')}:${res.reservationTime.minute.toString().padLeft(2, '0')}';
                      final dateStr = '${res.reservationTime.day.toString().padLeft(2, '0')}/${res.reservationTime.month.toString().padLeft(2, '0')}';

                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          backgroundColor: isDark ? AppColors.surfaceDarkElevated : AppColors.surfaceLightElevated,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          title: Row(
                            children: [
                              const Icon(Icons.bookmark_added_outlined, color: AppColors.tableReserved, size: 28),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Κράτηση - ${table.name}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                ),
                              ),
                            ],
                          ),
                          content: Container(
                            width: 320,
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (resName.isNotEmpty) ...[
                                  const Text(
                                    'ΟΝΟΜΑ ΚΡΑΤΗΣΗΣ',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey, letterSpacing: 0.5),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Icon(Icons.person_outline, size: 20, color: isDark ? AppColors.textLightSecondary : AppColors.textDarkSecondary),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          resName,
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: isDark ? AppColors.textLight : AppColors.textDark,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 24),
                                ],
                                if (resGuests.isNotEmpty) ...[
                                  const Text(
                                    'ΑΤΟΜΑ',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey, letterSpacing: 0.5),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Icon(Icons.people_outline, size: 20, color: isDark ? AppColors.textLightSecondary : AppColors.textDarkSecondary),
                                      const SizedBox(width: 8),
                                      Text(
                                        resGuests,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: isDark ? AppColors.textLight : AppColors.textDark,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 24),
                                ],
                                const Text(
                                  'ΗΜ/ΝΙΑ & ΩΡΑ',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey, letterSpacing: 0.5),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Icon(Icons.access_time, size: 20, color: isDark ? AppColors.textLightSecondary : AppColors.textDarkSecondary),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        '$timeStr ($dateStr)',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: isDark ? AppColors.textLight : AppColors.textDark,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          actionsAlignment: MainAxisAlignment.spaceEvenly,
                          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                          actions: [
                            IconButton.filledTonal(
                              onPressed: () {
                                Navigator.pop(ctx);
                              },
                              style: IconButton.styleFrom(
                                backgroundColor: AppColors.error.withOpacity(0.1),
                                foregroundColor: AppColors.error,
                                padding: const EdgeInsets.all(16),
                              ),
                              icon: const Icon(Icons.close),
                              tooltip: 'Ακύρωση',
                            ),
                            IconButton.filledTonal(
                              onPressed: () async {
                                Navigator.pop(ctx);
                                final result = await _showReservationDialog(
                                  context,
                                  tableName: table.name,
                                  initialName: resName,
                                  initialGuests: resGuests,
                                  initialDateTime: res.reservationTime,
                                );
                                if (result != null) {
                                  final dateTime = result['dateTime'] as DateTime;
                                  final description = result['description'] as String;
                                  ref.read(tableActionsProvider.notifier).updateStatus(
                                        tableId: table.id,
                                        status: Reserved(
                                          reservationTime: dateTime,
                                          description: description,
                                        ),
                                      );
                                }
                              },
                              style: IconButton.styleFrom(
                                backgroundColor: isDark ? Colors.blue.withOpacity(0.15) : Colors.blue.withOpacity(0.1),
                                foregroundColor: isDark ? Colors.blue[300] : Colors.blue,
                                padding: const EdgeInsets.all(16),
                              ),
                              icon: const Icon(Icons.edit_outlined),
                              tooltip: 'Επεξεργασία',
                            ),
                            IconButton.filled(
                              onPressed: () {
                                Navigator.pop(ctx);
                                context.go('/tables/${table.id}/order');
                              },
                              style: IconButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.all(16),
                              ),
                              icon: const Icon(Icons.restaurant_menu),
                              tooltip: 'Παραγγελία',
                            ),
                          ],
                        ),
                      );
                    } else {
                      context.go('/tables/${table.id}/order');
                    }
                  },
                  onLongPress: () {
                    // Quick status change
                    showModalBottomSheet(
                      context: context,
                      builder: (context) => SafeArea(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                'Αλλαγή κατάστασης: ${table.name}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ),
                            ListTile(
                              leading: const Icon(Icons.check_circle, color: AppColors.tableFree),
                              title: const Text('Ελεύθερο'),
                              onTap: () async {
                                Navigator.pop(context);
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('Ελεύθερο τραπέζι;'),
                                    content: const Text('Αυτή η ενέργεια θα ακυρώσει όλες τις ενεργές παραγγελίες του τραπεζιού.'),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Άκυρο')),
                                      TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Συνέχεια', style: TextStyle(color: AppColors.error))),
                                    ],
                                  ),
                                );
                                if (confirm == true) {
                                  ref.read(tableActionsProvider.notifier).updateStatus(tableId: table.id, status: const Free());
                                  ref.read(orderActionsProvider.notifier).cancelActiveOrdersForTable(tableId: table.id);
                                }
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.people, color: AppColors.tableOccupied),
                              title: const Text('Κατειλημμένο'),
                              onTap: () {
                                ref.read(tableActionsProvider.notifier).updateStatus(
                                      tableId: table.id,
                                      status: const Occupied(),
                                    );
                                Navigator.pop(context);
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.bookmark, color: AppColors.tableReserved),
                              title: const Text('Κράτηση'),
                              onTap: () async {
                                Navigator.pop(context);
                                final result = await _showReservationDialog(
                                  context,
                                  tableName: table.name,
                                );
                                if (result != null) {
                                  final dateTime = result['dateTime'] as DateTime;
                                  final description = result['description'] as String;
                                  ref.read(tableActionsProvider.notifier).updateStatus(
                                        tableId: table.id,
                                        status: Reserved(
                                          reservationTime: dateTime,
                                          description: description,
                                        ),
                                      );
                                }
                              },
                            ),
                            const Divider(),
                            ListTile(
                              leading: const Icon(Icons.euro, color: AppColors.primary),
                              title: const Text('Πληρώθηκε'),
                              onTap: () async {
                                Navigator.pop(context);
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('Πληρώθηκε;'),
                                    content: const Text('Θα καθαριστούν όλες οι παραγγελίες του τραπεζιού.'),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Άκυρο')),
                                      TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Συνέχεια', style: TextStyle(color: AppColors.primary))),
                                    ],
                                  ),
                                );
                                if (confirm == true) {
                                  ref.read(tableActionsProvider.notifier).updateStatus(tableId: table.id, status: const Paid());
                                  ref.read(orderActionsProvider.notifier).completeActiveOrdersForTable(tableId: table.id);
                                }
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.cancel, color: AppColors.error),
                              title: const Text('Ακυρώθηκε'),
                              onTap: () async {
                                Navigator.pop(context);
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('Ακύρωση τραπεζιού;'),
                                    content: const Text('Αυτή η ενέργεια θα ακυρώσει όλες τις ενεργές παραγγελίες του τραπεζιού.'),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Άκυρο')),
                                      TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Ακύρωση', style: TextStyle(color: AppColors.error))),
                                    ],
                                  ),
                                );
                                if (confirm == true) {
                                  ref.read(tableActionsProvider.notifier).updateStatus(tableId: table.id, status: const Cancelled());
                                  ref.read(orderActionsProvider.notifier).cancelActiveOrdersForTable(tableId: table.id);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                    child: table.status is Reserved
                        ? (() {
                            final res = table.status as Reserved;
                            final parts = res.description.split('|');
                            final resName = parts.isNotEmpty ? parts[0].trim() : '';
                            final resGuests = parts.length > 1 ? parts[1].trim() : '';
                            final timeStr = '${res.reservationTime.hour.toString().padLeft(2, '0')}:${res.reservationTime.minute.toString().padLeft(2, '0')}';
                            final dateStr = '${res.reservationTime.day.toString().padLeft(2, '0')}/${res.reservationTime.month.toString().padLeft(2, '0')}';
                            
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        table.name,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: isDark ? AppColors.textLight : AppColors.textDark,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '$timeStr ($dateStr)',
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.tableReserved,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Expanded(
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: resName.isNotEmpty
                                        ? Text(
                                            'Ν: ${resName.length > 7 ? "${resName.substring(0, 6)}..." : resName}',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                              color: isDark
                                                  ? AppColors.textLight.withOpacity(0.9)
                                                  : AppColors.textDark.withOpacity(0.9),
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          )
                                        : const SizedBox(),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.tableReserved.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Text(
                                        'ΚΡΑΤΗΣΗ',
                                        style: TextStyle(
                                          color: AppColors.tableReserved,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 9,
                                        ),
                                      ),
                                    ),
                                    if (resGuests.isNotEmpty)
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.people_outline,
                                            size: 14,
                                            color: isDark ? AppColors.textLightSecondary : AppColors.textDarkSecondary,
                                          ),
                                          const SizedBox(width: 2),
                                          Text(
                                            resGuests,
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: isDark ? AppColors.textLight : AppColors.textDark,
                                            ),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              ],
                            );
                          })()
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Icon(statusIcon, color: statusColor, size: 20),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: statusColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      _statusLabel(table.status),
                                      style: TextStyle(
                                        color: statusColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                table.name,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? AppColors.textLight : AppColors.textDark,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: 16),
              Text('Σφάλμα φόρτωσης. Δοκιμάστε ξανά.'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(tablesStreamProvider),
                child: const Text('Επανάληψη'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<Map<String, dynamic>?> _showReservationDialog(
    BuildContext context, {
    required String tableName,
    String initialName = '',
    String initialGuests = '',
    DateTime? initialDateTime,
  }) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) {
        final nameController = TextEditingController(text: initialName);
        final guestsController = TextEditingController(text: initialGuests);
        DateTime selectedDate = initialDateTime ?? DateTime.now();
        TimeOfDay selectedTime = TimeOfDay.fromDateTime(selectedDate);

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: isDark ? AppColors.surfaceDarkElevated : AppColors.surfaceLightElevated,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              title: Row(
                children: [
                  const Icon(Icons.bookmark_add_outlined, color: AppColors.tableReserved, size: 28),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      initialName.isEmpty ? 'Νέα Κράτηση - $tableName' : 'Επεξεργασία - $tableName',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ),
                ],
              ),
              content: Container(
                width: 320,
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: nameController,
                      style: TextStyle(color: isDark ? AppColors.textLight : AppColors.textDark),
                      decoration: InputDecoration(
                        labelText: 'Όνομα Κράτησης',
                        prefixIcon: const Icon(Icons.person_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: guestsController,
                      keyboardType: TextInputType.number,
                      style: TextStyle(color: isDark ? AppColors.textLight : AppColors.textDark),
                      decoration: InputDecoration(
                        labelText: 'Άτομα',
                        prefixIcon: const Icon(Icons.people_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'ΗΜΕΡΟΜΗΝΙΑ & ΩΡΑ',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${selectedDate.day}/${selectedDate.month} @ ${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? AppColors.textLight : AppColors.textDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton.filledTonal(
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.primary.withOpacity(0.15),
                            foregroundColor: AppColors.primary,
                          ),
                          onPressed: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: selectedDate,
                              firstDate: DateTime.now().subtract(const Duration(days: 30)),
                              lastDate: DateTime.now().add(const Duration(days: 365)),
                            );
                            if (date != null) {
                              setDialogState(() {
                                selectedDate = date;
                              });
                            }
                          },
                          icon: const Icon(Icons.calendar_today_outlined),
                        ),
                        const SizedBox(width: 8),
                        IconButton.filledTonal(
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.primary.withOpacity(0.15),
                            foregroundColor: AppColors.primary,
                          ),
                          onPressed: () async {
                            final time = await showTimePicker(
                              context: context,
                              initialTime: selectedTime,
                            );
                            if (time != null) {
                              setDialogState(() {
                                selectedTime = time;
                              });
                            }
                          },
                          icon: const Icon(Icons.access_time_outlined),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                  child: const Text('ΑΚΥΡΟ'),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  onPressed: () {
                    final finalDateTime = DateTime(
                      selectedDate.year,
                      selectedDate.month,
                      selectedDate.day,
                      selectedTime.hour,
                      selectedTime.minute,
                    );
                    Navigator.pop(ctx, {
                      'dateTime': finalDateTime,
                      'description': '${nameController.text.trim()}|${guestsController.text.trim()}',
                    });
                  },
                  child: Text(initialName.isEmpty ? 'ΚΡΑΤΗΣΗ' : 'ΑΠΟΘΗΚΕΥΣΗ'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

String _statusLabel(TableStatus status) {
  return switch (status) {
    Free() => 'ΕΛΕΥΘΕΡΟ',
    Occupied() => 'ΚΑΤΕΙΛ.',
    Reserved() => 'ΚΡΑΤΗΣΗ',
    Paid() => 'ΠΛΗΡΩΘΗΚΕ',
    Cancelled() => 'ΑΚΥΡΩΘΗΚΕ',
  };
}
