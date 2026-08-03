import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:e_taxi/core/api/api.dart';
import 'package:e_taxi/core/api/responce_handler.dart';
import 'package:e_taxi/core/debug/passenger_flow_debug.dart';
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
  final RxBool isLoading = true.obs;
  final RxBool isSending = false.obs;
  final SocketChannelService _socketService = SocketChannelService();
  final TextEditingController controller = TextEditingController();
  final String userId = AppPreference.getString(AppPreference.userId);

  StreamSubscription<dynamic>? _socketStream;
  Timer? _historyPollingTimer;

  @override
  void initState() {
    super.initState();
    final activeBookingId = AppConstant().bookingId.trim();
    PassengerFlowDebug.send(
      'passenger_chat_opened',
      bookingId: widget.bookingId,
      data: <String, dynamic>{
        'active_booking_id': activeBookingId,
        'booking_matches': activeBookingId.isEmpty ||
            activeBookingId == widget.bookingId.trim(),
      },
    );
    unawaited(getMsgHistory());
    unawaited(socketAuthConnection());
    _historyPollingTimer = Timer.periodic(
      const Duration(seconds: 4),
      (_) => unawaited(getMsgHistory(silent: true)),
    );
    _listenToSocket();
  }

  void _listenToSocket() {
    _socketStream?.cancel();
    _socketStream = _socketService.onSocketDataListen.listen((events) {
      try {
        if (events == null) return;
        final dynamic event = jsonDecode(events);
        if (event is! Map) return;
        final String eventName = event['event']?.toString() ?? '';
        if (eventName != 'chat.message' &&
            eventName != 'client-send-message') {
          return;
        }

        dynamic payload = event['data'];
        if (payload is String) payload = jsonDecode(payload);
        if (payload is! Map) return;
        dynamic rawChat = payload['chat'] ?? payload;
        if (rawChat is! Map) return;

        final chat = Chat.fromJson(Map<String, dynamic>.from(rawChat));
        final incomingBookingId = (chat.bookingId ?? '').trim();
        if (incomingBookingId.isNotEmpty &&
            incomingBookingId != widget.bookingId.trim()) {
          PassengerFlowDebug.send(
            'passenger_chat_foreign_message_ignored',
            bookingId: widget.bookingId,
            data: <String, dynamic>{
              'incoming_booking_id': incomingBookingId,
              'message_id': chat.id ?? '',
            },
          );
          return;
        }
        _upsertChat(chat);
        PassengerFlowDebug.send(
          'passenger_chat_socket_received',
          bookingId: widget.bookingId,
          data: <String, dynamic>{
            'event_name': eventName,
            'message_id': chat.id ?? '',
            'sender_id': chat.sender?.id ?? '',
          },
        );
      } catch (error, stack) {
        LogUtils.printError('PASSENGER CHAT SOCKET ERROR: $error, $stack');
        PassengerFlowDebug.send(
          'passenger_chat_socket_error',
          bookingId: widget.bookingId,
          data: <String, dynamic>{'error': '$error'},
        );
      }
    });
  }

  void _upsertChat(Chat chat) {
    final String chatId = chat.id?.trim() ?? '';
    if (chatId.isNotEmpty) {
      final index = chatList.indexWhere((item) => item.id == chatId);
      if (index >= 0) {
        chatList[index] = chat;
        chatList.refresh();
        return;
      }
    }
    chatList.insert(0, chat);
  }

  Future<void> getMsgHistory({bool silent = false}) async {
    try {
      if (!silent) isLoading.value = true;
      final response = await Api().get(
        '${ApiConstants.getChatHistory}${widget.bookingId}',
      );
      PassengerFlowDebug.send(
        'passenger_chat_history_response',
        bookingId: widget.bookingId,
        data: <String, dynamic>{
          'http_status': response.statusCode,
          'body_length': response.body.length,
          'silent': silent,
        },
      );
      await ResponseHandler.checkResponseError(
        response,
        showException: false,
      );

      final model = ChatListModel.fromJson(jsonDecode(response.body));
      chatList.assignAll(model.chats ?? <Chat>[]);
      PassengerFlowDebug.send(
        'passenger_chat_history_parsed',
        bookingId: widget.bookingId,
        data: <String, dynamic>{'message_count': chatList.length},
      );
      unawaited(_markMessagesRead());
    } catch (error, stack) {
      LogUtils.printError('PASSENGER CHAT HISTORY ERROR: $error, $stack');
      PassengerFlowDebug.send(
        'passenger_chat_history_error',
        bookingId: widget.bookingId,
        data: <String, dynamic>{'error': '$error', 'silent': silent},
      );
      if (!silent) {
        AppSnackBar.showErrorSnackBar(
          message: 'Az üzeneteket most nem sikerült betölteni.',
          isError: true,
        );
      }
    } finally {
      if (!silent) isLoading.value = false;
    }
  }

  Future<void> _markMessagesRead() async {
    try {
      await Api().post(
        ApiConstants.markChatRead,
        bodyData: <String, dynamic>{'booking_id': widget.bookingId},
      );
    } catch (_) {
      // Az olvasottság hibája nem akadályozhatja a chat használatát.
    }
  }

  Future<void> socketAuthConnection() async {
    try {
      if (AppConstant().socketId.isEmpty) {
        await Future<void>.delayed(const Duration(seconds: 2));
      }
      if (AppConstant().socketId.isEmpty) {
        PassengerFlowDebug.send(
          'passenger_chat_socket_auth_skipped',
          bookingId: widget.bookingId,
          data: <String, dynamic>{'reason': 'missing_socket_id'},
        );
        return;
      }

      final response = await Api().post(
        ApiConstants.socketAuthentication,
        bodyData: <String, dynamic>{
          'socket_id': AppConstant().socketId,
          'channel_name': 'private-chat.booking.${widget.bookingId}',
        },
      );

      PassengerFlowDebug.send(
        'passenger_chat_socket_auth_response',
        bookingId: widget.bookingId,
        data: <String, dynamic>{'http_status': response.statusCode},
      );

      if (response.statusCode != 200) return;
      final dynamic data = jsonDecode(response.body);
      final String auth = data is Map ? data['auth']?.toString() ?? '' : '';
      if (auth.isEmpty) return;
      _socketService.sendPusherEvent('pusher:subscribe', <String, dynamic>{
        'channel': 'private-chat.booking.${widget.bookingId}',
        'auth': auth,
      });
    } catch (error, stack) {
      log('PASSENGER CHAT SOCKET AUTH ERROR: $error');
      LogUtils.printError('PASSENGER CHAT SOCKET AUTH ERROR: $error, $stack');
      PassengerFlowDebug.send(
        'passenger_chat_socket_auth_error',
        bookingId: widget.bookingId,
        data: <String, dynamic>{'error': '$error'},
      );
      // A 4 másodperces HTTP frissítés miatt a chat socket nélkül is működhet.
    }
  }

  Future<void> sendMessage(String msg) async {
    final String message = msg.trim();
    final bookingId = widget.bookingId.trim();
    if (message.isEmpty || isSending.value) return;
    if (bookingId.isEmpty || bookingId == 'null') {
      PassengerFlowDebug.send('passenger_chat_send_blocked_missing_booking');
      AppSnackBar.showErrorSnackBar(
        message: 'A chat nem nyitható meg fuvarazonosító nélkül.',
        isError: true,
      );
      return;
    }

    isSending.value = true;
    PassengerFlowDebug.send(
      'passenger_chat_send_requested',
      bookingId: widget.bookingId,
      data: <String, dynamic>{'message_length': message.length},
    );

    try {
      final response = await Api().post(
        ApiConstants.sendChatMessage,
        bodyData: <String, dynamic>{
          'booking_id': widget.bookingId,
          'message': message,
          'message_type': 'text',
          'metadata': <String, dynamic>{},
        },
      );
      PassengerFlowDebug.send(
        'passenger_chat_send_response',
        bookingId: widget.bookingId,
        data: <String, dynamic>{
          'http_status': response.statusCode,
          'body_length': response.body.length,
        },
      );
      await ResponseHandler.checkResponseError(
        response,
        showException: false,
      );

      final dynamic decoded = jsonDecode(response.body);
      final dynamic rawChat = decoded is Map ? decoded['chat'] : null;
      if (rawChat is Map) {
        _upsertChat(Chat.fromJson(Map<String, dynamic>.from(rawChat)));
      } else {
        await getMsgHistory(silent: true);
      }
      controller.clear();
      PassengerFlowDebug.send(
        'passenger_chat_send_success',
        bookingId: widget.bookingId,
      );
    } catch (error, stack) {
      LogUtils.printError('PASSENGER CHAT SEND ERROR: $error, $stack');
      PassengerFlowDebug.send(
        'passenger_chat_send_error',
        bookingId: widget.bookingId,
        data: <String, dynamic>{'error': '$error'},
      );
      AppSnackBar.showErrorSnackBar(
        message: 'Az üzenetet nem sikerült elküldeni. Próbáld újra.',
        isError: true,
      );
    } finally {
      isSending.value = false;
    }
  }

  Future<void> _deleteMessage(Chat chat) async {
    final id = chat.id?.trim() ?? '';
    if (id.isEmpty || chat.sender?.id != userId) return;
    final bool confirmed = await Get.dialog<bool>(
          AlertDialog(
            title: const Text('Üzenet törlése'),
            content: const Text('Biztosan törlöd ezt az üzenetet?'),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: const Text('Mégse'),
              ),
              FilledButton(
                onPressed: () => Get.back(result: true),
                child: const Text('Törlés'),
              ),
            ],
          ),
        ) ??
        false;
    if (!confirmed) return;

    try {
      final response = await Api().delete('${ApiConstants.deleteChatMessage}$id');
      await ResponseHandler.checkResponseError(response, showException: false);
      await getMsgHistory(silent: true);
    } catch (_) {
      AppSnackBar.showErrorSnackBar(
        message: 'Az üzenet nem törölhető. Csak a saját, friss üzeneted törölhető.',
        isError: true,
      );
    }
  }

  @override
  void dispose() {
    PassengerFlowDebug.send(
      'passenger_chat_closed',
      bookingId: widget.bookingId,
      data: <String, dynamic>{'message_count': chatList.length},
    );
    _historyPollingTimer?.cancel();
    _socketStream?.cancel();
    _socketService.sendPusherEvent('pusher:unsubscribe', <String, dynamic>{
      'channel': 'private-chat.booking.${widget.bookingId}',
    });
    chatList.clear();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteGrey,
      appBar: const CustomAppBar(centerTitle: false, title: 'Üzenetek'),
      body: SafeArea(
        child: Obx(
          () => isLoading.value
              ? const Center(child: CircularProgressIndicator())
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
                        Expanded(
                          child: chatList.isEmpty
                              ? Center(
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 18.w,
                                      vertical: 12.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.whiteColor.withValues(
                                        alpha: 0.92,
                                      ),
                                      borderRadius: BorderRadius.circular(12.r),
                                    ),
                                    child: const Text(
                                      'Még nincs üzenet. Írj a sofőrnek!',
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                )
                              : ListView.separated(
                                  separatorBuilder: (_, __) => 6.verticalSpace,
                                  itemCount: chatList.length,
                                  reverse: true,
                                  itemBuilder: (context, index) {
                                    final data = chatList[index];
                                    final bool mine = data.isFromMe == true || data.sender?.id == userId;
                                    final bool deleted =
                                        data.messageType == 'deleted';
                                    return GestureDetector(
                                      onLongPress: mine && !deleted
                                          ? () => _deleteMessage(data)
                                          : null,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment: mine
                                            ? CrossAxisAlignment.end
                                            : CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            margin: EdgeInsets.only(
                                              left: mine ? Get.width * 0.22 : 0,
                                              right: mine ? 0 : Get.width * 0.22,
                                            ),
                                            padding: EdgeInsets.all(12.w),
                                            decoration: BoxDecoration(
                                              color: mine
                                                  ? AppColors.mainPrimaryColor
                                                  : AppColors.primaryContainer,
                                              borderRadius:
                                                  BorderRadius.circular(12.r),
                                            ),
                                            child: Text(
                                              deleted
                                                  ? 'Ez az üzenet törölve lett.'
                                                  : data.message ?? '',
                                              style: TextStyle(
                                                fontStyle: deleted
                                                    ? FontStyle.italic
                                                    : FontStyle.normal,
                                              ),
                                            ),
                                          ),
                                          if (Utils()
                                              .time(data.createdAt ?? '')
                                              .isNotEmpty)
                                            CommonText(
                                              string: Utils().time(
                                                data.createdAt ?? '',
                                              ),
                                              fontSize: 12.sp,
                                            ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                        ),
                        12.verticalSpace,
                        Row(
                          children: [
                            Expanded(
                              child: CustomTextField(
                                controller: controller,
                                hintText: 'Írj üzenetet…',
                              ),
                            ),
                            8.horizontalSpace,
                            GestureDetector(
                              onTap: () => sendMessage(controller.text),
                              child: Obx(
                                () => Container(
                                  height: 48.h,
                                  width: 48.h,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10.r),
                                    color: AppColors.mainPrimaryColor,
                                  ),
                                  alignment: Alignment.center,
                                  child: isSending.value
                                      ? SizedBox(
                                          height: 20.h,
                                          width: 20.h,
                                          child: const CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: AppColors.brandNavy,
                                          ),
                                        )
                                      : CustomImage(image: IconAsset.sendIcon),
                                ),
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

RxList<Chat> chatList = <Chat>[].obs;
