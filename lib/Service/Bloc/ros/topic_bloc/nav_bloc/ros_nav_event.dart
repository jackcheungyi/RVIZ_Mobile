part of 'ros_nav_bloc.dart';

sealed class RosNavEvent extends Equatable {
  const RosNavEvent();

  @override
  List<Object> get props => [];
}

class RosNavSendGoadlEvent extends RosNavEvent {
  final RobotposeModel goal;
  const RosNavSendGoadlEvent({required this.goal});
}

class RosUpdateProgressEvent extends RosNavEvent {
  final RobotposeModel goal;
  final RobotposeModel pose;
  const RosUpdateProgressEvent({required this.goal, required this.pose});
}