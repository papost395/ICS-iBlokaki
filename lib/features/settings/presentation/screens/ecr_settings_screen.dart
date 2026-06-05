import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:order/core/theme/app_colors.dart';
import 'package:order/features/settings/presentation/providers/ecr_config_provider.dart';

class EcrSettingsScreen extends ConsumerStatefulWidget {
  const EcrSettingsScreen({super.key});

  @override
  ConsumerState<EcrSettingsScreen> createState() => _EcrSettingsScreenState();
}

class _EcrSettingsScreenState extends ConsumerState<EcrSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late bool _enabled;
  late String _type;
  late TextEditingController _ipController;
  late TextEditingController _portController;

  @override
  void initState() {
    super.initState();
    final config = ref.read(ecrConfigNotifierProvider);
    _enabled = config.enabled;
    _type = config.type;
    _ipController = TextEditingController(text: config.ipAddress);
    _portController = TextEditingController(text: config.port.toString());
  }

  @override
  void dispose() {
    _ipController.dispose();
    _portController.dispose();
    super.dispose();
  }

  void _saveSettings() {
    if (_formKey.currentState!.validate()) {
      ref.read(ecrConfigNotifierProvider.notifier).setConfig(
        enabled: _enabled,
        type: _type,
        ipAddress: _ipController.text.trim(),
        port: int.tryParse(_portController.text.trim()) ?? 9100,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Οι ρυθμίσεις ταμειακής αποθηκεύτηκαν.'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ταμειακή Μηχανή'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Ενεργοποίηση Διασύνδεσης',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(height: 8),
                            SwitchListTile(
                              title: const Text('Χρήση Ταμειακής Μηχανής'),
                              subtitle: const Text('Αν ενεργοποιηθεί, το πακέτο λιανικής θα στέλνει αποδείξεις στην ταμειακή.'),
                              value: _enabled,
                              onChanged: (val) {
                                setState(() {
                                  _enabled = val;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_enabled) ...[
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Στοιχεία Επικοινωνίας (TCP/IP)',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              const SizedBox(height: 16),
                              DropdownButtonFormField<String>(
                                value: _type,
                                isExpanded: true,
                                decoration: const InputDecoration(
                                  labelText: 'Τύπος Μηχανής / Πρωτόκολλο',
                                  border: OutlineInputBorder(),
                                ),
                                items: const [
                                  DropdownMenuItem(value: 'MAT', child: Text('MAT Cash Machine (InfoCarina, Mirka)')),
                                  DropdownMenuItem(value: 'NONE', child: Text('Καμία / Απενεργοποιημένο')),
                                ],
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() {
                                      _type = val;
                                    });
                                  }
                                },
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _ipController,
                                decoration: const InputDecoration(
                                  labelText: 'IP Διεύθυνση',
                                  hintText: 'π.χ. 192.168.1.100',
                                  border: OutlineInputBorder(),
                                ),
                                validator: (val) {
                                  if (val == null || val.isEmpty) {
                                    return 'Η IP δεν μπορεί να είναι κενή';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _portController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Θύρα (Port)',
                                  hintText: 'π.χ. 9100',
                                  border: OutlineInputBorder(),
                                ),
                                validator: (val) {
                                  if (val == null || val.isEmpty) {
                                    return 'Η θύρα δεν μπορεί να είναι κενή';
                                  }
                                  if (int.tryParse(val) == null) {
                                    return 'Μη έγκυρος αριθμός';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                    FilledButton(
                      onPressed: _saveSettings,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('ΑΠΟΘΗΚΕΥΣΗ'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
