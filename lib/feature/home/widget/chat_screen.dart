import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:e_taxi/core/api/api.dart';
import 'package:e_taxi/core/api/responce_handler.dart';
import 'package:e_taxi/utils/api_constants.dart';
import 'package:e_taxi/utils/app_colors.dart';
import 'package:e_taxi/utils/app_preferences.dart';
import 'package:e_taxi/utils/constants.dart';
import 'package:e_taxi/utils/log_utils.dart';
import 'package:e_taxi/widgets/app_snackbar.dart';
import 'package:e_taxi/widgets/appbar.dart';
import 'package:e_taxi/widgets/custom_textfeild.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/socket_channel.dart';
import '../../../utils/assets.dart';
import '../../../utils/utils.dart';
import '../../../widgets/common_text.dart';
import '../../../widgets/custome_img.dart';
import '../model/chat_model.dart';

class ChatScreen extends StatefulWidget {
  final String bookingId;

  const ChatScreen({required this.bookingId, super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  RxBool isLoading = true.obs;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    socketAuthConnection();
    getMsgHistory();
    _socketStream = _socketService.onSocketDataListen.listen((events) {
      try {
        if (events != null) {
          var event = jsonDecode(events);
          log("EVENT ::$event");

          if (event['event'] == "client-send-message") {
            chatList.insert(
              0,
              Chat(
                message: (jsonDecode(event['data']))['message'],
                createdAt:
                    "${DateTime.now().toUtc().toIso8601String().split('.').first}.000000Z",
              ),
            );
          }
        }
      } catch (e, st) {
        LogUtils.printWhite("socket error :$e , $st");
      }
    });
  }

  StreamSubscription<dynamic>? _socketStream;

  final SocketChannelService _socketService = SocketChannelService();

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    chatList.clear();
    _socketStream?.cancel();

    _socketService.sendPusherEvent("pusher:unsubscribe", {
      "channel": "private-chat.booking.${widget.bookingId}",
    });
  }

  Future<void> socketAuthConnection() async {
    try {
      if (AppConstant().socketId.isEmpty) {
        await Future.delayed(Duration(seconds: 3));
      }

      final response = await Api().post(
        ApiConstants.socketAuthentication,
        bodyData: {
          "socket_id": AppConstant().socketId,
          "channel_name": "private-chat.booking.${widget.bookingId}",
        },
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        _socketService.sendPusherEvent("pusher:subscribe", {
          "channel": "private-chat.booking.${widget.bookingId}",
          "auth": "${data['auth']}",
        });
      } else {
        throw "Statuscode :${response.statusCode} ::${response.body}";
      }
    } catch (e, st) {
      LogUtils.printError("SOCKET AUTH ERROR $e, $st");
      Get.back();
      AppSnackBar.showErrorSnackBar(message: "Something are wrong!");
    } finally {}
  }

  Future<void> sendMessage(String msg) async {
    if (msg.isEmpty) {
      return;
    }
    try {
      _socketService.sendPusherEventChanel("client-send-message", {
        "message": msg,
        "message_type": "text",
        "metadata": {},
      }, channel: "private-chat.booking.${widget.bookingId}");

      chatList.insert(
        0,
        Chat(
          message: msg,
          sender: OtherParticipant(
            id: AppPreference.getString(AppPreference.userId),
          ),
          createdAt:
              "${DateTime.now().toUtc().toIso8601String().split('.').first}.000000Z",
        ),
      );
      controller.clear();
    } catch (e, st) {
      LogUtils.printError("send Msg Error :$e, $st");
    }
  }

  Future<void> getMsgHistory() async {
    try {
      final response = await Api().get(
        "${ApiConstants.getChatHistory}${widget.bookingId}",
      );
      await ResponseHandler.checkResponseError(response);

      chatList.value =
          (ChatListModel.fromJson(jsonDecode(response.body))).chats ?? [];
    } catch (e) {
      LogUtils.printError("error:::$e");
    } finally {
      isLoading(false);
    }
  }

  TextEditingController controller = TextEditingController();
  String userId = AppPreference.getString(AppPreference.userId);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteGrey,
      appBar: CustomAppBar(centerTitle: false, title: "Chat"),
      body: SafeArea(
        child: Obx(
          () => isLoading.value
              ? Center(child: CircularProgressIndicator())
              : Stack(
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(ImagesAsset.chatBg),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Obx(
                          () => Expanded(
                            child: ListView.separated(
                              separatorBuilder: (context, index) =>
                                  16.verticalSpace,
                              itemCount: chatList.length,
                              reverse: true,
                              itemBuilder: (context, index) {
                                final data = chatList[index];
                                return data.sender?.id == userId
                                    ? sender(data)
                                    : receiver(data);
                              },
                            ),
                          ),
                        ),
                        16.verticalSpace,
                        Row(
                          children: [
                            Expanded(
                              child: CustomTextField(controller: controller),
                            ),

                            8.horizontalSpace,
                            GestureDetector(
                              onTap: () {
                                sendMessage(controller.text.trim());
                              },
                              child: Container(
                                height: 48.h,
                                width: 48.h,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4.r),
                                  color: AppColors.mainPrimaryColor,
                                ),
                                alignment: Alignment.center,
                                child: CustomImage(image: IconAsset.sendIcon),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
        ),
      ).paddingAll(16.w),
    );
  }
}

Widget sender(Chat data) {
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
            topRight: Radius.circular(0.r),
            bottomLeft: Radius.circular(8.r),
            bottomRight: Radius.circular(8.r),
          ),
        ),
        child: Text(data.message ?? ""),
      ),
      if (Utils().time(data.createdAt ?? "").isNotEmpty)
        CommonText(string: Utils().time(data.createdAt ?? ""), fontSize: 12.sp),
    ],
  );
}

Widget receiver(Chat data) {
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
        child: Text(data.message ?? ""),
      ),
      if (Utils().time(data.createdAt ?? "").isNotEmpty)
        CommonText(string: Utils().time(data.createdAt ?? ""), fontSize: 12.sp),
    ],
  );
}

RxList<Chat> chatList = <Chat>[].obs;
