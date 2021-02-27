import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vaccio/controller/AppController.dart';
import 'package:vaccio/controller/DataController.dart';
import 'package:vaccio/res/colors.dart' as colors;

class BookAppointment extends StatefulWidget {
  final Map centre;

  const BookAppointment({Key key, this.centre}) : super(key: key);
  @override
  _BookAppointmentState createState() => _BookAppointmentState();
}

class _BookAppointmentState extends State<BookAppointment> {
  final dataController = Get.put(DataController());
  final format = DateFormat("yyyy-MM-dd HH:mm");
  DateTime dateTime;
  final appController = Get.put(AppController());
  final TextEditingController _aadharController = new TextEditingController();

  openMap(LatLng lng) async {
    double latitude = lng.latitude;
    double longitude = lng.longitude;
    String googleUrl =
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    if (await canLaunch(googleUrl)) {
      await launch(googleUrl);
    } else {
      throw 'Could not open the map.';
    }
  }

  Widget _info(String q, String a, Icon icon, Function tap) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: ListTile(
        onTap: tap,
        title: Padding(
          padding: EdgeInsets.only(bottom: 5),
          child: Text(
            "$q",
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
          ),
        ),
        subtitle: Text("> $a"),
        trailing: icon,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        floatingActionButton: Container(
          height: 55.0,
          width: 55.0,
          child: FloatingActionButton(
            heroTag: "l",
            backgroundColor: colors.c4,
            onPressed: () async {
              if (dateTime != null &&
                  _aadharController.text != null &&
                  _aadharController.text.length == 12) {
                double lat = widget.centre['location'].latitude;
                double long = widget.centre['location'].longitude;
                String uid = appController.uID.value;
                int persons = 1;
                String aadhar = _aadharController.text;

                dataController.bookappt(lat, long, uid, dateTime, persons , aadhar);
              } else {
                Get.snackbar('Error', "Please fill all the fields");
              }
            },
            child: Icon(
              FeatherIcons.check,
              color: Colors.white,
            ),
          ),
        ),
        backgroundColor: Colors.white,
        appBar: AppBar(
          brightness: Brightness.light,
          backgroundColor: Colors.white,
          elevation: 0.0,
          leading: Padding(
            padding: const EdgeInsets.only(bottom: 2.0),
            child: IconButton(
                splashColor: Colors.transparent,
                icon: Icon(
                  FeatherIcons.chevronLeft,
                  color: Colors.black,
                  size: 24,
                ),
                onPressed: () {
                  Get.back();
                }),
          ),
          title: Padding(
            padding: const EdgeInsets.all(8.0),
            child: RichText(
              text: TextSpan(
                text: 'New Appointment',
                style: GoogleFonts.poppins(
                    textStyle: TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                        fontWeight: FontWeight.w400)),
              ),
            ),
          ),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              _info(
                  'Centre Name',
                  widget.centre['name'],
                  Icon(
                    FeatherIcons.loader,
                    color: colors.c4,
                  ),
                  () {}),
              _info(
                  'Location',
                  'Click to view in Maps',
                  Icon(
                    FeatherIcons.mapPin,
                    color: colors.c4,
                  ),
                  () => openMap(widget.centre['location'])),
              _info(
                  'Contact',
                  widget.centre['contact'],
                  Icon(
                    FeatherIcons.phoneCall,
                    color: colors.c4,
                  ), () async {
                var no = widget.centre['contact'];
                var url = "tel:$no";
                if (await canLaunch(url)) {
                  await launch(url);
                } else {
                  throw 'Could not launch $url';
                }
              }),
              Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 10.0, horizontal: 10.0),
                child: DateTimeField(
                  decoration: InputDecoration(
                    suffixIcon: Icon(
                      FeatherIcons.calendar,
                      color: colors.c4,
                    ),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.red, //this has no effect
                      ),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    hintText: "Pick Appointment Time",
                  ),
                  format: format,
                  onShowPicker: (context, currentValue) async {
                    dateTime = currentValue;
                    final date = await showDatePicker(
                        context: context,
                        firstDate: DateTime.now(),
                        initialDate: currentValue ?? DateTime.now(),
                        lastDate: DateTime(2100));
                    if (date != null) {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(
                            currentValue ?? DateTime.now()),
                      );
                      return DateTimeField.combine(date, time);
                    } else {
                      return currentValue;
                    }
                  },
                  onChanged: (currentValue) {
                    dateTime = currentValue;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 10.0, horizontal: 10.0),
                child: TextField(
                  controller: _aadharController,
                  decoration: InputDecoration(
                    suffixIcon: Icon(
                      FeatherIcons.user,
                      color: colors.c4,
                    ),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.red, //this has no effect
                      ),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    hintText: "Aadhar No.",
                  ),
                ),
              )
            ],
          ),
        ));
  }
}
