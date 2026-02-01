part of 'ros_nav_bloc.dart';

sealed class RosNavState extends Equatable {
  const RosNavState();
  
  @override
  List<Object> get props => [];
}

final class RosNavInitial extends RosNavState {}

final class RosNavToGoalState extends RosNavState {
  final RobotposeModel goal;
  final bool reached;
  const RosNavToGoalState({required this.goal, required this.reached});

  @override
  List<Object> get props => [goal, reached];
}
