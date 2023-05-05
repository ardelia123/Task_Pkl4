import 'dart:async';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MqttManager {
  static MqttServerClient? client;
  static Function? onConnected;
  static Function? onDisconnected;
  static final StreamController<MqttConnectionState>
      _connectionStateController = StreamController<MqttConnectionState>();
  static Stream<MqttConnectionState> get connectionStateStream =>
      _connectionStateController.stream;
  static void connect() async {
    client = MqttServerClient('rmq2.pptik.id','');
    client!.port = 1883;
    client!.logging(on: true);
    client!.onDisconnected = () {
      print('Disconnected');
      _connectionStateController.add(MqttConnectionState.disconnected);
      onDisconnected?.call();
    };
    client!.onConnected = () {
      print('Connected');
      _connectionStateController.add(MqttConnectionState.connected);
      onConnected?.call();
    };
    try {
      await client?.connect('/smkwikramabogor:smkwikramabogor', 'qwerty');
    } catch (e) {
      print('Exception : $e');
      client?.disconnect();
    }
  }

  static void subscribe(String topic, Function(String) onMessage) {
    client!.subscribe(topic, MqttQos.atLeastOnce);
    client!.updates!.listen((List<MqttReceivedMessage<MqttMessage>> messages) {
      messages.forEach((message) {
        final MqttPublishMessage receivedMessage =
            message.payload as MqttPublishMessage;
        final String payload = MqttPublishPayload.bytesToStringAsString(
            receivedMessage.payload.message);
        print(payload);
        onMessage(payload);
      });
    });
  }

  static void publish(String topic, String message) {
    final MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
    builder.addString(message);
    client!.publishMessage(topic, MqttQos.exactlyOnce, builder.payload!);
    print('success');
  }

  static void disconnect() {
    client?.disconnect();
  }
}
