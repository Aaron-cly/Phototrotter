import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:location/location.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CurrentUser extends ChangeNotifier {
  String _uid = 'B5aoQJ4bykgbdQ3THbvta2DXdWm2';
  String _email = 'test@gmail.com';
  String _username = 'testname';
  LocationData _location;
  String _locationName = "other";
  String _regionName = "other";
  String _locationId = "0";
  String _regionId = "0";

  String get getUid => _uid;

  String get getEmail => _email;

  String get getUsername => _username;

  LocationData get getLocation => _location;

  String get getLocationId => _locationId;

  String get getLocationName => _locationName;

  String get getRegionId => _regionId;

  String get getRegionName => _regionName;

  void updateLocationId(String locationId) {
    _locationId = locationId;
  }

  void updateRegionId(String regionId) {
    _regionId = regionId;
  }

  void updateLocationInfo(String locationName, String regionName) {
    this._locationName = locationName;
    this._regionName = regionName;

    FirebaseFirestore.instance
        .collection('locations')
        .where('location_name', isEqualTo: locationName)
        .limit(1)
        .get()
        .then((snapshot) {
      if (snapshot.docs.isNotEmpty)
        this._locationId = snapshot.docs[0]['lid'];
      else
        this._locationId = "other";
    });
    print(this._locationName);
    FirebaseFirestore.instance
        .collection('regions')
        .where('region_name', isEqualTo: regionName)
        .limit(1)
        .get()
        .then((snapshot) {
      if (snapshot.docs.isNotEmpty) this._regionId = snapshot.docs[0]['rid'];
    });
    print(this._regionName);
  }

  void updateLocation(LocationData newLocation) {
    LocationData locationData = LocationData.fromMap(
        {"latitude": newLocation.latitude, "longitude": newLocation.longitude});

    this._location = locationData;
  }

  void updateLocationName(String name) {
    _locationName = name;
  }

  void updateRegionName(String name) {
    _regionName = name;
  }

  FirebaseAuth _auth = FirebaseAuth.instance;

  // Register with new account
  // ignore: non_constant_identifier_names
  Future<bool> RegisterWithEmailAndPW(
      String email, String password, String username) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);

      _uid = result.user.uid;
      _email = email;
      _username = username;

      FirebaseFirestore.instance.collection("users").doc("$_uid").set({
        "email": _email,
        "event_participated": 0,
        "score": 0,
        "point": 0,
        "travelled_regions": {},
        "username": _username,
        "uid": _uid,
      });
      notifyListeners();
      return true;
    } catch (e) {
      // print(e.toString());
      return false;
    }
  }

  Future<bool> signinUser(String email, String password) async {
    bool returnVal = false;

    try {
      UserCredential _authResult = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      if (_authResult.user != null) {
        String uid = _authResult.user.uid;
        print("uid $uid");
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .get()
            .then((snapshot) {
          _username = snapshot.data()['username'];
          _uid = uid;
          _email = email;
          returnVal = true;
        });
      }
    } catch (e) {
      print(e);
    }
    notifyListeners();
    return returnVal;
  }

  Future<void> signOutUser() async {
    try {
      await _auth.signOut();
      print('signout');
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }
}
