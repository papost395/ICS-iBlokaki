import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:order/core/theme/app_colors.dart';
import 'package:order/features/printing/domain/entities/printer_device.dart';
import 'package:order/features/printing/presentation/providers/printer_providers.dart';

class ManagePrintersScreen extends ConsumerStatefulWidget {
  final String shopId;

  const ManagePrintersScreen({
    required this.shopId,
    super.key,
  });

  @override
  ConsumerState<ManagePrintersScreen> createState() => _ManagePrintersScreenState();
}

class _ManagePrintersScreenState extends ConsumerState<ManagePrintersScreen> {
  final Map<String, bool?> _testingStatus = {};

  Future<void> _testPrinter(PrinterDevice printer) async {
    setState(() {
      _testingStatus[printer.id] = null; // null means testing in progress
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
              success ? 'Επιτυχής σύνδεση με ${printer.name}!' : 'Αποτυχία σύνδεσης με ${printer.name}.',
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
            content: Text('Σφάλμα δοκιμής: $e'),
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
    final cardBgColor = isDark ? AppColors.surfaceDarkElevated : AppColors.surfaceLightElevated;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Διαχείριση Εκτυπωτών'),
      ),
      body: SafeArea(
        child: printersStream.when(
          data: (printers) {
            if (printers.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.print_disabled_outlined, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text(
                      'Δεν υπάρχουν εκτυπωτές.',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditPrinterScreen(shopId: widget.shopId),
                          ),
                        );
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Προσθήκη Εκτυπωτή'),
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
                  color: cardBgColor,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
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
                                    '${printer.connectionType.name.toUpperCase()} • ${printer.address}',
                                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                            statusIndicator,
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Ρόλος: ${printer.role.name.toUpperCase()}',
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                TextButton.icon(
                                  onPressed: () => _testPrinter(printer),
                                  icon: const Icon(Icons.sync_alt, size: 16),
                                  label: const Text('Test'),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => EditPrinterScreen(
                                          shopId: widget.shopId,
                                          printer: printer,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: AppColors.error),
                                  onPressed: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Διαγραφή Εκτυπωτή'),
                                        content: Text('Είστε σίγουροι ότι θέλετε να διαγράψετε τον εκτυπωτή ${printer.name};'),
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
                                      await ref.read(printerActionsProvider.notifier).deletePrinter(printer.id);
                                    }
                                  },
                                ),
                              ],
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
          error: (err, stack) => Center(child: Text('Σφάλμα: $err')),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditPrinterScreen(shopId: widget.shopId),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Προσθήκη'),
      ),
    );
  }
}

class EditPrinterScreen extends ConsumerStatefulWidget {
  final String shopId;
  final PrinterDevice? printer;

  const EditPrinterScreen({
    required this.shopId,
    this.printer,
    super.key,
  });

  @override
  ConsumerState<EditPrinterScreen> createState() => _EditPrinterScreenState();
}

