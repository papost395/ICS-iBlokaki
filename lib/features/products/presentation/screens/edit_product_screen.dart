import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:order/core/theme/app_colors.dart';
import 'package:order/features/products/domain/entities/department.dart';
import 'package:order/features/products/domain/entities/product.dart';
import 'package:order/features/products/presentation/providers/product_providers.dart';

class EditProductScreen extends ConsumerStatefulWidget {
  const EditProductScreen({required this.product, super.key});

  final Product product;

  @override
  ConsumerState<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends ConsumerState<EditProductScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late Department _department;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product.name);
    _priceController = TextEditingController(text: widget.product.price.toStringAsFixed(2));
    _department = widget.product.department;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    final priceStr = _priceController.text.trim().replaceAll(',', '.');
    final price = double.tryParse(priceStr);

    if (name.isEmpty || price == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Παρακαλώ εισάγετε ένα έγκυρο όνομα και τιμή')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final updatedProduct = widget.product.copyWith(
        name: name,
        price: price,
        department: _department,
      );

      await ref.read(productActionsProvider.notifier).updateProduct(updatedProduct);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Το προϊόν ενημερώθηκε επιτυχώς!'), backgroundColor: AppColors.success),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Σφάλμα ενημέρωσης: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBgColor = isDark ? AppColors.surfaceDarkElevated : AppColors.surfaceLightElevated;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Επεξεργασία Προϊόντος'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Card(
                color: cardBgColor,
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Στοιχεία Προϊόντος',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Όνομα Προϊόντος',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.fastfood),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _priceController,
                        decoration: const InputDecoration(
                          labelText: 'Τιμή (€)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.euro),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      ),
                      const SizedBox(height: 20),
                      DropdownButtonFormField<Department>(
                        value: _department,
                        decoration: const InputDecoration(
                          labelText: 'Τμήμα (Department)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.category),
                        ),
                        items: Department.values.map((dept) {
                          return DropdownMenuItem(
                            value: dept,
                            child: Text(dept.name.toUpperCase()),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _department = val);
                          }
                        },
                      ),
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: _isSaving ? null : () => Navigator.pop(context),
                            child: const Text('Ακύρωση'),
                          ),
                          const SizedBox(width: 16),
                          FilledButton.icon(
                            onPressed: _isSaving ? null : _save,
                            icon: _isSaving
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                : const Icon(Icons.save),
                            label: const Text('Αποθήκευση'),
                          ),
                        ],
                      ),
                    ],
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
