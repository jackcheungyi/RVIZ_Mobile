part of 'ros_cmd_bloc.dart';

sealed class RosCmdState extends Equatable {
  const RosCmdState();
  
  @override
  List<Object> get props => [];
}

final class RosCmdInitial extends RosCmdState {}
