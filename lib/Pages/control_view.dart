import 'dart:math';
import 'package:flutter_joystick/flutter_joystick.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_mjpeg/flutter_mjpeg.dart';
import 'package:ros_control/Pages/SubPages/grid.dart';
import 'package:ros_control/Pages/SubPages/joystick.dart';
import 'package:ros_control/Pages/SubPages/laser.dart';
import 'package:ros_control/Pages/SubPages/map.dart';
import 'package:ros_control/Pages/SubPages/robot.dart';
import 'package:ros_control/Pages/SubPages/waypoint.dart';
import 'package:ros_control/Service/Bloc/app/controlview_bloc/controlview_bloc.dart';
import 'package:ros_control/Service/Bloc/ros/topic_bloc/cmd_bloc/ros_cmd_bloc.dart';
import 'package:ros_control/Service/Bloc/ros/topic_bloc/laser_bloc/laser_bloc.dart';
import 'package:ros_control/Service/Bloc/ros/topic_bloc/map_bloc/ros_map_bloc.dart';
import 'package:ros_control/Service/Bloc/ros/topic_bloc/nav_bloc/ros_nav_bloc.dart';
import 'package:ros_control/Service/Bloc/ros/topic_bloc/pose_bloc/robot_pose_bloc.dart';
import 'package:ros_control/Service/Data/Ros_model/robotpose_model.dart';
import 'package:ros_control/Service/ROS/ros_provider.dart';
import 'package:ros_control/Utilities/matrix_gesture_detector.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ControlView extends StatefulWidget {
  const ControlView({super.key});
  @override
  State<StatefulWidget> createState() => _ControlViewState();
}

class _ControlViewState extends State<ControlView> {
  final ValueNotifier<Matrix4> gestureTransform = ValueNotifier(
    Matrix4.identity(),
  );
  final ValueNotifier<RobotposeModel> _robotScenePose = ValueNotifier(
    RobotposeModel(x: 0, y: 0, theta: 0),
  );
  final ValueNotifier<RobotposeModel> _robotPose = ValueNotifier(
    RobotposeModel(x: 0, y: 0, theta: 0),
  );
  double _gestureScaleValue = 1.0;
  double _currentGestureScale = 1.0;
  final double _minScale = 0.8;
  double robotSize = 20;
  int poseDirectionSwellSize = 0;
  var originPose = Offset.zero;
  Matrix4 globalTransform = Matrix4.identity();
  double scaleValue = 1.0;
  final ValueNotifier<List<RobotposeModel>> _navPoints =
      ValueNotifier<List<RobotposeModel>>([]);
  bool _int_done = false;
  bool _showcamera = false;
  final ValueNotifier<Offset> _cameraPosition = ValueNotifier(Offset(50,50)) ;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    
    context.read<RosMapBloc>().add(RosMapInitialEvent());
    context.read<RobotPoseBloc>().add(RobotPoseInitEvent());
    context.read<ControlviewBloc>().add(ControlviewInitEvent());
    context.read<RosLaserBloc>().add(LaserInitEvent());
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    final screenSize_ = MediaQuery.of(context).size;
    final screenCenter_ = Offset(screenSize_.width / 2, screenSize_.height / 2);
    Offset tap_point = Offset.zero;
    if (_int_done != true){
      _int_done=true;
      gestureTransform.value = Matrix4.identity()
        ..translate(2*screenCenter_.dx/3, 2*screenCenter_.dy/3);
    }
    // globalTransform = Matrix4.identity()
    //     ..translate(2*screenCenter_.dx/3, 2*screenCenter_.dy/3);
    Matrix4 _initialTransform = Matrix4.identity()
        ..translate(2*screenCenter_.dx/3, 2*screenCenter_.dy/3);
    // print("first build : $globalTransform");

