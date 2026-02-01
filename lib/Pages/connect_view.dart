import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ros_control/Pages/SubPages/error_dialog.dart';
import 'package:ros_control/Service/Bloc/ros/ros_bloc/ros_url_bloc.dart';

class ConnectView extends StatefulWidget {
  const ConnectView({super.key});
  @override
  State<ConnectView> createState() => _ConnectViewState();
}

class _ConnectViewState extends State<ConnectView> {
  late final TextEditingController _address;
  late final TextEditingController _port;

  @override
  void initState() {
    _address = TextEditingController(text: '192.168.0.243');
    _port = TextEditingController(text: '9090');

    super.initState();
  }

  @override
  void dispose() {
    _address.dispose();
    _port.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return BlocListener<RosUrlBloc, RosUrlState>(
      listener: (context, state) async{
        // TODO: implement listener
        // print("state change chatched in listener");
        if (state is RosConnectFail){
          await showErrorDialog(context, "Invalid IP or Port!");
          context.read<RosUrlBloc>().add(const RosDisconnectReqEvent());
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Connect', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.blue,
        ),

        body:SingleChildScrollView( 
        child :Padding(
          padding: EdgeInsets.only(
            left: screenWidth / 8,
            right: screenWidth / 8,
            top: screenHeight / 10,
            bottom: screenHeight / 6,
          ),
          child: Column(
            children: [
              //Address Input block
              Padding(
                padding: const EdgeInsets.only(bottom: 30),
                child: TextField(
                  controller: _address,
                  enableIMEPersonalizedLearning: true,
                  enableSuggestions: false,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Enter IP address',
                    labelText: 'Address',
                    // prefixText: "192.168.0.243",
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color.fromRGBO(0, 100, 200, 100),
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(30)),
                    ),
                  ),
                ),
              ),
              //Port Input block
              Padding(
                padding: const EdgeInsets.only(bottom: 30),
                child: TextField(
                  controller: _port,
                  enableSuggestions: false,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Enter Port number',
                    labelText: 'Port ',
                    // prefixText: "9090",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(30)),
                    ),
                  ),
                ),
              ),

              BlocBuilder<RosUrlBloc, RosUrlState>(
                builder: (context, state) {
                  // print("state change chatched in builder");
                  // print("State : $state");
                  if (state is RosUrlDisconnected) {
                    if (!state.isLoading) {
                      return TextButton.icon(
                        onPressed: () async {
                          final ipAddr = _address.text;
                          final port = _port.text;
                          context.read<RosUrlBloc>().add(
                            RosConnectReqEvent(ipAddr, port),
                          );
                        },
                        label: const Text('Connect'),
                        icon: const Icon(Icons.settings_remote),
                      );
                     }else {
                      // print("isloading is true");
                       return const CircularProgressIndicator(color: Colors.blue);
                     }
                  }
                  // print("new state so return indicator");
                  return const CircularProgressIndicator(color: Colors.blue);
                },
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}
