// lib/app/data/repositories/user_repository.dart

import 'package:fresco_shop/app/data/models/token.dart';
import 'package:fresco_shop/app/data/models/user.dart';

import '../../utils/helpers/storage_helper.dart';

class UserRepository {
  static const String _userKey = 'current_user';

  Future<void> saveUser(User user) async {
    await StorageHelper.set(_userKey, user.toJson());
  }

  Future<User?> getUser() async {
    final userJson = await StorageHelper.get(_userKey);
    if (userJson != null) {
      return User.fromJson(userJson);
    }
    return null;
  }

  Future<void> clearUser() async {
    Token.clearToken();
    await StorageHelper.delete(_userKey);
  }

  Future<bool> hasUser() async {
    return await StorageHelper.get(_userKey) != null;
  }
}
