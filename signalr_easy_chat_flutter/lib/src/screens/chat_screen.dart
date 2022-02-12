import 'package:flutter/material.dart';
import 'package:signalr_easy_chat_flutter/src/models/message_model.dart';
import 'package:signalr_easy_chat_flutter/src/services/signalr_service.dart';
import 'package:signalr_easy_chat_flutter/src/utils/constant.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);
  final String title = "Chat";

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _formKey = GlobalKey<FormState>();
  final _receiverUserNameController = TextEditingController();
  final _messageController = TextEditingController();

  Form _sendMessageForm() {
    return Form(
        key: _formKey,
        child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            child: TextFormField(
                decoration: const InputDecoration(
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(),
                  labelText: 'Enter your Receiver Username',
                ),
                controller: _receiverUserNameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Receiver Username';
                  }
                  return null;
                }),
          ),
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              child: TextFormField(
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.message),
                    border: OutlineInputBorder(),
                    labelText: 'type your message',
                  ),
                  controller: _messageController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter message';
                    }
                    return null;
                  })),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            child: ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  await signalRService.sendMessage(
                      _receiverUserNameController.text,
                      _messageController.text);
                  _messageController.text = '';
                }
              },
              child: const Text('Send'),
            ),
          ),
        ]));
  }

  StreamBuilder _messageList() {
    return StreamBuilder(
        stream: signalRService.messages,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Container();
          }
          List<MessageModel> messages =
              snapshot.hasData ? snapshot.data as List<MessageModel> : [];
          return Expanded(
              child: ListView.builder(
            itemCount: messages.length,
            itemBuilder: (BuildContext context, int index) {
              final MessageModel message = messages[index];
              return ListTile(
                title: Row(
                  mainAxisAlignment: message.messageOf == MessageOfEnum.Sender
                      ? MainAxisAlignment.end
                      : MainAxisAlignment.start,
                  children: [
                    Text(message.senderUserName,
                        style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w300,
                            fontSize: 15))
                  ],
                ),
                subtitle: Row(
                  mainAxisAlignment: message.messageOf == MessageOfEnum.Sender
                      ? MainAxisAlignment.end
                      : MainAxisAlignment.start,
                  children: [
                    Text(message.messageText,
                        style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.normal,
                            fontSize: 18))
                  ],
                ),
              );
            },
          ));
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _messageList(),
            _sendMessageForm(),
          ],
        ),
      ),
    );
  }
}
