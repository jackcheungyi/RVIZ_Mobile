// import 'dart:async';
import 'dart:ui';

import 'package:bloc/bloc.dart';
// import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:ros_control/Service/Data/Ros_model/map_model.dart';
import 'package:ros_control/Service/ROS/ros_provider.dart';
// import 'package:ros_control/Service/Repository/ros_repository.dart';

part 'ros_map_event.dart';
part 'ros_map_state.dart';

class RosMapBloc extends Bloc<RosMapEvent, RosMapState> {
  final RosProvider rosProvider;
  // StreamSubscription<OccupancyMapModel>? _subscription;
  RosMapBloc(this.rosProvider) : super(RosMapInitial()) {
    

    on<RosMapInitialEvent>(_initial);

    on<RosMapFetchEvent>(_rosMapFetch);
  }

  void _initial(RosMapInitialEvent event, Emitter<RosMapState> emit){
    // print("RosMap Bloc initial called");
    rosProvider.mapStream.listen((map) {
      print("map is changed");
      add(RosMapFetchEvent(map: map)) ;
    });
    // rosProvider.map.addListener((){
    //   print("map is changed");
    //   add(RosMapFetchEvent(map: rosProvider.map.value)) ;
    // });
  }

  void _rosMapFetch(RosMapFetchEvent event,Emitter<RosMapState> emit)async{
    final listsobj =  await event.map.processMap();
    emit(RosMapFetechedState(map: event.map, occPointList: listsobj.item1, freePointList: listsobj.item2));
  }
}
