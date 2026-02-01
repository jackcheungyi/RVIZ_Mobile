import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:ros_control/Service/ROS/ros_provider.dart';
// import 'package:ros_control/Service/Repository/ros_repository.dart';
import 'package:roslibdart/roslibdart.dart';
import 'package:equatable/equatable.dart';

part 'ros_url_event.dart';
part 'ros_url_state.dart';

class RosUrlBloc extends Bloc<RosUrlEvent, RosUrlState> {
  final RosProvider rosProvider;
  RosUrlBloc(this.rosProvider) : super(RosUrlInitial()) {
    on<RosInitEvent>(_rosInit);
    
    on<RosConnectReqEvent>(_rosConnet);

    on<RosDisconnectReqEvent>(_rosDiconnect);
  }
  void _rosInit(RosInitEvent event,Emitter<RosUrlState> emit) {
    if (rosProvider.rosConnectState == Status.connected){
        emit(const RosUrlConnected()); 
    }
    else {
      emit(const RosUrlDisconnected(isLoading: false));
    }
  }

  void _rosConnet(RosConnectReqEvent event,Emitter<RosUrlState> emit) async{
    emit(const RosUrlDisconnected(isLoading: true));
    final String ip = event.ip;
    final String port = event.port;
    try{
      print("Connecting to $ip:$port from ros bloc");
      bool connected = await rosProvider.rosconnect(ip, port);
      // bool connected = await Future.delayed(Duration(seconds: 3), ()=>false);
      print("Connected: $connected");
      if (connected){
        emit(RosUrlConnected());
      }
      else {
        emit(RosConnectFail(exception: Exception("Connect Fail")));
      }
    }on Exception catch(e){
      emit(RosConnectFail(exception: e));
    }
  }

  void _rosDiconnect(RosDisconnectReqEvent event,Emitter<RosUrlState> emit) async{
    await rosProvider.rosDisconnect();
    emit(RosUrlDisconnected(isLoading: false));
  }
}
