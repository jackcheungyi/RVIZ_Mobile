
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ros_control/Service/Bloc/ros/topic_bloc/map_bloc/ros_map_bloc.dart';
import 'package:ros_control/Service/Data/Ros_model/map_model.dart';


class DrawMap extends StatelessWidget{
  const DrawMap();
  
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return RepaintBoundary(
      child: BlocBuilder<RosMapBloc, RosMapState>(
        builder: (context, state) {
          if (state is RosMapFetechedState){
            return Container(
            width: state.map.mapConfig!.width.toDouble()+1,
            height: state.map.mapConfig!.height.toDouble()+1,
            child: CustomPaint(
              painter: DisplayMapPainter(
                occPointList: state.occPointList,
                freePointList: state.freePointList,
                freeColor: Colors.white,
                occBaseColor: Colors.black,
              ),
            ),
          );
          }
          return CircularProgressIndicator();
        },
      ),
    );
  }
  
  
}

class DisplayMapPainter extends CustomPainter {
  final List<mapPoint> occPointList;
  final List<Offset> freePointList;
  final Color freeColor;
  final Color occBaseColor;

  DisplayMapPainter(
      {required this.occPointList,
      required this.freePointList,
      required this.freeColor,
      required this.occBaseColor});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..strokeCap = StrokeCap.butt
      ..style = PaintingStyle.fill
      ..strokeWidth = 1;

    final recorder = PictureRecorder();
    final recordingCanvas = Canvas(recorder);

    recordingCanvas.save();

    
    for (var mapPoint in occPointList) {
      paint.color = occBaseColor.withAlpha(mapPoint.value);
      recordingCanvas.drawPoints(PointMode.points, [mapPoint.point], paint);
    }

    
    if (freePointList.isNotEmpty) {
      paint.color = freeColor;
      final freePoints = Float32List.fromList(
          freePointList.expand((point) => [point.dx, point.dy]).toList());
      recordingCanvas.drawRawPoints(PointMode.points, freePoints, paint);
    }

   
    recordingCanvas.restore();

    
    final picture = recorder.endRecording();
    canvas.drawPicture(picture);
  }

  @override
  bool shouldRepaint(covariant DisplayMapPainter oldDelegate) {
    return oldDelegate.occPointList != occPointList ||
        oldDelegate.freePointList != freePointList ||
        oldDelegate.freeColor != freeColor ||
        oldDelegate.occBaseColor != occBaseColor;
  }
}