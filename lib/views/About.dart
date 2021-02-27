import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vaccio/res/colors.dart' as colors;

class About extends StatelessWidget {
  Widget tile(String title, String subtitle, Function tap) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListTile(
        leading: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Container(
            child: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(FeatherIcons.user, color: Colors.black)),
            decoration: BoxDecoration(
              border: Border.all(color: colors.c4, width: 2.0),
              shape: BoxShape.circle,
            ),
          ),
        ),
        onTap: tap,
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: Colors.white,
          ),
          borderRadius: BorderRadius.circular(15.0),
        ),
        title: Text(
          "$title",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Text(
            "<$subtitle/>",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                text: 'Goal Diggers',
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
        body: Column(
          children: [
            tile("Ojas Karmarkar", "App Developer", () async {}),
            tile("Dhruv Gada", "App Developer", () async {}),
            tile("Rosita D'mello", "App Designer", () async {}),
            tile("Lokita Varma", "App Designer", () async {}),
            Expanded(
              child: Align(
                  alignment: FractionalOffset.bottomCenter,
                  child: Padding(
                      padding: EdgeInsets.only(bottom: 40.0),
                      child: Text(
                        "Made In ❤️ With India",
                        style: TextStyle(
                            fontSize: 20,
                            color: Colors.black,
                            fontWeight: FontWeight.bold),
                      ))),
            ),
          ],
        ));
  }
}
