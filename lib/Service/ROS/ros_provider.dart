// import 'dart:math';
import 'dart:async';
import 'dart:math';
// import 'dart:convert';
// import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:ros_control/Service/Data/Ros_model/laserscan_model.dart';
import 'package:ros_control/Service/Data/Ros_model/map_model.dart';
import 'package:ros_control/Service/Data/Ros_model/robotpose_model.dart';
import 'package:ros_control/Service/Data/Ros_model/tf_model.dart';
import 'package:ros_control/Service/Data/Ros_model/twist_model.dart';
import 'package:ros_control/Service/ROS/Exception/ros_exception.dart';
import 'package:ros_control/Utilities/tf2_dart.dart';
import 'package:roslibdart/roslibdart.dart';

class RosProvider  {
  late Ros ros;
  late Topic _mapChannel;
  late Topic _tfChannel;
  late Topic _tfStaticChannel;
  late Topic _laserScanChannel;
  late Topic _clockChannel;
  late Topic _cmdChannel; 
  late Topic _navGoalChannel;
  // String _url = "";
  // late OccupancyMapModel map;
  // ValueNotifier<OccupancyMapModel> map = ValueNotifier<OccupancyMapModel>(OccupancyMapModel(mapConfig: null, data: null));
  final StreamController<OccupancyMapModel> _mapcontroller = StreamController<OccupancyMapModel>.broadcast();
  OccupancyMapModel _currentMap = OccupancyMapModel(mapConfig: null, data: null);
  TF2Dart tf = TF2Dart();
  // ValueNotifier<TF2Dart> tf2 = ValueNotifier(TF2Dart());
  late String IP;
  final StreamController<Laserscanmap_model> _laserScanController = StreamController<Laserscanmap_model>.broadcast();
  final StreamController<TwistModel> _cmdController = StreamController<TwistModel>.broadcast();
  DateTime? _lastMapCallbackTime;
  Status rosConnectState = Status.none; 
  Stamp _currentTime = Stamp(secs: 0, nsecs: 0);
  Stream<OccupancyMapModel> get mapStream => _mapcontroller.stream;
  Stream<Laserscanmap_model> get laserScanStream => _laserScanController.stream;
  Stream<TwistModel> get cmdStream => _cmdController.stream;
  OccupancyMapModel get currentMap => _currentMap;
  Stamp get currentTime => _currentTime;
  Future<bool> rosconnect(String ip,String port) async{
    final completer = Completer<bool>();
    rosConnectState = Status.none;
    if (ip == '' || port == ''){
      throw RosConnectionException();
    }
    final String url = 'ws://$ip:$port';
    print("Connecting to $url");
    try{
        ros = Ros(url: url);

        print("Rosprovider enter try block");
        ros.statusStream.listen(
          (Status data) {
            print("Ros connect state: $data");
            rosConnectState = data;
            if (data == Status.connected){
              if(!completer.isCompleted){
                Timer(const Duration(seconds: 2), () async {
                    await initChannel();
                    // await chatter.subscribe();
                    IP=ip;
                    completer.complete(true); 
                  });
                
              }
              
            }else if (data == Status.errored) {
                if (!completer.isCompleted) {
                  completer.complete(false);
                }
              }
          },
          onError: (error) {
            print('Ros Error occurred: $error'); 
            if (!completer.isCompleted) {
                  completer.complete(false);
                }
          },
          onDone: () {
            print('Ros status Stream closed'); 
          },
          cancelOnError: false, 
        );

        //connect to ros url
        print("Trying to connect to the ros websocket");
        // await Future.microtask(()=>ros.connect());
        ros.connect();
        

        Timer(const Duration(seconds: 5),(){
          if(!completer.isCompleted){
            print("Ros connect timeout");
            completer.complete(false);
          }
        });
        
      return completer.future;
    }
      catch(e){
        print("Ros connection error: $e");
        if (!completer.isCompleted) {
                completer.complete(false);
          }

          throw RosConnectionException();
      }
      // await Future.delayed(Duration(milliseconds: 100));
  }
  
  Future<void> rosDisconnect()async{

    if(rosConnectState == Status.connected){
      await ros.close();
    }
  }

