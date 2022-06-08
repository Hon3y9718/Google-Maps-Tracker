import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:gmaptracker/MyMap.dart';
import 'package:location/location.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final Location location = Location();
  StreamSubscription<LocationData>? _localtionSubscription;
  final firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    location.changeSettings(interval: 300, accuracy: LocationAccuracy.high);
    location.enableBackgroundMode(enable: true);
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Live Location Tracker'),),
      body: Column(children: [
        TextButton(onPressed: (){
          _getLocation();
        }, child: const Text("add my location")),
        TextButton(onPressed: (){
          _listenLocation();
        }, child: const Text("enable live location")),
        TextButton(onPressed: (){
          _stopListening();
        }, child: const Text("stop live location")),
        Expanded(child: StreamBuilder(stream: FirebaseFirestore.instance.collection("location").snapshots(), builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if(!snapshot.hasData){
            return const Center(child: CircularProgressIndicator());
          }
          else{
            return ListView.builder(
              itemCount: snapshot.data?.docs.length,
              itemBuilder: (context, index){
              return ListTile(
                title: Text(snapshot.data.docs[index]['name'].toString()),
                subtitle: Row(children: [
                  Text(snapshot.data.docs[index]['lat'].toString()),
                  const SizedBox(width: 20,),
                  Text(snapshot.data.docs[index]['long'].toString()),
                ],),
                trailing: IconButton(icon: const Icon(Icons.directions), onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => MyMap(user_id: snapshot.data.docs[index].id,)));
                },),
              );
            },);
          }
        },))
      ],),
    );
  }

  _getLocation()async {
    try{
      final LocationData _locationResult = await location.getLocation();
      await firestore.collection('location').doc('user1').set({
        'lat': _locationResult.latitude, "long": _locationResult.longitude, 'name': 'Umesh'
      }, SetOptions(merge: true));
    } catch (e) {
      print(e);
    }
  }

  _listenLocation() async {
    _localtionSubscription = location.onLocationChanged.handleError((onError) {
      print(onError);
      _localtionSubscription?.cancel();
      setState(() {
        _localtionSubscription = null;
      });
    }).listen((LocationData currentLoc)async{
      await firestore.collection('location').doc('user1').set({
        'lat': currentLoc.latitude, "long": currentLoc.longitude, 'name': 'Umesh'
      }, SetOptions(merge: true));
    });
  }

  _stopListening() {
    _localtionSubscription?.cancel();
    setState(() {
      _localtionSubscription = null;
    });
  }
}

