part of 'robot_pose_bloc.dart';

sealed class RobotPoseState  {
  const RobotPoseState();
}

final class RobotPoseInitial extends RobotPoseState {}


class RobotPoseFetched extends RobotPoseState with EquatableMixin{

  final RobotposeModel currRobotPose;
  final RobotposeModel robotPoseScene;
  const RobotPoseFetched({required this.currRobotPose,required this.robotPoseScene});

  @override
  // TODO: implement props
  List<Object?> get props => [currRobotPose,robotPoseScene];
  
}

// class RobotPoseFetched extends RobotPoseState  {

//   final RobotposeModel currRobotPose;
//   final RobotposeModel robotPoseScene;
//   const RobotPoseFetched({required this.currRobotPose,required this.robotPoseScene});

  
// }

class RobotPoseError extends RobotPoseState {
  const RobotPoseError();
}