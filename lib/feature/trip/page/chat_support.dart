import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:e_taxi/utils/app_colors.dart';
import 'package:e_taxi/utils/assets.dart';
import 'package:e_taxi/utils/utils.dart';
import 'package:e_taxi/widgets/appbar.dart';
import 'package:e_taxi/widgets/common_text.dart';
import 'package:e_taxi/widgets/custom_textfeild.dart';
import 'package:e_taxi/widgets/custome_img.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/api/api.dart';
import '../../../core/socket_channel.dart';
import '../../../utils/api_constants.dart';
import '../../../utils/app_preferences.dart';
import '../../../utils/constants.dart';
import '../../../utils/log_utils.dart';
import '../../../widgets/app_snackbar.dart';
import '../model/support_chat_model.dart';
import '../service/trip_service.dart';

class ChatSupportScreen extends StatefulWidget {
  final String bookingId;
  final String title;

  const ChatSupportScreen({
    required this.title,
    required this.bookingId,
    super.key,
  });

  @override
  State<ChatSupportScreen> createState() => _ChatSupportScreenState();
}

class _ChatSupportScreenState extends State<ChatSupportScreen> {
  StreamSubscription<dynamic>? _socketStream;
  Timer? _historyTimer;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    unawaited(socketAuthConnection());
    _socketStream = SocketChannelService().onSocketDataListen.listen((events) {
      try {
        if (events != null) {
          var event = jsonDecode(events);

          if (event['event'] == "support.chat.message") {
            var data = jsonDecode(event['data']);

            final supportChat = data['support_chat'];
            if (supportChat is Map) {
              _upsertMessage(
                ChatModel.fromJson(Map<String, dynamic>.from(supportChat)),
              );
            }
          }
        }
      } catch (e, st) {
        LogUtils.printWhite("socket error :$e , $st");
      }
    });

