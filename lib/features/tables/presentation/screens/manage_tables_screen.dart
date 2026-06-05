import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:order/core/theme/app_colors.dart';
import 'package:order/features/tables/presentation/providers/table_providers.dart';

class ManageTablesScreen extends ConsumerStatefulWidget {
  final String shopId;

  const ManageTablesScreen({
    required this.shopId,
    super.key,
  });

  @override
  ConsumerState<ManageTablesScreen> createState() => _ManageTablesScreenState();
}

class _ManageTablesScreenState extends ConsumerState<ManageTablesScreen> {
  final _addController = TextEditingController();
  final Map<String, TextEditingController> _editControllers = {};
  final Map<String, bool> _isEditing = {};

  @override
  void dispose() {
    _addController.dispose();
    for (final controller in _editControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tablesAsync = ref.watch(tablesStreamProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBgColor = isDark ? AppColors.surfaceDarkElevated : AppColors.surfaceLightElevated;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Διαχείριση Τραπεζιών'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Add Table Card
              Card(
                color: cardBgColor,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Προσθήκη Νέου Τραπεζιού',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _addController,
                              decoration: const InputDecoration(
                                labelText: 'Όνομα / Αριθμός Τραπεζιού',
                                hintText: 'π.χ. Τραπέζι 12',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () async {
                              final name = _addController.text.trim();
                              if (name.isNotEmpty) {
                                _addController.clear();
                                await ref.read(tableActionsProvider.notifier).addTable(
                                      shopId: widget.shopId,
                                      name: name,
                                    );
                              }
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('Προσθήκη'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Tables List Header
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: Text(
                  'Λίστα Τραπεζιών',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              const SizedBox(height: 8),

              // Tables List
              Expanded(
                child: tablesAsync.when(
                  data: (tables) {
                    if (tables.isEmpty) {
                      return const Center(
                        child: Text(
                          'Δεν υπάρχουν τραπέζια. Προσθέστε ένα παραπάνω!',
                          style: TextStyle(color: Colors.grey),
                        ),
                      );
                    }
                    return ListView.builder(
                      itemCount: tables.length,
                      itemBuilder: (context, index) {
                        final table = tables[index];
                        final editing = _isEditing[table.id] ?? false;

                        if (!_editControllers.containsKey(table.id)) {
                          _editControllers[table.id] = TextEditingController(text: table.name);
                        }
                        final controller = _editControllers[table.id]!;

                        return Card(
                          color: cardBgColor,
                          margin: const EdgeInsets.only(bottom: 8),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                            child: Row(
                              children: [
                                const Icon(Icons.table_bar, color: AppColors.primary),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: editing
                                      ? TextField(
                                          controller: controller,
                                          autofocus: true,
                                          decoration: const InputDecoration(
                                            border: UnderlineInputBorder(),
                                            isDense: true,
                                          ),
                                        )
                                      : Text(
                                          table.name,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (editing) ...[
                                      IconButton(
                                        icon: const Icon(Icons.check, color: Colors.green),
                                        onPressed: () async {
                                          final newName = controller.text.trim();
                                          if (newName.isNotEmpty && newName != table.name) {
                                            await ref
                                                .read(tableActionsProvider.notifier)
                                                .updateTableName(
                                                  tableId: table.id,
                                                  name: newName,
                                                );
                                          }
                                          setState(() {
                                            _isEditing[table.id] = false;
                                          });
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.close, color: Colors.red),
                                        onPressed: () {
                                          controller.text = table.name;
                                          setState(() {
                                            _isEditing[table.id] = false;
                                          });
                                        },
                                      ),
                                    ] else ...[
                                      IconButton(
                                        icon: const Icon(Icons.edit, color: Colors.blue),
                                        onPressed: () {
                                          setState(() {
                                            _isEditing[table.id] = true;
                                          });
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: AppColors.error),
                                        onPressed: () async {
                                          final confirm = await showDialog<bool>(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: const Text('Διαγραφή Τραπεζιού'),
                                              content: Text(
                                                  'Είστε σίγουροι ότι θέλετε να διαγράψετε το ${table.name};'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () => Navigator.pop(context, false),
                                                  child: const Text('Ακύρωση'),
                                                ),
                                                FilledButton(
                                                  onPressed: () => Navigator.pop(context, true),
                                                  style: FilledButton.styleFrom(
                                                      backgroundColor: AppColors.error),
                                                  child: const Text('Διαγραφή'),
                                                ),
                                              ],
                                            ),
                                          );
                                          if (confirm == true) {
                                            await ref
                                                .read(tableActionsProvider.notifier)
                                                .deleteTable(table.id);
                                          }
                                        },
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Σφάλμα: $e')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
