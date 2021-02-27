import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:vaccio/views/mainscreen.dart';

class DataController extends GetxController {
  RxList<Map> centres = RxList();

  void fetchCentres() async {
    var snapshot = await FirebaseFirestore.instance.collection("centres").get();
    if (snapshot != null)
      snapshot.docs.forEach((element) {
        LatLng latlng = new LatLng(
            element['location'].latitude, element['location'].longitude);
        centres.add({
          'location': latlng,
          'name': element['name'],
          'contact': element['contact'],
          'vaccines': element['vaccines']
        });
      });
    update();
  }

  void bookappt(double lat, double long, String uid, DateTime time, int persons,
      String aadhar) async {
    FirebaseFirestore.instance.collection("appointments").add({
      "place": GeoPoint(lat, long),
      "uID": uid,
      "timings": time,
      "persons": persons,
      "aadhar": aadhar
    }).then((value) {
      Get.off(MainScreen());
    }).catchError((e) => {});
  }
}