    Future.microtask(() => getHistory());
    _historyTimer = Timer.periodic(
      const Duration(seconds: 8),
      (_) => unawaited(getHistory(showLoading: false)),
    );
  }

  RxBool chatHistoryLoading = false.obs;

  RxList<ChatModel> chatList = <ChatModel>[].obs;

  Future<void> getHistory({bool showLoading = true}) async {
    try {
      if (showLoading) chatHistoryLoading(true);
      final response = await TripService.getSupportChatHistory(
        bookingId: widget.bookingId,
      );

      chatList.value = response.data ?? [];
    } catch (e, st) {
      LogUtils.printError("ERROR :: $e, $st");
      // Get.back();
    } finally {
      if (showLoading) chatHistoryLoading(false);
      isLoading(false);
    }
  }

  void _upsertMessage(ChatModel message) {
    final id = message.id;
    if (id != null) {
      final index = chatList.indexWhere((item) => item.id == id);
      if (index >= 0) {
        chatList[index] = message;
        return;
      }
    }
    chatList.insert(0, message);
  }

  final SocketChannelService _socketService = SocketChannelService();

  @override
  void dispose() {
    // TODO: implement dispose

    _socketService.sendPusherEvent("pusher:unsubscribe", {
      "channel": "private-support.booking.${widget.bookingId}",
    });

    _socketStream?.cancel();
    _historyTimer?.cancel();
    controller.dispose();

    super.dispose();
  }

  Future<void> socketAuthConnection() async {
    try {
      final response = await Api().post(
        ApiConstants.supportSocketAuthentication,
        bodyData: {
          "socket_id": AppConstant().socketId,
          "channel_name": "private-support.booking.${widget.bookingId}",
        },
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        log("AUTH :::::${data['auth']}");

        _socketService.sendPusherEvent("pusher:subscribe", {
          "channel": "private-support.booking.${widget.bookingId}",
          "auth": "${data['auth']}",
        });

        isLoading(false);
      } else {
        throw "Statuscode :${response.statusCode} ::${response.body}";
      }
    } catch (e, st) {
      LogUtils.printError("SOCKET AUTH ERROR $e, $st");
      AppSnackBar.showErrorSnackBar(
        message: 'Az élő kapcsolat nem elérhető, az üzenetek frissülnek.',
        isError: true,
      );
    }
  }

  Future<void> sendMessage(String msg) async {
    if (msg.isEmpty || isSending.value) {
      return;
    }
    try {
      final userId = int.tryParse(
        AppPreference.getString(AppPreference.userId),
      );
      if (userId == null) {
        throw const FormatException('Missing authenticated user id');
      }

      isSending(true);
      final savedMessage = await TripService.sendSupportChatMessage(
        bookingId: widget.bookingId,
        userId: userId,
        message: msg,
        subject: widget.title,
      );
      _upsertMessage(savedMessage);
      controller.clear();
    } catch (e, st) {
      LogUtils.printError("send Msg Error :$e, $st");
      AppSnackBar.showErrorSnackBar(
        message: 'Az üzenetet nem sikerült elküldeni. Próbáld újra.',
        isError: true,
      );
    } finally {
      isSending(false);
    }
  }

  TextEditingController controller = TextEditingController();

  RxBool isLoading = true.obs;
  RxBool isSending = false.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Ügyfélszolgálat – ${widget.title}',
        centerTitle: false,
      ),
      body: SafeArea(
        bottom: Utils().checkPlatForm,
        child: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(ImagesAsset.chatBg),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            Obx(
              () => isLoading.value
                  ? Center(child: CircularProgressIndicator())
                  : Column(
                      children: [
                        Expanded(
                          child: Obx(
                            () => ListView.separated(
                              reverse: true,
                              itemBuilder: (context, index) {
                                final data = chatList[index];

                                return data.adminId == null
                                    ? sender(data)
                                    : receiver(data);
                              },
                              separatorBuilder: (context, index) =>
                                  6.verticalSpace,
                              itemCount: chatList.length,
                            ),
                          ),
                        ),
                        16.verticalSpace,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: CustomTextField(
                                controller: controller,
                                hintText: 'Írj üzenetet…',
                              ),
                            ),
                            8.horizontalSpace,
                            Obx(
                              () => GestureDetector(
                                onTap: isSending.value
                                    ? null
                                    : () => sendMessage(controller.text.trim()),
                                child: Container(
                                  height: 48.h,
                                  width: 48.h,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4.r),
                                    color: AppColors.mainPrimaryColor,
                                  ),
                                  alignment: Alignment.center,
                                  child: isSending.value
                                      ? SizedBox(
                                          width: 20.w,
                                          height: 20.w,
                                          child:
                                              const CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.white,
                                              ),
                                        )
                                      : CustomImage(image: IconAsset.sendIcon),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ).paddingAll(16.w),
            ),
          ],
        ),
      ),
    );
  }

  Widget sender(ChatModel data) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          margin: EdgeInsets.only(left: Get.width * 0.4),
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: AppColors.primaryContainer,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(8.r),
              topRight: Radius.circular(8.r),
              bottomLeft: Radius.circular(8.r),
              bottomRight: Radius.circular(0.r),
            ),
          ),
          child: Text(data.message ?? "", softWrap: true),
        ),
        if (Utils().time(data.createdAt ?? "").isNotEmpty)
          CommonText(
            string: Utils().time(data.createdAt ?? ""),
            fontSize: 12.sp,
          ),
      ],
    );
  }

  Widget receiver(ChatModel data) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.only(right: Get.width * .4),
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: AppColors.primaryContainer,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(0.r),
              topRight: Radius.circular(8.r),
              bottomLeft: Radius.circular(8.r),
              bottomRight: Radius.circular(8.r),
            ),
          ),
          child: Text(data.message ?? "", softWrap: true),
        ),
        if (Utils().time(data.createdAt ?? "").isNotEmpty)
          CommonText(
            string: Utils().time(data.createdAt ?? ""),
            fontSize: 12.sp,
          ),
      ],
    );
  }
}
