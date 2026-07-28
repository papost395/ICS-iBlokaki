import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:order/core/theme/app_colors.dart';
import 'package:order/core/providers/device_config_provider.dart';
import 'package:order/core/providers/pocketbase_provider.dart';
import 'package:order/features/auth/presentation/providers/auth_providers.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _pinController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _submitWaiter() async {
    final pin = _pinController.text.trim();
    if (pin.isEmpty || _isLoading) return;

    setState(() => _isLoading = true);
    try {
      final shopId = ref.read(currentShopIdProvider);
      if (shopId == null) throw Exception('Shop ID not found in device config.');

      final repo = ref.read(waiterRepositoryProvider);
      final waiter = await repo.getWaiterByPin(shopId, pin);

      if (waiter != null) {
        ref.read(localAuthNotifierProvider.notifier).loginAsWaiter(waiter.id, waiter.name, waiter.isAdmin);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Λάθος PIN'), backgroundColor: AppColors.error),
          );
          _pinController.clear();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildNumpadButton(String text, {VoidCallback? onPressed}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: FilledButton.tonal(
          style: FilledButton.styleFrom(
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
          ),
          onPressed: onPressed ?? () {
            if (_pinController.text.length < 10) {
              setState(() {
                _pinController.text += text;
              });
            }
          },
          child: Text(
            text,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.surfaceDarkElevated : AppColors.surfaceLightElevated;
    final screenHeight = MediaQuery.of(context).size.height;

    // Logo takes ~22% of screen height, rest split between PIN display and numpad
    final logoSize = screenHeight * 1.85;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.restore, color: Colors.grey),
            tooltip: 'Επαναφορά Συσκευής',
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Επαναφορά Συσκευής;'),
                  content: const Text('Θα διαγραφούν οι ρυθμίσεις και θα μεταφερθείτε στην αρχική οθόνη.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('ΑΚΥΡΟ')),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('ΕΠΑΝΑΦΟΡΑ', style: TextStyle(color: AppColors.error)),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                ref.read(pocketBaseProvider).authStore.clear();
                ref.read(deviceConfigNotifierProvider.notifier).clearConfig();
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Logo ──────────────────────────────────────
                    Center(
                      child: SvgPicture.asset(
                        'assets/images/logo.svg',
                        width: logoSize.clamp(80, 150),
                        height: logoSize.clamp(80, 150),
                        fit: BoxFit.contain,
                        colorFilter: ColorFilter.mode(
                          isDark ? Colors.white.withOpacity(0.92) : Colors.black.withOpacity(0.80),
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── PIN display + Numpad Card ─────────────────
                    Card(
                      color: surfaceColor,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // PIN dots display
                            TextField(
                              controller: _pinController,
                              textAlign: TextAlign.center,
                              obscureText: true,
                              obscuringCharacter: '•',
                              readOnly: true,
                              style: const TextStyle(
                                fontSize: 34,
                                letterSpacing: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: 'PIN',
                              ),
                            ),

                            const SizedBox(height: 10),

                            // Numpad — uses Expanded rows to fill evenly
                            _buildNumRow(['1', '2', '3']),
                            _buildNumRow(['4', '5', '6']),
                            _buildNumRow(['7', '8', '9']),
                            Row(
                              children: [
                                _buildNumpadButton('C', onPressed: () {
                                  setState(() => _pinController.clear());
                                }),
                                _buildNumpadButton('0'),
                                _buildNumpadButton('⌫', onPressed: () {
                                  if (_pinController.text.isNotEmpty) {
                                    setState(() {
                                      _pinController.text = _pinController.text
                                          .substring(0, _pinController.text.length - 1);
                                    });
                                  }
                                }),
                              ],
                            ),

                            const SizedBox(height: 14),

                            // Submit button
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: FilledButton(
                                onPressed: _isLoading ? null : _submitWaiter,
                                style: FilledButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2.5, color: Colors.white),
                                      )
                                    : const Text(
                                        'ΕΙΣΟΔΟΣ',
                                        style: TextStyle(
                                            fontSize: 17, fontWeight: FontWeight.bold),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
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

  Widget _buildNumRow(List<String> labels) {
    return Row(children: labels.map((l) => _buildNumpadButton(l)).toList());
  }
}
