import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'socket_mobile_device.g.dart';

@JsonSerializable()
class SocketMobileDevice extends Equatable {
  const SocketMobileDevice(
    this.name,
    this.uuid,
    this.guid,
  );

  factory SocketMobileDevice.fromJson(Map<String, dynamic> json) =>
      _$SocketMobileDeviceFromJson(json);

  /// friendly name
  final String name;

  /// unique ID, corresponding to the bluetooth address
  final String uuid;

  /// session ID
  final String guid;

  @override
  List<Object> get props => [uuid];
}
