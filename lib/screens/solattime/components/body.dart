import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:simple_waktu_solat/constants.dart';
import 'package:intl/intl.dart';
import 'package:adhan/adhan.dart';
import 'package:hijri/digits_converter.dart';
import 'package:hijri/hijri_array.dart';
import 'package:hijri/hijri_calendar.dart';

class TimeImage {
  final int id;
  final String image;
  final String timestart, timeend;

  TimeImage({this.id, this.timestart, this.timeend, this.image});
}

class Body extends StatefulWidget {
  Body({Key key}) : super(key: key);

  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  List<TimeImage> images = [
    TimeImage(
      id: 1,
      timestart: "6:00",
      timeend: "10:00",
      image: "assets/images/mountain.svg",
    ),
    TimeImage(
      id: 2,
      timestart: "10:00",
      timeend: "18:00",
      image: "assets/images/sun.svg",
    ),
    TimeImage(
      id: 3,
      timestart: "18:00",
      timeend: "19:30",
      image: "assets/images/sunset.svg",
    ),
    TimeImage(
      id: 4,
      timestart: "19:30",
      timeend: "23:59",
      image: "assets/images/moon.svg",
    ),
    TimeImage(
      id: 5,
      timestart: "00:00",
      timeend: "6:00",
      image: "assets/images/moon.svg",
    ),
  ];

  String _timeString = DateFormat.jm().format(DateTime.now());
  Position _currentPosition;
  String _currentAddress;
  final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
  String _prayerTimeFajr = "Loading..";
  String _prayerTimeZuhur = "Loading..";
  String _prayerTimeAsar = "Loading..";
  String _prayerTimeMaghrib = "Loading..";
  String _prayerTimeIsyak = "Loading..";
  String _prayerName;
  var _today = new HijriCalendar.now();

  @override
  void initState() {
    _timeString = _formatDateTime(DateTime.now());
    Timer.periodic(Duration(seconds: 1), (Timer t) => _getTime());
    Timer.periodic(Duration(seconds: 3), (Timer t) => _getCurrentLocation());
    super.initState();
  }

