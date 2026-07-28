// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'print_job.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PrintJob {

 PrinterDevice get printer; List<OrderItem> get items; String get tableName; String get waiterName; String? get header; String? get footer; String? get logoPath; String? get stationName; DateTime? get timestamp;
/// Create a copy of PrintJob
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PrintJobCopyWith<PrintJob> get copyWith => _$PrintJobCopyWithImpl<PrintJob>(this as PrintJob, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PrintJob&&(identical(other.printer, printer) || other.printer == printer)&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.tableName, tableName) || other.tableName == tableName)&&(identical(other.waiterName, waiterName) || other.waiterName == waiterName)&&(identical(other.header, header) || other.header == header)&&(identical(other.footer, footer) || other.footer == footer)&&(identical(other.logoPath, logoPath) || other.logoPath == logoPath)&&(identical(other.stationName, stationName) || other.stationName == stationName)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp));
}


@override
int get hashCode => Object.hash(runtimeType,printer,const DeepCollectionEquality().hash(items),tableName,waiterName,header,footer,logoPath,stationName,timestamp);

@override
String toString() {
  return 'PrintJob(printer: $printer, items: $items, tableName: $tableName, waiterName: $waiterName, header: $header, footer: $footer, logoPath: $logoPath, stationName: $stationName, timestamp: $timestamp)';
}


}

/// @nodoc
abstract mixin class $PrintJobCopyWith<$Res>  {
  factory $PrintJobCopyWith(PrintJob value, $Res Function(PrintJob) _then) = _$PrintJobCopyWithImpl;
@useResult
$Res call({
 PrinterDevice printer, List<OrderItem> items, String tableName, String waiterName, String? header, String? footer, String? logoPath, String? stationName, DateTime? timestamp
});


$PrinterDeviceCopyWith<$Res> get printer;

}
/// @nodoc
class _$PrintJobCopyWithImpl<$Res>
    implements $PrintJobCopyWith<$Res> {
  _$PrintJobCopyWithImpl(this._self, this._then);

  final PrintJob _self;
  final $Res Function(PrintJob) _then;

/// Create a copy of PrintJob
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? printer = null,Object? items = null,Object? tableName = null,Object? waiterName = null,Object? header = freezed,Object? footer = freezed,Object? logoPath = freezed,Object? stationName = freezed,Object? timestamp = freezed,}) {
  return _then(_self.copyWith(
printer: null == printer ? _self.printer : printer // ignore: cast_nullable_to_non_nullable
as PrinterDevice,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<OrderItem>,tableName: null == tableName ? _self.tableName : tableName // ignore: cast_nullable_to_non_nullable
as String,waiterName: null == waiterName ? _self.waiterName : waiterName // ignore: cast_nullable_to_non_nullable
as String,header: freezed == header ? _self.header : header // ignore: cast_nullable_to_non_nullable
as String?,footer: freezed == footer ? _self.footer : footer // ignore: cast_nullable_to_non_nullable
as String?,logoPath: freezed == logoPath ? _self.logoPath : logoPath // ignore: cast_nullable_to_non_nullable
as String?,stationName: freezed == stationName ? _self.stationName : stationName // ignore: cast_nullable_to_non_nullable
as String?,timestamp: freezed == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of PrintJob
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PrinterDeviceCopyWith<$Res> get printer {
  
  return $PrinterDeviceCopyWith<$Res>(_self.printer, (value) {
    return _then(_self.copyWith(printer: value));
  });
}
}


/// Adds pattern-matching-related methods to [PrintJob].
extension PrintJobPatterns on PrintJob {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PrintJob value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PrintJob() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PrintJob value)  $default,){
final _that = this;
switch (_that) {
case _PrintJob():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PrintJob value)?  $default,){
final _that = this;
switch (_that) {
case _PrintJob() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( PrinterDevice printer,  List<OrderItem> items,  String tableName,  String waiterName,  String? header,  String? footer,  String? logoPath,  String? stationName,  DateTime? timestamp)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PrintJob() when $default != null:
return $default(_that.printer,_that.items,_that.tableName,_that.waiterName,_that.header,_that.footer,_that.logoPath,_that.stationName,_that.timestamp);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( PrinterDevice printer,  List<OrderItem> items,  String tableName,  String waiterName,  String? header,  String? footer,  String? logoPath,  String? stationName,  DateTime? timestamp)  $default,) {final _that = this;
switch (_that) {
case _PrintJob():
return $default(_that.printer,_that.items,_that.tableName,_that.waiterName,_that.header,_that.footer,_that.logoPath,_that.stationName,_that.timestamp);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( PrinterDevice printer,  List<OrderItem> items,  String tableName,  String waiterName,  String? header,  String? footer,  String? logoPath,  String? stationName,  DateTime? timestamp)?  $default,) {final _that = this;
switch (_that) {
case _PrintJob() when $default != null:
return $default(_that.printer,_that.items,_that.tableName,_that.waiterName,_that.header,_that.footer,_that.logoPath,_that.stationName,_that.timestamp);case _:
  return null;

}
}

}

/// @nodoc


class _PrintJob implements PrintJob {
  const _PrintJob({required this.printer, required final  List<OrderItem> items, required this.tableName, required this.waiterName, this.header, this.footer, this.logoPath, this.stationName, this.timestamp}): _items = items;
  

@override final  PrinterDevice printer;
 final  List<OrderItem> _items;
@override List<OrderItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override final  String tableName;
@override final  String waiterName;
@override final  String? header;
@override final  String? footer;
@override final  String? logoPath;
@override final  String? stationName;
@override final  DateTime? timestamp;

/// Create a copy of PrintJob
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PrintJobCopyWith<_PrintJob> get copyWith => __$PrintJobCopyWithImpl<_PrintJob>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PrintJob&&(identical(other.printer, printer) || other.printer == printer)&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.tableName, tableName) || other.tableName == tableName)&&(identical(other.waiterName, waiterName) || other.waiterName == waiterName)&&(identical(other.header, header) || other.header == header)&&(identical(other.footer, footer) || other.footer == footer)&&(identical(other.logoPath, logoPath) || other.logoPath == logoPath)&&(identical(other.stationName, stationName) || other.stationName == stationName)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp));
}


