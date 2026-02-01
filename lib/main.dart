import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ros_control/Pages/connect_view.dart';
import 'package:ros_control/Pages/control_view.dart';
import 'package:ros_control/Service/Bloc/app/controlview_bloc/controlview_bloc.dart';
import 'package:ros_control/Service/Bloc/ros/ros_bloc/ros_url_bloc.dart';
import 'package:ros_control/Service/Bloc/ros/topic_bloc/cmd_bloc/ros_cmd_bloc.dart';
import 'package:ros_control/Service/Bloc/ros/topic_bloc/laser_bloc/laser_bloc.dart';
import 'package:ros_control/Service/Bloc/ros/topic_bloc/map_bloc/ros_map_bloc.dart';
import 'package:ros_control/Service/Bloc/ros/topic_bloc/nav_bloc/ros_nav_bloc.dart';
import 'package:ros_control/Service/Bloc/ros/topic_bloc/pose_bloc/robot_pose_bloc.dart';
import 'package:ros_control/Service/ROS/ros_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ROS DEMO',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
      ),
      home: RepositoryProvider(
        create: (context) => RosProvider(),
        child: MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) => RosUrlBloc(context.read<RosProvider>()),
            ),
            BlocProvider(
              create: (context) => RosMapBloc(context.read<RosProvider>()),
            ),
            BlocProvider(
              create: (context) => RobotPoseBloc(context.read<RosProvider>()), 
            ),
            BlocProvider(
              create: (context) => RosLaserBloc(context.read<RosProvider>()), 
            ),
            BlocProvider(
              create: (context) => RosNavBloc(context.read<RosProvider>()),
            ),
            BlocProvider(
              create: (context)=> RosCmdBloc(context.read<RosProvider>()),
            ),
            BlocProvider(
              create: (context) => ControlviewBloc(),
            ),
          ], 
          child: const MainPages()),
      ),
    );
  }
}

class MainPages extends StatelessWidget {
  const MainPages({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    context.read<RosUrlBloc>().add(const RosInitEvent());
    return BlocBuilder<RosUrlBloc, RosUrlState>(
      builder: (context, state) {
        if (state is RosUrlDisconnected || state is RosConnectFail){
          return const ConnectView();
          
        }
        if (state is RosUrlConnected){
          return const ControlView();
        }
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}
