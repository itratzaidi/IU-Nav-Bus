import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:iu_nav_bus/fireAuth_service.dart';
import 'package:iu_nav_bus/main.dart';
import 'package:iu_nav_bus/notification_service.dart';
import 'package:url_launcher/url_launcher.dart';

String currentUserID = "";
String currentUserEmail = "";
String currentUserName = "";
LatLng randomDriverLocation = LatLng(32, 32);

String studentWhereToLoc = "";

LatLng studentWhereTOLatLong = LatLng(32, 32);

String studentFromLoc = "";

LatLng studentFromLatLng = LatLng(32, 32);

String uniName = "Iqra University North Campus";
LatLng uniLatLng = const LatLng(24.9737, 67.0468);
LatLng upmoreLatLng = const LatLng(24.9728, 67.0668);
LatLng sakhiHassan = const LatLng(24.9540, 67.0576);
LatLng twokbustop = const LatLng(24.9490, 67.0529);
LatLng naganChowrangi = const LatLng(24.9665, 67.0671);
LatLng bufferzone = const LatLng(24.9571, 67.0678);
LatLng sohrabgoth = const LatLng(24.9450, 67.0857);
LatLng gulshanchowrangi = const LatLng(24.9219, 67.0941);
LatLng nipa = const LatLng(24.9176, 67.0970);
LatLng ancholi = const LatLng(24.9454, 67.0772);
LatLng waterpump = const LatLng(24.9338, 66.9561);
LatLng naseerabad = const LatLng(24.9307, 67.0718);
LatLng ayeshamanzil = const LatLng(24.9273, 67.0646);
LatLng karimabad = const LatLng(24.9195, 67.0591);
LatLng federalurduuniversity = const LatLng(24.9112, 67.0894);
LatLng banapalace = const LatLng(24.9230, 67.0578);
LatLng baitulmukarammasjid = const LatLng(24.9066, 67.0827);
LatLng hassansquare = const LatLng(24.9025, 67.0729);
LatLng saghircenter = const LatLng(24.9371, 67.0844);
LatLng hyderi = const LatLng(24.9368, 67.0431);
LatLng kda = const LatLng(24.9557, 67.1127);
LatLng dilpasand = const LatLng(24.9456, 67.1464);
LatLng nazimabadnovii = const LatLng(24.9185, 67.0312);
LatLng baqaihospital = const LatLng(24.91588993250238, 67.03585589175186);
LatLng nazimabadpetrolpump = const LatLng(24.9103, 67.0318);
LatLng inquiryoffice = const LatLng(24.9064, 67.0310);
LatLng nazimabadchowrangi = const LatLng(24.9010, 67.0299);
LatLng powerstation = const LatLng(24.8453, 66.7889);
LatLng fiveStarChowrangi = const LatLng(24.9459, 67.0504);
List<String> stopsList = [
  "UP More",
  "Sakhi Hassan",
  "2k Bus Stop",
  "Nagan Chowrangi",
  "Buffer Zone",
  "Sohrab Goth",
  "Gulshan Chowrangi",
  "NIPA",
  "Ancholi",
  "Water Pump",
  "Naseerabad",
  "Ayesha Manzil",
  "Karimabad",
  "Federal Urdu University",
  "Bana Palace",
  "Bait-ul-Mukaram Majid",
  "Hassan Square",
  "Saghir Center",
  "Hyderi",
  "KDA",
  "Dilpasand",
  "Nazimabad No. VII",
  "Baqai Hospital",
  "Nazimabad Petrol Pump",
  "Inquiry Office",
  "Nazimabad Chowrangi",
  "Power Station",
  "Five Star Chowrangi"
];
List<LatLng> stops = [
  upmoreLatLng,
  sakhiHassan,
  twokbustop,
  naganChowrangi,
  bufferzone,
  sohrabgoth,
  gulshanchowrangi,
  nipa,
  ancholi,
  waterpump,
  naseerabad,
  ayeshamanzil,
  karimabad,
  federalurduuniversity,
  banapalace,
  baitulmukarammasjid,
  hassansquare,
  saghircenter,
  hyderi,
  kda,
  dilpasand,
  nazimabadnovii,
  baqaihospital,
  nazimabadpetrolpump,
  inquiryoffice,
  nazimabadchowrangi,
  powerstation,
  fiveStarChowrangi
];
List<LatLng> redRouteLatLng = [
  upmoreLatLng,
  naganChowrangi,
  bufferzone,
  powerstation,
  sohrabgoth,
  saghircenter,
  gulshanchowrangi,
  nipa,
  federalurduuniversity,
  baitulmukarammasjid,
  hassansquare
];
List<String> redRoute = [
  "UP More",
  "Nagan Chowrangi",
  "Buffer Zone",
  "Power Station",
  "Sohrab Goth",
  "Saghir Center",
  "Gulshan Chowrangi",
  "NIPA",
  "Federal Urdu University",
  "Bait-ul-Mukaram Majid",
  "Hassan Square",
];

List<LatLng> blueRouteLatLng = [
  upmoreLatLng,
  naganChowrangi,
  sakhiHassan,
  twokbustop,
  fiveStarChowrangi,
  hyderi,
  kda,
  dilpasand,
  nazimabadnovii,
  baqaihospital,
  nazimabadpetrolpump,
  inquiryoffice,
  nazimabadchowrangi
];
List<String> blueRoute = [
  "UP More",
  "Nagan Chowrangi",
  "Sakhi Hassan",
  "2k Bus Stop",
  "Five Star",
  "Hyderi",
  "KDA",
  "Dilpasand",
  "Nazimabad No. VII",
  "Baqai Hospital",
  "Nazimabad Petrol Pump",
  "Inquiry Office",
  "Nazimabad Chowrangi",
];

List<LatLng> greenRouteLatLng = [
  upmoreLatLng,
  naganChowrangi,
  bufferzone,
  powerstation,
  sohrabgoth,
  ancholi,
  waterpump,
  naseerabad,
  ayeshamanzil,
  banapalace,
  karimabad,
];
List<String> greenRoute = [
  "UP More",
  "Nagan Chowrangi",
  "Buffer Zone",
  "Power Station",
  "Sohrab Goth",
  "Ancholi",
  "Water Pump",
  "Naseerabad",
  "Ayesha Manzil",
  "Bana Palace",
  "Karimabad",
];

List<Map<String, dynamic>> onlineUsers = [];
int totalOnlineUser = 0;
List<Map<String, dynamic>> onlineDrivers = [];

void updateUserStatus(BuildContext context, String status) {
  var user = supabase.auth.currentUser;

  if (user != null) {
    var email = supabase.auth.currentUser!.email;
    updateUserStatusOnFireStore(
      context,
      status,
      email!,
    );
  }
}

String selectedDriverName = "";
double selectedDriverLat = 0;
double selectedDriverLng = 0;
String selectedDriverDistance = "";
String selectedDriverArrivalTime = "";
List<String> adsUrls = [];
String ad1 = "";
String ad2 = "";
String ad3 = "";

showBasicNotification(String title, String body) async {
  await NotificationService.showNotification(
    title: title,
    body: body,
  );
}

void launchURL(String url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}
