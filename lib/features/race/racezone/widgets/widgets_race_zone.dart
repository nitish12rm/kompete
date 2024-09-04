

// Widget for stat titles like ETA, DISTANCE, etc.
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class StatTitle extends StatelessWidget {
  final String title;
  const StatTitle({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
      ),
    );
  }
}

// Widget for player stats column
class PlayerStatsColumn extends StatelessWidget {
  final String playerName,eta,distance,speed,calories;
  const PlayerStatsColumn({Key? key, required this.playerName, required this.eta, required this.distance, required this.speed, required this.calories}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Players(playerName: playerName),
          StatValue(value: "$eta min"),
          StatValue(value: "$distance km"),
          StatValue(value: "$speed km/h"),
          StatValue(value: "$calories kcal"),
        ],
      ),
    );
  }
}

// Widget for individual stat values
class StatValue extends StatelessWidget {
  final String value;
  const StatValue({Key? key, required this.value}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        value,
        style: TextStyle(fontSize: 16.sp),
      ),
    );
  }
}

// Reusable Player widget
class Players extends StatelessWidget {
  final String playerName;

  const Players({Key? key, required this.playerName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          CircleAvatar(
            radius: 20.sp,
            backgroundColor: Colors.black,
            child: Icon(
              Icons.person,
              size: 20.sp,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 5),
          Text(
            playerName,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
