// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'printer_device.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PrinterDevice {

 String get id; String get shopId; String get name; ConnectionType get connectionType; String get address; PrinterRole get role; bool get isUtf8; bool get isCp737; int get paperSize; bool get isDoubleSize; bool get isExtraBold;
/// Create a copy of PrinterDevice
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PrinterDeviceCopyWith<PrinterDevice> get copyWith => _$PrinterDeviceCopyWithImpl<PrinterDevice>(this as PrinterDevice, _$identity);

  /// Serializes this PrinterDevice to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PrinterDevice&&(identical(other.id, id) || other.id == id)&&(identical(other.shopId, shopId) || other.shopId == shopId)&&(identical(other.name, name) || other.name == name)&&(identical(other.connectionType, connectionType) || other.connectionType == connectionType)&&(identical(other.address, address) || other.address == address)&&(identical(other.role, role) || other.role == role)&&(identical(other.isUtf8, isUtf8) || other.isUtf8 == isUtf8)&&(identical(other.isCp737, isCp737) || other.isCp737 == isCp737)&&(identical(other.paperSize, paperSize) || other.paperSize == paperSize)&&(identical(other.isDoubleSize, isDoubleSize) || other.isDoubleSize == isDoubleSize)&&(identical(other.isExtraBold, isExtraBold) || other.isExtraBold == isExtraBold));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,shopId,name,connectionType,address,role,isUtf8,isCp737,paperSize,isDoubleSize,isExtraBold);

@override
String toString() {
  return 'PrinterDevice(id: $id, shopId: $shopId, name: $name, connectionType: $connectionType, address: $address, role: $role, isUtf8: $isUtf8, isCp737: $isCp737, paperSize: $paperSize, isDoubleSize: $isDoubleSize, isExtraBold: $isExtraBold)';
}


}

/// @nodoc
abstract mixin class $PrinterDeviceCopyWith<$Res>  {
  factory $PrinterDeviceCopyWith(PrinterDevice value, $Res Function(PrinterDevice) _then) = _$PrinterDeviceCopyWithImpl;
@useResult
$Res call({
 String id, String shopId, String name, ConnectionType connectionType, String address, PrinterRole role, bool isUtf8, bool isCp737, int paperSize, bool isDoubleSize, bool isExtraBold
});




}
/// @nodoc
class _$PrinterDeviceCopyWithImpl<$Res>
    implements $PrinterDeviceCopyWith<$Res> {
  _$PrinterDeviceCopyWithImpl(this._self, this._then);

  final PrinterDevice _self;
  final $Res Function(PrinterDevice) _then;

/// Create a copy of PrinterDevice
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? shopId = null,Object? name = null,Object? connectionType = null,Object? address = null,Object? role = null,Object? isUtf8 = null,Object? isCp737 = null,Object? paperSize = null,Object? isDoubleSize = null,Object? isExtraBold = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,shopId: null == shopId ? _self.shopId : shopId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,connectionType: null == connectionType ? _self.connectionType : connectionType // ignore: cast_nullable_to_non_nullable
as ConnectionType,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as PrinterRole,isUtf8: null == isUtf8 ? _self.isUtf8 : isUtf8 // ignore: cast_nullable_to_non_nullable
as bool,isCp737: null == isCp737 ? _self.isCp737 : isCp737 // ignore: cast_nullable_to_non_nullable
as bool,paperSize: null == paperSize ? _self.paperSize : paperSize // ignore: cast_nullable_to_non_nullable
as int,isDoubleSize: null == isDoubleSize ? _self.isDoubleSize : isDoubleSize // ignore: cast_nullable_to_non_nullable
as bool,isExtraBold: null == isExtraBold ? _self.isExtraBold : isExtraBold // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [PrinterDevice].
extension PrinterDevicePatterns on PrinterDevice {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PrinterDevice value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PrinterDevice() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PrinterDevice value)  $default,){
final _that = this;
switch (_that) {
case _PrinterDevice():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PrinterDevice value)?  $default,){
final _that = this;
switch (_that) {
case _PrinterDevice() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String shopId,  String name,  ConnectionType connectionType,  String address,  PrinterRole role,  bool isUtf8,  bool isCp737,  int paperSize,  bool isDoubleSize,  bool isExtraBold)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PrinterDevice() when $default != null:
return $default(_that.id,_that.shopId,_that.name,_that.connectionType,_that.address,_that.role,_that.isUtf8,_that.isCp737,_that.paperSize,_that.isDoubleSize,_that.isExtraBold);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String shopId,  String name,  ConnectionType connectionType,  String address,  PrinterRole role,  bool isUtf8,  bool isCp737,  int paperSize,  bool isDoubleSize,  bool isExtraBold)  $default,) {final _that = this;
switch (_that) {
case _PrinterDevice():
return $default(_that.id,_that.shopId,_that.name,_that.connectionType,_that.address,_that.role,_that.isUtf8,_that.isCp737,_that.paperSize,_that.isDoubleSize,_that.isExtraBold);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String shopId,  String name,  ConnectionType connectionType,  String address,  PrinterRole role,  bool isUtf8,  bool isCp737,  int paperSize,  bool isDoubleSize,  bool isExtraBold)?  $default,) {final _that = this;
switch (_that) {
case _PrinterDevice() when $default != null:
return $default(_that.id,_that.shopId,_that.name,_that.connectionType,_that.address,_that.role,_that.isUtf8,_that.isCp737,_that.paperSize,_that.isDoubleSize,_that.isExtraBold);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PrinterDevice implements PrinterDevice {
  const _PrinterDevice({required this.id, required this.shopId, required this.name, required this.connectionType, required this.address, required this.role, this.isUtf8 = false, this.isCp737 = false, this.paperSize = 80, this.isDoubleSize = false, this.isExtraBold = false});
  factory _PrinterDevice.fromJson(Map<String, dynamic> json) => _$PrinterDeviceFromJson(json);

@override final  String id;
@override final  String shopId;
@override final  String name;
@override final  ConnectionType connectionType;
@override final  String address;
@override final  PrinterRole role;
@override@JsonKey() final  bool isUtf8;
@override@JsonKey() final  bool isCp737;
@override@JsonKey() final  int paperSize;
@override@JsonKey() final  bool isDoubleSize;
@override@JsonKey() final  bool isExtraBold;

/// Create a copy of PrinterDevice
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PrinterDeviceCopyWith<_PrinterDevice> get copyWith => __$PrinterDeviceCopyWithImpl<_PrinterDevice>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PrinterDeviceToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PrinterDevice&&(identical(other.id, id) || other.id == id)&&(identical(other.shopId, shopId) || other.shopId == shopId)&&(identical(other.name, name) || other.name == name)&&(identical(other.connectionType, connectionType) || other.connectionType == connectionType)&&(identical(other.address, address) || other.address == address)&&(identical(other.role, role) || other.role == role)&&(identical(other.isUtf8, isUtf8) || other.isUtf8 == isUtf8)&&(identical(other.isCp737, isCp737) || other.isCp737 == isCp737)&&(identical(other.paperSize, paperSize) || other.paperSize == paperSize)&&(identical(other.isDoubleSize, isDoubleSize) || other.isDoubleSize == isDoubleSize)&&(identical(other.isExtraBold, isExtraBold) || other.isExtraBold == isExtraBold));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,shopId,name,connectionType,address,role,isUtf8,isCp737,paperSize,isDoubleSize,isExtraBold);

@override
String toString() {
  return 'PrinterDevice(id: $id, shopId: $shopId, name: $name, connectionType: $connectionType, address: $address, role: $role, isUtf8: $isUtf8, isCp737: $isCp737, paperSize: $paperSize, isDoubleSize: $isDoubleSize, isExtraBold: $isExtraBold)';
}


}

