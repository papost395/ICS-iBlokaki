import 'package:order/features/auth/domain/entities/user.dart';

abstract class AuthRepository {
  Future<User> login({required String email, required String password});
  Future<void> logout();
  User? get currentUser;
  String? get currentShopId;
  Stream<User?> watchAuthState();
}
