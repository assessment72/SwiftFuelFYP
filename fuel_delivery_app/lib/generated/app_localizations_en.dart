import 'app_localizations.dart';

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get fuelOrdering => 'Fuel Ordering';

  @override
  String get vehicleNumberPlate => 'Vehicle Number Plate';

  @override
  String get deliveryDate => 'Delivery Date';

  @override
  String get placeOrder => 'Place Order';

  @override
  String get locationServiceDisabled => 'Location services are disabled.';

  @override
  String get locationPermissionDenied => 'Location permissions are denied';

  @override
  String get locationPermissionDeniedForever => 'Location permissions are permanently denied, we cannot request permissions.';

  @override
  String get fillAllFields => 'Please fill all fields';

  @override
  String get loginRequired => 'Login required';

  @override
  String get orderPlacedSuccessfully => 'Order placed successfully!';

  @override
  String get orderPlacementFailed => 'Order placement failed';

  @override
  String get confirmOrder => 'Confirm Order';

  @override
  String get confirmOrderMessage => 'Are you sure you want to place this order?';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get fuelType => 'Fuel Type';

  @override
  String get selectDeliveryDate => 'Select Delivery Date';

  @override
  String get selectDeliveryTime => 'Select Delivery Time';

  @override
  String get deliveryTime => 'Delivery Time';
}

