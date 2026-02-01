import 'dart:convert';

class linearModel {
  double x;
  double y;
  double z;
  linearModel({
    required this.x,
    required this.y,
    required this.z,
  });

  linearModel copyWith({
    double? x,
    double? y,
    double? z,
  }) {
    return linearModel(
      x: x ?? this.x,
      y: y ?? this.y,
      z: z ?? this.z,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'x': x,
      'y': y,
      'z': z,
    };
  }

  factory linearModel.fromMap(Map<String, dynamic> map) {
    return linearModel(
      x: map['x']?.toDouble() ?? 0.0,
      y: map['y']?.toDouble() ?? 0.0,
      z: map['z']?.toDouble() ?? 0.0,
    );
  }

  String toJson() => json.encode(toMap());

  factory linearModel.fromJson(String source) => linearModel.fromMap(json.decode(source));

  @override
  String toString() => 'linear(x: $x, y: $y, z: $z)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is linearModel &&
      other.x == x &&
      other.y == y &&
      other.z == z;
  }

  @override
  int get hashCode => x.hashCode ^ y.hashCode ^ z.hashCode;
}


class angularModel {
  double x;
  double y;
  double z;

  angularModel({
    required this.x,
    required this.y,
    required this.z,
  });

  angularModel copyWith({
    double? x,
    double? y,
    double? z,
  }) {
    return angularModel(
      x: x ?? this.x,
      y: y ?? this.y,
      z: z ?? this.z,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'x': x,
      'y': y,
      'z': z,
    };
  }

  factory angularModel.fromMap(Map<String, dynamic> map) {
    return angularModel(
      x: map['x']?.toDouble() ?? 0.0,
      y: map['y']?.toDouble() ?? 0.0,
      z: map['z']?.toDouble() ?? 0.0,
    );
  }

  String toJson() => json.encode(toMap());

  factory angularModel.fromJson(String source) => angularModel.fromMap(json.decode(source));

  @override
  String toString() => 'angular(x: $x, y: $y, z: $z)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is angularModel &&
      other.x == x &&
      other.y == y &&
      other.z == z;
  }

  @override
  int get hashCode => x.hashCode ^ y.hashCode ^ z.hashCode;
}


class TwistModel {
  linearModel linear;
  angularModel angular;
  TwistModel({
    required this.linear,
    required this.angular,
  });
  

  TwistModel copyWith({
    linearModel? linear,
    angularModel? angular,
  }) {
    return TwistModel(
      linear: linear ?? this.linear,
      angular: angular ?? this.angular,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'linear': linear.toMap(),
      'angular': angular.toMap(),
    };
  }

  factory TwistModel.fromMap(Map<String, dynamic> map) {
    return TwistModel(
      linear: linearModel.fromMap(map['linear']),
      angular: angularModel.fromMap(map['angular']),
    );
  }

  String toJson() => json.encode(toMap());

  factory TwistModel.fromJson(String source) => TwistModel.fromMap(json.decode(source));

  @override
  String toString() => 'TwistModel(linear: $linear, angular: $angular)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is TwistModel &&
      other.linear == linear &&
      other.angular == angular;
  }

  @override
  int get hashCode => linear.hashCode ^ angular.hashCode;
}
