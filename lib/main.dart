import 'package:flutter/material.dart';
import 'package:fluttermqtt/mqtt/listen_callback.dart';
import 'package:fluttermqtt/mqtt/mqtt_client.dart';
import 'package:mqtt_client/mqtt_client.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter MQTT',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<String> mReceiveMsg = [];

  TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    MqttUtils.getInstance()
        .connectMQTT()
        .then((state) => {dealConnectState(state.state)}, onError: (e) {
      print("MQTT 连接服务器失败：$e");
    });
    MqttUtils.getInstance().setListenCallback(ListenCallback(
        callMessage: (List<MqttReceivedMessage<MqttMessage>> messages) {
          final MqttPublishMessage recMess = messages[0].payload;
          ///服务器返回的数据信息
          final String pt =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
          mReceiveMsg.clear();
          setState(() {
            mReceiveMsg.add(pt);
          });
        }));
  }

  void _incrementCounter() {
    var content = _controller.text;
    if (content.isEmpty) return;
    MqttUtils.getInstance().publishMessageToMqttServer(content);
  }

  Widget _buildSendWidget() {
    return Container(
      height: 60,
      child: TextField(
        autofocus: true,
        obscureText: false,
        controller: _controller,
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.message),
          fillColor: Colors.white,
          filled: true,
          hintText: '说点什么？',
          hintStyle: TextStyle(color: Colors.grey, fontSize: 14.0),
          contentPadding: const EdgeInsets.all(10.0),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Flutter MQTT"),
      ),
      body: Center(
        child: ListView.builder(
          padding: new EdgeInsets.all(5.0),
          itemCount: mReceiveMsg.length,
          itemBuilder: (BuildContext context, int index) {
            return Text(mReceiveMsg[index]);
          },
        ),
      ),
      bottomNavigationBar: _buildSendWidget(),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: '发送消息',
        child: Icon(Icons.send),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  dealConnectState(MqttConnectionState state) {
    switch (state) {
      case MqttConnectionState.connected:
        print("MQTT 连接服务器成功");
        MqttUtils.getInstance()
            .subscribe()
            .then((subscribe) => {print("MQTT 订阅服务器成功")}, onError: (e) {
          print("MQTT 订阅服务器失败：$e");
        });
        break;
      case MqttConnectionState.disconnecting:
        print("MQTT 正在断开连接服务器");
        break;
      case MqttConnectionState.disconnected:
        print("MQTT 已经断开连接服务器");
        break;
      case MqttConnectionState.connecting:
        print("MQTT 正在连接服务器");
        break;
      case MqttConnectionState.faulted:
        print("MQTT 连接服务器失败");
        break;
    }
  }


  @override
  void dispose() {
    MqttUtils.getInstance().dispose();
    super.dispose();
  }
}
