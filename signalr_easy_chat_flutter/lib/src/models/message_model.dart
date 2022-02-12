import 'package:signalr_easy_chat_flutter/src/utils/constant.dart';

class MessageModel{
  final MessageOfEnum messageOf;
  final String messageText;
  final String senderUserName;

  MessageModel({
    required this.messageOf,
    required this.messageText,
    required this.senderUserName
  });
}