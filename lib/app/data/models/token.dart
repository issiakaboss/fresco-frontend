import 'package:fresco_shop/app/utils/helpers/storage_helper.dart';

class Token {
  static void saveToken(String token) {
    StorageHelper.set('auth_token', token);
  }

  static String? getToken() {
    return StorageHelper.get('auth_token');
  }

  static void clearToken() {
    StorageHelper.delete('auth_token');
  }
}
