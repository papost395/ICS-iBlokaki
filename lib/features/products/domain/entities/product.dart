import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:order/features/products/domain/entities/department.dart';

part 'product.freezed.dart';
part 'product.g.dart';

@freezed
abstract class Product with _$Product {
  const factory Product({
    required String id,
    required String shopId,
    required String categoryId,
    required String name,
    required double price,
    @Default(Department.none) Department department,
  }) = _Product;

  factory Product.fromJson(Map<String, dynamic> json) =>
      _$ProductFromJson(json);
}
