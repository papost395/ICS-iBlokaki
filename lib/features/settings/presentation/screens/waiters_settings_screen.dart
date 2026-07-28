import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:order/core/theme/app_colors.dart';
import 'package:order/features/auth/domain/entities/waiter.dart';
import 'package:order/features/auth/presentation/providers/auth_providers.dart';

class WaitersSettingsScreen extends ConsumerWidget {
  const WaitersSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final waitersAsync = ref.watch(waitersFutureProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Χρήστες / Σερβιτόροι'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Προσθήκη Χρήστη',
            onPressed: () => _showAddWaiterDialog(context, ref),
          ),
        ],
      ),
      body: SafeArea(
        child: waitersAsync.when(
          data: (waiters) {
            if (waiters.isEmpty) {
              return const Center(
                child: Text('Δεν υπάρχουν χρήστες.'),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: waiters.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final waiter = waiters[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primary,
                    child: Text(
                      waiter.name.isNotEmpty ? waiter.name[0].toUpperCase() : '?',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text('${waiter.name} ${waiter.isAdmin ? '(Admin)' : ''}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('PIN: ${waiter.pin}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: AppColors.error),
                    onPressed: () => _confirmDelete(context, ref, waiter),
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Σφάλμα: $err')),
        ),
      ),
    );
  }

  Future<void> _showAddWaiterDialog(BuildContext context, WidgetRef ref) async {
    final nameController = TextEditingController();
    final pinController = TextEditingController();
    bool isAdmin = false;

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Νέος Χρήστης'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Όνομα'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: pinController,
                    decoration: const InputDecoration(labelText: 'PIN'),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 10),
                  CheckboxListTile(
                    title: const Text('Είναι Διαχειριστής (Admin)'),
                    value: isAdmin,
                    onChanged: (val) {
                      setState(() {
                        isAdmin = val ?? false;
                      });
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('ΑΚΥΡΟ'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('ΑΠΟΘΗΚΕΥΣΗ'),
                ),
              ],
            );
          }
        );
      },
    );

    if (result == true) {
      final name = nameController.text.trim();
      final pin = pinController.text.trim();
      final shopId = ref.read(currentShopIdProvider) ?? 'local';

      if (name.isNotEmpty && pin.isNotEmpty) {
        final newWaiter = Waiter(
          id: 'w_${DateTime.now().millisecondsSinceEpoch}',
          shopId: shopId,
          name: name,
          pin: pin,
          isAdmin: isAdmin,
        );
        try {
          await ref.read(waiterRepositoryProvider).addWaiter(newWaiter);
          ref.invalidate(waitersFutureProvider);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Ο χρήστης προστέθηκε'), backgroundColor: AppColors.success),
            );
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Σφάλμα: $e'), backgroundColor: AppColors.error),
            );
          }
        }
      }
    }
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref, Waiter waiter) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Διαγραφή;'),
        content: Text('Θέλετε σίγουρα να διαγράψετε τον χρήστη "${waiter.name}";'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('ΑΚΥΡΟ')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('ΔΙΑΓΡΑΦΗ', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ref.read(waiterRepositoryProvider).deleteWaiter(waiter.id);
        ref.invalidate(waitersFutureProvider);
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Σφάλμα: $e'), backgroundColor: AppColors.error),
          );
        }
      }
    }
  }
}
