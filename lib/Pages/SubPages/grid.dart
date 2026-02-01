import 'package:flutter/material.dart';

class DrawGrid extends StatelessWidget{
  final double step;
  final double width;
  final double height; 
  const DrawGrid({super.key, required this.step,required this.width, required this.height});
  
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      width: width,
      height: height,
      color:Colors.white.withAlpha(60) ,
      child: CustomPaint(
        isComplex: true,
        willChange: false,
        painter: GridPainter(step: step, color: Colors.black.withAlpha(60)),
      ),
    );
  }
}

class GridPainter extends CustomPainter{

  late double step; 
  Color color;
  GridPainter({required this.step, required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    // TODO: implement paint
    final Paint paint = Paint()
    ..color = color
    ..strokeWidth = 2.0
    ..style = PaintingStyle.fill;

    for ( double x =0; x<=size.width; x+=step){
      for(double y =0; y<= size.height; y+=step){
        canvas.drawCircle(Offset(x, y), 1.0, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant GridPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return step != oldDelegate.step || color != oldDelegate.color;
  }

}