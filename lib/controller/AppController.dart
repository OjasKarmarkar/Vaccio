import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppController extends GetxController {
  var index = 0.obs;
  RxString uID = ''.obs;
  SharedPreferences preferences;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  init() async {
    preferences = await SharedPreferences.getInstance();
  }

  @override
  void onInit() {
    init();
    getUID();
    super.onInit();
  }

  void navigate(int i) => index.value = i;

  void clearAll() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.clear().then((value) {
      exit(0);
    });
  }

  getUID() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    uID.value = preferences.getString('uID');
  }

  saveUser(String uID, String name) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    print(uID);
    await preferences.setString('uID', uID);
    await preferences.setString('name', name);
    await preferences.setBool('seen', true);
  }

  Future<int> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    // Create a new credential
    final GoogleAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Once signed in, return the UserCredential
    final UserCredential authResult =
        await FirebaseAuth.instance.signInWithCredential(credential);
    final User user = authResult.user;

    if (user != null) {
      print(user.uid);
      saveUser(user.uid, user.displayName);
      return 1;
    } else {
      return 0;
    }
  }

  Future<void> signOut() async {
    return Future.wait([
      FirebaseAuth.instance.signOut(),
      _googleSignIn.signOut(),
    ]);
  }
}
