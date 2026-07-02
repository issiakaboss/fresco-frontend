import 'package:get/get.dart';

import '../controllers/cuisin_history_controller.dart';

class CuisinHistoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CuisinHistoryController>(
      () => CuisinHistoryController(),
    );
  }
}
