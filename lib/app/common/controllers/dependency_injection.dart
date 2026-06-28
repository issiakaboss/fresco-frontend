import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_storage/get_storage.dart';
import 'package:fresco_shop/app/config/env.dart';

class DependencieInjection {
  static Future<void> init() async {
    await GetStorage.init();
    await dotenv.load(
        fileName: Env.isLocal ? Env.developement : Env.production);
  }
}
