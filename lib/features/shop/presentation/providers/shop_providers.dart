import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:order/core/providers/pocketbase_provider.dart';
import 'package:order/features/auth/presentation/providers/auth_providers.dart';
import 'package:order/features/shop/data/datasources/shop_remote_datasource.dart';
import 'package:order/features/shop/data/repositories/shop_repository_impl.dart';
import 'package:order/features/shop/domain/entities/shop.dart';
import 'package:order/features/shop/domain/repositories/shop_repository.dart';

part 'shop_providers.g.dart';

@Riverpod(keepAlive: true)
ShopRepository shopRepository(Ref ref) {
  final pb = ref.watch(pocketBaseProvider);
  return ShopRepositoryImpl(
    remoteDataSource: ShopRemoteDataSourceImpl(pb: pb),
    pb: pb,
  );
}

@riverpod
Stream<Shop> currentShop(Ref ref) {
  final shopId = ref.watch(currentShopIdProvider);
  if (shopId == null) return const Stream.empty();
  final repo = ref.watch(shopRepositoryProvider);
  return repo.watchShop(shopId);
}
