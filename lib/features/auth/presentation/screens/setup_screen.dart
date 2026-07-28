import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:order/core/providers/device_config_provider.dart';
import 'package:order/core/providers/pocketbase_provider.dart';
import 'package:order/core/theme/app_colors.dart';
import 'package:order/core/providers/storage_mode_provider.dart';

class SetupScreen extends ConsumerStatefulWidget {
  const SetupScreen({super.key});

  @override
  ConsumerState<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends ConsumerState<SetupScreen> {
  bool _isScanning = false;
  bool _isLoading = false;

  void _onDetect(BarcodeCapture capture) async {
    if (_isLoading) return;
    
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      final String code = barcodes.first.rawValue ?? '';
      try {
        final Map<String, dynamic> data = jsonDecode(code);
        final url = data['url'];
        final shopId = data['shop_id'] ?? data['shopId'];
        final email = data['email'];
        final password = data['password'];
        
        if (url != null && shopId != null) {
          setState(() {
            _isScanning = false;
            _isLoading = true;
          });
          
          await ref.read(deviceConfigNotifierProvider.notifier).setConfig(
            apiUrl: url.toString(),
            shopId: shopId.toString(),
          );

          // Authenticate in the background if credentials are provided
          if (email != null && password != null) {
            try {
              final pb = ref.read(pocketBaseProvider);
              await pb.collection('users').authWithPassword(email, password);
            } catch (authError) {
              _showError('Αποτυχία σύνδεσης στο παρασκήνιο (λάθος email/password).');
              setState(() {
                _isLoading = false;
                _isScanning = true;
              });
              return;
            }
          }
          
          await Future.delayed(const Duration(seconds: 1)); // Artificial delay
          
          if (mounted) {
            context.go('/login');
          }
        } else {
          _showError('Μη έγκυρο QR Code (λείπει url ή shop_id).');
        }
      } catch (e) {
        _showError('Αποτυχία ανάγνωσης QR Code.');
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final elevatedColor = isDark ? AppColors.surfaceDarkElevated : AppColors.surfaceLightElevated;
    final textColor = isDark ? AppColors.textLight : AppColors.textDark;
    final subtextColor = isDark ? AppColors.textLightSecondary : AppColors.textDarkSecondary;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: bgColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 3,
              ),
              const SizedBox(height: 24),
              Text(
                'Γίνεται παραμετροποίηση...',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Παρακαλώ περιμένετε',
                style: TextStyle(
                  fontSize: 14,
                  color: subtextColor,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_isScanning) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            MobileScanner(
              onDetect: _onDetect,
            ),
            // Επικάλυψη σκίασης (Overlay) για εστίαση
            ColorFiltered(
              colorFilter: ColorFilter.mode(
                Colors.black.withValues(alpha: 0.7),
                BlendMode.srcOut,
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      backgroundBlendMode: BlendMode.dstOut,
                    ),
                  ),
                  Center(
                    child: Container(
                      height: 250,
                      width: 250,
                      decoration: BoxDecoration(
                        color: Colors.red, // Αυτό το χρώμα θα αφαιρεθεί από το srcOut
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Περίγραμμα (Frame) σκαναρίσματος
            Center(
              child: Container(
                height: 250,
                width: 250,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.primary, width: 3),
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
            // Κουμπί επιστροφής
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: IconButton.filled(
                  onPressed: () => setState(() => _isScanning = false),
                  icon: const Icon(Icons.close),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black45,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ),
            // Κείμενο οδηγίας
            const SafeArea(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.only(bottom: 64.0),
                  child: Text(
                    'Στοχεύστε το QR Code του καταστήματος\nμέσα στο πλαίσιο',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      shadows: [Shadow(color: Colors.black87, blurRadius: 8)],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: bgColor,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              padding: const EdgeInsets.all(32.0),
              decoration: BoxDecoration(
                color: elevatedColor,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.qr_code_scanner_rounded,
                      size: 64,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Καλώς ήρθατε!',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: textColor,
                      letterSpacing: -0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Η συσκευή χρειάζεται παραμετροποίηση.\nΣκανάρετε το QR Code του καταστήματος για να συνδεθείτε με τον Server.',
                    style: TextStyle(
                      fontSize: 15,
                      color: subtextColor,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: FilledButton.icon(
                      // Disable scanning for now
                      onPressed: null, // () => setState(() => _isScanning = true),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.camera_alt_rounded),
                      label: const Text(
                        'Σάρωση QR Code (Απενεργοποιημένο)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        // Start local mode
                        final container = ProviderScope.containerOf(context);
                        // Save local mode state
                        ref.read(storageModeNotifierProvider.notifier).setLocalMode(true);
                        
                        setState(() => _isLoading = true);
                        
                        // We need to set the storage mode to true
                        // I will import the provider at the top of the file.
                        
                        await ref.read(deviceConfigNotifierProvider.notifier).setConfig(
                          apiUrl: 'local',
                          shopId: 'local',
                        );
                        
                        // Wait a bit
                        await Future.delayed(const Duration(seconds: 1));
                        if (mounted) {
                          context.go('/login');
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      icon: const Icon(Icons.storage_rounded),
                      label: const Text(
                        'Χρήση Τοπικής Βάσης (Χωρίς Cloud)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
