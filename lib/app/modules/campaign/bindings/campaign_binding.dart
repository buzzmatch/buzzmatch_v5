import 'package:get/get.dart';
import '../controllers/campaign_controller.dart';

class CampaignBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<CampaignController>(
      CampaignController(),
      permanent: false,
    );
  }
}
