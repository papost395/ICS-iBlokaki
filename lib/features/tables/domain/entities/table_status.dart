sealed class TableStatus {
  const TableStatus();

  factory TableStatus.fromString(String status, {DateTime? reservationTime, String? description}) {
    return switch (status) {
      'occupied' => const Occupied(),
      'reserved' => Reserved(
          reservationTime: reservationTime ?? DateTime.now(),
          description: description ?? '',
        ),
      'paid' => const Paid(),
      'cancelled' => const Cancelled(),
      _ => const Free(),
    };
  }

  String get value => switch (this) {
        Free() => 'free',
        Occupied() => 'occupied',
        Reserved() => 'reserved',
        Paid() => 'paid',
        Cancelled() => 'cancelled',
      };
}

class Free extends TableStatus {
  const Free();
}

class Occupied extends TableStatus {
  const Occupied();
}

class Reserved extends TableStatus {
  const Reserved({required this.reservationTime, this.description = ''});
  final DateTime reservationTime;
  final String description;
}

class Paid extends TableStatus {
  const Paid();
}

class Cancelled extends TableStatus {
  const Cancelled();
}
