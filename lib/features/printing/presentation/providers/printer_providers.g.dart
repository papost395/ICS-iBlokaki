// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'printer_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$printerRepositoryHash() => r'fbb57bd1658d8ccce259df87669e757b2a528c05';

/// See also [printerRepository].
@ProviderFor(printerRepository)
final printerRepositoryProvider = Provider<PrinterRepository>.internal(
  printerRepository,
  name: r'printerRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$printerRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PrinterRepositoryRef = ProviderRef<PrinterRepository>;
String _$printersStreamHash() => r'995d0b72cf8530874fc09ebd6c53e717b0e54bfe';

/// See also [printersStream].
@ProviderFor(printersStream)
final printersStreamProvider = StreamProvider<List<PrinterDevice>>.internal(
  printersStream,
  name: r'printersStreamProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$printersStreamHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PrintersStreamRef = StreamProviderRef<List<PrinterDevice>>;
String _$printerActionsHash() => r'736c680698658261f93c81630da313693a38971c';

/// See also [PrinterActions].
@ProviderFor(PrinterActions)
final printerActionsProvider =
    AutoDisposeAsyncNotifierProvider<PrinterActions, void>.internal(
      PrinterActions.new,
      name: r'printerActionsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$printerActionsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$PrinterActions = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
