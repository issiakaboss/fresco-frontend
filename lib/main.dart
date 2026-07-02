import 'package:flutter/material.dart';
import 'package:fresco_shop/app/common/controllers/dependency_injection.dart';
import 'package:fresco_shop/app/common/controllers/socket_controller.dart';
import 'package:fresco_shop/app/common/controllers/user_controller.dart';
import 'package:fresco_shop/app/core/services/printer_service.dart';
import 'package:fresco_shop/app/data/repositories/user_repository.dart';

import 'package:get/get.dart';

import 'app/routes/app_pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DependencieInjection.init();
  runApp(
    GetMaterialApp(
      title: "Fresco shop",
      debugShowCheckedModeBanner: false,
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      initialBinding: BindingsBuilder(() {
        Get.put(PrinterService(), permanent: true);
        Get.put(UserRepository(), permanent: true);
        Get.put(SocketController(), permanent: true);
        Get.put(UserController(Get.find<UserRepository>()), permanent: true);
      }),
    ),
  );
}
