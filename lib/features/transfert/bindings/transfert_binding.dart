import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/bindings_interface.dart';
import 'package:get/get_instance/src/extension_instance.dart';

import '../../depot_momo/controllers/depot_momo_controller.dart';
import '../controllers/transfert_controller.dart';

class TransfertBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TransfertController>(() => TransfertController());
    Get.lazyPut<DepotMomoController>(() => DepotMomoController());
  }
}