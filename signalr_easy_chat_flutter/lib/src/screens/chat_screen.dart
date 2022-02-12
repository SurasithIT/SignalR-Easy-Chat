import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:signalr_easy_chat_flutter/src/services/signalr_service.dart';

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

  Form _myForm(){
    return Form(
        key: _formKey,
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextFormField(
                  controller: _receiverUserNameController,
                  validator: (value){
                    if (value == null || value.isEmpty) {
                      return 'Please enter Receiver Username';
                    }
                    return null;
                  }
              ),
              TextFormField(
                  controller: _messageController,
                  validator: (value){
                    if (value == null || value.isEmpty) {
                      return 'Please enter message';
                    }
                    return null;
                  }
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      await signalRService.sendMessage(_receiverUserNameController.text, _messageController.text);
                    }
                  },
                  child: const Text('Send'),
                ),
              ),
            ]
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _myForm(),
          ],
        ),
      ),
    );
  }
}
