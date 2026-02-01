import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'controlview_event.dart';
part 'controlview_state.dart';

enum Mode{
  normal,
  reloc,
  addNavPoint,
  robotFixedCenter,
}

class ControlviewBloc extends Bloc<ControlviewEvent, ControlviewState> {
  ControlviewBloc() : super(ControlviewInitial(mode :Mode.normal, isManualCtrl: false)) {
    
    on<ControlviewInitEvent>((event, emit) {
      Mode mode = Mode.normal;
      bool isManualCtrl = false;
      emit(ControlViewUpdated(mode: mode, isManualCtrl: isManualCtrl));
    
    });

    on<ControlViewModeChangedEvent>((event, emit) {
      emit(ControlViewUpdated(mode: event.mode, isManualCtrl: event.isManualCtrl));
    });
  }
}
