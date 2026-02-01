part of 'controlview_bloc.dart';

sealed class ControlviewState extends Equatable {
  final Mode mode;
  final bool isManualCtrl;
  const ControlviewState({required this.mode, required this.isManualCtrl});
  
  @override
  List<Object> get props => [];
}

final class ControlviewInitial extends ControlviewState {
  const ControlviewInitial({required super.mode, required super.isManualCtrl});
}

class ControlViewUpdated extends ControlviewState {
  
  // final bool isManualCtrl;
  const ControlViewUpdated({required super.mode, required super.isManualCtrl});

  @override
  List<Object> get props => [mode, isManualCtrl];
}