import 'package:buzzmatch_v5/app/translations/en_US/en_US.dart';
import 'package:get/get.dart';
import 'ar_SA/ar_SA.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'en_US': enUS,
        'ar_SA': arSA,
      };
}
