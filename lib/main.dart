import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:geolocator/geolocator.dart';

void main() async {
  await GetStorage.init();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List _position = [];
  @override
  void initState() {
    super.initState();
    if (box.read('positionList') == null) {
      box.write('positionList', _position);
    }
    if (box.read('positionList') != null) {}
    _position = box.read('positionList');
  }

  double distanceSum = 0.0;
  final box = GetStorage();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(2.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                      onPressed: () {
                        StreamSubscription<Position> positionStream =
                            Geolocator.getPositionStream(
                          distanceFilter: 3,
                          desiredAccuracy: LocationAccuracy.best,
                        ).listen((Position position) {
                          _position.add(position);
                          print(_position.length);
                          box.write('positionList', _position);
                        });
                        print(positionStream);
                      },
                      child: Text('Add')),
                  TextButton(
                      onPressed: () {
                        double thisSum;
                        var pa = box.read('positionList');
                        for (var i = 0; i < pa.length - 1; i++) {
                          if (pa[i]['latitude'] - pa[i + 1]['latitude'] >=
                                  0.00009 ||
                              pa[i]['longitude'] - pa[i + 1]['longitude'] >=
                                  0.00009) {
                            thisSum = Geolocator.distanceBetween(
                                pa[i]['latitude'],
                                pa[i]['longitude'],
                                pa[i + 1]['latitude'],
                                pa[i + 1]['longitude']);
                            distanceSum = distanceSum + thisSum;
                          }
                        }
                        print(distanceSum);
                        distanceSum = 0;
                      },
                      child: Text('Calculate Sum')),
                  Text(distanceSum.toString()),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