@override
int get hashCode => Object.hash(runtimeType,printer,const DeepCollectionEquality().hash(_items),tableName,waiterName,header,footer,logoPath,stationName,timestamp);

@override
String toString() {
  return 'PrintJob(printer: $printer, items: $items, tableName: $tableName, waiterName: $waiterName, header: $header, footer: $footer, logoPath: $logoPath, stationName: $stationName, timestamp: $timestamp)';
}


}

/// @nodoc
abstract mixin class _$PrintJobCopyWith<$Res> implements $PrintJobCopyWith<$Res> {
  factory _$PrintJobCopyWith(_PrintJob value, $Res Function(_PrintJob) _then) = __$PrintJobCopyWithImpl;
@override @useResult
$Res call({
 PrinterDevice printer, List<OrderItem> items, String tableName, String waiterName, String? header, String? footer, String? logoPath, String? stationName, DateTime? timestamp
});


@override $PrinterDeviceCopyWith<$Res> get printer;

}
/// @nodoc
class __$PrintJobCopyWithImpl<$Res>
    implements _$PrintJobCopyWith<$Res> {
  __$PrintJobCopyWithImpl(this._self, this._then);

  final _PrintJob _self;
  final $Res Function(_PrintJob) _then;

/// Create a copy of PrintJob
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? printer = null,Object? items = null,Object? tableName = null,Object? waiterName = null,Object? header = freezed,Object? footer = freezed,Object? logoPath = freezed,Object? stationName = freezed,Object? timestamp = freezed,}) {
  return _then(_PrintJob(
printer: null == printer ? _self.printer : printer // ignore: cast_nullable_to_non_nullable
as PrinterDevice,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<OrderItem>,tableName: null == tableName ? _self.tableName : tableName // ignore: cast_nullable_to_non_nullable
as String,waiterName: null == waiterName ? _self.waiterName : waiterName // ignore: cast_nullable_to_non_nullable
as String,header: freezed == header ? _self.header : header // ignore: cast_nullable_to_non_nullable
as String?,footer: freezed == footer ? _self.footer : footer // ignore: cast_nullable_to_non_nullable
as String?,logoPath: freezed == logoPath ? _self.logoPath : logoPath // ignore: cast_nullable_to_non_nullable
as String?,stationName: freezed == stationName ? _self.stationName : stationName // ignore: cast_nullable_to_non_nullable
as String?,timestamp: freezed == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of PrintJob
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PrinterDeviceCopyWith<$Res> get printer {
  
  return $PrinterDeviceCopyWith<$Res>(_self.printer, (value) {
    return _then(_self.copyWith(printer: value));
  });
}
}

// dart format on
