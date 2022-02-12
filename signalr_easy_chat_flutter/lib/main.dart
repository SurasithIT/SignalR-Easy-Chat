import 'package:flutter/material.dart';
import 'package:signalr_easy_chat_flutter/src/pages/chat_page.dart';
import 'src/services/signalr_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SignalR Easy Chat Flutter',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'SignalR Easy Chat Flutter'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _formKey = GlobalKey<FormState>();
  final _userNameController = TextEditingController();

  Form _myForm(){
    return Form(
      key: _formKey,
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextFormField(
              controller: _userNameController,
              validator: (value){
                if (value == null || value.isEmpty) {
                  return 'Please enter Username';
                }
                return null;
              }
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: ElevatedButton(
                onPressed: () async {
                  print(_userNameController.text);
                  if (_formKey.currentState!.validate()) {
                    await signalRService.disconnect();
                    await signalRService.connect(_userNameController.text).then((value) =>
                    {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Connect Success!')),
                      ),
                      signalRService.addMessageListener(),
                      Navigator.push(context,
                        MaterialPageRoute(builder: (context) => const ChatPage()))
                    }).catchError((error) => {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Connect Error! please try again later.'), backgroundColor: Colors.red),
                        )
                    });
                  }
                },
                child: const Text('Connect'),
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
