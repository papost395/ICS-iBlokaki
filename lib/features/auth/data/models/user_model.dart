import 'package:pocketbase/pocketbase.dart';
import 'package:order/features/auth/domain/entities/user.dart';

class UserModel {
  static User fromRecord(RecordModel record) {
    return User(
      id: record.id,
      shopId: record.getStringValue('shop_id'),
      name: record.getStringValue('name'),
      email: record.getStringValue('email'),
      role: UserRole.values.firstWhere(
        (r) => r.name == record.getStringValue('role'),
        orElse: () => UserRole.waiter,
      ),
    );
  }
}