    double camWidgetWidth = screenSize_.width / 3.5;
    double camWidgetHeight = camWidgetWidth / (640/ 480);
    camWidgetWidth = screenSize_.width / 3.5;
    camWidgetHeight = camWidgetWidth / (640/ 480);
    return Scaffold(
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: gestureTransform,
            builder: (ctx, child) {
              return Container(
                width: screenSize_.width,
                height: screenSize_.height,
                child: BlocBuilder<ControlviewBloc, ControlviewState>(
                  builder: (context, appstate) {
                    // print("appstate is $appstate");
                    return MatrixGestureDetector(
                      onMatrixUpdate: (
                        matrix,
                        transDelta,
                        scaleValue,
                        rotateDelta,
                      ) {
                        // print("onMatrixUpdate");
                        if (appstate is ControlViewUpdated) {
                          if (appstate.mode == Mode.robotFixedCenter) {
                            Fluttertoast.showToast(msg: "robotFixedCenter");
                          }
                        }
                        final translation = matrix.getTranslation();
                        final rotation = matrix.getRotation();
                        final angle = atan2(rotation[1], rotation[0]);
                        _currentGestureScale = scaleValue;
                        _currentGestureScale = max(
                          _currentGestureScale,
                          _minScale,
                        );
                        gestureTransform.value =
                            Matrix4.identity()
                              ..multiply(_initialTransform)
                              ..translate(translation.x, translation.y)
                              ..rotateZ(angle)
                              ..scale(_currentGestureScale);
                        // print(gestureTransform.value);
                        // print("matrix is $matrix");
                        // double currentScale = matrix.getMaxScaleOnAxis();
                        // print("current sacle : $currentScale");
                        // // double minScale = 1.1;

                        // if (currentScale < 1.0) {
                        //   print("limit scale called");
                        //   // final correctionScale = minScale / currentScale;
                        //   // matrix.scale(correctionScale);
                        // }
                        // gestureTransform.value = matrix;

                        _gestureScaleValue =
                            gestureTransform.value.getMaxScaleOnAxis();
                        // print(gestureScaleValue_);
                      },
                      child: BlocBuilder<RobotPoseBloc, RobotPoseState>(
                        builder: (context, posestate) {
                          originPose = Offset.zero;
                          globalTransform = gestureTransform.value;
                          // print(globalTransform);
                          scaleValue = _gestureScaleValue;

                          // print("scaleValue: $scaleValue");
                          if (appstate is ControlViewUpdated &&
                              posestate is RobotPoseFetched) {
                            // print(
                              // "current mode: ${appstate.mode} and robotPoseScene: ${posestate.robotPoseScene} and robotPose: ${posestate.currRobotPose}",
                            // );
                            _robotScenePose.value = posestate.robotPoseScene;
                            _robotPose.value = posestate.currRobotPose;
                            if (appstate.mode == Mode.robotFixedCenter) {
                              // scaleValue = cameraFixedScaleValue_;
                              globalTransform =
                                  Matrix4.identity()
                                    ..translate(
                                      screenCenter_.dx -
                                          posestate.robotPoseScene.x,
                                      screenCenter_.dy -
                                          posestate.robotPoseScene.y,
                                    )
                                    ..rotateZ(
                                      posestate.robotPoseScene.theta -
                                          deg2rad(90),
                                    )
                                    ..scale(scaleValue);
                            }
                          }

                          return Stack(
                            children: [
                              //Grid
                              BlocBuilder<RosMapBloc, RosMapState>(
                                builder: (context, mapstate) {
                                  if (mapstate is RosMapFetechedState) {
                                    // print("mapstate is RosMapFetechedState");
                                    return Container(
                                      child: DrawGrid(
                                        step:
                                            (1 /
                                                mapstate
                                                    .map
                                                    .mapConfig!
                                                    .resolution) *
                                            scaleValue,
                                        width: screenSize_.width,
                                        height: screenSize_.height,
                                      ),
                                    );
                                  }
                                  return CircularProgressIndicator();
                                },
                              ),

                              //Map
                              Transform(
                                transform: globalTransform,
                                origin: originPose,
                                child: IgnorePointer(
                                  ignoring:
                                      appstate.mode == Mode.addNavPoint
                                          ? false
                                          : true,
                                  child: GestureDetector(
                                    child: DrawMap(),
                                    onPanStart: (details) {
                                      tap_point = details.localPosition;
                                    },
                                    onPanEnd: (details) {
                                      double angle =
                                          -atan2(
                                            details.localPosition.dy -
                                                tap_point.dy,
                                            details.localPosition.dx -
                                                tap_point.dx,
                                          );
                                      RobotposeModel tap_pose = RobotposeModel(
                                        x: tap_point.dx,
                                        y: tap_point.dy,
                                        theta: angle,
                                      );

                                      final newList = [
                                        ..._navPoints.value,
                                        tap_pose,
                                      ];
                                      _navPoints.value = newList;
                                      print("add new point");
                                      setState(() {});
                                    },
                                  ),
                                ),
                              ),

                              //Nav Point
                              // ..._navPoints.value.map((pose){
                              //   Matrix4 _robot_transform = Matrix4.identity()
                              //     ..translate(
                              //         pose.x -
                              //             robotSize / 2 -
                              //             poseDirectionSwellSize / 2,
                              //         pose.y -
                              //             robotSize / 2 -
                              //             poseDirectionSwellSize / 2,
                              //       )
                              //     ..rotateZ(
                              //         (-pose.theta),
                              //       );
                              //   return Transform(
                              //     transform: globalTransform,
                              //     origin: originPose,
                              //     child: Transform(
                              //       transform: _robot_transform,
                              //       child: Container(
                              //         height: robotSize + poseDirectionSwellSize,
                              //         width: robotSize + poseDirectionSwellSize,
                              //         child: DisplayWaypoint(size: robotSize, color: Colors.yellow, cout: 3),
                              //       )
                              //     ),
                              //     );
                              //   }).toList(),
                              ..._navPoints.value.map((pose) {
                                // print("pose is $pose");
                                Matrix4 _robot_transform =
                                    Matrix4.identity()
                                      ..translate(
                                        pose.x -
                                            robotSize / 2 -
                                            poseDirectionSwellSize / 2,
                                        pose.y -
                                            robotSize / 2 -
                                            poseDirectionSwellSize / 2,
                                      )
                                      ..rotateZ(-pose.theta);
                                return Transform(
                                  transform: globalTransform,
                                  origin: originPose,
                                  child: Transform(
                                    alignment: Alignment.center,
                                    transform: _robot_transform,
                                    child: GestureDetector(
                                      behavior: HitTestBehavior.translucent,
                                      onTap: () {
                                        if (appstate.mode == Mode.normal) {
                                          print("Navigating to point $pose");
                                          context.read<RosNavBloc>().add(
                                            RosNavSendGoadlEvent(goal: pose),
                                          );
                                        }
                                      },
                                      onDoubleTap: () {
                                        print("double tap delet pose");
                                        final newList = [..._navPoints.value];
                                        newList.remove(pose);
                                        _navPoints.value = newList;
                                        setState(() {});
                                      },
                                      child: BlocBuilder<
                                        RosNavBloc,
                                        RosNavState
                                      >(
                                        builder: (context, navstate) {
                                         
                                          // if (navstate is RosNavToGoalState) {
                                          //   print("navstate.goal is ${navstate.goal}");
                                          //   print("pose : ${pose}");
                                          //   if (navstate.goal == pose) {
                                          //     print("reached : ${navstate.reached}");
                                          //     return Container(
                                          //       height:
                                          //           robotSize +
                                          //           poseDirectionSwellSize,
                                          //       width:
                                          //           robotSize +
                                          //           poseDirectionSwellSize,
                                          //       child: DisplayWaypoint(
                                          //         size: robotSize,
                                          //         color: navstate.reached? Colors.green:Colors.yellow,
                                          //         cout: 3,
                                          //       )
                                          //     );
                                          //   }
                                          // }
                                          
                                          return Container(
                                            height:
                                                robotSize +
                                                poseDirectionSwellSize,
                                            width:
                                                robotSize +
                                                poseDirectionSwellSize,
                                            child: DisplayWaypoint(
                                              size: robotSize,
                                              color: Colors.green,
                                              cout: 3,
                                            ),
                                          );
                          
                                          
                                        },
                                      ),
                                    ),
                                  ),
                                );
                              }),

                              //Robot
                              Transform(
                                transform: globalTransform,

                                child:
                                    BlocBuilder<RobotPoseBloc, RobotPoseState>(
                                      builder: (context, state) {
                                        Matrix4 _robot_transform =
                                            Matrix4.identity()
                                              ..translate(
                                                _robotScenePose.value.x -
                                                    robotSize / 2 -
                                                    poseDirectionSwellSize / 2,
                                                _robotScenePose.value.y -
                                                    robotSize / 2 -
                                                    poseDirectionSwellSize / 2,
                                              )
                                              ..rotateZ(
                                                (-_robotScenePose.value.theta),
                                              );
                                        // print(-_robotPose.value.theta);
                                        return Transform(
                                          alignment: Alignment.center,
                                          transform: _robot_transform,
                                          child: IgnorePointer(
                                            ignoring:
                                                appstate.mode ==
                                                        Mode.addNavPoint
                                                    ? true
                                                    : false,
                                            child: Container(
                                              height:
                                                  robotSize +
                                                  poseDirectionSwellSize,
                                              width:
                                                  robotSize +
                                                  poseDirectionSwellSize,
                                              child: Stack(
                                                children: [
                                                  DrawRobot(
                                                    size: robotSize,
                                                    color: Colors.blue,
                                                    count: 2,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                              ),

                              //laser
                              Transform(
                                transform: globalTransform,
                                origin: originPose,
                                child: IgnorePointer(
                                  ignoring: true,
                                  child: DisplayLaser(_robotPose.value),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    );
                  },
                ),
              );
            },
          ),

          //AnimatedIcon(icon: icon, progress: progress)
          Positioned(
            right: 60,
            top: 30,
            child: FittedBox(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  //Add Nav Point Button
                  Card(
                    shadowColor: Colors.blueGrey,
                    elevation: 10,
                    child: GestureDetector(
                      onLongPress: () {},
                      child: BlocBuilder<ControlviewBloc, ControlviewState>(
                        builder: (context, state) {
                          if (state is ControlViewUpdated) {
                            return IconButton(
                              onPressed: () {
                                if (state.mode == Mode.normal) {
                                  context.read<ControlviewBloc>().add(
                                    ControlViewModeChangedEvent(
                                      mode: Mode.addNavPoint,
                                      isManualCtrl: state.isManualCtrl,
                                    ),
                                  );
                                } else if (state.mode == Mode.addNavPoint) {
                                  context.read<ControlviewBloc>().add(
                                    ControlViewModeChangedEvent(
                                      mode: Mode.normal,
                                      isManualCtrl: state.isManualCtrl,
                                    ),
                                  );
                                }
                              },
                              icon: Icon(
                                IconData(0xe801, fontFamily: 'Icons'),
                                color:
                                    state.mode == Mode.addNavPoint
                                        ? const Color.fromARGB(
                                          255,
                                          226,
                                          171,
                                          20,
                                        )
                                        : state.mode == Mode.normal
                                        ? Colors.blue
                                        : Colors.grey,
                              ),
                            );
                          }
                          return Container();
                        },
                      ),
                    ),
                  ),

                  //Reloc Button
                  BlocBuilder<ControlviewBloc, ControlviewState>(
                    builder: (context, state) {
                      if (state is ControlViewUpdated) {
                        return SizedBox(
                          width: 180, // Enough for both buttons
                          height: 60, // Fixed height
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              // Close Button (animated)
                              Positioned(
                                left: 0,
                                child: AnimatedOpacity(
                                  duration: const Duration(milliseconds: 300),
                                  opacity:
                                      state.mode == Mode.reloc
                                          ? 1
                                          : 0, // Fades in/out

                                  child: Card(
                                    shadowColor: Colors.blueGrey,
                                    elevation: 10,
                                    child: IconButton(
                                      onPressed: () {
                                        context.read<ControlviewBloc>().add(
                                          ControlViewModeChangedEvent(
                                            mode: Mode.normal,
                                            isManualCtrl: state.isManualCtrl,
                                          ),
                                        );
                                      },
                                      icon: const Icon(
                                        Icons.done,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              Positioned(
                                left: 60,
                                child: AnimatedOpacity(
                                  duration: const Duration(milliseconds: 300),
                                  opacity:
                                      state.mode == Mode.reloc
                                          ? 1
                                          : 0, // Fades in/out
                                  child: Card(
                                    shadowColor: Colors.blueGrey,
                                    elevation: 10,
                                    child: IconButton(
                                      onPressed: () {
                                        context.read<ControlviewBloc>().add(
                                          ControlViewModeChangedEvent(
                                            mode: Mode.normal,
                                            isManualCtrl: state.isManualCtrl,
                                          ),
                                        );
                                      },
                                      icon: const Icon(
                                        Icons.close,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              // Reloc Button (always visible)
                              Positioned(
                                right: 0,
                                child: Card(
                                  shadowColor: Colors.blueGrey,
                                  elevation: 10,
                                  child: IconButton(
                                    onPressed: () {
                                      if (state.mode != Mode.reloc) {
                                        context.read<ControlviewBloc>().add(
                                          ControlViewModeChangedEvent(
                                            mode: Mode.reloc,
                                            isManualCtrl: state.isManualCtrl,
                                          ),
                                        );
                                      }
                                    },
                                    icon: Icon(
                                      IconData(0xe800, fontFamily: 'Icons'),
                                      color:
                                          state.mode == Mode.reloc
                                              ? const Color.fromARGB(
                                                255,
                                                226,
                                                171,
                                                20,
                                              )
                                              : Colors.blue,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      return Container();
                    },
                  ),
                  
                  Card(
                    shadowColor: Colors.blueGrey,
                    elevation: 10,
                    child: BlocBuilder<ControlviewBloc, ControlviewState>(
                      builder: (context, state) {
                        return IconButton(
                              icon: Icon(IconData(0xe802, fontFamily: 'Icons'),
                              color: state.isManualCtrl?const Color.fromARGB(255, 6, 21, 231):Colors.blue,),
                              onPressed: () {
                                context.read<ControlviewBloc>().add(
                                  ControlViewModeChangedEvent(
                                    mode:state.mode ,
                                    isManualCtrl: state.isManualCtrl? false:true,
                                  ),
                                );
                              },
                            );
                      },
                    )
                  ),

                  Card(
                    shadowColor: Colors.blueGrey,
                    elevation: 10,
                    child: IconButton(
                      icon: Icon(IconData(0xe803, fontFamily: 'Icons'),
                      color: Colors.blue,),
                      onPressed: () {
                        _showcamera = _showcamera?false:true;
                        setState(() {
                          
                        });
                      }
                    )
                  ),
                ],
              ),
            ),
          ),

          BlocBuilder<ControlviewBloc, ControlviewState>(
            builder: (context, state) {
              return Positioned(
                    left: screenSize_.width-300,
                    top: screenSize_.height-300,  
                    child: Visibility(
                      visible: state.isManualCtrl,
                      child: Container(
                        width: 300,
                        height: 300,
                        child: Center(
                          child: Joystick(
                            stick:MyJoystickStick(),
                            listener: (detail){
                              // print("Y value : ${detail.y}");
                              // print("X value : ${detail.x}");
                              context.read<RosCmdBloc>().add(RosCmdSendEvent(linear: detail.y, angular: detail.x));
                            }),
                        ),
                      ),
                    ));
            },
          ),
          
          Positioned(
            left: 60,
            top: 30,
            child: Container()),

          Visibility(
            visible: _showcamera,
            child:ValueListenableBuilder(
            valueListenable: _cameraPosition, 
            builder: (context,cameraPosition,_){
              return Positioned(
                left: cameraPosition.dx,
                top: cameraPosition.dy,
                child: GestureDetector(
                  onPanUpdate: (details) {
                    double newX = cameraPosition.dx + details.delta.dx;
                    double newY = cameraPosition.dy + details.delta.dy;
                    newX = newX.clamp(0.0, screenSize_.width - camWidgetWidth);
                    newY = newY.clamp(0.0, screenSize_.height - camWidgetHeight);
                    _cameraPosition.value = Offset(newX, newY);
                  },
                  child: Container(
                    width: camWidgetWidth,
                    height: camWidgetHeight,
                    child: Mjpeg(
                      stream: "http://${context.read<RosProvider>().IP}:8080/stream?topic=/camera/image_raw",
                      isLive: true,
                      width: camWidgetWidth,
                      height: camWidgetHeight,
                      fit:BoxFit.fill, 
                    ),
                  ),
                ));
            }) ,
          ),
        ],
      ),
    );
  }
}
