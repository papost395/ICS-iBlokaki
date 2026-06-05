// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'shop_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ShopConfig {

 String get id; String get shopId; bool get isSplitPrintingEnabled; String get receiptHeader; String get receiptFooter;
/// Create a copy of ShopConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ShopConfigCopyWith<ShopConfig> get copyWith => _$ShopConfigCopyWithImpl<ShopConfig>(this as ShopConfig, _$identity);

  /// Serializes this ShopConfig to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ShopConfig&&(identical(other.id, id) || other.id == id)&&(identical(other.shopId, shopId) || other.shopId == shopId)&&(identical(other.isSplitPrintingEnabled, isSplitPrintingEnabled) || other.isSplitPrintingEnabled == isSplitPrintingEnabled)&&(identical(other.receiptHeader, receiptHeader) || other.receiptHeader == receiptHeader)&&(identical(other.receiptFooter, receiptFooter) || other.receiptFooter == receiptFooter));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,shopId,isSplitPrintingEnabled,receiptHeader,receiptFooter);

@override
String toString() {
  return 'ShopConfig(id: $id, shopId: $shopId, isSplitPrintingEnabled: $isSplitPrintingEnabled, receiptHeader: $receiptHeader, receiptFooter: $receiptFooter)';
}


}

/// @nodoc
abstract mixin class $ShopConfigCopyWith<$Res>  {
  factory $ShopConfigCopyWith(ShopConfig value, $Res Function(ShopConfig) _then) = _$ShopConfigCopyWithImpl;
@useResult
$Res call({
 String id, String shopId, bool isSplitPrintingEnabled, String receiptHeader, String receiptFooter
});




}
/// @nodoc
class _$ShopConfigCopyWithImpl<$Res>
    implements $ShopConfigCopyWith<$Res> {
  _$ShopConfigCopyWithImpl(this._self, this._then);

  final ShopConfig _self;
  final $Res Function(ShopConfig) _then;

/// Create a copy of ShopConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? shopId = null,Object? isSplitPrintingEnabled = null,Object? receiptHeader = null,Object? receiptFooter = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,shopId: null == shopId ? _self.shopId : shopId // ignore: cast_nullable_to_non_nullable
as String,isSplitPrintingEnabled: null == isSplitPrintingEnabled ? _self.isSplitPrintingEnabled : isSplitPrintingEnabled // ignore: cast_nullable_to_non_nullable
as bool,receiptHeader: null == receiptHeader ? _self.receiptHeader : receiptHeader // ignore: cast_nullable_to_non_nullable
as String,receiptFooter: null == receiptFooter ? _self.receiptFooter : receiptFooter // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ShopConfig].
extension ShopConfigPatterns on ShopConfig {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ShopConfig value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ShopConfig() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ShopConfig value)  $default,){
final _that = this;
switch (_that) {
case _ShopConfig():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ShopConfig value)?  $default,){
final _that = this;
switch (_that) {
case _ShopConfig() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String shopId,  bool isSplitPrintingEnabled,  String receiptHeader,  String receiptFooter)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ShopConfig() when $default != null:
return $default(_that.id,_that.shopId,_that.isSplitPrintingEnabled,_that.receiptHeader,_that.receiptFooter);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String shopId,  bool isSplitPrintingEnabled,  String receiptHeader,  String receiptFooter)  $default,) {final _that = this;
switch (_that) {
case _ShopConfig():
return $default(_that.id,_that.shopId,_that.isSplitPrintingEnabled,_that.receiptHeader,_that.receiptFooter);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String shopId,  bool isSplitPrintingEnabled,  String receiptHeader,  String receiptFooter)?  $default,) {final _that = this;
switch (_that) {
case _ShopConfig() when $default != null:
return $default(_that.id,_that.shopId,_that.isSplitPrintingEnabled,_that.receiptHeader,_that.receiptFooter);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ShopConfig implements ShopConfig {
  const _ShopConfig({required this.id, required this.shopId, this.isSplitPrintingEnabled = false, this.receiptHeader = '', this.receiptFooter = ''});
  factory _ShopConfig.fromJson(Map<String, dynamic> json) => _$ShopConfigFromJson(json);

@override final  String id;
@override final  String shopId;
@override@JsonKey() final  bool isSplitPrintingEnabled;
@override@JsonKey() final  String receiptHeader;
@override@JsonKey() final  String receiptFooter;

/// Create a copy of ShopConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ShopConfigCopyWith<_ShopConfig> get copyWith => __$ShopConfigCopyWithImpl<_ShopConfig>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ShopConfigToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ShopConfig&&(identical(other.id, id) || other.id == id)&&(identical(other.shopId, shopId) || other.shopId == shopId)&&(identical(other.isSplitPrintingEnabled, isSplitPrintingEnabled) || other.isSplitPrintingEnabled == isSplitPrintingEnabled)&&(identical(other.receiptHeader, receiptHeader) || other.receiptHeader == receiptHeader)&&(identical(other.receiptFooter, receiptFooter) || other.receiptFooter == receiptFooter));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,shopId,isSplitPrintingEnabled,receiptHeader,receiptFooter);

@override
String toString() {
  return 'ShopConfig(id: $id, shopId: $shopId, isSplitPrintingEnabled: $isSplitPrintingEnabled, receiptHeader: $receiptHeader, receiptFooter: $receiptFooter)';
}


}

/// @nodoc
abstract mixin class _$ShopConfigCopyWith<$Res> implements $ShopConfigCopyWith<$Res> {
  factory _$ShopConfigCopyWith(_ShopConfig value, $Res Function(_ShopConfig) _then) = __$ShopConfigCopyWithImpl;
@override @useResult
$Res call({
 String id, String shopId, bool isSplitPrintingEnabled, String receiptHeader, String receiptFooter
});




}
/// @nodoc
class __$ShopConfigCopyWithImpl<$Res>
    implements _$ShopConfigCopyWith<$Res> {
  __$ShopConfigCopyWithImpl(this._self, this._then);

  final _ShopConfig _self;
  final $Res Function(_ShopConfig) _then;

/// Create a copy of ShopConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? shopId = null,Object? isSplitPrintingEnabled = null,Object? receiptHeader = null,Object? receiptFooter = null,}) {
  return _then(_ShopConfig(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,shopId: null == shopId ? _self.shopId : shopId // ignore: cast_nullable_to_non_nullable
as String,isSplitPrintingEnabled: null == isSplitPrintingEnabled ? _self.isSplitPrintingEnabled : isSplitPrintingEnabled // ignore: cast_nullable_to_non_nullable
as bool,receiptHeader: null == receiptHeader ? _self.receiptHeader : receiptHeader // ignore: cast_nullable_to_non_nullable
as String,receiptFooter: null == receiptFooter ? _self.receiptFooter : receiptFooter // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
