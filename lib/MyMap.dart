import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gmaptracker/models/Directions.dart';
import 'package:gmaptracker/models/directionsRepo.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

import 'SS.dart';

class MyMap extends StatefulWidget {
  const MyMap({Key? key, required this.user_id}) : super(key: key);

  final user_id;

  @override
  State<MyMap> createState() => _MyMapState();
}

class _MyMapState extends State<MyMap> {
  final location = Location();
  var _info;
  late GoogleMapController _controller;
  bool _added = false;
  final firestore = FirebaseFirestore.instance;
  var lat = 28.7005;
  var long = 77.2592;
  var repo = DirectionRepo();

  late List<LatLng> polylines;

  setLocation() async {
    final LocationData _locationData = await location.getLocation();
    lat = _locationData.latitude!;
    long = _locationData.longitude!;
  }

  @override
  void initState() {
    setLocation();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection("location").snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (_added) {
            mymap(snapshot);
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          } else {
            return GoogleMap(
              mapType: MapType.hybrid,
              polylines: {
                if (_info != null)
                  Polyline(
                    polylineId: PolylineId("1"),
                    visible: true,
                    points: polylines,
                    color: Colors.red,
                    width: 5,
                  ),
              },
              markers: {
                Marker(
                    position: LatLng(
                      snapshot.data?.docs.singleWhere(
                          (element) => element.id == widget.user_id)['lat'],
                      snapshot.data?.docs.singleWhere(
                          (element) => element.id == widget.user_id)['long'],
                    ),
                    markerId: MarkerId('id'),
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueMagenta)),
                Marker(
                    position: LatLng(lat, long),
                    markerId: MarkerId('mylocation'),
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueRed))
              },
              initialCameraPosition: CameraPosition(
                  target: LatLng(
                    snapshot.data?.docs.singleWhere(
                        (element) => element.id == widget.user_id)['lat'],
                    snapshot.data?.docs.singleWhere(
                        (element) => element.id == widget.user_id)['long'],
                  ),
                  zoom: 100),
              onMapCreated: (GoogleMapController controller) async {
                setState(() {
                  _controller = controller;
                  _added = true;
                });
              },
            );
          }
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () async {
              final uin8list = await _controller.takeSnapshot();
              print("Image Taken");
              final image = Image.memory(
                uin8list!,
                fit: BoxFit.cover,
              );
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SS(
                            image: image,
                          )));
            },
            child: const Icon(Icons.add_a_photo),
          ),
          const SizedBox(
            height: 10,
          ),
          FloatingActionButton(
            child: const Icon(Icons.my_location),
            onPressed: () async {
              final LocationData _locationResult = await location.getLocation();
              setState(() {
                lat = _locationResult.latitude!;
                long = _locationResult.longitude!;
                _controller.animateCamera(CameraUpdate.newCameraPosition(
                    CameraPosition(target: LatLng(lat, long), zoom: 14.47)));
              });
            },
          ),
        ],
      ),
    );
  }

  mymap(AsyncSnapshot<QuerySnapshot> snapshot) async {
    Directions _dir = await repo.getDirections(
        org: LatLng(
          snapshot.data?.docs
              .singleWhere((element) => element.id == widget.user_id)['lat'],
          snapshot.data?.docs
              .singleWhere((element) => element.id == widget.user_id)['long'],
        ),
        dest: LatLng(lat, long));

    _info = _dir;

    setState(() {
      polylines = _dir.polylinePoints
          .map((e) => LatLng(e.latitude, e.longitude))
          .toList();
    });
    await _controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
            target: LatLng(
              snapshot.data?.docs.singleWhere(
                  (element) => element.id == widget.user_id)['lat'],
              snapshot.data?.docs.singleWhere(
                  (element) => element.id == widget.user_id)['long'],
            ),
            zoom: 14),
      ),
    );
  }
}
