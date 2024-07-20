import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

class LocationService extends ChangeNotifier {
  double? latitude;
  double? longitude;
  StreamSubscription<Position>? _positionStream;

  LocationService() {
    _startLocationUpdates();
  }

  void _startLocationUpdates() {
    print('Starting location updates...');
    _positionStream = Geolocator.getPositionStream(
      locationSettings: LocationSettings(accuracy: LocationAccuracy.high),
    ).listen(
      (Position position) {
        print('New position received: Latitude: ${position.latitude}, Longitude: ${position.longitude}');
        latitude = position.latitude;
        longitude = position.longitude;
        notifyListeners();
      },
      onError: (error) {
        print('Error in location updates: $error');
      },
    );
  }

  @override
  void dispose() {
    print('Stopping location updates...');
    _positionStream?.cancel();
    super.dispose();
  }
}

