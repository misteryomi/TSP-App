import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:food_delivery_app/src/helpers/helper.dart';
import 'package:food_delivery_app/src/helpers/maps_util.dart';
import 'package:food_delivery_app/src/models/restaurant.dart';
import 'package:food_delivery_app/src/repository/restaurant_repository.dart';
import 'package:food_delivery_app/src/repository/settings_repository.dart' as sett;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

class MapController extends ControllerMVC {
  Restaurant currentRestaurant;
  List<Restaurant> topRestaurants = <Restaurant>[];
  List<Marker> allMarkers = <Marker>[];
  LocationData currentLocation;
  Set<Polyline> polylines = new Set();
  CameraPosition cameraPosition;
  MapsUtil mapsUtil = new MapsUtil();
  Completer<GoogleMapController> mapController = Completer();

  MapController() {
    getCurrentLocation();
    getDirectionSteps();
  }

  void listenForNearRestaurants(LocationData myLocation, LocationData areaLocation) async {
    final Stream<Restaurant> stream = await getNearRestaurants(myLocation, areaLocation);
    stream.listen((Restaurant _restaurant) {
      setState(() {
        topRestaurants.add(_restaurant);
      });
      Helper.getMarker(_restaurant.toMap()).then((marker) {
        setState(() {
          allMarkers.add(marker);
        });
      });
    }, onError: (a) {}, onDone: () {});
  }

  void getCurrentLocation() async {
    try {
      currentLocation = await sett.getCurrentLocation();
      setState(() {
        cameraPosition = CameraPosition(
          target: LatLng(double.parse(currentRestaurant.latitude), double.parse(currentRestaurant.longitude)),
          zoom: 14.4746,
        );
      });
      Helper.getMyPositionMarker(currentLocation.latitude, currentLocation.longitude).then((marker) {
        setState(() {
          allMarkers.add(marker);
        });
      });
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        print('Permission denied');
      }
    }
  }

  Future<void> goCurrentLocation() async {
    final GoogleMapController controller = await mapController.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: LatLng(currentLocation.latitude, currentLocation.longitude),
      zoom: 14.4746,
    )));
  }

  void getRestaurantsOfArea() async {
    setState(() {
      topRestaurants = <Restaurant>[];
      LocationData areaLocation = LocationData.fromMap(
          {"latitude": cameraPosition.target.latitude, "longitude": cameraPosition.target.longitude});
      if (cameraPosition != null) {
        listenForNearRestaurants(currentLocation, areaLocation);
      } else {
        listenForNearRestaurants(currentLocation, currentLocation);
      }
    });
  }

  void getDirectionSteps() async {
    currentLocation = await sett.getCurrentLocation();
    mapsUtil
        .get("origin=" +
            currentLocation.latitude.toString() +
            "," +
            currentLocation.longitude.toString() +
            "&destination=" +
            currentRestaurant.latitude +
            "," +
            currentRestaurant.longitude +
            "&key=${sett.setting.value?.googleMapsKey}")
        .then((dynamic res) {
      List<LatLng> _latLng = res as List<LatLng>;
      _latLng.insert(0, new LatLng(currentLocation.latitude, currentLocation.longitude));
      setState(() {
        polylines.add(new Polyline(
            visible: true,
            polylineId: new PolylineId(currentLocation.hashCode.toString()),
            points: _latLng,
            color: Color(0xFFea5c44),
            width: 6));
      });
    });
  }

  Future refreshMap() async {
    setState(() {
      topRestaurants = <Restaurant>[];
    });
    listenForNearRestaurants(currentLocation, currentLocation);
  }
}
