import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geocoder/geocoder.dart';
import 'package:intl/intl.dart';
import 'package:vaccio/res/colors.dart' as colors;
import 'dart:core';
import 'package:vaccio/controller/AppController.dart';
import 'package:get/get.dart';
import 'package:vaccio/views/MapView.dart';

class Appointments extends StatefulWidget {
  @override
  _AppointmentsState createState() => _AppointmentsState();
}

class _AppointmentsState extends State<Appointments> {
  final appController = Get.put(AppController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 50,
                ),
                Text(
                  "Appointments",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection("appointments")
                      .where('uID', isEqualTo: appController.uID.value)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.data != null) {
                      if (snapshot.data.docs != null &&
                          snapshot.data.docs.isEmpty == false) {
                        print(snapshot.data.docs.isEmpty);
                        final documents = snapshot.data.docs;
                        return Container(
                          child: ListView.builder(
                            itemBuilder: (BuildContext context, int index) {
                              return AppointmentCard(
                                text: documents[index]['timings'],
                                gp: documents[index]['place'],
                                persons: documents[index]['persons'].toString(),
                              );
                            },
                            itemCount: documents.length,
                            shrinkWrap: true,
                          ),
                        );
                      } else {
                        return Padding(
                          padding: EdgeInsets.only(top: 100.0),
                          child: Center(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                new SvgPicture.asset(
                                  "assets/images/mask-man.svg",
                                  height: 300,
                                  fit: BoxFit.fitWidth,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 20.0),
                                  child:
                                      Text("You don't have any appointments!"),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                      top: 50.0, left: 20.0, right: 20.0),
                                  child: Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                        color: Colors.black,
                                        borderRadius: BorderRadius.circular(5)),
                                    child: OutlineButton(
                                      onPressed: () async {},
                                      child: Text(
                                        'Book one now!',
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 20),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                    } else {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                          child: new SvgPicture.asset(
                            "assets/images/mask-man.svg",
                            height: 300,
                            fit: BoxFit.fitWidth,
                          ),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ));
  }
}

class AppointmentCard extends StatefulWidget {
  final GeoPoint gp;
  final Timestamp text;
  final String persons;
  const AppointmentCard({Key key, this.gp, this.text, this.persons})
      : super(key: key);

  @override
  _AppointmentCardState createState() => _AppointmentCardState();
}

class _AppointmentCardState extends State<AppointmentCard> {
  String place = '', addressline = '';
  String formatDate(var date) {
    DateTime myDateTime = (date).toDate();
    return DateFormat.yMMMd().add_jm().format(myDateTime).toString();
  }

  Future<String> _getLocation() async {
    GeoPoint geoPoint = widget.gp;
    final coordinates = new Coordinates(geoPoint.latitude, geoPoint.longitude);
    var addresses =
        await Geocoder.local.findAddressesFromCoordinates(coordinates);
    var first = addresses.first;
    print("${first.locality}");
    return first.locality;
  }

  void finalPlace() {
    _getLocation().then((value) {
      setState(() {
        place = value;
      });
    });
    print(place);
  }

  @override
  void initState() {
    finalPlace();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(top: 5.0, bottom: 5.0),
        child: InkWell(
          onTap: () {
            Get.to(MapView(destination:place));
          },
          child: Card(
            elevation: 10,
            shape: BeveledRectangleBorder(
              borderRadius: BorderRadius.circular(5.0),
            ),
            child: Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    width: 80.0,
                    height: 80.0,
                    child: Icon(
                      FeatherIcons.calendar,
                      color: colors.c4,
                      size: 30,
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "Place : " + place,
                      style: TextStyle(color: Colors.black, fontSize: 15),
                    ),
                    Text(
                      "Timings : " + formatDate(widget.text),
                      style: TextStyle(color: Colors.black, fontSize: 15),
                    ),
                    Text(
                      "People : " + widget.persons,
                      style: TextStyle(color: Colors.black, fontSize: 15),
                    )
                  ],
                )
              ],
            ),
          ),
        ));
  }
}
