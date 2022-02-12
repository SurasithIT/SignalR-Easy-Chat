import 'package:signalr_easy_chat_flutter/src/utils/constant.dart';
import 'package:signalr_netcore/signalr_client.dart';

class SignalRService {
  late HubConnection? hubConnection = null;
  late String _userName;

  Future<void> connect(String userName) async {
    _userName = userName;
    this.hubConnection = HubConnectionBuilder().withUrl(Constant.hubConnectionUrl + "?userName=$_userName").build();
    hubConnection?.onclose(({Exception? error}) => print("Connection Closed"));

    return hubConnection!.start()?.catchError((error) =>
    {
      print("Connection error $error"),
      throw error
    });
  }

  Future<void> disconnect() async {
    if(hubConnection != null){
      await hubConnection?.stop();
      hubConnection = null;
    }
  }

  Future<void> sendMessage(String receiverUserName, String message) async {
    await hubConnection?.invoke("SendMessage",args: <String>[receiverUserName, message, _userName]);
  }

  void addMessageListener() async {
    hubConnection?.on("ReceiveMessage", _handleAClientProvidedFunction);
  }

  void _handleAClientProvidedFunction(List<Object>? parameters) {
    print(parameters?.toString());
    // logger.log(LogLevel.Information, "Server invoked the method");
  }
}

SignalRService signalRService = new SignalRService();