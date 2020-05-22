import 'package:mqtt_client/mqtt_client.dart';

typedef CallMessage = void Function(
    List<MqttReceivedMessage<MqttMessage>> messages);

class ListenCallback {
  CallMessage callMessage;

  ListenCallback({this.callMessage});
}
