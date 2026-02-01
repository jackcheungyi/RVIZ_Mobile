// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
import 'package:ros_control/Service/Data/Ros_model/transform_model.dart';

class TF {
  final List<TransformElement> transforms;
  TF({
    required this.transforms,
  });
  static const String transformKey = "transforms";

  TF copyWith({
    List<TransformElement>? transforms,
  }) {
    return TF(
      transforms: transforms ?? this.transforms,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'transfroms': transforms.map((x) => x.toMap()).toList(),
    };
  }

  factory TF.fromMap(Map<String, dynamic> map) {
    // print("TF From map called");
    List<TransformElement> temp = [];
    if (map["transforms"]==null)  {
      temp = [];
      print("empty transformation infomation");
    }else {
      // print("Data : $map");
      temp = (map['transforms'] as List<dynamic>).map((x){
        // print("Processing transform: $x");
        return TransformElement.fromMap(x as Map<String, dynamic>);
      }).toList();
      // temp.asMap().forEach((index, element) {
      //   print("[Element $index]: $element");
      //   }
      // );
    }
    return TF(
      transforms: temp,
    );
  }

  String toJson() => json.encode(toMap());

  factory TF.fromJson(String source) => TF.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'TF(transfroms: $transforms)';

  @override
  bool operator ==(covariant TF other) {
    if (identical(this, other)) return true;
  
    return 
      listEquals(other.transforms, transforms);
  }

  @override
  int get hashCode => transforms.hashCode;
}

class Stamp {
  final num secs;
  static const String secsKey = "secs";
  final num nsecs;
  Stamp({
    required this.secs,
    required this.nsecs,
  });
  static const String nsecsKey = "nsecs";
  
  Stamp copyWith({
    num? secs,
    num? nsecs,
  }) {
    return Stamp(
      secs: secs ?? this.secs,
      nsecs: nsecs ?? this.nsecs,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'secs': secs,
      'nsecs': nsecs,
    };
  }

  factory Stamp.fromMap(Map<String, dynamic> map) {
    return Stamp(
      secs: map['sec'] as num,
      nsecs: map['nanosec'] as num,
    );
  }

  String toJson() => json.encode(toMap());

  factory Stamp.fromJson(String source) => Stamp.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'Stamp(secs: $secs, nsecs: $nsecs)';

  @override
  bool operator ==(covariant Stamp other) {
    if (identical(this, other)) return true;
  
    return 
      other.secs == secs &&
      other.nsecs == nsecs;
  }

  @override
  int get hashCode => secs.hashCode ^ nsecs.hashCode;
}

class Header {
  final num? seq;
  static const String seqKey = 'seq';

  final Stamp? stamp;
  static const String stampKey = "stamp";

  final String frameId;
  Header({
    required this.seq,
    this.stamp,
    required this.frameId,
  });
  static const String frameIdKey = "frame_id";

  Header copyWith({
    num? seq,
    Stamp? stamp,
    String? frameId,
  }) {
    return Header(
      seq: seq ?? this.seq,
      stamp: stamp ?? this.stamp,
      frameId: frameId ?? this.frameId,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'seq': seq,
      'stamp': stamp?.toMap(),
      'frameId': frameId,
    };
  }

  factory Header.fromMap(Map<String, dynamic> map) {
    // print("Header from map called");
    // print("Header Data: $map" );
    return Header(
      seq: map['seq'] != null ? map['seq'] as num : null,
      stamp: map['stamp'] != null ? Stamp.fromMap(map['stamp'] as Map<String,dynamic>) : null,
      frameId: map['frame_id'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory Header.fromJson(String source) => Header.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'Header(seq: $seq, stamp: $stamp, frameId: $frameId)';

  @override
  bool operator ==(covariant Header other) {
    if (identical(this, other)) return true;
  
    return 
      other.seq == seq &&
      other.stamp == stamp &&
      other.frameId == frameId;
  }

  @override
  int get hashCode => seq.hashCode ^ stamp.hashCode ^ frameId.hashCode;
}

class TransformElement {
  final Header? header;
  static const String headerKey = "header";

  final String childFrameId;
  static const String childFrameIdKey = "child_frame_id";

  final RosTransformModel? transform;
  TransformElement({
    this.header,
    required this.childFrameId,
    this.transform,
  });
  static const String transformKey = "transform";

  TransformElement copyWith({
    Header? header,
    String? childFrameId,
    RosTransformModel? transform,
  }) {
    return TransformElement(
      header: header ?? this.header,
      childFrameId: childFrameId ?? this.childFrameId,
      transform: transform ?? this.transform,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'header': header?.toMap(),
      'childFrameId': childFrameId,
      'stransform': transform?.toMap(),
    };
  }

  factory TransformElement.fromMap(Map<String, dynamic> map) {
    // print("TransformElement from map called");
    // print("Transform Data: $map");
    // Header? tempHeader;
    // if (map["header"] == null) {
    //   print("Header is null");
    //   tempHeader = null;
    // }else {
    //   print("Header is not null");
    //   tempHeader = Header.fromMap(map['header']as Map<String, dynamic>);
    // }
    // String  childFID = map["child_frame_id"];
    // print("childfid : $childFID");
    // if (map["transform"] != null){
    //   print("Transform is not null");
    //   print(RosTransformModel.fromMap(map['transform'] as Map<String, dynamic>).toString());
    // } 
    
    return TransformElement(
      header: map['header'] != null ? Header.fromMap(map['header']as Map<String,dynamic>) : null,
      // header: tempHeader,
      childFrameId: map['child_frame_id'] as String,
      transform: map['transform'] != null ? RosTransformModel.fromMap(map['transform'] ): null,
    );
  }

  String toJson() => json.encode(toMap());

  factory TransformElement.fromJson(String source) => TransformElement.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'TransformElement(header: $header, childFrameId: $childFrameId, transform: $transform)';

  @override
  bool operator ==(covariant TransformElement other) {
    if (identical(this, other)) return true;
  
    return 
      other.header == header &&
      other.childFrameId == childFrameId &&
      other.transform == transform;
  }

  @override
  int get hashCode => header.hashCode ^ childFrameId.hashCode ^ transform.hashCode;
}
