import 'package:flutter/material.dart';
import 'package:zendesk_messaging/zendesk_messaging.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late bool _isInitialized;
  late TextEditingController _channelKeyController;
  late TextEditingController _jwtController;

  @override
  void initState() {
    _isInitialized = false;
    _channelKeyController = TextEditingController();
    _jwtController = TextEditingController();
    super.initState();
  }

  String? errorText;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            children: [if (!_isInitialized) ...buildNotInitializedWidgetList() else ...buildInitializedWidgetList()],
          ),
        ),
      ),
    );
  }

  List<Widget> buildNotInitializedWidgetList() {
    return [
      const Text('Enter your channel key'),
      TextField(
        controller: _channelKeyController,
      ),
      ElevatedButton(
        onPressed: _tryInitializeZendesk,
        child: const Text('Initialize Zendesk'),
      ),
      const SizedBox(height: 20),
      const Text('Click button to see error behavior (error will be printed bellow)'),
      ElevatedButton(
        onPressed: () => ZendeskMessaging.showZendeskView(),
        child: const Text('Wrong attempt to show zendesk'),
      ),
    ];
  }

  Future<void> _tryInitializeZendesk() async {
    try {
      await ZendeskMessaging.initializeZendesk(_channelKeyController.value.text);

      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      // ignore: avoid_print
      print(e.toString());
    }
  }

  List<Widget> buildInitializedWidgetList() {
    return [
      const Text('Try login user'),
      TextField(
        controller: _jwtController,
      ),
      ElevatedButton(
        onPressed: () => _tryExecuteSimpleAction(() => ZendeskMessaging.loginUser(_jwtController.value.text)),
        child: const Text('Login'),
      ),
      const SizedBox(height: 20),
      const Text('Try logout user'),
      ElevatedButton(
        onPressed: () => _tryExecuteSimpleAction(() => ZendeskMessaging.logoutUser()),
        child: const Text('Logout'),
      ),
      const SizedBox(height: 20),
      const Text('Try show zendesk view'),
      ElevatedButton(
        onPressed: () => _tryExecuteSimpleAction(() => ZendeskMessaging.showZendeskView()),
        child: const Text('Zendesk View'),
      ),
    ];
  }

  Future<void> _tryExecuteSimpleAction(Function action) async {
    try {
      await action();
    } catch (e) {
      // ignore: avoid_print
      print(e.toString());
    }
  }
}
