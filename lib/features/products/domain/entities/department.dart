import 'package:json_annotation/json_annotation.dart';

enum Department {
  @JsonValue('kitchen')
  kitchen,
  @JsonValue('bar')
  bar,
  @JsonValue('none')
  none;

  factory Department.fromString(String value) {
    return Department.values.firstWhere(
      (d) => d.name == value,
      orElse: () => Department.none,
    );
  }
}
