

// import 'package:ros_control/Service/Data/Ros_model/map_model.dart';
// import 'package:ros_control/Service/ROS/ros_provider.dart';

// class RosRepository {
//   final RosProvider rosProvider;
//   RosRepository(this.rosProvider);

//   Future<bool> connect(String ip,String port) async{

//     try{
//       // String urlLink = 'ws://$ip:$port';
//       bool connect = await rosProvider.rosconnect(ip,port);
//       if (connect){
//         return true;
//       }
//     }catch (e){
//         rethrow;
//     }
//     return false;
//   }

//   Future<void> disconnect() async {
//     await rosProvider.rosDisconnect();
//   }

 
// }