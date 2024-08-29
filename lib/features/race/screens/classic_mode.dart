import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:latlong2/latlong.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../controller/lobby_controller.dart';

class ClassicModeScreen extends StatelessWidget {
  ClassicModeScreen({super.key});

  final LobbyController lobbyController = Get.put(LobbyController());
  TextEditingController startController = TextEditingController();
  TextEditingController endController = TextEditingController();
  late GoogleMapController mapController;

  final LatLng _center =  LatLng(45.521563, -122.677433);

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          physics: NeverScrollableScrollPhysics(),
          child: Column(
            children: [
              /// Map to select start and end point
              Container(
                height: 75.h,
                color: Colors.black,
                child: Column(
                  children: [
                    /// Selector
                    Obx(
                          () => Container(
                        child: lobbyController.isCreateClicked.value
                            ? LobbyIdBox(
                          controller: lobbyController,
                        )
                            : LocationSelectorBox(),
                      ),
                    ),

                    /// Map
                    // Uncomment and replace with your map widget
                    Expanded(
                      child: Container(
                        color: Colors.transparent,
                        child: GoogleMap(
                          onMapCreated: _onMapCreated,
                          initialCameraPosition: CameraPosition(
                            target: _center,
                            zoom: 11.0,
                          ),
                        ),
                        // child: FlutterMap(
                        //   options: MapOptions(
                        //     initialCenter: LatLng(37.7749, -122.4194),
                        //     // Center the map on a specific location (e.g., San Francisco)
                        //     initialZoom: 13.0, // Set the initial zoom level
                        //   ),
                        //   children: [
                        //     TileLayer(
                        //       urlTemplate:
                        //       'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        //       userAgentPackageName: 'com.example.app',
                        //     )
                        //   ],
                        // ),
                        // This can be your map or other content
                      ),
                    ),
                  ],
                ),
              ),

              /// Create a lobby and join a lobby
              Container(
                height: 25.h,  // Use a fixed height here to ensure it fits
                child: Obx(() {
                  return lobbyController.isCreateClicked.value
                      ? _buildStartWidget()
                      : _buildCreateJoinWidget(context);
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCreateJoinWidget(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              lobbyController.toggleCreateClicked(); // Update state
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return LobbyPopup(lobbyId: 'ABC123');
                  });
            },
            child: Container(
              color: Colors.black,
              child: Center(
                child: Text(
                  'CREATE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          width: 2,
        ),
        Expanded(
          child: GestureDetector(
            child: Container(
              color: Colors.black,
              child: Center(
                child: Text(
                  'JOIN',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStartWidget() {
    return Column(
      children: [
        Expanded(
          child: Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Repeat for other players
                _buildPlayerWidget(),
                _buildPlayerWidget(),
                _buildPlayerWidget(),
                _buildPlayerWidget(),
              ],
            ),
          ),
        ),

        /// Start
        Container(
          height: 10.h,  // Use a fixed height here
          color: Colors.black,
          child: Row(
            children: [
              SizedBox(
                width: 20,
              ),
              Text(
                "START",
                style: TextStyle(
                    color: Colors.white,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.bold,
                    fontSize: 20.sp),
              ),
              Spacer(),
              Icon(
                Icons.arrow_forward,
                color: Colors.white,
              ),
              SizedBox(
                width: 20,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlayerWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black, width: 2),
          ),
          child: Icon(
            Icons.person,
            size: 25.sp,
          ),
        ),
        Text(
          'PLAYER',
          style: TextStyle(fontWeight: FontWeight.w400),
        ),
      ],
    );
  }
}


class LobbyIdBox extends StatelessWidget {
  const LobbyIdBox({
    super.key,
    required this.controller,
  });

  final LobbyController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 15.h,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                    onPressed: () {
                      controller.isCreateClicked.toggle();
                    },
                    icon: Icon(
                      Icons.arrow_back,
                      color: Colors.black,
                    )),
                Text(
                  'Lobby ID',
                  style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic),
                ),
                Text(
                  "123",
                  style: TextStyle(
                      fontSize: 17.sp,
                      color: Colors.black,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(
              height: 8,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: "123"));
                      final snackBar = SnackBar(
                        content: Text('Lobby ID copied to clipboard!'),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    },
                    icon: Icon(
                      Icons.copy_sharp,
                      color: Colors.black,
                    )),
                IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.share_outlined,
                      color: Colors.black,
                    )),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class LocationSelectorBox extends StatelessWidget {
  const LocationSelectorBox({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white, width: 3),
          borderRadius: BorderRadius.circular(20),
        ),
        height: 15.h,
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LocationSelectorField(

                icon: Icons.location_searching,
                title: 'Start',
              ),
              Row(
                children: [
                  SizedBox(
                    width: 11,
                  ),
                  Container(
                    width: 1,
                    height: 25,
                    color: Colors.white,
                  ),
                  Container(
                    width: 1,
                    height: 25,
                    color: Colors.white,
                  ),
                  SizedBox(
                    width: 30,
                  ),
                  Container(
                    width: 70.w,
                    height: 1,
                    color: Colors.white,
                  ),
                ],
              ),
              LocationSelectorField(
                icon: Icons.location_on,
                title: 'End',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// class LocationSelectorField extends StatelessWidget {
//   const LocationSelectorField({
//     super.key,
//     required this.icon,
//     required this.title,
//   });
//
//   final IconData icon;
//   final String title;
//
//
//   @override
//   Widget build(BuildContext context) {
//
//     return Row(
//       children: [
//         Icon(icon, color: Colors.white),
//         SizedBox(width: 10),
//         Expanded(
//           child: Container(
//               height: 40, // Set a fixed height for better visibility
//               child: TypeAheadField(
//                 builder: (context, controller, focusNode) {
//
//                   return TextField(
//                     controller: controller,
//               focusNode: focusNode,
//               decoration: InputDecoration(
//                 hintText: title.toUpperCase(),
//                 hintStyle: TextStyle(
//                     fontSize: 15.sp,
//                     color: Colors.white,
//                     fontFamily: "Roboto",
//                     fontWeight: FontWeight.w500),
//                 // Change hint text color
//                 border: InputBorder.none,
//                 // Remove default border
//                 filled: true,
//                 fillColor: Colors.transparent,
//                 // Background color of the TextField
//                 contentPadding:
//                     EdgeInsets.symmetric(vertical: 10, horizontal: 10),
//               ),
//               style: TextStyle(color: Colors.white),); // Change text color
//
//
//                 },
//                 itemBuilder: (context, String suggestion) {
//                   return Container(
//                     color: Colors.white,
//                     child: ListTile(
//                       leading: Icon(
//                         Icons.location_on,
//                         color: Colors.black,
//                       ),
//                       title: Text(suggestion,
//                           style: TextStyle(color: Colors.black)),
//                     ),
//                   );
//                 },
//                 onSelected: (String suggestion) {
//                   // Handle location selection
//
//                   print('Selected location: $suggestion');
//
//                 },
//                 suggestionsCallback: (pattern) {
//                   return LocationService.getSuggestions(pattern);
//                 },
//               )),
//         ),
//       ],
//     );
//   }
// }
class LocationSelectorField extends StatelessWidget {
  const LocationSelectorField({
    super.key,
    required this.icon,
    required this.title,
  });

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.white),
        SizedBox(width: 10),
        Expanded(
          child: Container(
            height: 40, // Set a fixed height for better visibility
            child: TextField(
              decoration: InputDecoration(
                hintText: title.toUpperCase(),
                hintStyle: TextStyle(
                    fontSize: 15.sp,
                    color: Colors.white,
                    fontFamily: "Roboto",
                    fontWeight: FontWeight.w500),
                // Change hint text color
                border: InputBorder.none,
                // Remove default border
                filled: true,
                fillColor: Colors.transparent,
                // Background color of the TextField
                contentPadding:
                    EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              ),
              style: TextStyle(color: Colors.white), // Change text color
            ),
          ),
        ),
      ],
    );
  }
}

class LobbyPopup extends StatelessWidget {
  final String lobbyId;

  LobbyPopup({required this.lobbyId});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0.0), side: BorderSide(width: 2)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Lobby ID',
              style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic),
            ),
            SizedBox(height: 10.0),
            Text(
              lobbyId,
              style: TextStyle(
                  fontSize: 18.sp,
                  color: Colors.black,
                  fontWeight: FontWeight.bold),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: lobbyId));
                      final snackBar = SnackBar(
                        content: Text('Lobby ID copied to clipboard!'),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    },
                    icon: Icon(
                      Icons.copy_sharp,
                      color: Colors.black,
                    )),
                IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.share_outlined,
                      color: Colors.black,
                    )),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class LocationService {
  static final List<String> _locations = [
    "New York",
    "Los Angeles",
    "San Francisco",
    "Chicago",
    "Houston",
    "Miami",
    // Add more locations here
  ];

  static List<String> getSuggestions(String query) {
    List<String> matches = [];
    matches.addAll(_locations);
    matches.retainWhere((s) => s.toLowerCase().contains(query.toLowerCase()));
    return matches;
  }
}
