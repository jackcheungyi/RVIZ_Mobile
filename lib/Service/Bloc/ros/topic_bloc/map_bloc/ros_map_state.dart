part of 'ros_map_bloc.dart';

@immutable
sealed class RosMapState {}

final class RosMapInitial extends RosMapState {}

class RosMapFetechedState extends RosMapState  {
  final OccupancyMapModel map;
  final List<mapPoint> occPointList;
  final List<Offset> freePointList;
  RosMapFetechedState({
    required this.map,
    required this.occPointList,
    required this.freePointList,
  }
  );
 
}