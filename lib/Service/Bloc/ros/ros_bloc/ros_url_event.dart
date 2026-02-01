part of 'ros_url_bloc.dart';

@immutable
sealed class RosUrlEvent {
  const RosUrlEvent();
}

class RosInitEvent extends RosUrlEvent{
  const RosInitEvent();
}

class RosConnectReqEvent extends RosUrlEvent{
  final String ip;
  final String port;
  const RosConnectReqEvent( this.ip, this.port);
}

class RosDisconnectReqEvent extends RosUrlEvent{
  const RosDisconnectReqEvent();
}