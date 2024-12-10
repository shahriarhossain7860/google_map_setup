import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController _mapController;
  LatLng? _currentPosition;
  Marker? _currentMarker;
  Polyline _polyline = Polyline(
    polylineId: PolylineId('route'),
    color: Colors.blue,
    width: 4,
    points: [],
  );
  List<LatLng> _polylinePoints = [];
  StreamSubscription<Position>? _positionStream;

  @override
  void initState() {
    super.initState();
    _initializeLocationUpdates();
  }

  Future<void> _initializeLocationUpdates() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    // Get the initial position
    Geolocator.getCurrentPosition().then((position) {
      _updateLocation(position);
    });

    // Define location settings for the stream
    LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // Minimum distance (in meters) for updates
    );

    // Listen for location updates
    _positionStream = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen((Position position) {
      _updateLocation(position);
    });
  }

  void _updateLocation(Position position) {
    LatLng newPosition = LatLng(position.latitude, position.longitude);

    setState(() {
      if (_currentPosition != null) {
        _polylinePoints.add(newPosition);
      }
      _currentPosition = newPosition;
      _currentMarker = Marker(
        markerId: MarkerId('current_location'),
        position: _currentPosition!,
        infoWindow: InfoWindow(
          title: "My current location",
          snippet: "Lat: ${_currentPosition!.latitude}, Lng: ${_currentPosition!.longitude}",
        ),
      );

      _polyline = Polyline(
        polylineId: PolylineId('route'),
        color: Colors.blue,
        width: 4,
        points: List<LatLng>.from(_polylinePoints),
      );
    });

    _mapController.animateCamera(
      CameraUpdate.newLatLng(_currentPosition!),
    );
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Text("Google Maps Location"),
      ),
      body: _currentPosition == null
          ? Center(child: CircularProgressIndicator())
          : GoogleMap(
        onMapCreated: (controller) {
          _mapController = controller;
        },
        initialCameraPosition: CameraPosition(
          target: _currentPosition!,
          zoom: 16,
        ),
        trafficEnabled: true,
        markers: _currentMarker != null ? {_currentMarker!} : {},
        polylines: {_polyline},
        myLocationEnabled: true,
      ),
    );
  }
}