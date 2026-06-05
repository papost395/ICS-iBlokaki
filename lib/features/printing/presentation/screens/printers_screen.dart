import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:order/core/theme/app_colors.dart';
import 'package:order/features/printing/domain/entities/printer_device.dart';
import 'package:order/features/printing/presentation/providers/printer_providers.dart';

class PrintersScreen extends ConsumerStatefulWidget {
  const PrintersScreen({super.key});

  @override
  ConsumerState<PrintersScreen> createState() => _PrintersScreenState();
}

class _PrintersScreenState extends ConsumerState<PrintersScreen> {
  final Map<String, bool?> _testingStatus = {};

  Future<void> _testPrinter(PrinterDevice printer) async {
    setState(() {
      _testingStatus[printer.id] = null; // null means loading/testing
    });

    try {
      final success = await ref.read(printerRepositoryProvider).testConnection(printer);
      if (mounted) {
        setState(() {
          _testingStatus[printer.id] = success;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success ? 'Successfully connected to ${printer.name}!' : 'Failed to connect to ${printer.name}.',
            ),
            backgroundColor: success ? AppColors.success : AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _testingStatus[printer.id] = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error testing connection: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final printersStream = ref.watch(printersStreamProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Printers Setup'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(printersStreamProvider),
          ),
        ],
      ),
      body: printersStream.when(
        data: (printers) {
          if (printers.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.print_disabled_outlined, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'No printers configured',
                    style: TextStyle(
                      fontSize: 18,
                      color: isDark ? AppColors.textLightSecondary : AppColors.textDarkSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Configure printers in your PocketBase backend.',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: printers.length,
            itemBuilder: (context, index) {
              final printer = printers[index];
              final status = _testingStatus[printer.id];
              final itemBgColor = isDark ? AppColors.surfaceDarkElevated : AppColors.surfaceLightElevated;

              Widget statusIndicator;
              if (status == null && _testingStatus.containsKey(printer.id)) {
                statusIndicator = const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                );
              } else if (status == true) {
                statusIndicator = const Icon(Icons.check_circle, color: AppColors.success);
              } else if (status == false) {
                statusIndicator = const Icon(Icons.error, color: AppColors.error);
              } else {
                statusIndicator = const Icon(Icons.help_outline, color: Colors.grey);
              }

              return Card(
                color: itemBgColor,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                        child: const Icon(Icons.print, color: AppColors.primary),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              printer.name,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Type: ${printer.connectionType.name.toUpperCase()} | Address: ${printer.address}',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? AppColors.textLightSecondary : AppColors.textDarkSecondary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'ROLE: ${printer.role.name.toUpperCase()}',
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          statusIndicator,
                          const SizedBox(width: 12),
                          OutlinedButton.icon(
                            onPressed: () => _testPrinter(printer),
                            icon: const Icon(Icons.sync_alt, size: 16),
                            label: const Text('Test'),
                          ),
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
        error: (err, stack) => Center(child: Text('Error loading printers: $err')),
      ),
    );
  }
}
