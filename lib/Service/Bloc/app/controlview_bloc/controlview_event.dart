part of 'controlview_bloc.dart';

sealed class ControlviewEvent extends Equatable {
  const ControlviewEvent();

  @override
  List<Object> get props => [];
}

class ControlviewInitEvent extends ControlviewEvent {
  const ControlviewInitEvent();
}

class ControlViewModeChangedEvent extends ControlviewEvent {
  final Mode mode;
  final bool isManualCtrl;
  const ControlViewModeChangedEvent({required this.mode, required this.isManualCtrl});
}