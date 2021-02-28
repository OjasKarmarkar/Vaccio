import 'package:flutter/material.dart';

class Precautions extends StatefulWidget {
  @override
  _PrecautionsState createState() => _PrecautionsState();
}

class _PrecautionsState extends State<Precautions> {
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
            children: <Widget>[
              // Text(
              //   "Prevention",
              //   style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              // ),
              SizedBox(height: 50),
              Text(
                "Symptoms",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    InfoCard(
                      image: "assets/images/headache.png",
                      title: "Headache",
                      isActive: true,
                    ),
                    InfoCard(
                      image: "assets/images/caugh.png",
                      title: "Cough",
                    ),
                    InfoCard(
                      image: "assets/images/fever.png",
                      title: "Fever",
                    ),
                  ],
                ),
              ),
              Text(
                "Prevention",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              PreventCard(
                text:
                    "Since the start of the coronavirus outbreak some Vaccio Maps have fully embraced wearing facemasks",
                image: "assets/images/wear_mask.png",
                title: "Wear face mask",
              ),
              PreventCard(
                text:
                    "Washing your hands is a very simple but effective solution against covid-19",
                image: "assets/images/wash_hands.png",
                title: "Wash your hands",
              ),
              SizedBox(height: 50),
              Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(height: 20),
                        // Column(
                        //   children: [

                        //   ],
                        // ),
                      ]))
            ],
          ),
        ),
      ),
    );
  }
}

class PreventCard extends StatelessWidget {
  final String image;
  final String title;
  final String text;
  const PreventCard({
    Key key,
    this.image,
    this.title,
    this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: SizedBox(
        height: 156,
        child: Stack(
          alignment: Alignment.centerLeft,
          children: <Widget>[
            Container(
              height: 136,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                      offset: Offset(0, 8), blurRadius: 18, color: Colors.grey),
                ],
              ),
            ),
            Image.asset(image),
            Positioned(
              left: 130,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                height: 136,
                width: MediaQuery.of(context).size.width - 170,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      title,
                    ),
                    Expanded(
                      child: Text(
                        text,
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  final String image;
  final String title;
  final bool isActive;
  const InfoCard({
    Key key,
    this.image,
    this.title,
    this.isActive = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.white,
        boxShadow: [
          BoxShadow(offset: Offset(0, 8), blurRadius: 18, color: Colors.grey),
        ],
      ),
      child: Column(
        children: <Widget>[
          Image.asset(image, height: 90),
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
