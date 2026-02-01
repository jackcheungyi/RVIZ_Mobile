import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ros_control/Service/Bloc/ros/topic_bloc/laser_bloc/laser_bloc.dart';
import 'package:ros_control/Service/Data/Ros_model/robotpose_model.dart';

class DisplayLaser extends StatelessWidget {
  
  final RobotposeModel pose;
  const DisplayLaser( this.pose, {super.key});
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RosLaserBloc, LaserState>(
      builder: (context, state) {
        if(state is LaserFetched){
          context.read<RosLaserBloc>().add(LaserProcessEvent(pose: pose));
          // print("request process data");
        }

        if (state is LaserProcessed) {
          
            //draw laser
            // print("data process done");
            // print(state.laserPointsScene.length);
            return RepaintBoundary(
              child: Container(
                width: state.width,
                height: state.height,
                child: CustomPaint(
                  painter: DrawPointPainter(points: state.laserPointsScene.where((point)=>point.dx.isFinite && point.dy.isFinite ).toList()),
                ),
              )
            );
          }
          
        
        return Container();
      },
    );
  }
}


class DrawPointPainter extends CustomPainter {
  final List<Offset> points;
  final Paint _paint = Paint()
  ..color = Colors.red
  ..strokeCap = StrokeCap.butt
  ..strokeWidth = 1.0;
  DrawPointPainter({required this.points});
  @override
  void paint(Canvas canvas, Size size) {
    // print("draw something : ${points.length}");
    canvas.drawPoints(PointMode.points, points, _paint);
  }

  @override
  bool shouldRepaint(DrawPointPainter oldDelegate) {
    return oldDelegate.points != points;
  }
}