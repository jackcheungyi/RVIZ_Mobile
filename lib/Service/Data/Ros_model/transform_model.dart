// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'dart:math';

import 'package:ros_control/Service/Data/Ros_model/robotpose_model.dart';

class Position {
  double? x;
  double? y;
  double? z;
  Position({
    this.x,
    this.y,
    this.z,
  });

  Position copyWith({
    double? x,
    double? y,
    double? z,
  }) {
    return Position(
      x: x ?? this.x,
      y: y ?? this.y,
      z: z ?? this.z,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'x': x,
      'y': y,
      'z': z,
    };
  }

  factory Position.fromMap(Map<String, dynamic> map) {
    return Position(
      x: map['x'] != null ? map['x'] as double : null,
      y: map['y'] != null ? map['y'] as double : null,
      z: map['z'] != null ? map['z'] as double : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Position.fromJson(String source) => Position.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'Position(x: $x, y: $y, z: $z)';

  @override
  bool operator ==(covariant Position other) {
    if (identical(this, other)) return true;
  
    return 
      other.x == x &&
      other.y == y &&
      other.z == z;
  }

  @override
  int get hashCode => x.hashCode ^ y.hashCode ^ z.hashCode;
}

class Orientation {
  double? x;
  double? y;
  double? z;
  double? w;
  Orientation({
    this.x,
    this.y,
    this.z,
    this.w,
  });
  

  Orientation copyWith({
    double? x,
    double? y,
    double? z,
    double? w,
  }) {
    return Orientation(
      x: x ?? this.x,
      y: y ?? this.y,
      z: z ?? this.z,
      w: w ?? this.w,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'x': x,
      'y': y,
      'z': z,
      'w': w,
    };
  }

  factory Orientation.fromMap(Map<String, dynamic> map) {
    return Orientation(
      x: map['x'] != null ? map['x'] as double : null,
      y: map['y'] != null ? map['y'] as double : null,
      z: map['z'] != null ? map['z'] as double : null,
      w: map['w'] != null ? map['w'] as double : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Orientation.fromJson(String source) => Orientation.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Orientation(x: $x, y: $y, z: $z, w: $w)';
  }

  @override
  bool operator ==(covariant Orientation other) {
    if (identical(this, other)) return true;
  
    return 
      other.x == x &&
      other.y == y &&
      other.z == z &&
      other.w == w;
  }

  @override
  int get hashCode {
    return x.hashCode ^
      y.hashCode ^
      z.hashCode ^
      w.hashCode;
  }
}

class RosTransformModel {
  final Position? translation;
  static const String translationKey = "translation";

  final Orientation? rotation;
  RosTransformModel({
    this.translation,
    this.rotation,
  });
  static const String rotationKey = "rotation";

  RobotposeModel getRobotPose(){
    return RobotposeModel(x: getXYZ()[0].toDouble(), y: getXYZ()[1].toDouble(), theta: getRPY()[2].toDouble());
  } 

  List<double> getXYZ(){
    return [translation!.x!, translation!.y!, translation!.z!];
  }

  List<double> getRPY(){
    double rx = rotation!.x!;
    double ry = rotation!.y!;
    double rz = rotation!.z!;
    double rw = rotation!.w!;

    double roll = atan2(2*(rw * rx + ry * rz), 1 - 2 * (rx * rx + ry * ry));
    double pitch = asin(2 * (rw * ry - rz * rx));
    double yaw = atan2(2 * (rw * rz + rx * ry), 1 - 2 * (ry * ry + rz * rz));

    return [roll, pitch, yaw];
  } 


  RosTransformModel copyWith({
    Position? translation,
    Orientation? rotation,
  }) {
    return RosTransformModel(
      translation: translation ?? this.translation,
      rotation: rotation ?? this.rotation,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'translation': translation?.toMap(),
      'rotation': rotation?.toMap(),
    };
  }

  factory RosTransformModel.fromMap(Map<String, dynamic> map) {
    return RosTransformModel(
      translation: map['translation'] != null ? Position.fromMap(map['translation'] as Map<String,dynamic>) : null,
      rotation: map['rotation'] != null ? Orientation.fromMap(map['rotation'] as Map<String,dynamic>) : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory RosTransformModel.fromJson(String source) => RosTransformModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'Rostransform_model(translation: $translation, rotation: $rotation)';

  @override
  bool operator ==(covariant RosTransformModel other) {
    if (identical(this, other)) return true;
  
    return 
      other.translation == translation &&
      other.rotation == rotation;
  }

  @override
  int get hashCode => translation.hashCode ^ rotation.hashCode;
}
