import 'package:freezed_annotation/freezed_annotation.dart';

part 'waiter.freezed.dart';
part 'waiter.g.dart';

@freezed
abstract class Waiter with _$Waiter {
  const factory Waiter({
    required String id,
    required String shopId,
    required String name,
    required String pin,
    @Default(false) bool isAdmin,
  }) = _Waiter;

  factory Waiter.fromJson(Map<String, dynamic> json) => _$WaiterFromJson(json);
}
