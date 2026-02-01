
part of 'ros_url_bloc.dart';

@immutable
sealed class RosUrlState {
    const RosUrlState();
}

class RosUrlInitial extends RosUrlState {
    const RosUrlInitial();
}

class RosUrlConnected extends RosUrlState{
    const RosUrlConnected();
}

class RosUrlDisconnected extends RosUrlState with EquatableMixin{
    final bool isLoading;
    const RosUrlDisconnected({required this.isLoading});
    @override
    List<Object?> get props => [isLoading];
}



class RosConnectFail extends RosUrlState{
    final Exception exception;
    const RosConnectFail({required this.exception});
}