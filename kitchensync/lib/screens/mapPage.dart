// ignore_for_file: unused_import, file_names, library_private_types_in_public_api, prefer_final_fields, prefer_const_constructors, sized_box_for_whitespace, no_leading_underscores_for_local_identifiers, avoid_print, prefer_const_literals_to_create_immutables, deprecated_member_use, use_build_context_synchronously

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kitchensync/backend/dataret.dart';
import 'package:kitchensync/styles/AppColors.dart';
import 'package:kitchensync/styles/AppFonts.dart';
import 'package:kitchensync/styles/size_config.dart';
import 'package:location/location.dart';
import 'package:quickalert/quickalert.dart';
import 'dart:async';
import 'dart:ui' as ui;

import 'package:url_launcher/url_launcher.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  Set<Marker> _markers = {};
  List<FoodBank> foodBanks = [];
  late GoogleMapController mapController;
  final Location location = Location();
  LatLng _currentLocation = LatLng(0, 0); // Default to zero
  bool _locationReady = false;

  @override
  void initState() {
    super.initState();
    _loadAndDisplayFoodBanks(37.77483, -122.41942);
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    var _locationData = await location.getLocation();
    print(
        "Current Location: ${_locationData.latitude}, ${_locationData.longitude}"); // This will show the fetched coordinates in the console

    setState(() {
      _currentLocation =
          LatLng(_locationData.latitude!, _locationData.longitude!);
      _locationReady = true;
      _loadAndDisplayFoodBanks(
          _currentLocation.latitude, _currentLocation.longitude);
    });
  }

  Future<void> _loadAndDisplayFoodBanks(
      double latitude, double longitude) async {
    foodBanks = await FoodBank.fetchFoodBanks(latitude, longitude);
    print(
        "Food Banks Loaded: ${foodBanks.length}"); // Check how many were loaded
    setState(() {
      _markers.clear();
      for (final bank in foodBanks) {
        print(
            "Adding Marker for: ${bank.name}, at ${bank.latitude}, ${bank.longitude}"); // Verify each marker's data
        _markers.add(
          Marker(
            markerId: MarkerId(bank.name),
            position: LatLng(bank.latitude, bank.longitude),
            infoWindow: InfoWindow(title: bank.name, snippet: bank.address),
          ),
        );
      }
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    _moveCameraToCurrentUserLocation();
  }

  void _moveCameraToCurrentUserLocation() {
    if (_currentLocation.latitude != 0.0 && _currentLocation.longitude != 0.0) {
      mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: _currentLocation,
            zoom: 14.0,
          ),
        ),
      );
    } else {
      print("Default location is being used.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        Container(
            height: propHeight(980),
            width: propWidth(600),
            child: _locationReady
                ? GoogleMap(
                    mapType: MapType.normal,
                    onMapCreated: _onMapCreated,
                    compassEnabled: true,
                    liteModeEnabled: false,
                    myLocationButtonEnabled: true,
                    initialCameraPosition: CameraPosition(
                      target:
                          _currentLocation, // Updated to use _currentLocation
                      zoom: 14.0,
                    ),
                    markers: _markers,
                  )
                : loadingIndicator()),
        _locationReady
            ? Positioned(
                bottom: 0,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: propHeight(400),
                    width: propWidth(430),
                    child: DraggableScrollableSheet(
                      expand: false,
                      snap: true,
                      snapAnimationDuration: Duration(milliseconds: 50),
                      builder: (context, scrollController) {
                        return Container(
                          decoration: BoxDecoration(
                            color: AppColors.light,
                            borderRadius:
                                BorderRadius.vertical(top: Radius.circular(16)),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.minimize_rounded,
                                    size: 30,
                                    color: AppColors.dark,
                                  )
                                ],
                              ),
                              Expanded(
                                child: ListView.builder(
                                  physics: BouncingScrollPhysics(),
                                  controller: scrollController,
                                  itemCount: foodBanks.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return Card(
                                      color: AppColors.primary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(17.0),
                                      ),
                                      child: ListTile(
                                        leading: Image.asset(
                                          'assets/images/Nav.png',
                                          width: propWidth(35),
                                          height: propHeight(35),
                                        ),
                                        title: Text(
                                          foodBanks[index].name,
                                          style: AppFonts.locCard,
                                        ),
                                        subtitle: Text(
                                          foodBanks[index].address,
                                          style: AppFonts.locSub,
                                        ),
                                        onTap: () {
                                          final url = _createGoogleMapsUrl(
                                              foodBanks[index].latitude,
                                              foodBanks[index].longitude);
                                          QuickAlert.show(
                                            context: context,
                                            type: QuickAlertType.confirm,
                                            title: foodBanks[index].name,
                                            backgroundColor: AppColors.light,
                                            cancelBtnText: 'No',
                                            text:
                                                "Address: ${foodBanks[index].address}",
                                            confirmBtnText: "Navigate!",
                                            barrierDismissible: true,
                                            confirmBtnColor: AppColors.primary,
                                            confirmBtnTextStyle:
                                                AppFonts.numbers,
                                            animType:
                                                QuickAlertAnimType.slideInUp,
                                            onConfirmBtnTap: () async {
                                              if (await canLaunch(url)) {
                                                await launch(url);
                                              } else {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(SnackBar(
                                                        backgroundColor:
                                                            Colors.red,
                                                        content: Text(
                                                          "Could not open the map.",
                                                          style:
                                                              AppFonts.locCard,
                                                        )));
                                              }
                                            },
                                          );
                                          // showDialog(
                                          //   context: context,
                                          //   builder: (context) =>
                                          //       BackdropFilter(
                                          //     filter: ui.ImageFilter.blur(
                                          //         sigmaX: 5, sigmaY: 5),
                                          //     child: AlertDialog(
                                          //       shape:
                                          //           ContinuousRectangleBorder(
                                          //               borderRadius:
                                          //                   BorderRadius
                                          //                       .circular(
                                          //                           propWidth(
                                          //                               17))),
                                          //       backgroundColor:
                                          //           AppColors.light,
                                          //       title:
                                          //           Text(foodBanks[index].name),
                                          //       content: Text(
                                          //           "Address: ${foodBanks[index].address}"),
                                          //       actions: [
                                          //         TextButton(
                                          //             child: Text('Navigate'),
                                          //             onPressed: () {}),
                                          //         TextButton(
                                          //           child: Text('Cancel',
                                          //               style: TextStyle(
                                          //                   color:
                                          //                       AppColors.red)),
                                          //           onPressed: () =>
                                          //               Navigator.of(context)
                                          //                   .pop(true),
                                          //         ),
                                          //       ],
                                          //     ),
                                          //   ),
                                          // );
                                        },
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              )
            : loadingIndicator(),
        Positioned(
          top: propHeight(30), // Adjust this value to position it as needed
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              SizedBox(
                width: propWidth(15),
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Image.asset(
                  'assets/images/Prvs.png',
                  height: propHeight(35),
                  color: AppColors.dark,
                  width: propWidth(35),
                ),
              ),
              Expanded(child: Container()),
              Text(
                "KitchenSync",
                textAlign: TextAlign.center,
                style: AppFonts.appname,
              ),
              SizedBox(
                width: propWidth(15),
              )
            ],
          ),
        ),
      ]),
    );
  }
}

String _createGoogleMapsUrl(double lat, double lng) {
  // Creates a URL that opens Google Maps with directions to the given coordinates
  return 'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving';
}

Widget loadingIndicator() {
  return Center(
    child: Stack(
      alignment: Alignment.center,
      children: [
        CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          strokeCap: StrokeCap.round,
          strokeWidth: 8,
          backgroundColor: Colors.grey[300],
        ),
        CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.green),
          strokeWidth: 4,
          strokeCap: StrokeCap.round,
        ),
      ],
    ),
  );
}
