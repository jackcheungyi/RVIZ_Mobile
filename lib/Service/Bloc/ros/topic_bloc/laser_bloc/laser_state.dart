part of 'laser_bloc.dart';

sealed class LaserState extends Equatable {
  const LaserState();
  
  @override
  List<Object> get props => [];
}

final class LaserInitial extends LaserState {}

final class LaserFetched extends LaserState {
  final Laserscanmap_model laser;
  const LaserFetched({required this.laser});
}

final class LaserProcessed extends LaserState{
  final List<Offset> laserPointsScene;
  final double width;
  final double height;
  const LaserProcessed( this.laserPointsScene,  this.width, this.height);
}