// lib/app/common/controllers/user_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/token.dart';
import 'package:fresco_shop/app/common/controllers/socket_controller.dart';
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
      final token = Token.getToken();
      final hasUser = await _userRepo.hasUser();

      if (hasUser && token != null && token.isNotEmpty) {
        final localUser = await _userRepo.getUser();
        
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

  Future<void> performLogOut({bool shouldLoad = false}) async {
    try {
      shouldLoad == true ? showLoadingDialog() : null;
      await _authProvider.logout();

      if (Get.isRegistered<SocketController>()) {
        Get.find<SocketController>().disconnectSocket(isLogout: true);
      }
      await _userRepo.clearUser();
      userRx.value = null;
      if (Get.isDialogOpen ?? false) Get.back();
      Get.offAllNamed(Routes.LOGIN);
    } catch (e) {
      debugPrint("Erreur globale Logout: $e");
      if (Get.isRegistered<SocketController>()) {
        Get.find<SocketController>().disconnectSocket(isLogout: true);
      }
      await _userRepo.clearUser();
      userRx.value = null;
      if (Get.isDialogOpen ?? false) Get.back();
      Get.offAllNamed(Routes.LOGIN);
    }
  }

  Future<void> updateUser(User updatedUser) async {
    await _userRepo.saveUser(updatedUser);
    userRx.value = updatedUser;
  }

  void redirectUserBasedOnRole() {
    final currentModel = user;
    if (currentModel == null) {
      Get.offAllNamed(Routes.LOGIN);
      return;
    }

    // Aiguillage précis selon le rôle défini dans ton Enum Laravel
    switch (currentModel.role) {
      case 'caisse':
        Get.offAllNamed(Routes.CAISSE);
        break;
      case 'cuisine':
        Get.offAllNamed(Routes.CUISINE);
        break;
      case 'distribution':
        Get.offAllNamed(Routes.DISTRIBUTION);
        break;
      case 'admin':
        // Rediriger vers l'écran admin ou l'écran caisse par défaut
        Get.offAllNamed(Routes.CAISSE);
        break;
      default:
        Get.offAllNamed(Routes.LOGIN);
        Get.snackbar("Erreur", "Rôle utilisateur non reconnu.");
    }
  }

  void showLoadingDialog() {
    Get.dialog(
      PopScope(
        canPop:
            false, // Empêche l'utilisateur de fermer le loader avec le bouton retour
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.amber.shade800,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Déconnexion en cours...",
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    decoration: TextDecoration
                        .none, // Enlève les traits jaunes sous le texte en mode Dialog brut
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false, // Empêche la fermeture en cliquant à côté
    );
  }
}
