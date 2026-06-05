// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'waiter.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Waiter {

 String get id; String get shopId; String get name; String get pin;
/// Create a copy of Waiter
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WaiterCopyWith<Waiter> get copyWith => _$WaiterCopyWithImpl<Waiter>(this as Waiter, _$identity);

  /// Serializes this Waiter to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Waiter&&(identical(other.id, id) || other.id == id)&&(identical(other.shopId, shopId) || other.shopId == shopId)&&(identical(other.name, name) || other.name == name)&&(identical(other.pin, pin) || other.pin == pin));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,shopId,name,pin);

@override
String toString() {
  return 'Waiter(id: $id, shopId: $shopId, name: $name, pin: $pin)';
}


}

/// @nodoc
abstract mixin class $WaiterCopyWith<$Res>  {
  factory $WaiterCopyWith(Waiter value, $Res Function(Waiter) _then) = _$WaiterCopyWithImpl;
@useResult
$Res call({
 String id, String shopId, String name, String pin
});




}
/// @nodoc
class _$WaiterCopyWithImpl<$Res>
    implements $WaiterCopyWith<$Res> {
  _$WaiterCopyWithImpl(this._self, this._then);

  final Waiter _self;
  final $Res Function(Waiter) _then;

/// Create a copy of Waiter
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? shopId = null,Object? name = null,Object? pin = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,shopId: null == shopId ? _self.shopId : shopId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,pin: null == pin ? _self.pin : pin // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Waiter].
extension WaiterPatterns on Waiter {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Waiter value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Waiter() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Waiter value)  $default,){
final _that = this;
switch (_that) {
case _Waiter():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Waiter value)?  $default,){
final _that = this;
switch (_that) {
case _Waiter() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String shopId,  String name,  String pin)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Waiter() when $default != null:
return $default(_that.id,_that.shopId,_that.name,_that.pin);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String shopId,  String name,  String pin)  $default,) {final _that = this;
switch (_that) {
case _Waiter():
return $default(_that.id,_that.shopId,_that.name,_that.pin);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String shopId,  String name,  String pin)?  $default,) {final _that = this;
switch (_that) {
case _Waiter() when $default != null:
return $default(_that.id,_that.shopId,_that.name,_that.pin);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Waiter implements Waiter {
  const _Waiter({required this.id, required this.shopId, required this.name, required this.pin});
  factory _Waiter.fromJson(Map<String, dynamic> json) => _$WaiterFromJson(json);

@override final  String id;
@override final  String shopId;
@override final  String name;
@override final  String pin;

/// Create a copy of Waiter
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WaiterCopyWith<_Waiter> get copyWith => __$WaiterCopyWithImpl<_Waiter>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WaiterToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Waiter&&(identical(other.id, id) || other.id == id)&&(identical(other.shopId, shopId) || other.shopId == shopId)&&(identical(other.name, name) || other.name == name)&&(identical(other.pin, pin) || other.pin == pin));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,shopId,name,pin);

@override
String toString() {
  return 'Waiter(id: $id, shopId: $shopId, name: $name, pin: $pin)';
}


}

/// @nodoc
abstract mixin class _$WaiterCopyWith<$Res> implements $WaiterCopyWith<$Res> {
  factory _$WaiterCopyWith(_Waiter value, $Res Function(_Waiter) _then) = __$WaiterCopyWithImpl;
@override @useResult
$Res call({
 String id, String shopId, String name, String pin
});




}
/// @nodoc
class __$WaiterCopyWithImpl<$Res>
    implements _$WaiterCopyWith<$Res> {
  __$WaiterCopyWithImpl(this._self, this._then);

  final _Waiter _self;
  final $Res Function(_Waiter) _then;

/// Create a copy of Waiter
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? shopId = null,Object? name = null,Object? pin = null,}) {
  return _then(_Waiter(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,shopId: null == shopId ? _self.shopId : shopId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,pin: null == pin ? _self.pin : pin // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
