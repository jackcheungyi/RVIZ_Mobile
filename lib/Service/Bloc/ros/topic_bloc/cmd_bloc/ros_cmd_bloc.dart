import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:ros_control/Service/ROS/ros_provider.dart';

part 'ros_cmd_event.dart';
part 'ros_cmd_state.dart';

class RosCmdBloc extends Bloc<RosCmdEvent, RosCmdState> {
  final RosProvider rosProvider;
  RosCmdBloc(this.rosProvider) : super(RosCmdInitial()) {
    on<RosCmdInitEvent>(_init);
    on<RosCmdSendEvent>(_send);
  }
  void _init(RosCmdInitEvent event, Emitter<RosCmdState> emit) {
    
  }
  void _send(RosCmdSendEvent event, Emitter<RosCmdState> emit) async {

    var linear = {'x': -event.linear * 0.1, 'y': 0.0, 'z': 0.0};
    var angular = {'x': 0.0, 'y': 0.0, 'z': -event.angular * 0.1};
    var twist = {'linear': linear, 'angular': angular};
    try{
      await rosProvider.sendVelocityCommand(twist);
    }catch(e){
      print(e);
    }
  }
}
