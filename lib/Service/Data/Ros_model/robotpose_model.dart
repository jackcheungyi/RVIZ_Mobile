// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'dart:math';
import 'package:ros_control/Service/Data/Ros_model/tf_model.dart';
import 'package:vector_math/vector_math.dart';


class RobotposeModel {
  Stamp? timestamp;
  double x;
  double y;
  double theta;
  RobotposeModel({
    required this.x,
    required this.y,
    required this.theta,
    this.timestamp,
  });
  

  RobotposeModel copyWith({
    double? x,
    double? y,
    double? theta,
  }) {
    return RobotposeModel(
      x: x ?? this.x,
      y: y ?? this.y,
      theta: theta ?? this.theta,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'x': x,
      'y': y,
      'theta': theta,
    };
  }

  factory RobotposeModel.fromMap(Map<String, dynamic> map) {
    return RobotposeModel(
      x: map['x'] as double,
      y: map['y'] as double,
      theta: map['theta'] as double,
    );
  }

  String toJson() => json.encode(toMap());

  factory RobotposeModel.fromJson(String source) => RobotposeModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'RobotposeModel(x: $x, y: $y, theta: $theta)';

  @override
  bool operator ==(covariant RobotposeModel other) {
    if (identical(this, other)) return true;
  
    return 
      other.x == x &&
      other.y == y &&
      // other.theta == theta;
      compareDoubles(other.theta, theta);
  }

  bool compareDoubles(double a, double b, {int precision = 4}) {
    final factor = pow(10, precision);
    return (a * factor).round() == (b * factor).round();
  }


  RobotposeModel operator +(RobotposeModel other) =>
      RobotposeModel(x: x + other.x,y: y + other.y,theta: theta + other.theta);
  RobotposeModel operator -(RobotposeModel other) =>
      RobotposeModel(x: x - other.x, y: y - other.y,theta:  theta - other.theta);

  @override
  int get hashCode => x.hashCode ^ y.hashCode ^ theta.hashCode;

  RobotposeModel.zero():x=0,y=0,theta =0;
  

}

double deg2rad(double deg) => deg * pi / 180;

double rad2deg(double rad) => rad * 180 / pi;

RobotposeModel absoluteSum(RobotposeModel p1, RobotposeModel p2){
  double s = sin(p1.theta);
  double c = cos(p1.theta);
  return RobotposeModel(x: c * p2.x - s * p2.y, y: s * p2.x + c * p2.y, theta: p2.theta) + p1;
}

RobotposeModel absoluteDifference(RobotposeModel p1, RobotposeModel p2){
  RobotposeModel delta = p1 -p2;
  delta.theta = atan2(sin(delta.theta), cos(delta.theta));
  double s = sin(p2.theta), c = cos(p2.theta);
  return RobotposeModel(x: c*delta.x + s*delta.y, y:  -s * delta.x + c * delta.y, theta: delta.theta);
}

RobotposeModel getRobotPoseFromMatrix(Matrix4 matrix){
  double x = matrix.storage[12];
  double y = matrix.storage[13];
  double theta = atan2(matrix.storage[1], matrix.storage[0]);

  return RobotposeModel(x: x, y: y, theta: theta);
}