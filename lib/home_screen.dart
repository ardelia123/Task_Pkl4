import 'package:flutter/material.dart';
import 'mqtt_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

String connectionStatus = 'Disconnected';
String topic = 'chatmessage';
String publish = '';
List<String> messages = [];
final fieldText = TextEditingController();

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    connect();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => {
          setState(() {
            messages = [];
          }),
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              duration: Duration(seconds: 1),
              content: Text('Cleared all messages'),
            ),
          ),
        },
        child: const Icon(Icons.delete_outline),
      ),
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Message'),
        centerTitle: true,
        titleTextStyle: const TextStyle(fontSize: 15),
      ),
      body: Container(
        height: double.infinity,
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                TextField(
                  cursorColor: Colors.white,
                  decoration: const InputDecoration(
                    hintText: 'Enter a message',
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Color.fromARGB(26, 255, 254, 254), width: 1.0),
                    ),
                  ),
                  onChanged: (value) {
                    publish = value;
                  },
                  controller: fieldText,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                            Colors.blueGrey[700]!),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.0)),
                        ),
                      ),
                      onPressed: () => publishMessage(context),
                      child: const Text('Publish'),
                    ),
                    const SizedBox(width: 10),
                    if (connectionStatus == 'Connected')
                      ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              Colors.redAccent),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18.0)),
                          ),
                        ),
                        onPressed: disconnect,
                        child: const Text('Disconnect'),
                      ),
                    if (connectionStatus == 'Disconnected')
                      ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              Colors.greenAccent),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18.0)),
                          ),
                        ),
                        onPressed: connect,
                        child: const Text('Connect'),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            connectionStates(),
            const SizedBox(height: 20),
            if (messages.isEmpty) const Text('No Message Received'),
            if (messages.isNotEmpty) const Text('Received Message'),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemBuilder: (BuildContext context, int index) {
                  return Card(
                    child: ListTile(
                      title: Text(messages[index]),
                    ),
                  );
                },
                itemCount: messages.length,
                shrinkWrap: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  void connect() {
    MqttManager.connect();
    MqttManager.onConnected = () {
      MqttManager.subscribe(topic, (String message) {
        setState(() {
          messages.insert(0, message);
          print(messages);
        });
      });
      setState(() {
        connectionStatus = 'Connected';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          duration: Duration(seconds: 2),
          content: Text('Connected to MQTT'),
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Duration(seconds: 1),
          content: Text('Subscribed to Topic: $topic'),
        ),
      );
    };
  }

  void disconnect() {
    MqttManager.disconnect();
    setState(() {
      connectionStatus = 'Disconnected';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        duration: Duration(seconds: 1),
        content: Text('Disconnected from MQTT'),
      ),
    );
  }
}

Widget connectionStates() {
  return Row(
    children: [
      Text('Connection Status: $connectionStatus'),
      const SizedBox(width: 10),
      if (connectionStatus == 'Connected')
        const Icon(
          Icons.check_circle_outline,
          color: Colors.green,
          size: 16,
        ),
      if (connectionStatus == 'Disconnected')
        const Icon(
          Icons.cancel_outlined,
          color: Colors.red,
          size: 16,
        ),
    ],
  );
}

void publishMessage(BuildContext context) {
  if (publish == '') {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Please enter a message to Publish'),
        duration: Duration(seconds: 1),
      ),
    );
  } else if (connectionStatus == 'Disconnected') {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Please connect to the broker'),
        duration: Duration(seconds: 1),
      ),
    );
  } else {
    MqttManager.publish(topic, publish);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Message Published'),
      ),
    );
  }
  fieldText.clear();
  FocusScope.of(context).unfocus();
}
