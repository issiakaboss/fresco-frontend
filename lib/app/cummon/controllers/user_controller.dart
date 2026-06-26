// lib/app/common/controllers/user_controller.dart
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../data/models/token.dart';
import 'package:fresco_shop/app/cummon/controllers/socket_controller.dart';
import 'package:fresco_shop/app/data/providers/api_provider.dart';
import 'package:fresco_shop/app/data/providers/auth_provider.dart';
import 'package:fresco_shop/app/routes/app_pages.dart';
import '../../data/models/user.dart';
import '../../data/repositories/user_repository.dart';

class UserController extends GetxController {
  static UserController get to {
    try {
      return Get.find<UserController>();
    } catch (e) {
      debugPrint("ERREUR: UserController n'est pas encore prêt");
      rethrow;
    }
  }

  final UserRepository _userRepo;
 final AuthProvider _authProvider = AuthProvider();
  final Rxn<User> userRx = Rxn<User>();

  UserController(this._userRepo);

  User? get user => userRx.value;
  bool get isLoggedIn => userRx.value != null;
  @override
  void onInit() {
    super.onInit();
    ever(userRx, (User? user) {
      // var token = Token.getAuthToken();
      if (user != null) {
        Get.find<SocketController>().connectToSocket(user: user);
        debugPrint("🔌 Socket connecté automatiquement pour ${user.name}");
      }
    });
  }

  Future<void> loadUser() async {
    try {
      final token = await Token.getToken();
      final hasUser = await _userRepo.hasUser();

      if (hasUser && token != null && token.isNotEmpty) {
        final localUser = await _userRepo.getUser();
        try {
          final response =
              await ApiProvider.get(apiURL: 'users/me', auth: true);
          if (response != null && response['data'] != null) {
            final userObject = User.fromJson(response['data']);
            await affectToCurrentUser(userObject);
            return;
          }
        } catch (e) {
          debugPrint(
              "Impossible de rafraîchir l'utilisateur via l'API, utilisation du mode local.");
        }
        if (localUser != null) {
          userRx.value = localUser;
        }
      } else {
        userRx.value = null;
      }
    } catch (e) {
      userRx.value = null;
    }
  }


  Future<void> affectToCurrentUser(User user) async {
    await _userRepo.saveUser(user);
    userRx.value = user;
  }

  Future<void> performLogOut() async {
    try {
      await _authProvider.logout();

      if (Get.isRegistered<SocketController>()) {
        Get.find<SocketController>().disconnectSocket(isLogout: true);
      }
      await _userRepo.clearUser();
      userRx.value = null;
      // Get.offAllNamed(AppPages.LOGIN);
    } catch (e) {
      debugPrint("Erreur globale Logout: $e");
      if (Get.isRegistered<SocketController>()) {
        Get.find<SocketController>().disconnectSocket(isLogout: true);
      }
      await _userRepo.clearUser();
      userRx.value = null;
      // Get.offAllNamed(AppPages.LOGIN);
    }
  }

  Future<void> updateUser(User updatedUser) async {
    await _userRepo.saveUser(updatedUser);
    userRx.value = updatedUser;
  }
}
