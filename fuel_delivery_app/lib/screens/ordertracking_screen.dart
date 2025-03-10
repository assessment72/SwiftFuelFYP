import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle;

class OrderTrackingScreen extends StatefulWidget {
  final String orderId;

  const OrderTrackingScreen({Key? key, required this.orderId}) : super(key: key);

  @override
  _OrderTrackingScreenState createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  GoogleMapController? _mapController;
  LatLng? _customerLocation;
  LatLng? _driverLocation;
  String _orderStatus = "Pending";
  Set<Polyline> _polylines = {};
  String _mapStyle = '';

  String googleMapsApiKey = "AIzaSyAoAkKeq7jfY5Z8xic5KTXp_Ex30u25ijw";

  @override
  void initState() {
    super.initState();
    _loadMapStyle();
    _listenToOrderUpdates();
  }

  /// Load Modern Google Maps Theme
  Future<void> _loadMapStyle() async {
    _mapStyle = await rootBundle.loadString('assets/map_style.json');
  }


  void _listenToOrderUpdates() {
    FirebaseFirestore.instance.collection('orders').doc(widget.orderId).snapshots().listen((orderSnapshot) {
      if (orderSnapshot.exists) {
        GeoPoint customerGeoPoint = orderSnapshot['location'];
        LatLng newCustomerLocation = LatLng(customerGeoPoint.latitude, customerGeoPoint.longitude);

        LatLng? newDriverLocation;
        if (orderSnapshot.data()!.containsKey('driverLocation')) {
          GeoPoint driverGeoPoint = orderSnapshot['driverLocation'];
          newDriverLocation = LatLng(driverGeoPoint.latitude, driverGeoPoint.longitude);
        }

        setState(() {
          _orderStatus = orderSnapshot['status'];
          _customerLocation = newCustomerLocation;
          _driverLocation = newDriverLocation;
        });

        // Fetch and update route when driver location changes
        if (_driverLocation != null) {
          _fetchRoute();
        }

        // Move the map to the updated driver location
        if (_mapController != null && _driverLocation != null) {
          _mapController!.animateCamera(
            CameraUpdate.newLatLng(_driverLocation!),
          );
        }
      }
    });
  }

  /// Fetch Route using Google Directions API
  Future<void> _fetchRoute() async {
    if (_customerLocation == null || _driverLocation == null) return;

    String url =
        "https://maps.googleapis.com/maps/api/directions/json?origin=${_driverLocation!.latitude},${_driverLocation!.longitude}&destination=${_customerLocation!.latitude},${_customerLocation!.longitude}&key=$googleMapsApiKey";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);

      if (data['routes'].isNotEmpty) {
        String encodedPolyline = data['routes'][0]['overview_polyline']['points'];
        List<LatLng> polylineCoordinates = _decodePolyline(encodedPolyline);

        setState(() {
          _polylines.clear();
          _polylines.add(Polyline(
            polylineId: const PolylineId("route"),
            points: polylineCoordinates,
            color: const Color(0xFFE91E63),
            width: 6,
          ));
        });
      }
    } else {
      print("Error fetching route: ${response.statusCode}");
    }
  }

  /// Decode Google Maps Encoded Polyline
  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> polylinePoints = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int shift = 0, result = 0;
      int byte;

      do {
        byte = encoded.codeUnitAt(index++) - 63;
        result |= (byte & 0x1F) << shift;
        shift += 5;
      } while (byte >= 0x20);

      int deltaLat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += deltaLat;

      shift = 0;
      result = 0;

      do {
        byte = encoded.codeUnitAt(index++) - 63;
        result |= (byte & 0x1F) << shift;
        shift += 5;
      } while (byte >= 0x20);

      int deltaLng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += deltaLng;

      polylinePoints.add(LatLng(lat / 1E5, lng / 1E5));
    }

    return polylinePoints;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFE91E63),
        title: const Text(
          "Order Tracking",
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            height: 300,
            margin: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.pink.shade200),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: _customerLocation == null
                  ? const Center(child: CircularProgressIndicator())
                  : GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: _customerLocation!,
                  zoom: 14,
                ),
                onMapCreated: (controller) {
                  _mapController = controller;
                  _mapController!.setMapStyle(_mapStyle);
                },
                markers: {
                  if (_customerLocation != null)
                    Marker(
                      markerId: const MarkerId('customer'),
                      position: _customerLocation!,
                      infoWindow: const InfoWindow(title: "Your Location"),
                      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
                    ),
                  if (_driverLocation != null)
                    Marker(
                      markerId: const MarkerId('driver'),
                      position: _driverLocation!,
                      infoWindow: const InfoWindow(title: "Driver Location"),
                      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
                    ),
                },
                polylines: _polylines,
              ),
            ),
          ),

          // Order Status and Details Section
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Fuel Order Details",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Order No: #${widget.orderId.substring(0, 8).toUpperCase()}",
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Order Status: $_orderStatus",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _orderStatus == "Completed" ? Colors.green : Colors.orange),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Your fuel is on the way! Track the progress above."
                        "Our delivery partner may contact you",
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
