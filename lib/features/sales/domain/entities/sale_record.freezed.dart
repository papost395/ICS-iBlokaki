// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sale_record.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SaleRecord {

 String get id; String get shopId; String get productId; String get productName; int get quantity; double get price; int get timestamp;
/// Create a copy of SaleRecord
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SaleRecordCopyWith<SaleRecord> get copyWith => _$SaleRecordCopyWithImpl<SaleRecord>(this as SaleRecord, _$identity);

  /// Serializes this SaleRecord to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SaleRecord&&(identical(other.id, id) || other.id == id)&&(identical(other.shopId, shopId) || other.shopId == shopId)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.productName, productName) || other.productName == productName)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.price, price) || other.price == price)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,shopId,productId,productName,quantity,price,timestamp);

@override
String toString() {
  return 'SaleRecord(id: $id, shopId: $shopId, productId: $productId, productName: $productName, quantity: $quantity, price: $price, timestamp: $timestamp)';
}


}

/// @nodoc
abstract mixin class $SaleRecordCopyWith<$Res>  {
  factory $SaleRecordCopyWith(SaleRecord value, $Res Function(SaleRecord) _then) = _$SaleRecordCopyWithImpl;
@useResult
$Res call({
 String id, String shopId, String productId, String productName, int quantity, double price, int timestamp
});




}
/// @nodoc
class _$SaleRecordCopyWithImpl<$Res>
    implements $SaleRecordCopyWith<$Res> {
  _$SaleRecordCopyWithImpl(this._self, this._then);

  final SaleRecord _self;
  final $Res Function(SaleRecord) _then;

/// Create a copy of SaleRecord
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? shopId = null,Object? productId = null,Object? productName = null,Object? quantity = null,Object? price = null,Object? timestamp = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,shopId: null == shopId ? _self.shopId : shopId // ignore: cast_nullable_to_non_nullable
as String,productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String,productName: null == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [SaleRecord].
extension SaleRecordPatterns on SaleRecord {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SaleRecord value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SaleRecord() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SaleRecord value)  $default,){
final _that = this;
switch (_that) {
case _SaleRecord():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SaleRecord value)?  $default,){
final _that = this;
switch (_that) {
case _SaleRecord() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String shopId,  String productId,  String productName,  int quantity,  double price,  int timestamp)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SaleRecord() when $default != null:
return $default(_that.id,_that.shopId,_that.productId,_that.productName,_that.quantity,_that.price,_that.timestamp);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String shopId,  String productId,  String productName,  int quantity,  double price,  int timestamp)  $default,) {final _that = this;
switch (_that) {
case _SaleRecord():
return $default(_that.id,_that.shopId,_that.productId,_that.productName,_that.quantity,_that.price,_that.timestamp);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String shopId,  String productId,  String productName,  int quantity,  double price,  int timestamp)?  $default,) {final _that = this;
switch (_that) {
case _SaleRecord() when $default != null:
return $default(_that.id,_that.shopId,_that.productId,_that.productName,_that.quantity,_that.price,_that.timestamp);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SaleRecord implements SaleRecord {
  const _SaleRecord({required this.id, required this.shopId, required this.productId, required this.productName, required this.quantity, required this.price, required this.timestamp});
  factory _SaleRecord.fromJson(Map<String, dynamic> json) => _$SaleRecordFromJson(json);

@override final  String id;
@override final  String shopId;
@override final  String productId;
@override final  String productName;
@override final  int quantity;
@override final  double price;
@override final  int timestamp;

/// Create a copy of SaleRecord
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SaleRecordCopyWith<_SaleRecord> get copyWith => __$SaleRecordCopyWithImpl<_SaleRecord>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SaleRecordToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SaleRecord&&(identical(other.id, id) || other.id == id)&&(identical(other.shopId, shopId) || other.shopId == shopId)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.productName, productName) || other.productName == productName)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.price, price) || other.price == price)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,shopId,productId,productName,quantity,price,timestamp);

@override
String toString() {
  return 'SaleRecord(id: $id, shopId: $shopId, productId: $productId, productName: $productName, quantity: $quantity, price: $price, timestamp: $timestamp)';
}


}

/// @nodoc
abstract mixin class _$SaleRecordCopyWith<$Res> implements $SaleRecordCopyWith<$Res> {
  factory _$SaleRecordCopyWith(_SaleRecord value, $Res Function(_SaleRecord) _then) = __$SaleRecordCopyWithImpl;
@override @useResult
$Res call({
 String id, String shopId, String productId, String productName, int quantity, double price, int timestamp
});




}
/// @nodoc
class __$SaleRecordCopyWithImpl<$Res>
    implements _$SaleRecordCopyWith<$Res> {
  __$SaleRecordCopyWithImpl(this._self, this._then);

  final _SaleRecord _self;
  final $Res Function(_SaleRecord) _then;

/// Create a copy of SaleRecord
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? shopId = null,Object? productId = null,Object? productName = null,Object? quantity = null,Object? price = null,Object? timestamp = null,}) {
  return _then(_SaleRecord(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,shopId: null == shopId ? _self.shopId : shopId // ignore: cast_nullable_to_non_nullable
as String,productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String,productName: null == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