  Future<void> initChannel() async{

    //Sub
    //Clock topic 
    _clockChannel = Topic(
      ros: ros,
      name: "/clock",
      type: "rosgraph_msgs/Clock",
      queueSize: 1,
      reconnectOnClose: true,
    );
    _clockChannel.subscribe(_clockCallback);
    //map topic 
    _mapChannel = Topic(
        ros: ros,
        name: "map",
        type: "nav_msgs/OccupancyGrid",
        reconnectOnClose: true,
        queueLength: 10,
        queueSize: 10);
    _mapChannel.subscribe(_mapCallback);

    //TF topic
    _tfChannel = Topic(
        ros: ros, 
        name: "/tf",
        type: "/tf2_msgs/TFMessage", 
        queueSize: 1, 
        reconnectOnClose: true);
    _tfChannel.subscribe(_tfCallback);
    
    //TF static topic
    _tfStaticChannel = Topic(
      ros: ros,
      name: "/tf_static",
      type: "tf2_msgs/TFMessage",
      queueSize: 1,
      reconnectOnClose: true,
    );
    _tfStaticChannel.subscribe(_tfStaticCallback);

    //laser scan topic
    _laserScanChannel = Topic(
      ros: ros,
      name: "/scan",
      type: "sensor_msgs/LaserScan",
      queueSize: 1,
      reconnectOnClose: true,
    );
    _laserScanChannel.subscribe(_laserScanCallback);

    //Pub
    _cmdChannel = Topic(ros: ros, 
      name: '/cmd_vel', 
      type: "geometry_msgs/Twist",
      queueSize: 1,
      reconnectOnClose: true,
      );
    _cmdChannel.subscribe(_cmdCallback);

    _navGoalChannel = Topic(
      ros: ros,
      name: '/goal_pose',
      type: "geometry_msgs/PoseStamped",
      queueSize: 1,
      reconnectOnClose: true,
    );
  }
  Future<void> _laserScanCallback(Map<String, dynamic> msg) async {
    // print("new laser data ");
    LaserscanModel laser = LaserscanModel.fromMap(msg);
    RobotposeModel laserbasepose = RobotposeModel(x: 0, y: 0, theta: 0);
    try{
      laserbasepose = tf.lookUpForTransform('base_link', laser.header!.frameId);
    }catch(e){
      print("tf error: $e");
      return;
      }
    double angle_min = laser.angleMin!;
    // double angle_max = laser.angleMax!;
    double angle_increment = laser.angleIncrement!;
    List<double> ranges = laser.ranges!;
    List<Offset> laserpoints = [];
    for (int i = 0; i < ranges.length; i++) {
      double angle = angle_min + i * angle_increment;
      if(ranges[i].isInfinite || ranges[i].isNaN){
        continue; 
      } 
      double dist = ranges[i];
      // print(dist);
      if(dist == -1){
        continue;
      }
      RobotposeModel laserpointpose = RobotposeModel(x: dist * cos(angle),y : dist * sin(angle),theta : 0 );
      RobotposeModel poseBaseLink = absoluteSum(laserbasepose, laserpointpose);
      laserpoints.add(Offset(poseBaseLink.x, poseBaseLink.y));
    }
    Laserscanmap_model laserscanmap = Laserscanmap_model(timestamp: laser.header!.stamp!, points: laserpoints);
    _laserScanController.add(laserscanmap);
  }
  Future<void> _clockCallback(Map<String, dynamic> msg) async {
    // print(msg);
    _currentTime = Stamp.fromMap(msg['clock']as Map<String, dynamic>);
    // print(_currentTime);
    
  }
  
  Future<void>_mapCallback(Map<String, dynamic> msg)async{
    
    DateTime currentTimeStamp = DateTime.now();
    if(_lastMapCallbackTime != null){
      Duration duration = currentTimeStamp.difference(_lastMapCallbackTime!);
      if (duration.inSeconds<5){
        return;
      }
    }

    _lastMapCallbackTime = currentTimeStamp;
    print("new map: ");
    // map.value = OccupancyMapModel.fromMap(msg);
    try{
      _currentMap = OccupancyMapModel.fromMap(msg);
    }catch(e){
      print("map parse error: $e");
      return;
    }
    
    // print("new map ok");
    _mapcontroller.add(_currentMap);
  }

  Future<void>_cmdCallback(Map<String, dynamic> msg)async{
    // print("new cmd: $msg");
    _cmdController.add(TwistModel.fromMap(msg));
  }


  Future<void>_tfCallback(Map<String, dynamic> msg)async{
    // print("new tf: ");
    
    tf.updateTF(TF.fromMap(msg));
    // notifyListeners();
  }

  Future<void>_tfStaticCallback(Map<String, dynamic> msg)async{
    // print("new tf static: ");
    
    tf.updateTF(TF.fromMap(msg));
    // notifyListeners();
  }

  Future<void> sendNavigationGoal(Map<String,dynamic> msg)async{
      await _navGoalChannel.publish(msg);
  }

  Future<void> sendVelocityCommand(Map<String,dynamic> msg)async{
    await _cmdChannel.publish(msg); 
  }
}