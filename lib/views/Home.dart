import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:get/get.dart';
import 'package:vaccio/controller/AppController.dart';
import 'package:vaccio/controller/DataController.dart';
import 'package:vaccio/res/colors.dart' as colors;

import 'Nearby.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final dataController = Get.put(DataController());
  List<String> qs = [
    'Is it mandatory to take the vacine?',
    'Is it necessary for a COVID recovered person to take the vaccine?',
    'If one is taking medicines for illnesses like Cancer, Diabetes, Hypertension etc, can s/he take the COVID-19 vaccine?',
    'What documents should I carry while coming to the centre?',
    'What happens if I miss my scheduled appointment?'
  ];
  List<String> ans = [
    'Vaccination for COVID-19 is voluntary. However, it is advisable to receive the complete schedule of COVID-19 vaccine for protecting one-self against this disease and also to limit the spread of this disease to the close contacts including family members, friends, relatives and co-workers.',
    'Yes, it is advisable to receive complete schedule of COVID vaccine irrespective of past history of infection with COVID-19. This will help in developing a strong immune response against the disease.',
    'Yes. Persons with one or more of these comorbid conditions are considered high risk category. They need to get COVID-19 vaccination',
    'Adhar Card and the phone with which one, has registered. ',
    'You will have to follow the same booking procedure again; and you will receive a fresh booking number.'
  ];

  Widget _faq(String q, String a) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: ListTile(
        title: Padding(
          padding: EdgeInsets.only(bottom: 5),
          child: Text(
            "Q. $q",
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
          ),
        ),
        subtitle: Text("> $a"),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    dataController.fetchCentres();
  }

  final appController = Get.put(AppController());
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
              SizedBox(
                height: 50,
              ),
              Obx(() => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        appController.name.value ?? "Welcome!",
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                      appController.imgURl.value != null
                          ? Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                  width: 40.0,
                                  height: 40.0,
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      image: DecorationImage(
                                          fit: BoxFit.fill,
                                          image: NetworkImage(
                                              '${appController.imgURl.value}')))),
                            )
                          : CircleAvatar(
                              radius: 20,
                              backgroundColor: colors.c4,
                              backgroundImage:
                                  AssetImage('assets/images/logo.png'),
                              // backgroundImage: Image.asset(
                              //   'assets/images/logo.png',
                              //   height: 100,
                              //   width: 100,
                              // ),
                            ),
                    ],
                  )),
              Padding(
                  padding: EdgeInsets.only(top: 50.0, bottom: 5.0),
                  child: InkWell(
                    onTap: () {},
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
                              width: 50.0,
                              height: 90.0,
                              child: Icon(
                                FeatherIcons.info,
                                color: colors.c4,
                                size: 30,
                              ),
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              StreamBuilder(
                                stream: FirebaseFirestore.instance
                                    .collection("centres")
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  if (snapshot.data != null) {
                                    if (snapshot.data.docs != null &&
                                        snapshot.data.docs.isEmpty == false) {
                                      var count = snapshot.data.docs.length;

                                      return Text(
                                        "Vaccination Centres  :  $count",
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                      );
                                    } else {
                                      return Text(
                                        "Total Vaccination Centres : 0",
                                        style: TextStyle(
                                            color: Colors.black, fontSize: 18),
                                      );
                                    }
                                  } else {
                                    return Text(
                                      "Total Vaccination Centres : 0",
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 15),
                                    );
                                  }
                                },
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  )),
              InkWell(
                onTap: () {
                  Get.to(() => Nearby(
                      vaccineCentres: List.from(dataController.centres)));
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
                            width: 90.0,
                            height: 90.0,
                            child: Image.asset("assets/images/vaccine.jpg")),
                      ),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Click To See \nVaccine Centres Nearby!',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 30.0, left: 10),
                child: Text(
                  "FAQ's",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return _faq(qs[index], ans[index]);
                  },
                  itemCount: qs.length)
            ],
          ),
        ),
      ),
    );
  }
}
