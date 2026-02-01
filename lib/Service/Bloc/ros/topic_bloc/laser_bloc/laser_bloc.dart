import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:ros_control/Service/Data/Ros_model/laserscan_model.dart';
import 'package:ros_control/Service/Data/Ros_model/robotpose_model.dart';
import 'package:ros_control/Service/Data/Ros_model/tf_model.dart';
import 'package:ros_control/Service/ROS/ros_provider.dart';

part 'laser_event.dart';
part 'laser_state.dart';

class RosLaserBloc extends Bloc<LaserEvent, LaserState> {
  final RosProvider rosProvider;
  Laserscanmap_model _laser = Laserscanmap_model(timestamp: Stamp(secs: 0, nsecs: 0), points: []);
  RosLaserBloc(this.rosProvider) : super(LaserInitial()) {
    on<LaserInitEvent>(_LaserInit);
    on<LaserFetchEvent>(_LaserFetch);
    on<LaserProcessEvent>(_ProcessPoints);
  }

  void _LaserInit(LaserInitEvent event, Emitter<LaserState> emit) {
    rosProvider.laserScanStream.listen((laser) {
    // print("new laser data catched");
    add(LaserFetchEvent( laser: laser));
    _laser = laser;
  });
  }

  void _LaserFetch(LaserFetchEvent event, Emitter<LaserState> emit) {
    emit(LaserFetched(laser: event.laser));
    // laser = event.laser;
    // print("new laser data emit");
  }
  
  void _ProcessPoints(LaserProcessEvent event, Emitter<LaserState> emit){
    RobotposeModel robotPosemap = event.pose;
    List<Offset> laserPointsScene = [];
    double width = 0;
    double height = 0;
    for (var point in _laser.points){
      RobotposeModel pointMap = absoluteSum(robotPosemap, RobotposeModel(x: point.dx, y: point.dy, theta: 0));
      Offset pointScene = rosProvider.currentMap.xy2idx(Offset(pointMap.x, pointMap.y));
      if(pointScene.dx.isFinite && pointScene.dx > width) {
        width = pointScene.dx;
        }
      if(pointScene.dy.isFinite && pointScene.dy > height) {
        height = pointScene.dy;
      }
      laserPointsScene.add(pointScene);
    }
    width = width.clamp(1.0, double.infinity);
    height = height.clamp(1.0, double.infinity);
    emit(LaserProcessed(laserPointsScene,width,height));
  }
}

