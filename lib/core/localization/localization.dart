import 'package:e_taxi/core/localization/language/aerabic.dart';
import 'package:get/get_navigation/src/root/internacionalization.dart';

import 'language/english.dart';
import 'language/hindi.dart';
import 'language/hungarian.dart';

class Languages extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    'hu_HU': hungarianLn,
    'en_US': englishLn,
    'hi_IN': hindiLn,
    "ar_AE": aerabicLn,
  };
}
