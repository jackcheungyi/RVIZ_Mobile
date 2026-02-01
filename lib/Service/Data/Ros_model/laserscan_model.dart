
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
// import 'package:flutter/widgets.dart';

import 'package:ros_control/Service/Data/Ros_model/tf_model.dart';

class LaserscanModel {
  Header? header;
  double? angleMin;
  double? angleMax;
  double? angleIncrement;
  double? timeIncrement;
  double? scanTime;
  double? rangeMin;
  double? rangeMax;
  List<double>? ranges;
  List<int>? intensities;
  LaserscanModel({
    this.header,
    this.angleMin,
    this.angleMax,
    this.angleIncrement,
    this.timeIncrement,
    this.scanTime,
    this.rangeMin,
    this.rangeMax,
    this.ranges,
    this.intensities,
  });

  LaserscanModel copyWith({
    ValueGetter<Header?>? header,
    ValueGetter<double?>? angleMin,
    ValueGetter<double?>? angleMax,
    ValueGetter<double?>? angleIncrement,
    ValueGetter<double?>? timeIncrement,
    ValueGetter<double?>? scanTime,
    ValueGetter<double?>? rangeMin,
    ValueGetter<double?>? rangeMax,
    ValueGetter<List<double>?>? ranges,
    ValueGetter<List<int>?>? intensities,
  }) {
    return LaserscanModel(
      header: header != null ? header() : this.header,
      angleMin: angleMin != null ? angleMin() : this.angleMin,
      angleMax: angleMax != null ? angleMax() : this.angleMax,
      angleIncrement: angleIncrement != null ? angleIncrement() : this.angleIncrement,
      timeIncrement: timeIncrement != null ? timeIncrement() : this.timeIncrement,
      scanTime: scanTime != null ? scanTime() : this.scanTime,
      rangeMin: rangeMin != null ? rangeMin() : this.rangeMin,
      rangeMax: rangeMax != null ? rangeMax() : this.rangeMax,
      ranges: ranges != null ? ranges() : this.ranges,
      intensities: intensities != null ? intensities() : this.intensities,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'header': header?.toMap(),
      'angleMin': angleMin,
      'angleMax': angleMax,
      'angleIncrement': angleIncrement,
      'timeIncrement': timeIncrement,
      'scanTime': scanTime,
      'rangeMin': rangeMin,
      'rangeMax': rangeMax,
      'ranges': ranges,
      'intensities': intensities,
    };
  }

  factory LaserscanModel.fromMap(Map<String, dynamic> map) {
    return LaserscanModel(
      header: map['header'] != null ? Header.fromMap(map['header']) : null,
      angleMin: (map['angle_min'] as num?)?.toDouble() ?? 0.0,
      angleMax: (map['angle_max'] as num?)?.toDouble() ?? 0.0,
      angleIncrement: (map['angle_increment'] as num?)?.toDouble() ?? 0.0,
      timeIncrement: (map['time_increment'] as num?)?.toDouble() ?? 0.0,
      scanTime: (map['scan_time'] as num?)?.toDouble() ?? 0.0,
      rangeMin: (map['range_min'] as num?)?.toDouble() ?? 0.0,
      rangeMax: (map['range_max'] as num?)?.toDouble() ?? 0.0,
      ranges: (map['ranges'] as List<dynamic>?)?.map((e) {
            if (e == null) return -1.0;
            if (e is num) return e.toDouble();
            return -1.0;
          }).toList() ??
          [],
      intensities: (map['intensities'] as List<dynamic>?)?.map((e) {
            if (e == null) return 0;
            if (e is num) return e.toInt();
            return 0;
          }).toList() ??
          [],
    );
  }

  String toJson() => json.encode(toMap());

  factory LaserscanModel.fromJson(String source) => LaserscanModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'LaserscanModel(header: $header, angleMin: $angleMin, angleMax: $angleMax, angleIncrement: $angleIncrement, timeIncrement: $timeIncrement, scanTime: $scanTime, rangeMin: $rangeMin, rangeMax: $rangeMax, ranges: $ranges, intensities: $intensities)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is LaserscanModel &&
      other.header == header &&
      other.angleMin == angleMin &&
      other.angleMax == angleMax &&
      other.angleIncrement == angleIncrement &&
      other.timeIncrement == timeIncrement &&
      other.scanTime == scanTime &&
      other.rangeMin == rangeMin &&
      other.rangeMax == rangeMax &&
      listEquals(other.ranges, ranges) &&
      listEquals(other.intensities, intensities);
  }

  @override
  int get hashCode {
    return header.hashCode ^
      angleMin.hashCode ^
      angleMax.hashCode ^
      angleIncrement.hashCode ^
      timeIncrement.hashCode ^
      scanTime.hashCode ^
      rangeMin.hashCode ^
      rangeMax.hashCode ^
      ranges.hashCode ^
      intensities.hashCode;
  }
}

class Laserscanmap_model{
  Stamp timestamp;
  List<Offset> points;
  Laserscanmap_model({required this.timestamp, required this.points});
}