/// @nodoc
abstract mixin class _$PrinterDeviceCopyWith<$Res> implements $PrinterDeviceCopyWith<$Res> {
  factory _$PrinterDeviceCopyWith(_PrinterDevice value, $Res Function(_PrinterDevice) _then) = __$PrinterDeviceCopyWithImpl;
@override @useResult
$Res call({
 String id, String shopId, String name, ConnectionType connectionType, String address, PrinterRole role, bool isUtf8, bool isCp737, int paperSize, bool isDoubleSize, bool isExtraBold
});




}
/// @nodoc
class __$PrinterDeviceCopyWithImpl<$Res>
    implements _$PrinterDeviceCopyWith<$Res> {
  __$PrinterDeviceCopyWithImpl(this._self, this._then);

  final _PrinterDevice _self;
  final $Res Function(_PrinterDevice) _then;

/// Create a copy of PrinterDevice
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? shopId = null,Object? name = null,Object? connectionType = null,Object? address = null,Object? role = null,Object? isUtf8 = null,Object? isCp737 = null,Object? paperSize = null,Object? isDoubleSize = null,Object? isExtraBold = null,}) {
  return _then(_PrinterDevice(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,shopId: null == shopId ? _self.shopId : shopId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,connectionType: null == connectionType ? _self.connectionType : connectionType // ignore: cast_nullable_to_non_nullable
as ConnectionType,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as PrinterRole,isUtf8: null == isUtf8 ? _self.isUtf8 : isUtf8 // ignore: cast_nullable_to_non_nullable
as bool,isCp737: null == isCp737 ? _self.isCp737 : isCp737 // ignore: cast_nullable_to_non_nullable
as bool,paperSize: null == paperSize ? _self.paperSize : paperSize // ignore: cast_nullable_to_non_nullable
as int,isDoubleSize: null == isDoubleSize ? _self.isDoubleSize : isDoubleSize // ignore: cast_nullable_to_non_nullable
as bool,isExtraBold: null == isExtraBold ? _self.isExtraBold : isExtraBold // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
