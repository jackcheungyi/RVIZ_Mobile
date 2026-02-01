part of 'ros_cmd_bloc.dart';

sealed class RosCmdEvent extends Equatable {
  const RosCmdEvent();

  @override
  List<Object> get props => [];
}


class RosCmdInitEvent extends RosCmdEvent {}

class RosCmdSendEvent extends RosCmdEvent {
  final double linear;
  final double angular;
  const RosCmdSendEvent({
    required this.linear,
    required this.angular,
  });
}