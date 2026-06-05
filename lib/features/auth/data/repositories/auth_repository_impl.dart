import 'dart:async';
import 'package:order/core/errors/exceptions.dart';
import 'package:order/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:order/features/auth/domain/entities/user.dart';
import 'package:order/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({required this.remoteDataSource});

  final AuthRemoteDataSource remoteDataSource;
  final _authStateController = StreamController<User?>.broadcast();

  @override
  Future<User> login({
    required String email,
    required String password,
  }) async {
    try {
      final user = await remoteDataSource.login(
        email: email,
        password: password,
      );
      _authStateController.add(user);
      return user;
    } on AuthException {
      rethrow;
    }
  }

  @override
  Future<void> logout() async {
    await remoteDataSource.logout();
    _authStateController.add(null);
  }

  @override
  User? get currentUser => remoteDataSource.currentUser;

  @override
  String? get currentShopId => currentUser?.shopId;

  @override
  Stream<User?> watchAuthState() => _authStateController.stream;
}
