

class SubscribeException implements Exception{

  SubscribeException(){
    _message = "MQTT订阅失败";
  }

  String _message;

  @override
  String toString() => _message;

}