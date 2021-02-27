import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vaccio/controller/AppController.dart';
import 'package:vaccio/onboarding/onboarding.dart';

import 'About.dart';

class Settings extends StatelessWidget {
  final appController = Get.put(AppController());
  Widget settingsTile(String title, Function tap) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: ListTile(
        onTap: tap,
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: Colors.white,
          ),
          borderRadius: BorderRadius.circular(15.0),
        ),
        title: Text(
          "$title",
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
        ),
        trailing: Icon(FeatherIcons.chevronRight, color: Colors.black),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 50),
              Text(
                "App Settings",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              settingsTile("About Us", () {
                Get.to(() => About());
              }),
              settingsTile("Donate A Coffee", () async {
                const url = "https://www.paypal.com/paypalme/ojask002";
                if (await canLaunch(url)) {
                  await launch(url);
                } else {
                  throw 'Could not launch $url';
                }
              }),
              settingsTile("Support / Updates", () async {
                const url = 'https://wa.me/919167403295';
                if (await canLaunch(url)) {
                  await launch(url);
                } else {
                  throw 'Could not launch $url';
                }
              }),
              settingsTile("Email Us", () async {
                const url = 'mailto:ojask2002@gmail.com';
                if (await canLaunch(url)) {
                  await launch(url);
                } else {
                  throw 'Could not launch $url';
                }
              }),
              Padding(
                padding: EdgeInsets.only(top: 50.0, left: 20.0, right: 20.0),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(5)),
                  child: OutlineButton(
                    onPressed: () async {
                      appController.signOut().then((value) {
                        Get.off(() => OnBoarding());
                      });
                    },
                    child: Text(
                      'Log Out',
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20.0, 20.0, 0, 10),
                child: Text(
                  "App Version - 1B - Beta",
                  style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
