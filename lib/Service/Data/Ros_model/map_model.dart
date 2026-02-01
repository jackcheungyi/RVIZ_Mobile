// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/foundation.dart';

class MapConfigModel {
  final String? image;
  final double resolution;
  final double originx;
  final double originy;
  final double originTheta;
  final int width;
  final int height;
  MapConfigModel({
    required this.image,
    required this.resolution,
    required this.originx,
    required this.originy,
    required this.originTheta,
    required this.width,
    required this.height,
  });

  MapConfigModel copyWith({
    String? image,
    double? resolution,
    double? originx,
    double? originy,
    double? originTheta,
    int? width,
    int? height,
  }) {
    return MapConfigModel(
      image: image ?? this.image,
      resolution: resolution ?? this.resolution,
      originx: originx ?? this.originx,
      originy: originy ?? this.originy,
      originTheta: originTheta ?? this.originTheta,
      width: width ?? this.width,
      height: height ?? this.height,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'image': image,
      'resolution': resolution,
      'originx': originx,
      'originy': originy,
      'originTheta': originTheta,
      'width': width,
      'height': height,
    };
  }

  factory MapConfigModel.fromMap(Map<String, dynamic> map) {
    
    final data = map;
    print("data object : $data");
    return MapConfigModel(
      image: data["image"],
      resolution: data["resolution"],
      originx: data["origin"]["position"]["x"],
      originy: data["origin"]["position"]["y"],
      originTheta: data["origin"]["position"]["z"],
      width: data["width"],
      height: data["height"],
    );
  }

  String toJson() => json.encode(toMap());

  factory MapConfigModel.fromJson(String source) => MapConfigModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'MapConfigModel(image: $image, resolution: $resolution, originx: $originx, originy: $originy, originTheta: $originTheta, width: $width, height: $height)';
  }

  @override
  bool operator ==(covariant MapConfigModel other) {
    if (identical(this, other)) return true;
  
    return 
      other.image == image &&
      other.resolution == resolution &&
      other.originx == originx &&
      other.originy == originy &&
      other.originTheta == originTheta &&
      other.width == width &&
      other.height == height;
  }

  @override
  int get hashCode {
    return image.hashCode ^
      resolution.hashCode ^
      originx.hashCode ^
      originy.hashCode ^
      originTheta.hashCode ^
      width.hashCode ^
      height.hashCode;
  }
}


class OccupancyMapModel {
  final MapConfigModel? mapConfig;
  final List<List<int>>? data;
  OccupancyMapModel({
    required this.mapConfig,
    required this.data,
  });

  OccupancyMapModel copyWith({
    MapConfigModel? mapConfig,
    List<List<int>>? data,
  }) {
    return OccupancyMapModel(
      mapConfig: mapConfig ?? this.mapConfig,
      data: data ?? this.data,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'mapConfig': mapConfig!.toMap(),
      'data': data,
    };
  }

  factory OccupancyMapModel.fromMap(Map<String, dynamic> map) {
    // print("incoming map : $map");
    List<int> dataList = [];
    if(map["data"] != null){
      print("data is not null");
      dataList = List<int>.from(map["data"]);
      // print(dataList);
    }
    
    MapConfigModel tempConfig = MapConfigModel.fromMap(map["info"]as Map<String,dynamic>);
    List<List<int>> tempList = List.generate(
      tempConfig.height,
    (i)=>List.generate(
        tempConfig.width, 
        (j) => 0, 
      ),
      );

    for (int i = 0; i<dataList.length; i++){
      int x = i ~/ tempConfig.width;
      int y = i % tempConfig.width;
      tempList[x][y] = dataList[i];
    }

    return OccupancyMapModel(
      mapConfig: tempConfig,
      data: List.from(tempList.reversed),
    );
  }

  String toJson() => json.encode(toMap());

  factory OccupancyMapModel.fromJson(String source) => OccupancyMapModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'OccupancyMapModel(mapConfig: $mapConfig, data: $data)';

  @override
  bool operator ==(covariant OccupancyMapModel other) {
    if (identical(this, other)) return true;
  
    return 
      other.mapConfig == mapConfig &&
      listEquals(other.data, data);
  }

  @override
  int get hashCode => mapConfig.hashCode ^ data.hashCode;


  Offset idx2xy(Offset occPoint) {
    double y =(mapConfig!.height - occPoint.dy) * mapConfig!.resolution + mapConfig!.originy;
    double x = occPoint.dx * mapConfig!.resolution + mapConfig!.originx;
    return Offset(x, y);
  }

  Offset xy2idx(Offset mapPoint) {
    double x = (mapPoint.dx - mapConfig!.originx) / mapConfig!.resolution;
    double y = mapConfig!.height - (mapPoint.dy - mapConfig!.originy) / mapConfig!.resolution;
    return Offset(x, y);
  }

  Future <Tuple<List<mapPoint>,List<Offset>>> processMap(){
    List<mapPoint> occPointList = [];
    List<Offset> freePointList = [];
    Completer<Tuple<List<mapPoint>,List<Offset>>> completer = Completer();
    for (int i = 0; i<mapConfig!.width; i++){
      for (int j = 0; j<mapConfig!.height; j++){
        int mapValue = data![j][i];
        Offset point = Offset(i.toDouble(), j.toDouble());
        if (mapValue > 0){
          int alpha = (mapValue*2.55).clamp(0, 255).toInt();
          occPointList.add(mapPoint(point: point, value: alpha));
        }else{
          freePointList.add(point);
        }
      }
    }completer.complete(Tuple(item1: occPointList, item2: freePointList));
    
    return completer.future;
  }
}

class mapPoint{
  final Offset point;
  final int value;
  mapPoint({required this.point, required this.value});
}

class Tuple<T1,T2>{
  final T1 item1;
  final T2 item2;

  Tuple({
    required this.item1,
    required this.item2,
  });
}