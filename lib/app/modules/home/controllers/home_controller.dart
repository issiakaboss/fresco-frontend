import 'package:fresco_shop/app/routes/app_pages.dart';
import 'package:get/get.dart';
import 'package:fresco_shop/app/common/controllers/user_controller.dart';

class HomeController extends GetxController {
  @override
  void onReady() async {
    super.onReady();
    await UserController.to.loadUser();
    if (UserController.to.isLoggedIn) {
      UserController.to.redirectUserBasedOnRole();
    } else {
      Get.offAllNamed(Routes.LOGIN);
    }
  }
}
