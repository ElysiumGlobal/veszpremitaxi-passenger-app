import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:e_taxi/core/service/location_utils.dart';
import 'package:e_taxi/feature/auth/model/ride_type_list_model.dart';
import 'package:e_taxi/feature/auth/service/auth_service.dart';
import 'package:e_taxi/utils/app_preferences.dart';
import 'package:e_taxi/utils/log_utils.dart';
import 'package:e_taxi/widgets/app_snackbar.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../../../utils/app_string.dart';
import '../../../utils/common_api_caller.dart';
import '../../../utils/loading_mixin.dart';
import '../../../utils/navigation_utils/navigation.dart';
import '../../../utils/navigation_utils/routes.dart';
import '../../../utils/utils.dart';
import '../model/place_adress_model.dart';
import '../model/req_doc_model.dart';

class RegisterController extends GetxController
    with LoadingMixin, LoadingApiMixin {
  String? placeApi = Platform.isAndroid
      ? dotenv.env['GOOGLE_MAPS_API_KEY_Android']
      : dotenv.env['GOOGLE_MAPS_API_KEY_Ios'];

  Timer? debounce;

  void closeDebounce() {
    if (debounce?.isActive ?? false) debounce?.cancel();
  }

  RxList<Prediction> searchList = <Prediction>[].obs;

  Future<void> searchPlace(String value) async {
    try {
      searchLoading(true);

      var result = await http.post(
        Uri.parse(
          "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$value&components=country:HU&key=$placeApi",
        ),
      );

      if (result.statusCode == 200) {
        AddressPlaceModel model = AddressPlaceModel.fromJson(
          jsonDecode(result.body),
        );

        searchList.value = model.predictions ?? [];
      }
    } catch (e, st) {
      LogUtils.printError("Error;$e , $st");
    } finally {
      searchLoading(false);
    }
  }

  RxMap selectedAddress = {}.obs;

  Map tempAddress = {};
  String inPlace = "";

  Future<void> getPlaceDetails(String placeId, String inPlace) async {
    this.inPlace = inPlace;
    selectedAddress.value = {};
    selectedIndx.value = 1;
    final url = Uri.parse(
      "https://maps.googleapis.com/maps/api/place/details/json"
      "?place_id=$placeId"
      "&fields=geometry,formatted_address,name"
      "&key=$placeApi",
    );

    handleLoading(true);
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'OK') {
          tempAddress = data['result'];
          print("DATA::::${data['result']}");
          await checkService(
            tempAddress['geometry']['location']['lat'],
            tempAddress['geometry']['location']['lng'],
          );
        } else {
          selectedIndx.value = 0;
          throw Exception("Error: ${data['status']}");
        }
      } else {
        selectedIndx.value = 0;

        throw Exception("Failed to load place details");
      }
    } catch (e) {
    } finally {
      handleLoading(false);
    }
  }

  RxInt selectedIndx = 0.obs;

  Future<bool> checkService(
    double lat,
    double long, {
    bool isDeviceLocation = false,
  }) async {
    bool isload = false;
    await processApi(
      () async {
        return await AuthService.registerZero(lat: lat, long: long);
      },
      result: (data) {
        isload = true;
        print("data $data");

        selectedAddress.value = tempAddress;
        if (isDeviceLocation) {
          tempAddress = LocationService().locationSelect;
        }
      },
      error: (error, stack) {
        if (isDeviceLocation) {
          tempAddress = LocationService().locationSelect;
        }
        selectedIndx.value = 2;
      },
      loading: handleLoading,
    );
    return isload;
  }

  RxBool searchLoading = false.obs;


  Rx<XFile?> profileImage = Rxn<XFile>();

  Future<void> getProfileImage() async {
    var image = await Utils().getImage();
    if (image != null) {
      profileImage.value = image;
    }
  }

  Future<String?> selectDate() async {
    DateTime now = DateTime.now();
    DateTime? value = await Utils().selectDate(
      lastDate: DateTime(now.year - 18, now.month, now.day - 1),
    );

    if (value != null) {
      return Utils().formatDate(value);
    } else {
      return null;
    }
  }

  Future<void> profileDateUpload({
    required String name,
    required String phone,
    required String dob,
    String email = "",
    String referCode = "",
    required String countryCode,
  }) async {
    processApi(
      () => AuthService.registerFirst(
        countryCode: countryCode,
        phone: phone,
        dob: dob,
        name: name,
        email: email,
        imagePath: profileImage.value?.path ?? "",
        referCode: referCode,
      ),
      result: (data) {
        print("DATA:::::::${data}");
        Navigation.pushNamed(Routes.vehicleSetupScreen);
        AppPreference.setInt(AppPreference.userStep, 2);
      },

      loading: handleLoading,
    );
  }

  Future<void> vehicleDateUpload({
    required int rideType,
    required String noPlate,
  }) async {
    processApi(
      () => AuthService.registerSecound(rideType: rideType, noPlate: noPlate),
      result: (data) {
        AppPreference.setInt(AppPreference.userStep, 3);

        Navigation.pushNamed(Routes.documentScreen);
      },
      loading: handleLoading,
      error: (error, stack) {
        LogUtils.printError("ERROR ::$error, $stack");
      },
    );
  }

  Future<void> documentUpload({
    required List<String> imageList,
    required String make,
    required String model,
    required String year,
    required List<String> fileNameList,
  }) async {
    processApi(
      () => AuthService.registerThird(
        imageList: imageList,
        make: make,
        model: model,
        year: year,
        imageFileName: fileNameList,
      ),
      result: (data) {
        docUpload = true;
        if (govDocUpload) {
          Navigation.replaceAll(Routes.accountReview);
          AppPreference.setInt(AppPreference.userStep, 4);
        } else {
          AppSnackBar.showErrorSnackBar(message: AppString.uploadGovDocs.tr);
        }
      },
      loading: handleLoading,
    );
  }

  bool govDocUpload = false;
  bool docUpload = false;

  Future<bool> govIdUpload(List<String> imageList) async {
    bool res = false;
    await processApi(
      () => AuthService.registerGovIdUpload(imageList: imageList),
      result: (data) {
        govDocUpload = true;
        if (docUpload) {
          Navigation.replaceAll(Routes.accountReview);
          AppPreference.setInt(AppPreference.userStep, 4);
        } else {
            res = true;
        }
      },
      loading: handleLoading,
    );
    return res;
  }

  RxList<RideType> rideTypeList = <RideType>[].obs;

  Future<void> getRideTypeList() async {
    processApi(
      () => AuthService.getRideTypeList(),
      result: (data) {
        rideTypeList.value = data.data?.rideTypes ?? [];
      },
    );
  }

  Rxn<RequiredDocModel> reqDocList = Rxn<RequiredDocModel>();
  RxBool reqDocLoading = true.obs;
  Map<String, List<Document>> requiredMap = {};

  Future<void> getDocList() async {
    reqDocLoading(true);
    await processApi(
      () => AuthService.getRequiredDoc(),
      result: (data) {
        reqDocList.value = data;
        for (Document doc in data.data?.documents ?? []) {
          if (doc.isRequired == true) {
            final type = doc.type;
            if (!requiredMap.containsKey(type)) {
              requiredMap[type ?? ""] = [];
            }
            requiredMap[type]!.add(doc);
          }
        }
        reqDocLoading(false);
      },
      error: (error, stack) {
        reqDocLoading(false);
      },
    );
  }

  Rx<XFile?> docFront = Rxn<XFile>();
  Rx<XFile?> docBack = Rxn<XFile>();
}
