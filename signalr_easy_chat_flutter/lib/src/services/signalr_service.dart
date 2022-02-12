import 'package:signalr_easy_chat_flutter/src/models/message_model.dart';
import 'package:signalr_easy_chat_flutter/src/utils/constant.dart';
import 'package:signalr_netcore/signalr_client.dart';
import 'package:rxdart/rxdart.dart';

class SignalRService {
  late HubConnection? hubConnection;
  late String _userName;
  final BehaviorSubject<List<MessageModel>> messages =
      BehaviorSubject<List<MessageModel>>.seeded([]);
  List<MessageModel> _messages = [];

  Future<void> connect(String userName) async {
    _userName = userName;
    hubConnection = HubConnectionBuilder()
        .withUrl(Constant.hubConnectionUrl + "?userName=$_userName")
        .build();
    hubConnection?.onclose(({Exception? error}) => print("Connection Closed"));

    return hubConnection!.start()?.catchError(
        (error) => {print("Connection error $error"), throw error});
  }

  Future<void> disconnect() async {
    _messages = [];
    messages.add(_messages);

    if (hubConnection != null) {
      await hubConnection?.stop();
      hubConnection = null;
    }
  }

  Future<void> sendMessage(String receiverUserName, String message) async {
    await hubConnection?.invoke("SendMessage",
        args: <String>[receiverUserName, message, _userName]);
    _messages.add(MessageModel(
        messageOf: MessageOfEnum.Sender,
        messageText: message,
        senderUserName: _userName));
    messages.add(_messages);
  }

  void addMessageListener() async {
    hubConnection?.on("ReceiveMessage", _handleReceiveMessage);
  }

  void _handleReceiveMessage(List<Object>? parameters) {
    print(parameters?.toString());
    _messages.add(MessageModel(
        messageOf: MessageOfEnum.Receiver,
        messageText: parameters != null ? parameters[1].toString() : '',
        senderUserName: parameters != null ? parameters[0].toString() : ''));
    messages.add(_messages);
  }
}

SignalRService signalRService = SignalRService();
