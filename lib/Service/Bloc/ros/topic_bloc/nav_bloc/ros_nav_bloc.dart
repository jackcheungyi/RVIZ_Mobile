import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:ros_control/Service/Data/Ros_model/robotpose_model.dart';
import 'package:ros_control/Service/ROS/ros_provider.dart';
import 'package:vector_math/vector_math_64.dart' as vm;

part 'ros_nav_event.dart';
part 'ros_nav_state.dart';

class RosNavBloc extends Bloc<RosNavEvent, RosNavState> {
  final RosProvider rosProvider;
  RosNavBloc(this.rosProvider) : super(RosNavInitial()) {
    on<RosNavSendGoadlEvent>(_sendgoal);
    on<RosUpdateProgressEvent>(_updateProgress);
  }

  void _sendgoal(RosNavSendGoadlEvent event, Emitter<RosNavState> emit) async {
    Offset point = rosProvider.currentMap.idx2xy(Offset(event.goal.x, event.goal.y));
    RobotposeModel goal = RobotposeModel(x: point.dx, y: point.dy, theta: event.goal.theta);
    vm.Quaternion q = vm.Quaternion.euler(0,0,goal.theta);
    Map<String,dynamic> msg ={
      "header" : {
        "stamp" : {
          "secs" : rosProvider.currentTime.secs,
          "nsecs" : rosProvider.currentTime.nsecs
        },
        "frame_id" : "map"
      },
      "pose" :{
        "position" : {"x" : goal.x, "y" : goal.y, "z" : 0},
        "orientation" : {"x" : q.x, "y" : q.y, "z" : q.z, "w" : q.w}
      }
    };

    try{  
      await rosProvider.sendNavigationGoal(msg);
      emit(RosNavToGoalState(goal: event.goal, reached: false));
    }catch(e){
      print(e);
    }
  }

  void _updateProgress(RosUpdateProgressEvent event, Emitter<RosNavState> emit) {
    double dx = event.goal.x - event.pose.x;
    double dy = event.goal.y - event.pose.y;
    double distance = sqrt(dx * dx + dy * dy);
    bool reached = distance < 0.1 && (event.goal.theta - event.pose.theta).abs() < 0.1;
    emit(RosNavToGoalState(goal: event.goal, reached: reached));
  }
}
