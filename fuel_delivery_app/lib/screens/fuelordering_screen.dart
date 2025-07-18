import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fuel_delivery_app/generated/app_localizations.dart';

class FuelOrderingScreen extends StatefulWidget {
  const FuelOrderingScreen({super.key});

  @override
  State<FuelOrderingScreen> createState() => _FuelOrderingScreenState();
}

class _FuelOrderingScreenState extends State<FuelOrderingScreen> {
  final TextEditingController _vehicleNumberController = TextEditingController();
  final ValueNotifier<String?> _selectedFuelType = ValueNotifier<String?>(null);
  final ValueNotifier<LatLng?> _selectedLocation = ValueNotifier<LatLng?>(null);
  final ValueNotifier<DateTime?> _selectedDate = ValueNotifier<DateTime?>(null);
  final ValueNotifier<TimeOfDay?> _selectedTime = ValueNotifier<TimeOfDay?>(null);

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _vehicleNumberController.dispose();
    _selectedFuelType.dispose();
    _selectedLocation.dispose();
    _selectedDate.dispose();
    _selectedTime.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.locationServiceDisabled)),
      );
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.locationPermissionDenied)),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.locationPermissionDeniedForever)),
      );
      return;
    }

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    _selectedLocation.value = LatLng(position.latitude, position.longitude);
  }

  Future<void> _selectLocationOnMap() async {
    // Implement map selection logic here
    // For now, we'll just use the current location
  }

  Future<void> _placeOrder() async {
    final AppLocalizations localizations = AppLocalizations.of(context)!;

    if (_selectedFuelType.value == null ||
        _vehicleNumberController.text.isEmpty ||
        _selectedLocation.value == null ||
        _selectedDate.value == null ||
        _selectedTime.value == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizations.fillAllFields)),
      );
      return;
    }

    User? user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizations.loginRequired)),
      );
      return;
    }

    try {
      DocumentReference orderRef = await _firestore.collection('orders').add({
        'userId': user.uid,
        'fuelType': _selectedFuelType.value,
        'vehicleNumber': _vehicleNumberController.text,
        'location': GeoPoint(_selectedLocation.value!.latitude, _selectedLocation.value!.longitude),
        'orderedAt': Timestamp.now(),
        'deliveryDate': _selectedDate.value != null ? Timestamp.fromDate(_selectedDate.value!) : null,
        'deliveryTime': _selectedTime.value != null ? _selectedTime.value!.format(context) : null,
        'status': 'Pending',
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizations.orderPlacedSuccessfully)),
      );

      // Clear form fields after successful order
      _selectedFuelType.value = null;
      _vehicleNumberController.clear();
      _selectedLocation.value = null;
      _selectedDate.value = null;
      _selectedTime.value = null;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${localizations.orderPlacementFailed}: $e')),
      );
    }
  }

  void _showOrderConfirmation() {
    final AppLocalizations localizations = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(localizations.confirmOrder),
          content: Text(localizations.confirmOrderMessage),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(localizations.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _placeOrder();
              },
              child: Text(localizations.confirm),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField(TextEditingController controller, String labelText, {Key? key}) {
    return TextField(
      key: key,
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        filled: true,
        fillColor: Theme.of(context).cardColor,
      ),
    );
  }

  Widget _buildDropdown(String? fuelType, AppLocalizations localizations) {
    return DropdownButtonFormField<String>(
      value: fuelType,
      decoration: InputDecoration(
        labelText: localizations.fuelType,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        filled: true,
        fillColor: Theme.of(context).cardColor,
      ),
      items: <String>['Petrol', 'Diesel', 'Premium']
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (String? newValue) {
        _selectedFuelType.value = newValue;
      },
    );
  }

  Widget _buildDatePicker(DateTime? selectedDate, AppLocalizations localizations) {
    return GestureDetector(
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: selectedDate ?? DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 30)),
        );
        if (picked != null && picked != selectedDate) {
          _selectedDate.value = picked;
        }
      },
      child: Container(
        padding: const EdgeInsets.all(15.0),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(color: Theme.of(context).dividerColor),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor.withOpacity(0.1),
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: <Widget>[
            Icon(Icons.calendar_today, color: Theme.of(context).iconTheme.color),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                selectedDate == null
                    ? localizations.selectDeliveryDate
                    : "${localizations.deliveryDate}: ${selectedDate.toLocal().toString().split(' ')[0]}",
                style: TextStyle(fontSize: 16, color: Theme.of(context).textTheme.bodyLarge?.color),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePicker(TimeOfDay? selectedTime, AppLocalizations localizations) {
    return GestureDetector(
      onTap: () async {
        final TimeOfDay? picked = await showTimePicker(
          context: context,
          initialTime: selectedTime ?? TimeOfDay.now(),
        );
        if (picked != null && picked != selectedTime) {
          _selectedTime.value = picked;
        }
      },
      child: Container(
        padding: const EdgeInsets.all(15.0),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(color: Theme.of(context).dividerColor),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor.withOpacity(0.1),
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: <Widget>[
            Icon(Icons.access_time, color: Theme.of(context).iconTheme.color),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                selectedTime == null
                    ? localizations.selectDeliveryTime
                    : "${localizations.deliveryTime}: ${selectedTime.format(context)}",
                style: TextStyle(fontSize: 16, color: Theme.of(context).textTheme.bodyLarge?.color),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.fuelOrdering),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: <Widget>[
            ValueListenableBuilder<String?>(
              valueListenable: _selectedFuelType,
              builder: (context, fuelType, _) {
                return _buildDropdown(fuelType, localizations);
              },
            ),
            const SizedBox(height: 20),
            _buildTextField(
              _vehicleNumberController,
              localizations.vehicleNumberPlate,
              key: const Key('vehicleField'),
            ),
            const SizedBox(height: 20),
            ValueListenableBuilder<DateTime?>(
              valueListenable: _selectedDate,
              builder: (context, date, _) {
                return _buildDatePicker(date, localizations);
              },
            ),
            const SizedBox(height: 20),
            ValueListenableBuilder<TimeOfDay?>(
              valueListenable: _selectedTime,
              builder: (context, time, _) {
                return _buildTimePicker(time, localizations);
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _showOrderConfirmation,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
              ),
              child: Text(localizations.placeOrder, style: const TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}


