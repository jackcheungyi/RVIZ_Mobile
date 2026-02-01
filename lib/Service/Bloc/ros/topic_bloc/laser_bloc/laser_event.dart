part of 'laser_bloc.dart';

sealed class LaserEvent  {
  const LaserEvent();

 
}

class LaserInitEvent extends LaserEvent {
  const LaserInitEvent();
}

class LaserFetchEvent extends LaserEvent {
  
  final Laserscanmap_model laser;
  const LaserFetchEvent({required this.laser});
}

class LaserProcessEvent extends LaserEvent{
  final RobotposeModel pose;
  // final List<Offset> laserpoints;

  const LaserProcessEvent({required this.pose});
}