class _EditPrinterScreenState extends ConsumerState<EditPrinterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  ConnectionType _connectionType = ConnectionType.network;
  PrinterRole _role = PrinterRole.cashier;
  bool _isSaving = false;
  bool _isUtf8 = false;
  bool _isCp737 = false;
  int _paperSize = 80;

  List<BluetoothDevice> _bondedDevices = [];
  bool _isLoadingDevices = false;

  Future<bool> _requestBluetoothPermissions() async {
    if (!Platform.isAndroid) return true;

    int sdkInt = 0;
    try {
      final versionStr = Platform.operatingSystemVersion;
      final match = RegExp(r'SDK\s+(\d+)').firstMatch(versionStr);
      if (match != null) {
        sdkInt = int.tryParse(match.group(1) ?? '') ?? 0;
      } else {
        final matchDigits = RegExp(r'(\d+)').firstMatch(versionStr);
        if (matchDigits != null) {
          sdkInt = int.tryParse(matchDigits.group(1) ?? '') ?? 0;
        }
      }
    } catch (_) {}

    if (sdkInt >= 31) {
      final status = await Permission.bluetoothConnect.request();
      final scanStatus = await Permission.bluetoothScan.request();
      return status.isGranted && scanStatus.isGranted;
    } else {
      final status = await Permission.location.request();
      return status.isGranted;
    }
  }

  Future<void> _loadBluetoothDevices() async {
    if (!Platform.isAndroid) return;

    setState(() {
      _isLoadingDevices = true;
    });

    try {
      final hasPermission = await _requestBluetoothPermissions();
      if (hasPermission) {
        final devices = await BlueThermalPrinter.instance.getBondedDevices();
        setState(() {
          _bondedDevices = devices;
          
          final address = _addressController.text.trim();
          if (address.isNotEmpty) {
            final exists = _bondedDevices.any((d) => d.address == address);
            if (!exists) {
              _bondedDevices.insert(
                0,
                BluetoothDevice(widget.printer?.name ?? 'Unknown Device', address),
              );
            }
          }
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Δεν παραχωρήθηκαν δικαιώματα Bluetooth για την εύρεση συσκευών.'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error loading bonded devices: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingDevices = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    final p = widget.printer;
    if (p != null) {
      _nameController.text = p.name;
      _addressController.text = p.address;
      _connectionType = p.connectionType;
      _role = p.role;
      _isUtf8 = p.isUtf8;
      _isCp737 = p.isCp737;
      _paperSize = p.paperSize;
    }
    if (_connectionType == ConnectionType.bluetooth) {
      _loadBluetoothDevices();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    final p = widget.printer;
    final printer = PrinterDevice(
      id: p?.id ?? '',
      shopId: widget.shopId,
      name: _nameController.text.trim(),
      connectionType: _connectionType,
      address: _addressController.text.trim(),
      role: _role,
      isUtf8: _isUtf8,
      isCp737: _isCp737,
      paperSize: _paperSize,
    );

    try {
      if (p == null) {
        await ref.read(printerActionsProvider.notifier).addPrinter(printer);
      } else {
        await ref.read(printerActionsProvider.notifier).updatePrinter(printer);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(p == null ? 'Ο εκτυπωτής προστέθηκε!' : 'Ο εκτυπωτής ενημερώθηκε!'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Σφάλμα αποθήκευσης: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBgColor = isDark ? AppColors.surfaceDarkElevated : AppColors.surfaceLightElevated;
    final isEdit = widget.printer != null;

    final addressLabel = _connectionType == ConnectionType.network 
        ? 'IP Διεύθυνση' 
        : (_connectionType == ConnectionType.cloud ? 'Σειριακός Αριθμός (SN)' : 'MAC Διεύθυνση');
    final addressHint = _connectionType == ConnectionType.network 
        ? 'π.χ. 192.168.1.100:9100' 
        : (_connectionType == ConnectionType.cloud ? 'π.χ. N123456789' : 'π.χ. 00:11:22:33:FF:EE');

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Επεξεργασία Εκτυπωτή' : 'Προσθήκη Εκτυπωτή'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Card(
                color: cardBgColor,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Όνομα Εκτυπωτή',
                            hintText: 'π.χ. Εκτυπωτής Κουζίνας',
                            border: OutlineInputBorder(),
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Παρακαλώ εισάγετε ένα όνομα';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<ConnectionType>(
                          value: _connectionType,
                          decoration: const InputDecoration(
                            labelText: 'Τύπος Σύνδεσης',
                            border: OutlineInputBorder(),
                          ),
                          items: ConnectionType.values.map((type) {
                            return DropdownMenuItem(
                              value: type,
                              child: Text(type.name.toUpperCase()),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _connectionType = val;
                                if (val == ConnectionType.bluetooth) {
                                  _loadBluetoothDevices();
                                }
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        if (_connectionType == ConnectionType.bluetooth) ...[
                          if (_isLoadingDevices)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: CircularProgressIndicator(),
                              ),
                            )
                          else if (_bondedDevices.isEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Row(
                                children: [
                                  const Expanded(
                                    child: Text(
                                      'Δεν βρέθηκαν συζευγμένες συσκευές Bluetooth στο Android. Κάντε σύζευξη στις ρυθμίσεις της συσκευής σας.',
                                      style: TextStyle(color: Colors.orange, fontSize: 13),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.refresh),
                                    onPressed: _loadBluetoothDevices,
                                  ),
                                ],
                              ),
                            )
                          else ...[
                            Builder(
                              builder: (context) {
                                BluetoothDevice? selectedValue;
                                final address = _addressController.text.trim();
                                if (address.isNotEmpty) {
                                  try {
                                    selectedValue = _bondedDevices.firstWhere(
                                      (d) => d.address == address,
                                    );
                                  } catch (_) {}
                                }

                                return DropdownButtonFormField<BluetoothDevice>(
                                  value: selectedValue,
                                  isExpanded: true,
                                  decoration: const InputDecoration(
                                    labelText: 'Επιλογή Συσκευής Bluetooth',
                                    border: OutlineInputBorder(),
                                  ),
                                  items: _bondedDevices.map((device) {
                                    return DropdownMenuItem<BluetoothDevice>(
                                      value: device,
                                      child: Text(
                                        '${device.name ?? 'Unknown Device'} (${device.address})',
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (device) {
                                    if (device != null) {
                                      setState(() {
                                        _addressController.text = device.address ?? '';
                                        if (_nameController.text.trim().isEmpty) {
                                          _nameController.text = device.name ?? '';
                                        }
                                      });
                                    }
                                  },
                                  validator: (val) {
                                    if (val == null && _addressController.text.isEmpty) {
                                      return 'Παρακαλώ επιλέξτε μια συσκευή';
                                    }
                                    return null;
                                  },
                                );
                              }
                            ),
                          ],
                          const SizedBox(height: 16),
                        ] else ...[
                          TextFormField(
                            controller: _addressController,
                            key: ValueKey(_connectionType), // Recreate field so hint updates
                            decoration: InputDecoration(
                              labelText: addressLabel,
                              hintText: addressHint,
                              border: const OutlineInputBorder(),
                            ),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Παρακαλώ εισάγετε μια διεύθυνση';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                        ],
                        DropdownButtonFormField<PrinterRole>(
                          value: _role,
                          decoration: const InputDecoration(
                            labelText: 'Ρόλος Εκτυπωτή',
                            border: OutlineInputBorder(),
                          ),
                          items: PrinterRole.values.map((role) {
                            return DropdownMenuItem(
                              value: role,
                              child: Text(role.name.toUpperCase()),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _role = val;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Κωδικοποίηση / Γραμματοσειρά Εκτυπωτή',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<int>(
                          value: _paperSize,
                          decoration: const InputDecoration(
                            labelText: 'Μέγεθος Χαρτιού (Paper Size)',
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(value: 80, child: Text('80mm')),
                            DropdownMenuItem(value: 58, child: Text('58mm')),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _paperSize = val;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 8),
                        SwitchListTile(
                          title: const Text('Κωδικοσελίδα UTF-8'),
                          value: _isUtf8,
                          contentPadding: EdgeInsets.zero,
                          onChanged: (val) {
                            setState(() {
                              _isUtf8 = val;
                              if (val) {
                                _isCp737 = false;
                              }
                            });
                          },
                        ),
                        SwitchListTile(
                          title: const Text('Κωδικοσελίδα CP737'),
                          value: _isCp737,
                          contentPadding: EdgeInsets.zero,
                          onChanged: (val) {
                            setState(() {
                              _isCp737 = val;
                              if (val) {
                                _isUtf8 = false;
                              }
                            });
                          },
                        ),
                        const SizedBox(height: 20),
                        FilledButton.icon(
                          onPressed: _isSaving ? null : _save,
                          icon: _isSaving
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Icon(Icons.save),
                          label: Text(isEdit ? 'Αποθήκευση Αλλαγών' : 'Προσθήκη Εκτυπωτή'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
