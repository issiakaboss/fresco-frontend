import 'package:fresco_shop/app/common/controllers/user_controller.dart';
import 'package:get/get.dart';
import 'package:fresco_shop/app/data/providers/auth_provider.dart';

class LoginController extends GetxController {
  final AuthProvider _authProvider = AuthProvider();

  var isLoading = false.obs;

  Future<void> submitLogin(String email, String password) async {
    try {
      isLoading.value = true;
      final loggedInUser = await _authProvider.login(
        email: email,
        password: password,
      );
      if (loggedInUser != null) {
        await UserController.to.affectToCurrentUser(loggedInUser);
        UserController.to.redirectUserBasedOnRole();
      }
    } finally {
      isLoading.value = false;
    }
  }
}
