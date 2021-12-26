import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Location location = new Location();
  StreamSubscription? _locationSub;

  late bool _serviceEnabled;
  late PermissionStatus _permissionGranted;
  LocationData? _locationData;
  GoogleMapController? _controller;

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(17.385044, 78.486671),
    zoom: 18,
  );

  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  late MarkerId markerId1;
  late Marker marker1;
  Set<Circle> circles = Set.from([Circle(
    circleId: CircleId("id"),
    center: LatLng(17.385044, 78.486671),
    radius: 4000,
  )]);

  @override
  void initState() {
    super.initState();
    markerId1 = MarkerId("Current");
    marker1 = Marker(
        markerId: markerId1,
        position: LatLng(17.385044, 78.486671),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: InfoWindow(
            title: "Hytech City", onTap: () {}, snippet: "Snipet Hitech City"));
    markers[markerId1] = marker1;
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Stack(
          children: [
            GoogleMap(
              mapType: MapType.hybrid,
              initialCameraPosition: _kGooglePlex,
              onMapCreated: (GoogleMapController controller) {
                _controller = controller;
              },
              markers: Set<Marker>.of(markers.values),
              circles: circles,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.location_searching),
        onPressed: () {
        getCurrentLocation();
      },

      ),
    );
  }

  void getCurrentLocation() async {
    try {
      var loc = await location.getLocation();
      update(loc);

      if (_locationSub != null) {
        _locationSub!.cancel();
      }

      _locationSub = location.onLocationChanged.listen((newloc) {
        if (_controller != null) {
          _controller!.animateCamera(CameraUpdate.newCameraPosition(
              new CameraPosition(
                  zoom: 18.00,
                  target: LatLng(
                      newloc.latitude as double, newloc.longitude as double))));
          update(loc);
        }
      });
    } on PlatformException catch (e) {
      print(e.message);
    }
  }

  void update(LocationData newlocationData) {
    LatLng latLng = LatLng(newlocationData.latitude as double,
        newlocationData.longitude as double);
    this.setState(() {
      marker1 = Marker(
          markerId: markerId1,
          position: latLng,
          flat: true,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: InfoWindow(
              title: "Hytech City",
              onTap: () {},
              snippet: "Snipet Hitech City"));
    });
  }
}
