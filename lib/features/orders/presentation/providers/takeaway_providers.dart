import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:order/features/products/domain/entities/product.dart';

part 'takeaway_providers.g.dart';

class TakeawayCartItem {
  final Product product;
  final int quantity;

  TakeawayCartItem({required this.product, this.quantity = 1});

  TakeawayCartItem copyWith({Product? product, int? quantity}) {
    return TakeawayCartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }
}

@riverpod
class TakeawayCart extends _$TakeawayCart {
  @override
  List<TakeawayCartItem> build() => [];

  void addProduct(Product product) {
    final index = state.indexWhere((item) => item.product.id == product.id);
    if (index >= 0) {
      final updated = List<TakeawayCartItem>.from(state);
      updated[index] = updated[index].copyWith(quantity: updated[index].quantity + 1);
      state = updated;
    } else {
      state = [...state, TakeawayCartItem(product: product)];
    }
  }

  void removeProduct(Product product) {
    final index = state.indexWhere((item) => item.product.id == product.id);
    if (index >= 0) {
      final updated = List<TakeawayCartItem>.from(state);
      if (updated[index].quantity > 1) {
        updated[index] = updated[index].copyWith(quantity: updated[index].quantity - 1);
        state = updated;
      } else {
        updated.removeAt(index);
        state = updated;
      }
    }
  }

  void clear() {
    state = [];
  }

  double get total {
    return state.fold(0.0, (sum, item) => sum + (item.product.price * item.quantity));
  }
}
