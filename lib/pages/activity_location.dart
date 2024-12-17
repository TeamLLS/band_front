import 'dart:developer';

import 'package:band_front/cores/repository.dart';
import 'package:band_front/cores/widget_utils.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class ActivityLocationView extends StatefulWidget {
  const ActivityLocationView({super.key});

  @override
  State<ActivityLocationView> createState() => _ActivityLocationViewState();
}

class _ActivityLocationViewState extends State<ActivityLocationView> {
  late String location;
  LatLng? targetLocation;
  GoogleMapController? mapController;

  @override
  void initState() {
    super.initState();
    _initActivityLocationView();
  }

  Future<void> _initActivityLocationView() async {
    location = context.read<ActivityDetailRepo>().activity!.location!;
    try {
      List<Location> locations = await locationFromAddress(location);
      setState(() {
        targetLocation = LatLng(locations[0].latitude, locations[0].longitude);
      });
    } catch (e) {
      log('Error converting address to coordinates: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    double parentWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: const Text('장소 보기'),
      ),
      body: targetLocation == null
          ? const Center(child: Text("올바른 위치가 아닙니다."))
          : Stack(
              children: [
                GoogleMap(
                  onMapCreated: (GoogleMapController controller) {
                    mapController = controller;
                  },
                  initialCameraPosition: CameraPosition(
                    target: targetLocation!,
                    zoom: 15.0,
                  ),
                  markers: {
                    Marker(
                      markerId: const MarkerId('targetLocation'),
                      position: targetLocation!,
                    ),
                  },
                ),
                menuBarUnit(
                    width: parentWidth,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(location),
                    )),
              ],
            ),
    );
  }
}
