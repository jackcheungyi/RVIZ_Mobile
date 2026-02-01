// import 'dart:nativewrappers/_internal/vm/lib/async_patch.dart';
import 'dart:async';
// import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:ros_control/Service/Data/Ros_model/robotpose_model.dart';
import 'package:ros_control/Service/ROS/ros_provider.dart';
// import 'package:equatable/equatable.dart';

part 'robot_pose_event.dart';
part 'robot_pose_state.dart';

class RobotPoseBloc extends Bloc<RobotPoseEvent, RobotPoseState> {
  final RosProvider rosProvider;
  Timer? _timer;
  RobotPoseBloc(this.rosProvider) : super(RobotPoseInitial()) {
    on<RobotPoseInitEvent>(_initial);
    on<RobotPoseUpdateEvent>(_update);
    on<RobotPoseCloseEvent>(_close);
  }


  void _initial(RobotPoseInitEvent event, Emitter<RobotPoseState> emit){
    //periodic update the robot pose 
    _timer = Timer.periodic(const Duration(milliseconds: 32),(timer){     
      add(RobotPoseUpdateEvent());
    });
  }

  void _update(RobotPoseUpdateEvent event, Emitter<RobotPoseState> emit){
    try{
        RobotposeModel currRobotPose_ = rosProvider.tf.lookUpForTransform('map', 'base_link');
        currRobotPose_.timestamp = rosProvider.currentTime;
        // print("currRobotPose_ is $currRobotPose_");
        Offset poseOffset_ = rosProvider.currentMap.xy2idx(Offset(currRobotPose_.x, currRobotPose_.y));
        // print("Current poseoffset : $poseOffset_");
        RobotposeModel robotPoseScene_ = RobotposeModel(x: poseOffset_.dx, y: poseOffset_.dy, theta: currRobotPose_.theta);
        // print("current robotPoseScene_ is $robotPoseScene_");
        robotPoseScene_.timestamp = rosProvider.currentTime;
        // print("should emit RobotPoseFetched");
        emit(RobotPoseFetched(currRobotPose: currRobotPose_, robotPoseScene: robotPoseScene_));
      }catch(e){
        emit(const RobotPoseError());                              
        // print("Robot pose update error: $e");
      }
  }

  void _close(RobotPoseCloseEvent event, Emitter<RobotPoseState> emit){
    _timer?.cancel();
  }
}
