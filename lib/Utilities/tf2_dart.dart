
import 'dart:collection';

import 'package:ros_control/Service/Data/Ros_model/robotpose_model.dart';
import 'package:ros_control/Service/Data/Ros_model/tf_model.dart';

class TF2Dart{
  Map<String, Set<String>> adj = {};
  Map<String, List<TransformElement>> adjTrasnform = {};

  void updateTF(TF data){
    for (var trans in data.transforms){
      String parentFrame = trans.header!.frameId;
      String childFrame = trans.childFrameId;
      // if(parentFrame == "map" || childFrame == "map"){
      //   print("map frame tf updated");
      // }
      if (!adj.containsKey(parentFrame)) {
        adj[parentFrame] = {};
      }
      adj[parentFrame]?.add(childFrame);

      if (!adj.containsKey(childFrame)){
        adj[childFrame] = {};
      }
      adj[childFrame]?.add(parentFrame);

      if (!adjTrasnform.containsKey(parentFrame)){
        adjTrasnform[parentFrame] = [];
      }
      adjTrasnform[parentFrame]!.removeWhere((element) => element.childFrameId == childFrame);
      adjTrasnform[parentFrame]?.add(trans);
    }
  }

  RobotposeModel lookUpForTransform(String from, String to){
      try{
        var path = shortPath(from, to);
        if (path.isEmpty) {
          // print("Warning: No path found from $from to $to");
          return RobotposeModel(x: 0, y: 0, theta: 0); 
        }
        RobotposeModel pose = RobotposeModel(x: 0, y: 0, theta: 0);
        for (int i = 0; i < path.length - 1; i++){
          String curr = path[i];
          String next = path[i + 1];

          var transformList = adjTrasnform[curr];
          if (transformList == null || transformList.isEmpty) {
            // print("Warning: No transform found from $curr to $next");
            continue;
          }

          var transform = transformList.firstWhere(
            (element) => element.childFrameId == next,
            orElse: () => TransformElement(header: Header(seq: 0, stamp: null, frameId: curr),
                                            childFrameId: next,
                                            transform: null),
          );

          if (transform.transform != null) {
            // print("pose: $pose");
            // print("transform: ${transform.transform?.getRobotPose()}"); 
            pose = absoluteSum(pose, transform.transform!.getRobotPose());
          }
        }
        return pose;
      }catch(e){
        // print("Error in lookUpForTransform: $e");
        return RobotposeModel(x: 0, y: 0, theta: 0); 
      }
  }

  List<String> shortPath(String from, String to){
    if(from == to) return [from];

    if (!adj.containsKey(from)) {
      // print("Warning: Frame '$from' not found in TF tree");
      return [];
    }

    Map<String, String> parent = {};
    Queue<String> queue = Queue<String>();
    Set<String> visited = {from};

    queue.add(from);
    parent[from] = "";

    while (queue.isNotEmpty){
      String current = queue.removeFirst();
      if (current == to) {
        List<String> path = [];
        String node = to;
        while (node != "") {
          path.insert(0, node);
          node = parent[node] ?? "";
        }
        return path;
      }

      for (String next in (adj[current] ?? {})) {
        if (!visited.contains(next)) {
          visited.add(next);
          queue.add(next);
          parent[next] = current;
        }
      }

    }
    // print("Warning: No path found between '$from' and '$to'");
    return [];
  }
}