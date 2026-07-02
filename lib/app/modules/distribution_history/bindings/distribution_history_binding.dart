import 'package:get/get.dart';

import '../controllers/distribution_history_controller.dart';

class DistributionHistoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DistributionHistoryController>(
      () => DistributionHistoryController(),
    );
  }
}
