import 'package:get/get.dart';

import '../controllers/caisse_controller.dart';

class CaisseBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CaisseController>(
      () => CaisseController(),
    );
  }
}
