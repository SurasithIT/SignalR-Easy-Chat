import 'package:flutter/material.dart';
import 'package:signalr_easy_chat_flutter/src/screens/chat_screen.dart';
import 'package:signalr_easy_chat_flutter/src/services/signalr_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userNameController = TextEditingController();

  Form _loginForm() {
    return Form(
        key: _formKey,
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            child: TextFormField(
                decoration: const InputDecoration(
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(),
                  labelText: 'Enter your Username',
                ),
                controller: _userNameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your Username';
                  }
                  return null;
                }),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            child: ElevatedButton(
              onPressed: () async {
                print(_userNameController.text);
                if (_formKey.currentState!.validate()) {
                  await signalRService.disconnect();
                  await signalRService
                      .connect(_userNameController.text)
                      .then((value) => {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Connect Success!')),
                            ),
                            signalRService.addMessageListener(),
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const ChatScreen())).then(
                                (value) async =>
                                    await signalRService.disconnect())
                          })
                      .catchError((error) => {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Connect Error! please try again later.'),
                                  backgroundColor: Colors.red),
                            )
                          });
                }
              },
              child: const Text('Connect'),
            ),
          ),
        ]));
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
            _loginForm(),
          ],
        ),
      ),
    );
  }
}
