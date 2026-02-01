

import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:ros_control/Service/Data/Ros_model/robotpose_model.dart';

class DrawRobot extends StatefulWidget {
  final double size;
  final Color color ;
  final int count ;
  final double direction ; 
  DrawRobot(
      {required this.size,
      required this.color,
      required this.count,
      this.direction = 0});
  @override
  State<StatefulWidget> createState() => _DrawRobotState();
}


class _DrawRobotState extends State<DrawRobot> with SingleTickerProviderStateMixin{
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller, 
        builder: 
        (context, child) {
          return CustomPaint(
            painter: RobotPainter(progress: _controller.value,
             count: widget.count, 
             color: widget.color,
             direction: widget.direction),
          );
      }
      )
    );
  }
}

class RobotPainter extends CustomPainter {
  final double progress;
  final int count;
  final Color color;
  final double direction ;
  Paint _paint = Paint()..style = PaintingStyle.fill;

  RobotPainter(
    {required this.progress, 
    required this.count, 
    required this.color, 
    this.direction = 0});
  
  @override
  void paint(Canvas canvas, Size size) {
    // TODO: implement paint
    // print("size width : ${size.width}");
    // print("size height : ${size.height}");
    
    canvas.save();
    //draw wave pulse
    final double radius = min(size.width / 2, size.height / 2);
    for (int i = count; i>=0; i--){
      final double opacity = (1.0 - ((i + progress) / (count + 1)));
      _paint.color = color.withValues(alpha: opacity);
      double _radius = radius * ((i + progress) / (count + 1));
      canvas.drawCircle(
          Offset(size.width / 2, size.height / 2), _radius, _paint);
    }

    // radius = min(size.width / 2, size.height / 2);
    //draw robot
    double center_r = radius * 0.5;
    Paint _robot_paint =Paint()..style = PaintingStyle.stroke
      ..color = const Color.fromARGB(255, 15, 228, 228)
      ..strokeWidth = 1.4;

    _paint.color = Colors.red;
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), center_r, _robot_paint);
    final path_ = Path();
    _paint.color = Color.fromARGB(255, 2, 117, 2);
    final p1_= Offset(size.width/2+cos(direction)*center_r, size.height/2+sin(direction)*center_r);
    final p2_= Offset(size.width/2+cos(direction+deg2rad(120))*center_r, size.height/2+sin(direction+deg2rad(120))*center_r);
    final p3_= Offset(size.width/2+cos(direction+deg2rad(240))*center_r, size.height/2+sin(direction+deg2rad(240))*center_r);
    // print("p1_ : $p1_ , p2_ : $p2_, p3_ : $p3_");
    path_.moveTo(size.width/2, size.height/2);
    path_.lineTo(p2_.dx, p2_.dy);
    path_.lineTo(p1_.dx, p1_.dy);
    path_.lineTo(p3_.dx, p3_.dy);
    // path_.lineTo(size.width/2, size.height/2);
    path_.close(); 

    canvas.drawPath(path_, _paint);

    canvas.restore();
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return true;
  }
}