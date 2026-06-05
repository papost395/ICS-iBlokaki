// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'table_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RestaurantTable {

 String get id; String get shopId; String get name; TableStatus get status;
/// Create a copy of RestaurantTable
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RestaurantTableCopyWith<RestaurantTable> get copyWith => _$RestaurantTableCopyWithImpl<RestaurantTable>(this as RestaurantTable, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RestaurantTable&&(identical(other.id, id) || other.id == id)&&(identical(other.shopId, shopId) || other.shopId == shopId)&&(identical(other.name, name) || other.name == name)&&(identical(other.status, status) || other.status == status));
}


@override
int get hashCode => Object.hash(runtimeType,id,shopId,name,status);

@override
String toString() {
  return 'RestaurantTable(id: $id, shopId: $shopId, name: $name, status: $status)';
}


}

/// @nodoc
abstract mixin class $RestaurantTableCopyWith<$Res>  {
  factory $RestaurantTableCopyWith(RestaurantTable value, $Res Function(RestaurantTable) _then) = _$RestaurantTableCopyWithImpl;
@useResult
$Res call({
 String id, String shopId, String name, TableStatus status
});




}
/// @nodoc
class _$RestaurantTableCopyWithImpl<$Res>
    implements $RestaurantTableCopyWith<$Res> {
  _$RestaurantTableCopyWithImpl(this._self, this._then);

  final RestaurantTable _self;
  final $Res Function(RestaurantTable) _then;

/// Create a copy of RestaurantTable
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? shopId = null,Object? name = null,Object? status = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,shopId: null == shopId ? _self.shopId : shopId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TableStatus,
  ));
}

}


/// Adds pattern-matching-related methods to [RestaurantTable].
extension RestaurantTablePatterns on RestaurantTable {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RestaurantTable value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RestaurantTable() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RestaurantTable value)  $default,){
final _that = this;
switch (_that) {
case _RestaurantTable():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RestaurantTable value)?  $default,){
final _that = this;
switch (_that) {
case _RestaurantTable() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String shopId,  String name,  TableStatus status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RestaurantTable() when $default != null:
return $default(_that.id,_that.shopId,_that.name,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String shopId,  String name,  TableStatus status)  $default,) {final _that = this;
switch (_that) {
case _RestaurantTable():
return $default(_that.id,_that.shopId,_that.name,_that.status);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String shopId,  String name,  TableStatus status)?  $default,) {final _that = this;
switch (_that) {
case _RestaurantTable() when $default != null:
return $default(_that.id,_that.shopId,_that.name,_that.status);case _:
  return null;

}
}

}

/// @nodoc


class _RestaurantTable implements RestaurantTable {
  const _RestaurantTable({required this.id, required this.shopId, required this.name, required this.status});
  

@override final  String id;
@override final  String shopId;
@override final  String name;
@override final  TableStatus status;

/// Create a copy of RestaurantTable
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RestaurantTableCopyWith<_RestaurantTable> get copyWith => __$RestaurantTableCopyWithImpl<_RestaurantTable>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RestaurantTable&&(identical(other.id, id) || other.id == id)&&(identical(other.shopId, shopId) || other.shopId == shopId)&&(identical(other.name, name) || other.name == name)&&(identical(other.status, status) || other.status == status));
}


@override
int get hashCode => Object.hash(runtimeType,id,shopId,name,status);

@override
String toString() {
  return 'RestaurantTable(id: $id, shopId: $shopId, name: $name, status: $status)';
}


}

/// @nodoc
abstract mixin class _$RestaurantTableCopyWith<$Res> implements $RestaurantTableCopyWith<$Res> {
  factory _$RestaurantTableCopyWith(_RestaurantTable value, $Res Function(_RestaurantTable) _then) = __$RestaurantTableCopyWithImpl;
@override @useResult
$Res call({
 String id, String shopId, String name, TableStatus status
});




}
/// @nodoc
class __$RestaurantTableCopyWithImpl<$Res>
    implements _$RestaurantTableCopyWith<$Res> {
  __$RestaurantTableCopyWithImpl(this._self, this._then);

  final _RestaurantTable _self;
  final $Res Function(_RestaurantTable) _then;

/// Create a copy of RestaurantTable
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? shopId = null,Object? name = null,Object? status = null,}) {
  return _then(_RestaurantTable(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,shopId: null == shopId ? _self.shopId : shopId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as TableStatus,
  ));
}


}

// dart format on