  @override
  void dispose() {
    var timer = Timer.periodic(Duration(seconds: 1), (Timer t) => _getTime());
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    DateFormat dateFormat = new DateFormat.Hm();
    String image = "Loading..";

    for (int i = 0; i < images.length; i++) {
      final now = new DateTime.now();
      DateTime starttime = dateFormat.parse(images[i].timestart);
      starttime = new DateTime(
          now.year, now.month, now.day, starttime.hour, starttime.minute);
      DateTime endtime = dateFormat.parse(images[i].timeend);
      endtime = new DateTime(
          now.year, now.month, now.day, endtime.hour, endtime.minute);

      if (now.isAfter(starttime) && now.isBefore(endtime)) {
        image = images[i].image;
      } else {
        continue;
      }
    }

    return SafeArea(
      bottom: false,
      child: Column(
        children: <Widget>[
          SizedBox(height: kDefaultPadding / 2),
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                Container(
                  margin:
                      EdgeInsets.only(top: 40, bottom: 90, left: 20, right: 20),
                  decoration: BoxDecoration(
                      color: kBackgroundColor,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(40),
                          topRight: Radius.circular(40),
                          bottomLeft: Radius.circular(40),
                          bottomRight: Radius.circular(40)),
                      boxShadow: [kDefaultShadow]),
                  child: Container(
                      alignment: AlignmentDirectional(0.0, 0.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            child: Center(
                              child: _currentAddress != null
                                  ? Text(_currentAddress,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                        color: kPrimaryColor,
                                      ))
                                  : CircularProgressIndicator(),
                            ),
                          ),
                          Container(
                            margin:
                                EdgeInsets.only(top: 30, left: 20, right: 20),
                            child: SvgPicture.asset(
                              image,
                              height: 130.0,
                            ),
                          ),
                          Container(
                            margin:
                                EdgeInsets.only(top: 30, left: 20, right: 20),
                            child: Center(
                              child: _prayerName != null
                                  ? Text(_prayerName,
                                      style: TextStyle(
                                        fontSize: 35,
                                        fontWeight: FontWeight.w800,
                                        color: kPrimaryColor,
                                      ))
                                  : CircularProgressIndicator(),
                            ),
                          ),
                          Container(
                            margin:
                                EdgeInsets.only(top: 5, left: 20, right: 20),
                            child: Center(
                              child: Text(_today.toFormat("MMMM dd, yyyy"),
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w400,
                                    color: kSecondaryColor,
                                  )),
                            ),
                          ),
                          Container(
                            margin:
                                EdgeInsets.only(top: 5, left: 20, right: 20),
                            child: Center(
                              child: Text(_timeString,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w400,
                                    color: kSecondaryColor,
                                  )),
                            ),
                          ),
                        ],
                      )),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _getTime() {
    final DateTime now = DateTime.now();
    final String formattedDateTime = _formatDateTime(now);
    setState(() {
      _timeString = formattedDateTime;
    });
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat.jms().format(dateTime);
  }

  _getCurrentLocation() {
    geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position position) {
      setState(() {
        _currentPosition = position;
      });
      _getAddressFromLatLng();
      _getPrayerTime();
    }).catchError((e) {
      print(e);
    });
  }

  _getAddressFromLatLng() async {
    try {
      List<Placemark> p = await geolocator.placemarkFromCoordinates(
          _currentPosition.latitude, _currentPosition.longitude);

      Placemark place = p[0];

      setState(() {
        _currentAddress = "${place.locality}, ${place.country}";
      });
    } catch (e) {
      print(e);
    }
  }

  _getPrayerTime() {
    final myCoordinates = Coordinates(_currentPosition.latitude,
        _currentPosition.longitude); // Replace with your own location lat, lng.
    final params = CalculationMethod.muslim_world_league.getParameters();
    params.madhab = Madhab.shafi;
    final prayerTimes = PrayerTimes.today(myCoordinates, params);

    setState(() {
      _prayerTimeFajr = DateFormat.jm().format(prayerTimes.fajr);
      _prayerTimeZuhur = DateFormat.jm().format(prayerTimes.dhuhr);
      _prayerTimeAsar = DateFormat.jm().format(prayerTimes.asr);
      _prayerTimeMaghrib = DateFormat.jm().format(prayerTimes.maghrib);
      _prayerTimeIsyak = DateFormat.jm().format(prayerTimes.isha);
    });
    _getPrayerName(
        _prayerTimeFajr,
        DateFormat.jm().format(prayerTimes.sunrise),
        _prayerTimeZuhur,
        _prayerTimeAsar,
        _prayerTimeMaghrib,
        _prayerTimeIsyak);
  }

  _getPrayerName(fajr, sunrise, zuhur, asar, maghrib, isyak) {
    final DateTime now = DateTime.now();
    DateFormat dateFormat = new DateFormat.jm();
    DateTime startFajr = dateFormat.parse(fajr);
    startFajr = new DateTime(
        now.year, now.month, now.day, startFajr.hour, startFajr.minute);
    DateTime startSunrise = dateFormat.parse(sunrise);
    startSunrise = new DateTime(
        now.year, now.month, now.day, startSunrise.hour, startSunrise.minute);
    DateTime startZuhur = dateFormat.parse(zuhur);
    startZuhur = new DateTime(
        now.year, now.month, now.day, startZuhur.hour, startZuhur.minute);
    DateTime startAsar = dateFormat.parse(asar);
    startAsar = new DateTime(
        now.year, now.month, now.day, startAsar.hour, startAsar.minute);
    DateTime startMaghrib = dateFormat.parse(maghrib);
    startMaghrib = new DateTime(
        now.year, now.month, now.day, startMaghrib.hour, startMaghrib.minute);
    DateTime startIsyak = dateFormat.parse(isyak);
    startIsyak = new DateTime(
        now.year, now.month, now.day, startIsyak.hour, startIsyak.minute);

    if (now.isAfter(startFajr) && now.isBefore(startSunrise)) {
      setState(() {
        _prayerName = "Fajr";
      });
    } else if (now.isAfter(startZuhur) && now.isBefore(startAsar)) {
      setState(() {
        _prayerName = "Zuhur";
      });
    } else if (now.isAfter(startAsar) && now.isBefore(startMaghrib)) {
      setState(() {
        _prayerName = "Asar";
      });
    } else if (now.isAfter(startMaghrib) && now.isBefore(startIsyak)) {
      setState(() {
        _prayerName = "Maghrib";
      });
    } else if (now.isAfter(startIsyak)) {
      setState(() {
        _prayerName = "Isyak";
      });
    } else {
      setState(() {
        _prayerName = "No current prayer";
      });
    }
  }
}
