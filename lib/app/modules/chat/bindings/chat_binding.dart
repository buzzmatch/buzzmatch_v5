import 'package:get/get.dart';
import '../controllers/chat_controller.dart';

class ChatBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<ChatController>(
      ChatController(),
      permanent: false,
    );
  }
}
