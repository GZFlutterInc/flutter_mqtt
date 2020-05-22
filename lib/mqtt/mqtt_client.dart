import 'package:fluttermqtt/mqtt/listen_callback.dart';
import 'package:fluttermqtt/mqtt/mqtt_config.dart';
import 'package:fluttermqtt/mqtt/subscribe_exception.dart';

import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:mqtt_client/mqtt_client.dart';

class MqttUtils {
  MqttUtils._();

  static MqttUtils _instance;
  MqttServerClient _mqttClient;
  ListenCallback _callback;

  static MqttUtils getInstance() {
    if (_instance == null) {
      _instance = MqttUtils._();
    }
    return _instance;
  }

  void setListenCallback(ListenCallback callback) {
    this._callback = callback;
  }

  Future<MqttClientConnectionStatus> connectMQTT() async {
    _mqttClient = MqttServerClient.withPort(
        MqttConfig.MQTT_HOST, MqttConfig.MQTT_NAME, MqttConfig.MQTT_PORT);
    return _mqttClient.connect();
  }

  Future<Subscription> subscribe() async {
    if (null != _mqttClient) {
      return _mqttClient.subscribe(MqttConfig.MQTT_TOPIC, MqttQos.atMostOnce);
    } else {
      throw SubscribeException();
    }
  }

  // atLeastOnce
  Future<void> publishMessageToMqttServer(String message) async {
    final MqttClientPayloadBuilder payloadBuilder = MqttClientPayloadBuilder();
    payloadBuilder.addString(message);
    _mqttClient.publishMessage(
        MqttConfig.MQTT_TOPIC, MqttQos.exactlyOnce, payloadBuilder.payload);

    ///监听服务器发来的信息
    _mqttClient.updates.listen((List<MqttReceivedMessage<MqttMessage>> c) {
      if (null != _callback) {
        _callback.callMessage(c);
      }
    });
  }

  void dispose() {
    _mqttClient.disconnect();
  }
}
