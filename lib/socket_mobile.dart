import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:socket_mobile/socket_mobile_device.dart';
import 'package:socket_mobile/socket_mobile_message.dart';

class SocketMobile {
  SocketMobile._();
  static const MethodChannel _channel = MethodChannel('socket_mobile');

  static final shared = SocketMobile._();

  List<SocketMobileDevice> devices = [];

  Stream<List<SocketMobileDevice>> get devicesStream =>
      _devicesController.stream;
  Stream<SocketMobileMessage> get messageStream => _messageController.stream;

  final _devicesController =
      StreamController<List<SocketMobileDevice>>.broadcast();
  final _messageController = StreamController<SocketMobileMessage>.broadcast();

  Future<void> configure({
    required String developerId,
    required String appKeyIOS,
    required String appIdIOS,
    required String appKeyAndroid,
    required String appIdAndroid,
  }) async {
    Map<String, dynamic> params;

    if (Platform.isIOS) {
      params = {
        'developerId': developerId,
        'appKey': appKeyIOS,
        'appId': appIdIOS,
      };
    } else {
      params = {
        'developerId': developerId,
        'appKey': appKeyAndroid,
        'appId': appIdAndroid,
      };
    }

    _channel.setMethodCallHandler((MethodCall call) async {
      if (call.method == 'devices') {
        final devicesJson = call.arguments as List;
        final devices = devicesJson
            .map((x) => x as Map)
            .map(
              (x) => SocketMobileDevice.fromJson(
                Map<String, dynamic>.from(x),
              ),
            )
            .toList();

        this.devices = devices;
        _devicesController.sink.add(devices);
      } else if (call.method == 'data') {
        final text = call.arguments['message'] as String? ?? '';
        final deviceJson = call.arguments['device'] as Map? ?? {};

        final device =
            SocketMobileDevice.fromJson(Map<String, dynamic>.from(deviceJson));
        final message = SocketMobileMessage(text, device);

        _messageController.sink.add(message);
      } else {
        print('[SocketMobile] unknown method ${call.method}');
      }
    });

    await _channel.invokeMethod('configure', params);
  }
}
