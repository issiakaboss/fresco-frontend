
import 'package:fresco_shop/app/cummon/controllers/base_controller.dart';
import 'package:fresco_shop/app/data/models/token.dart';
import 'package:fresco_shop/app/data/models/user.dart';
import 'package:fresco_shop/app/data/providers/api_provider.dart';
import 'package:fresco_shop/app/utils/enums/api_routes.dart';
import 'package:get/get.dart';
import '../repositories/user_repository.dart';

class AuthProvider with BaseController {
  Future<dynamic> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await ApiProvider.post(
        auth: false,
        apiURL: ApiRoutes.login.path,
        data: {'email': email, 'password': password},
      ).catchError(handleError);
      if (response != null) {
        Token.saveToken(response['data']['token']);
        User user = User.fromJson(response['data']);
        await Get.find<UserRepository>().saveUser(user);
        return user;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<User?> updateUser(
      {required String userId, required Map<String, dynamic> data}) async {
    try {
      final response = await ApiProvider.put(
        auth: true,
        apiURL: ApiRoutes.updateUser.format({"user": userId}),
        data: data,
      ).catchError(handleError);
      if (response != null) {
        User user = User.fromJson(response['data']);
        await Get.find<UserRepository>().saveUser(user);
        return user;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<User?> signUp(User user) async {
    try {
      final response = await ApiProvider.post(
        auth: false,
        apiURL: ApiRoutes.register.path,
        data: user.toJson(),
      ).catchError(handleError);
      if (response != null) {
         Token.saveToken(response['data']['token']);
        User newUser = User.fromJson(response['data']);
        await Get.find<UserRepository>().saveUser(newUser);
        return newUser;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> logout() async {
    try {
      // --- LOGIQUE BACKEND ---
      return await ApiProvider.post(
        auth: true,
        apiURL: ApiRoutes.logout.path,
        data: {},
      ).catchError(handleError);
    } catch (e) {
   }
  }

 

  
}
