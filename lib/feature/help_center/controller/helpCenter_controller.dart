import 'dart:developer';

import 'package:e_taxi/feature/help_center/model/support_model.dart';
import 'package:e_taxi/feature/help_center/model/ticket_support_model.dart';
import 'package:e_taxi/feature/help_center/service/hepcenter_service.dart';
import 'package:e_taxi/utils/common_api_caller.dart';
import 'package:e_taxi/utils/loading_mixin.dart';
import 'package:e_taxi/utils/log_utils.dart';
import 'package:e_taxi/widgets/app_snackbar.dart';
import 'package:get/get.dart';

import '../model/emergency_model.dart';

class HelpCenterController extends GetxController
    with LoadingApiMixin, LoadingMixin {
  RxList<Contact> contactList = <Contact>[].obs;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    getEmergencyContact();
    getContactSupport();
  }

  Future<void> getEmergencyContact() async {
    if (contactList.isNotEmpty) {
      return;
    }
    await processApi(
      () => HelpCenterService.getEmergency(),
      result: (data) {
        contactList.value = data.data?.contacts ?? [];
      },
    );
  }

  Future<Map> addEmergencyContact({
    required String name,
    required String phone,
  }) async {
    Map res = {};
    await processApi(
      () => HelpCenterService.addEmergency(name: name, phone: phone),
      result: (data) {
        res = data;

        var model = data['data']['contact'];
        contactList.add(
          Contact(
            id: model['id'],
            name: model['name'],
            mobileNumber: model['mobile_number'],
            formattedMobile: model['formatted_mobile'],
            isPrimary: model['is_primary'],
            createdAt: model['created_at'],
            updatedAt: model['updated_at'],
          ),
        );
        contactList.refresh();
      },
      loading: handleLoading,
    );

    return res;
  }

  Future<Map> deleteEmergency(int id, int index) async {
    Map res = {};
    await processApi(
      () => HelpCenterService.deleteEmergency(id),
      result: (data) {
        res = data;
        contactList.removeAt(index);
      },
      loading: handleLoading,
    );
    return res;
  }

  RxBool supportLoading = false.obs;
  Rxn<SupportModel> supportModel = Rxn<SupportModel>();

  Future<void> getContactSupport() async {
    supportLoading(true);
    await processApi(
      () => HelpCenterService.contactSupport(),
      result: (data) {
        supportModel.value = data;
      },
    );
    supportLoading(false);
  }

  Rxn<TicketSupportModel> ticketSupportModel = Rxn<TicketSupportModel>();
  RxBool ticketLoading = false.obs;

  Future getTicketDetails({required String id}) async {
    ticketLoading(true);
    ticketSupportModel.value = null;

    await processApi(
      () => HelpCenterService.getSupportDetails(id),
      result: (data) {
        ticketSupportModel.value = data;
      },
    );
    ticketLoading(false);
  }

  Future supportDocUpdate({
    required String id,
    required int index,
    required String imagePath,
    required int idAttechment,
  }) async {
    Map map = {};
    await processApi(
      () => HelpCenterService.supportDocumentUpdate(
        id: id,
        index: idAttechment,
        imageList: [imagePath],
      ),
      result: (data) {
        map = data;
        log("DATA GET ::::${data}");
        ticketSupportModel.value?.data?.attachments?[index].imageUrl =
            data['data']['attachment']['image_url'];
        ticketSupportModel.refresh();
      },
      loading: handleLoading,
    );

    AppSnackBar.showErrorSnackBar(message: map['message']);
  }

  Future supportDocDelete({
    required String id,
    required int index,
    required int idAttechment,
  }) async {
    Map res = {};
    await processApi(
      () => HelpCenterService.supportDocDelete(id: id, index: idAttechment),
      result: (data) {
        res = data;
        ticketSupportModel.value?.data?.attachments?.removeAt(index);
        ticketSupportModel.refresh();
      },
      loading: handleLoading,
    );

    Get.back();

    AppSnackBar.showErrorSnackBar(message: res['message']);
  }

  Future<Map> raiseTicket({
    required String title,
    required String des,
    required List<String> imagePath,
  }) async {
    print(">>>>>$des");
    Map res = {};
    await processApi(
      () => HelpCenterService.raiseTicket(
        title: title,
        des: des,
        imagePath: imagePath,
      ),
      result: (data) {
        res = data;

        log("_______$data");
      },
      error: (error, stack) {
        LogUtils.printError("asd:::::$error$stack");
      },
      loading: handleLoading,
    );
    return res;
  }
}
