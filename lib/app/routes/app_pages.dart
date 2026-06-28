import 'package:get/get.dart';

import '../modules/caisse/bindings/caisse_binding.dart';
import '../modules/caisse/views/caisse_view.dart';
import '../modules/cuisine/bindings/cuisine_binding.dart';
import '../modules/cuisine/views/cuisine_view.dart';
import '../modules/distribution/bindings/distribution_binding.dart';
import '../modules/distribution/views/distribution_view.dart';
import '../modules/history/bindings/history_binding.dart';
import '../modules/history/views/history_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/login/bindings/login_binding.dart';
import '../modules/login/views/login_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.HOME;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.LOGIN,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: _Paths.CAISSE,
      page: () => const CaisseView(),
      binding: CaisseBinding(),
    ),
    GetPage(
      name: _Paths.CUISINE,
      page: () => const CuisineView(),
      binding: CuisineBinding(),
    ),
    GetPage(
      name: _Paths.DISTRIBUTION,
      page: () => const DistributionView(),
      binding: DistributionBinding(),
    ),
    GetPage(
      name: _Paths.HISTORY,
      page: () => const HistoryView(),
      binding: HistoryBinding(),
    ),
  ];
}
