part of 'robot_pose_bloc.dart';

sealed class RobotPoseEvent  {
  const RobotPoseEvent(); 
}

class RobotPoseInitEvent extends RobotPoseEvent{
  const RobotPoseInitEvent();
}

class RobotPoseUpdateEvent extends RobotPoseEvent{

  const RobotPoseUpdateEvent();
}

class RobotPoseCloseEvent extends RobotPoseEvent{
  const RobotPoseCloseEvent();
}