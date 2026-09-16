import 'package:get/get.dart';
import '../controllers/pispi_controller.dart';

class PispiBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PispiController>(() => PispiController());
  }
}