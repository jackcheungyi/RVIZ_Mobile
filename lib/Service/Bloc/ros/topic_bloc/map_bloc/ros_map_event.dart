part of 'ros_map_bloc.dart';

@immutable
sealed class RosMapEvent {
  const RosMapEvent();
}

class RosMapInitialEvent extends RosMapEvent{
  const RosMapInitialEvent();
}

class RosMapFetchEvent extends RosMapEvent{
  final OccupancyMapModel map;
  const RosMapFetchEvent({required this.map});
}