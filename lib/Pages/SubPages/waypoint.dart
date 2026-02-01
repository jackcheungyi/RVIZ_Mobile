


import 'dart:math';

import 'package:flutter/material.dart';
import 'package:ros_control/Service/Data/Ros_model/robotpose_model.dart';


class DisplayWaypoint extends StatefulWidget {

  late double size;
  late Color color = Colors.blue;
  final int cout ;
  DisplayWaypoint({required this.size,required this.color,required this.cout});

  @override
  State<StatefulWidget> createState() => _DisplayWaypointState();

}

class _DisplayWaypointState extends State<DisplayWaypoint> with SingleTickerProviderStateMixin {
  
  late AnimationController _controller;
  
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(animation: _controller, builder: (context, child){
        return CustomPaint(
          painter: WaypointPainter(progress: _controller.value, count: widget.cout, color: widget.color),
        );
      }),
    );

  }

}

class WaypointPainter extends CustomPainter{
  final double progress;
  final int count;
  final Color color;
  WaypointPainter({required this.progress,required this.count,required this.color});

  Paint _paint = Paint()
                ..style = PaintingStyle.fill;
                
  @override
  void paint(Canvas canvas, Size size) {
    
    double radius = min(size.width / 2, size.height / 2);
    canvas.save();

    for (int i = count; i>=0;i--){
      double opacity = (1.0 -((i+progress)/(count+1)));
      _paint.color = color.withValues(alpha: opacity);
      double _radius = radius * ((i+progress)/(count+1));
      final path = Path()
        ..moveTo(size.width / 2 + _radius, size.height / 2) // 右顶点
        ..lineTo(size.width / 2, size.height / 2 + _radius) // 下顶点
        ..lineTo(size.width / 2 - _radius, size.height / 2) // 左顶点
        ..lineTo(size.width / 2, size.height / 2 - _radius) // 上顶点
        ..close(); // 闭合路径
      canvas.drawPath(path, _paint);
    }

    final path = Path()
      ..moveTo(size.width / 2 + radius / 3, size.height / 2) // 右顶点
      ..lineTo(size.width / 2, size.height / 2 + radius / 3) // 下顶点
      ..lineTo(size.width / 2 - radius / 3, size.height / 2) // 左顶点
      ..lineTo(size.width / 2, size.height / 2 - radius / 3) // 上顶点
      ..close(); // 闭合路径

    // 绘制路径
    canvas.drawPath(path, _paint);

    Paint dirPainter = Paint()..style = PaintingStyle.fill;
    dirPainter.color = color.withValues(alpha: 0.3);
    Rect rect = Rect.fromCircle(center: Offset(size.width / 2, size.height / 2), radius: radius);
    canvas.drawArc(rect, -deg2rad(15), deg2rad(30), true, dirPainter);
    canvas.restore();

  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return true;
  }
}