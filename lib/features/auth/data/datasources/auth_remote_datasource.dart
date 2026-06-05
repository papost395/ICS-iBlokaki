import 'package:pocketbase/pocketbase.dart';
import 'package:order/core/constants/api_constants.dart';
import 'package:order/core/errors/exceptions.dart';
import 'package:order/features/auth/data/models/user_model.dart';
import 'package:order/features/auth/domain/entities/user.dart';

abstract class AuthRemoteDataSource {
  Future<User> login({required String email, required String password});
  Future<void> logout();
  User? get currentUser;
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl({required this.pb});

  final PocketBase pb;

  @override
  Future<User> login({required String email, required String password}) async {
    try {
      final record = await pb
          .collection(ApiConstants.usersCollection)
          .authWithPassword(email, password);
      return UserModel.fromRecord(record.record!);
    } catch (e) {
      throw AuthException('Login failed: ${e.toString()}');
    }
  }

  @override
  Future<void> logout() async {
    pb.authStore.clear();
  }

  @override
  User? get currentUser {
    if (!pb.authStore.isValid) return null;
    final model = pb.authStore.record;
    if (model == null) return null;
    return UserModel.fromRecord(model);
  }
}
