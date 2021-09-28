import 'dart:convert';
import 'dart:io';

import 'package:food_delivery_app/src/helpers/helper.dart';
import 'package:food_delivery_app/src/models/restaurant.dart';
import 'package:food_delivery_app/src/models/review.dart';
import 'package:food_delivery_app/src/repository/user_repository.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';

Future<Stream<Restaurant>> getNearRestaurants(LocationData myLocation, LocationData areaLocation) async {
  String _nearParams = '';
  String _orderLimitParam = '';
  if (myLocation != null && areaLocation != null) {
    _orderLimitParam = 'orderBy=area&limit=5';
    _nearParams =
        '&myLon=${myLocation.longitude}&myLat=${myLocation.latitude}&areaLon=${areaLocation.longitude}&areaLat=${areaLocation.latitude}';
  }
  final String url = '${GlobalConfiguration().getString('api_base_url')}restaurants?$_nearParams&$_orderLimitParam';

  final client = new http.Client();
  final streamedRest = await client.send(http.Request('get', Uri.parse(url)));

  return streamedRest.stream
      .transform(utf8.decoder)
      .transform(json.decoder)
      .map((data) => Helper.getData(data))
      .expand((data) => (data as List))
      .map((data) {
    return Restaurant.fromJSON(data);
  });
}

Future<Stream<Restaurant>> searchRestaurants(String search, LocationData location) async {
  final String _searchParam = 'search=name:$search;description:$search&searchFields=name:like;description:like';
  final String _locationParam =
      'myLon=${location.longitude}&myLat=${location.latitude}&areaLon=${location.longitude}&areaLat=${location.latitude}';
  final String _orderLimitParam = 'orderBy=area&limit=5';
  final String url =
      '${GlobalConfiguration().getString('api_base_url')}restaurants?&$_searchParam&$_locationParam&$_orderLimitParam';

  final client = new http.Client();
  final streamedRest = await client.send(http.Request('get', Uri.parse(url)));

  return streamedRest.stream
      .transform(utf8.decoder)
      .transform(json.decoder)
      .map((data) => Helper.getData(data))
      .expand((data) => (data as List))
      .map((data) {
    return Restaurant.fromJSON(data);
  });
}

Future<Stream<Restaurant>> getRestaurant(String id) async {
  final String url = '${GlobalConfiguration().getString('api_base_url')}restaurants/$id';

  final client = new http.Client();
  final streamedRest = await client.send(http.Request('get', Uri.parse(url)));

  return streamedRest.stream
      .transform(utf8.decoder)
      .transform(json.decoder)
      .map((data) => Helper.getData(data))
      .map((data) => Restaurant.fromJSON(data));
}

Future<Stream<Review>> getRestaurantReviews(String id) async {
  final String url =
      '${GlobalConfiguration().getString('api_base_url')}restaurant_reviews?with=user&search=restaurant_id:$id';

  final client = new http.Client();
  final streamedRest = await client.send(http.Request('get', Uri.parse(url)));

  return streamedRest.stream
      .transform(utf8.decoder)
      .transform(json.decoder)
      .map((data) => Helper.getData(data))
      .expand((data) => (data as List))
      .map((data) {
    return Review.fromJSON(data);
  });
}

Future<Stream<Review>> getRecentReviews() async {
  final String url =
      '${GlobalConfiguration().getString('api_base_url')}restaurant_reviews?orderBy=updated_at&sortedBy=desc&limit=3&with=user';

  final client = new http.Client();
  final streamedRest = await client.send(http.Request('get', Uri.parse(url)));

  return streamedRest.stream
      .transform(utf8.decoder)
      .transform(json.decoder)
      .map((data) => Helper.getData(data))
      .expand((data) => (data as List))
      .map((data) {
    return Review.fromJSON(data);
  });
}

Future<Review> addRestaurantReview(Review review, Restaurant restaurant) async {
  final String url = '${GlobalConfiguration().getString('api_base_url')}restaurant_reviews';
  final client = new http.Client();
  review.user = currentUser.value;
  final response = await client.post(
    url,
    headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    body: json.encode(review.ofRestaurantToMap(restaurant)),
  );
  if (response.statusCode == 200) {
    review = Review.fromJSON(json.decode(response.body)['data']);
  }
  return review;
}
