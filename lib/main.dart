import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Lokatsiyani olish'),
        ),
        body: LocationWidget(),
      ),
    );
  }
}

class LocationWidget extends StatefulWidget {
  @override
  _LocationWidgetState createState() => _LocationWidgetState();
}

class _LocationWidgetState extends State<LocationWidget> {
  String _locationMessage = "Lokatsiyani oling";
  String _addressMessage = "Manzil: Ma'lumotlar yo'q";

  // Lokatsiyani olish va manzilni aniqlash funksiyasi
  Future<void> _getCurrentLocation() async {
    LocationPermission permission;
    
    // Lokatsiya xizmatlari yoqilganligini tekshirish
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _locationMessage = "Lokatsiya xizmatlari o'chirilgan.";
      });
      return;
    }

    // Ruxsatlarni tekshirish
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _locationMessage = "Lokatsiya ruxsatnomasi rad etildi.";
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _locationMessage = "Lokatsiya ruxsatnomasi doimiy ravishda rad etildi.";
      });
      return;
    }

    // Hozirgi lokatsiyani olish
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      _locationMessage =
          "Latitude: ${position.latitude}, Longitude: ${position.longitude}";
    });

    // Koordinatalar asosida manzilni aniqlash
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude, position.longitude);

      Placemark place = placemarks[0];
      setState(() {
        _addressMessage =
            "Manzil: ${place.locality}, ${place.street}, ${place.country}";
      });
    } catch (e) {
      setState(() {
        _addressMessage = "Manzilni aniqlab bo'lmadi: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            _locationMessage,
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 10),
          Text(
            _addressMessage,
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _getCurrentLocation,
            child: Text("Lokatsiyani olish"),
          ),
        ],
      ),
    );
  }
}
