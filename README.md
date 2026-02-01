# RVIZ_Mobile

A mobile app function demo for RViz/ROS visualization and control.

## Features

- Remote robot control via joystick
- Real-time RViz visualization (laser scan, map, robot pose)
- Waypoint navigation
- TF2 transform visualization
- Grid display

## Demo Videos

- [RVIZ_Mobile Demo 1](https://youtu.be/6S_p8XqCCw0)
- [RVIZ_Mobile Demo 2](https://youtu.be/IP7mFs-BQT0)

## Getting Started

This is a Flutter project for ROS (Robot Operating System) mobile control.

### Prerequisites

- Flutter SDK
- ROS 2 (or ROS 1) running on robot
- WiFi connection to robot

### Installation

1. Clone the repository:
```bash
git clone https://github.com/jackcheungyi/RVIZ_Mobile.git
```

2. Get Flutter dependencies:
```bash
cd RVIZ_Mobile
flutter pub get
```

3. Run on device:
```bash
flutter run
```

### Configuration

Connect to your robot's ROS master by entering the robot's IP address and port in the app settings.

## Tech Stack

- **Flutter** - Cross-platform mobile framework
- **ROS** - Robot Operating System
- **WebSocket** - Real-time communication with ROS
- **RViz** - 3D visualization tool

## License

MIT License
