import 'package:flutter/material.dart'; // Stores the Google Maps API Key
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:vaccio/res/colors.dart' as colors;

import 'dart:math' show cos, sqrt, asin;

import 'package:url_launcher/url_launcher.dart';

class MapView extends StatefulWidget {
  final String destination;

  const MapView({Key key, this.destination}) : super(key: key);
  @override
  _MapViewState createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  CameraPosition _initialLocation = CameraPosition(target: LatLng(0.0, 0.0));
  GoogleMapController mapController;
  Position _currentPosition;
  String _currentAddress;

  final startAddressController = TextEditingController();
  final destinationAddressController = TextEditingController();

  final startAddressFocusNode = FocusNode();
  final desrinationAddressFocusNode = FocusNode();

  String _startAddress = '';
  String _destinationAddress = '';
  String _placeDistance;
  BitmapDescriptor pinLocationIcon;
  Set<Marker> markers = {};
  double destLat = 0;
  double destlong = 0;
  final Set<Polyline> _polyline = {};
  PolylinePoints polylinePoints;
  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];

  void setCustomMapPin() async {
    pinLocationIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5),
        'assets/images/destination_map_marker.png');
    setState(() {});
  }

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  Widget _textField({
    TextEditingController controller,
    FocusNode focusNode,
    String label,
    String hint,
    double width,
    Icon prefixIcon,
    Widget suffixIcon,
    Function(String) locationCallback,
  }) {
    return Container(
      width: width * 0.8,
      child: TextField(
        onChanged: (value) {
          locationCallback(value);
        },
        controller: controller,
        focusNode: focusNode,
        decoration: new InputDecoration(
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(10.0),
            ),
            borderSide: BorderSide(
              color: Colors.grey[400],
              width: 2,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(10.0),
            ),
            borderSide: BorderSide(
              color: Colors.blue[300],
              width: 2,
            ),
          ),
          contentPadding: EdgeInsets.all(15),
          hintText: hint,
        ),
      ),
    );
  }

  // Method for retrieving the current location
  _getCurrentLocation() async {
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) async {
      setState(() {
        _currentPosition = position;
        print('CURRENT POS: $_currentPosition');
        mapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(position.latitude, position.longitude),
              zoom: 18.0,
            ),
          ),
        );
        _destinationAddress = widget.destination;
        destinationAddressController.text = widget.destination;
      });
      await _getAddress();
      await _calculateDistance();
    }).catchError((e) {
      print(e);
    });
  }

  _getAddress() async {
    try {
      List<Placemark> p = await placemarkFromCoordinates(
          _currentPosition.latitude, _currentPosition.longitude);

      Placemark place = p[0];

      setState(() {
        _currentAddress =
            "${place.name}, ${place.locality}, ${place.postalCode}, ${place.country}";
        startAddressController.text = _currentAddress;
        _startAddress = _currentAddress;
      });
    } catch (e) {
      print(e);
    }
  }

  Future<bool> _calculateDistance() async {
    try {
      List<Location> startPlacemark = await locationFromAddress(_startAddress);
      List<Location> destinationPlacemark =
          await locationFromAddress(_destinationAddress);

      if (startPlacemark != null && destinationPlacemark != null) {
        Position startCoordinates = _startAddress == _currentAddress
            ? Position(
                latitude: _currentPosition.latitude,
                longitude: _currentPosition.longitude)
            : Position(
                latitude: startPlacemark[0].latitude,
                longitude: startPlacemark[0].longitude);
        Position destinationCoordinates = Position(
            latitude: destinationPlacemark[0].latitude,
            longitude: destinationPlacemark[0].longitude);

        Marker startMarker = Marker(
          markerId: MarkerId('$startCoordinates'),
          position: LatLng(
            startCoordinates.latitude,
            startCoordinates.longitude,
          ),
          infoWindow: InfoWindow(
            title: 'Start',
            snippet: _startAddress,
          ),
          icon: BitmapDescriptor.defaultMarker,
        );

        // Destination Location Marker
        Marker destinationMarker = Marker(
            markerId: MarkerId('$destinationCoordinates'),
            position: LatLng(
              destinationCoordinates.latitude,
              destinationCoordinates.longitude,
            ),
            infoWindow: InfoWindow(
              title: 'Destination',
              snippet: _destinationAddress,
            ),
            icon: pinLocationIcon);

        // Adding the markers to the list
        markers.add(startMarker);
        markers.add(destinationMarker);

        print('START COORDINATES: $startCoordinates');
        print('DESTINATION COORDINATES: $destinationCoordinates');

        Position _northeastCoordinates;
        Position _southwestCoordinates;

        // Calculating to check that the position relative
        // to the frame, and pan & zoom the camera accordingly.
        double miny =
            (startCoordinates.latitude <= destinationCoordinates.latitude)
                ? startCoordinates.latitude
                : destinationCoordinates.latitude;
        double minx =
            (startCoordinates.longitude <= destinationCoordinates.longitude)
                ? startCoordinates.longitude
                : destinationCoordinates.longitude;
        double maxy =
            (startCoordinates.latitude <= destinationCoordinates.latitude)
                ? destinationCoordinates.latitude
                : startCoordinates.latitude;
        double maxx =
            (startCoordinates.longitude <= destinationCoordinates.longitude)
                ? destinationCoordinates.longitude
                : startCoordinates.longitude;

        _southwestCoordinates = Position(latitude: miny, longitude: minx);
        _northeastCoordinates = Position(latitude: maxy, longitude: maxx);

        mapController.animateCamera(
          CameraUpdate.newLatLngBounds(
            LatLngBounds(
              northeast: LatLng(
                _northeastCoordinates.latitude,
                _northeastCoordinates.longitude,
              ),
              southwest: LatLng(
                _southwestCoordinates.latitude,
                _southwestCoordinates.longitude,
              ),
            ),
            100.0,
          ),
        );
        double calculateDistance(lat1, lon1, lat2, lon2) {
          var p = 0.017453292519943295;
          var c = cos;
          var a = 0.5 -
              c((lat2 - lat1) * p) / 2 +
              c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
          return 12742 * asin(sqrt(a));
        }

        await _createPolylines(startCoordinates, destinationCoordinates);

        // double totalDistance = 0.0;

        // // Calculating the total distance by adding the distance
        // // between small segments
        // for (int i = 0; i < polylineCoordinates.length - 1; i++) {
        //   totalDistance += _coordinateDistance(
        //     polylineCoordinates[i].latitude,
        //     polylineCoordinates[i].longitude,
        //     polylineCoordinates[i + 1].latitude,
        //     polylineCoordinates[i + 1].longitude,
        //   );
        // }
        List<LatLng> latlng = [];
        LatLng _new =
            LatLng(startCoordinates.latitude, startCoordinates.longitude);
        LatLng _news = LatLng(
            destinationCoordinates.latitude, destinationCoordinates.longitude);
        destLat = destinationCoordinates.latitude;
        destlong = destinationCoordinates.longitude;
        latlng.add(_new);
        latlng.add(_news);

        _polyline.add(Polyline(
          polylineId: PolylineId("1235".toString()),
          visible: true,
          //latlng is List<LatLng>
          points: latlng,
          color: colors.c4,
        ));
        print(_polyline);

        // PolylinePoints polylinePoints = PolylinePoints();
        // PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        //     'AIzaSyABlyGL-kSWtDYa7Sjlji6CgkhCl-PsB7k', // Google Maps API Key
        //     PointLatLng(startCoordinates.latitude, startCoordinates.longitude),
        //     PointLatLng(destinationCoordinates.latitude,
        //         destinationCoordinates.longitude));
        // print(result.points);

        setState(() {
          _placeDistance = calculateDistance(
                  startCoordinates.latitude,
                  startCoordinates.longitude,
                  destinationCoordinates.latitude,
                  destinationCoordinates.longitude)
              .toStringAsFixed(0);
        });
        // setState(() {
        //   _placeDistance = totalDistance.toStringAsFixed(2);
        //   print('DISTANCE: $_placeDistance km');
        // });

        return true;
      }
    } catch (e) {
      print(e);
    }
    return false;
  }

  // Create the polylines for showing the route between two Vaccio Maps
  _createPolylines(Position start, Position destination) async {
    polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      'AIzaSyABlyGL-kSWtDYa7Sjlji6CgkhCl-PsB7k', // Google Maps API Key
      PointLatLng(start.latitude, start.longitude),
      PointLatLng(destination.latitude, destination.longitude),
      travelMode: TravelMode.transit,
    );
    print(result.points);
    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }

    PolylineId id = PolylineId('poly');
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.red,
      points: polylineCoordinates,
      width: 3,
    );
    polylines[id] = polyline;
  }

  @override
  void initState() {
    super.initState();
    setCustomMapPin();
    _getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Container(
      height: height,
      width: width,
      child: Scaffold(
        key: _scaffoldKey,
        body: Stack(
          children: <Widget>[
            // Map View
            GoogleMap(
              markers: markers != null ? Set<Marker>.from(markers) : null,
              initialCameraPosition: _initialLocation,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              mapType: MapType.normal,
              zoomGesturesEnabled: true,
              zoomControlsEnabled: false,
              polylines: _polyline,
              onMapCreated: (GoogleMapController controller) {
                mapController = controller;
              },
            ),
            // Show zoom buttons
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    ClipOval(
                      child: Material(
                        color: Colors.black, // button color
                        child: InkWell(
                          splashColor: Colors.blue, // inkwell color
                          child: SizedBox(
                            width: 50,
                            height: 50,
                            child: Icon(FeatherIcons.plus, color: Colors.white),
                          ),
                          onTap: () {
                            mapController.animateCamera(
                              CameraUpdate.zoomIn(),
                            );
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    ClipOval(
                      child: Material(
                        color: Colors.black, // button color
                        child: InkWell(
                          splashColor: Colors.blue, // inkwell color
                          child: SizedBox(
                            width: 50,
                            height: 50,
                            child: Icon(
                              Icons.remove,
                              color: Colors.white,
                            ),
                          ),
                          onTap: () {
                            mapController.animateCamera(
                              CameraUpdate.zoomOut(),
                            );
                          },
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            // Show the place input fields & button for
            // showing the route
            SafeArea(
              child: Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white70,
                      borderRadius: BorderRadius.all(
                        Radius.circular(20.0),
                      ),
                    ),
                    width: width * 0.9,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            'Vaccio Maps',
                            style: TextStyle(fontSize: 20.0),
                          ),
                          SizedBox(height: 10),
                          _textField(
                              label: 'Start',
                              hint: 'Choose starting point',
                              prefixIcon: Icon(Icons.looks_one),
                              suffixIcon: IconButton(
                                icon: Icon(Icons.my_location),
                                onPressed: () {
                                  startAddressController.text = _currentAddress;
                                  _startAddress = _currentAddress;
                                },
                              ),
                              controller: startAddressController,
                              focusNode: startAddressFocusNode,
                              width: width,
                              locationCallback: (String value) {
                                setState(() {
                                  _startAddress = value;
                                });
                              }),
                          SizedBox(height: 10),
                          _textField(
                              label: 'Vaccination Centre',
                              hint: 'Choose destination',
                              prefixIcon: Icon(Icons.looks_two),
                              controller: destinationAddressController,
                              focusNode: desrinationAddressFocusNode,
                              width: width,
                              locationCallback: (String value) {
                                setState(() {
                                  _destinationAddress = value;
                                });
                              }),
                          SizedBox(height: 10),
                          Visibility(
                            visible: _placeDistance == null ? false : true,
                            child: Text(
                              'Distance : $_placeDistance km',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(height: 5),
                          RaisedButton(
                            onPressed: (_startAddress != '' &&
                                    _destinationAddress != '')
                                ? () async {
                                    startAddressFocusNode.unfocus();
                                    desrinationAddressFocusNode.unfocus();
                                    setState(() {
                                      if (markers.isNotEmpty) markers.clear();
                                      if (polylines.isNotEmpty)
                                        polylines.clear();
                                      if (polylineCoordinates.isNotEmpty)
                                        polylineCoordinates.clear();
                                      _placeDistance = null;
                                    });

                                    _calculateDistance().then((isCalculated) {
                                      if (isCalculated) {
                                      } else {}
                                    });
                                  }
                                : null,
                            color: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'Show Distance',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20.0,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 5),
                          RaisedButton(
                            onPressed: (_startAddress != '' &&
                                    _destinationAddress != '')
                                ? () => showMaps()
                                : null,
                            color: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'Show in Maps',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20.0,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Show current location button
            SafeArea(
              child: Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 10.0, bottom: 10.0),
                  child: ClipOval(
                    child: Material(
                      color: Colors.black, // button color
                      child: InkWell(
                        splashColor: Colors.orange, // inkwell color
                        child: SizedBox(
                          width: 56,
                          height: 56,
                          child: Icon(
                            FeatherIcons.mapPin,
                            color: Colors.white,
                          ),
                        ),
                        onTap: () {
                          mapController.animateCamera(
                            CameraUpdate.newCameraPosition(
                              CameraPosition(
                                target: LatLng(
                                  _currentPosition.latitude,
                                  _currentPosition.longitude,
                                ),
                                zoom: 18.0,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showMaps() async {
    List<Location> startPlacemark = await locationFromAddress(_startAddress);
    List<Location> destinationPlacemark =
        await locationFromAddress(_destinationAddress);
    if (startPlacemark != null && destinationPlacemark != null) {
      Position startCoordinates = _startAddress == _currentAddress
          ? Position(
              latitude: _currentPosition.latitude,
              longitude: _currentPosition.longitude)
          : Position(
              latitude: startPlacemark[0].latitude,
              longitude: startPlacemark[0].longitude);
      Position destinationCoordinates = Position(
          latitude: destinationPlacemark[0].latitude,
          longitude: destinationPlacemark[0].longitude);
      String googleUrl =
          'https://www.google.com/maps/search/?api=1&query=${destinationCoordinates.latitude},${destinationCoordinates.longitude}';
      if (await canLaunch(googleUrl)) {
        await launch(googleUrl);
      } else {
        throw 'Could not open the map.';
      }
    }
  }
}
