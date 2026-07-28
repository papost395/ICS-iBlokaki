import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:order/core/providers/pocketbase_provider.dart';
import 'package:order/features/auth/presentation/providers/auth_providers.dart';
import 'package:order/features/settings/presentation/providers/settings_providers.dart';
import 'package:order/features/printing/data/datasources/printer_remote_datasource.dart';
import 'package:order/features/printing/data/repositories/printer_repository_impl.dart';
import 'package:order/features/printing/domain/entities/printer_device.dart';
import 'package:order/features/printing/domain/repositories/printer_repository.dart';

import 'package:order/core/providers/storage_mode_provider.dart';

part 'printer_providers.g.dart';

@Riverpod(keepAlive: true)
PrinterRepository printerRepository(Ref ref) {
  final pb = ref.watch(pocketBaseProvider);
  final settingsRepo = ref.watch(settingsRepositoryProvider);
  final isLocalMode = ref.watch(storageModeNotifierProvider);
  return PrinterRepositoryImpl(
    remoteDataSource: PrinterRemoteDataSourceImpl(pb: pb),
    pb: pb,
    settingsRepo: settingsRepo,
    isLocalMode: isLocalMode,
  );
}

@Riverpod(keepAlive: true)
Stream<List<PrinterDevice>> printersStream(Ref ref) {
  final shopId = ref.watch(currentShopIdProvider);
  if (shopId == null) return const Stream.empty();
  final repo = ref.watch(printerRepositoryProvider);
  return repo.watchPrinters(shopId);
}

@riverpod
class PrinterActions extends _$PrinterActions {
  @override
  FutureOr<void> build() {}

  Future<void> addPrinter(PrinterDevice printer) async {
    final repo = ref.read(printerRepositoryProvider);
    await repo.addPrinter(printer);
    ref.invalidate(printersStreamProvider);
  }

  Future<void> deletePrinter(String id) async {
    final repo = ref.read(printerRepositoryProvider);
    await repo.deletePrinter(id);
    ref.invalidate(printersStreamProvider);
  }

  Future<void> updatePrinter(PrinterDevice printer) async {
    final repo = ref.read(printerRepositoryProvider);
    await repo.updatePrinter(printer);
    ref.invalidate(printersStreamProvider);
  }
}
