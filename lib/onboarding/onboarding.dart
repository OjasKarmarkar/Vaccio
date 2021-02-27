import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vaccio/controller/AppController.dart';
import 'package:vaccio/views/mainscreen.dart';
import 'Data_Model.dart';
import 'OnBoard_page.dart';
import 'package:flutter/material.dart';
import 'package:vaccio/res/colors.dart' as colors;

class OnBoarding extends StatefulWidget {
  @override
  _OnBoardingState createState() => _OnBoardingState();
}

class _OnBoardingState extends State<OnBoarding> {
  final PageController pageController = PageController();
  final _currentPageNotifier = ValueNotifier<int>(0);
  SharedPreferences preferences;
  int selIndex = 1;
  final appController = Get.put(AppController());

  void init() async {
    preferences = await SharedPreferences.getInstance();
  }

  @override
  void initState() {
    init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: <Widget>[
          PageView.builder(
              controller: pageController,
              itemCount: onboardData.length + 1,
              itemBuilder: (BuildContext context, int index) {
                if (index == 2) {
                  return Padding(
                    padding: EdgeInsets.only(top: 80),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: colors.c4,
                          backgroundImage: AssetImage('assets/images/logo.png'),
                          // backgroundImage: Image.asset(
                          //   'assets/images/logo.png',
                          //   height: 100,
                          //   width: 100,
                          // ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 40.0),
                          child: Text(
                            "Please Login Before\nYou Start!",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 20.0),
                          child: Text(
                            "Log in & track your \nappointments from anywhere!",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
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
                              onPressed: () async {
                                final resp =
                                    await appController.signInWithGoogle();
                                if (resp == 1) {
                                  Get.off(() => MainScreen());
                                } else {
                                  Get.snackbar(
                                    "Firebase Error", // title
                                    "Please try again!", // message
                                    icon: Icon(FeatherIcons.alertTriangle),
                                    shouldIconPulse: true,

                                    barBlur: 20,
                                    isDismissible: true,
                                    duration: Duration(seconds: 3),
                                  );
                                }
                              },
                              child: Text(
                                'Login With Google',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 20),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                              top: 20.0, left: 20.0, right: 20.0),
                          child: Container(
                            height: 40,
                            width: double.infinity,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5)),
                            child: OutlineButton(
                              focusColor: Colors.white,
                              onPressed: () async {
                                final resp =
                                    await appController.signInWithGoogle();
                                if (resp == 1) {
                                  Get.off(() => MainScreen());
                                } else {
                                  Get.snackbar(
                                    "Firebase Error", // title
                                    "Please try again!", // message
                                    icon: Icon(FeatherIcons.alertTriangle),
                                    shouldIconPulse: true,

                                    barBlur: 20,
                                    isDismissible: true,
                                    duration: Duration(seconds: 3),
                                  );
                                }
                              },
                              child: Text(
                                'Sign Up With Google',
                                style: TextStyle(
                                    color: Colors.black, fontSize: 20),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                } else {
                  return OnBoardPage(
                    pageModel: onboardData[index],
                    pageController: pageController,
                  );
                }
              },
              onPageChanged: (int index) {
                setState(() {
                  _currentPageNotifier.value = index;
                });
              }),
          Visibility(
            visible: _currentPageNotifier.value == 2 ? false : true,
            child: Container(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.only(bottom: 20, top: 20),
                  child: DotsIndicator(
                    dotsCount: onboardData.length + 1,
                    position: _currentPageNotifier.value.toDouble(),
                    decorator: DotsDecorator(
                      activeColor: colors.c4,
                      size: const Size.square(9.0),
                      activeSize: const Size(18.0, 9.0),
                      activeShape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0)),
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
