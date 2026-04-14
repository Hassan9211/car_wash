import 'package:car_wash/core/router/app_navigation.dart';
import 'package:car_wash/core/location/app_location_details.dart';
import 'package:car_wash/core/theme/app_button_colors.dart';
import 'package:car_wash/core/theme/app_colors.dart';
import 'package:car_wash/core/widgets/app_buttons.dart';
import 'package:car_wash/features/authentication/data/auth_session.dart';
import 'package:car_wash/features/home/booking/model/booking_flow_details.dart';
import 'package:car_wash/features/home/model/service_provider_profile.dart';
import 'package:car_wash/features/services/data/service_catalog.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key, required this.provider});

  final ServiceProviderProfile provider;

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _numberPlateController = TextEditingController();

  bool _hasAttemptedSubmit = false;
  AppLocationDetails? _selectedLocation;
  String? _selectedServiceType;
  String? _selectedBrand;
  String? _selectedCar;

  static const _serviceTypePlaceholder = 'Select Service type';

  static const _brandPlaceholder = 'Select Brand';
  static const _carPlaceholder = 'Select Car';

  static const _uaeCarModelsByBrand = <String, List<String>>{
    'Toyota': [
      'Land Cruiser',
      'Prado',
      'Fortuner',
      'Hilux',
      'Corolla',
      'Camry',
      'Yaris',
      'Raize',
      'RAV4',
      'Highlander',
      'Innova',
      'Coaster',
    ],
    'Nissan': [
      'Patrol',
      'Patrol Safari',
      'X-Trail',
      'Kicks',
      'Pathfinder',
      'Altima',
      'Sunny',
      'Sentra',
      'Maxima',
      'Z',
      'Navara',
      'Urvan',
    ],
    'Mitsubishi': [
      'Pajero',
      'Montero Sport',
      'L200',
      'ASX',
      'Outlander',
      'Eclipse Cross',
      'Attrage',
      'Xpander',
    ],
    'Honda': [
      'Civic',
      'Accord',
      'City',
      'HR-V',
      'CR-V',
      'ZR-V',
      'Pilot',
      'Odyssey',
    ],
    'Hyundai': [
      'Elantra',
      'Accent',
      'Sonata',
      'Azera',
      'Tucson',
      'Santa Fe',
      'Palisade',
      'Creta',
      'Venue',
      'Staria',
    ],
    'Kia': [
      'Picanto',
      'Rio',
      'Cerato',
      'K5',
      'Sonet',
      'Seltos',
      'Sportage',
      'Sorento',
      'Telluride',
      'Carnival',
    ],
    'Mazda': [
      'Mazda 2',
      'Mazda 3',
      'Mazda 6',
      'CX-3',
      'CX-30',
      'CX-5',
      'CX-60',
      'CX-9',
      'CX-90',
    ],
    'Suzuki': [
      'Swift',
      'Dzire',
      'Baleno',
      'Ciaz',
      'Jimny',
      'Vitara',
      'Ertiga',
      'XL7',
    ],
    'Ford': [
      'Territory',
      'Escape',
      'Edge',
      'Explorer',
      'Expedition',
      'Taurus',
      'Mustang',
      'Ranger',
      'F-150',
      'Bronco',
    ],
    'Chevrolet': [
      'Spark',
      'Groove',
      'Captiva',
      'Equinox',
      'Traverse',
      'Tahoe',
      'Suburban',
      'Silverado',
      'Camaro',
      'Malibu',
    ],
    'GMC': [
      'Terrain',
      'Acadia',
      'Yukon',
      'Sierra',
      'Hummer EV',
    ],
    'Jeep': [
      'Wrangler',
      'Grand Cherokee',
      'Cherokee',
      'Compass',
      'Renegade',
      'Gladiator',
    ],
    'Dodge': [
      'Charger',
      'Challenger',
      'Durango',
      'Hornet',
    ],
    'Ram': [
      '1500',
      '2500',
      'TRX',
    ],
    'Lexus': [
      'LX',
      'GX',
      'RX',
      'NX',
      'UX',
      'ES',
      'IS',
      'LS',
      'LM',
    ],
    'Infiniti': [
      'QX80',
      'QX60',
      'QX55',
      'Q50',
    ],
    'BMW': [
      '1 Series',
      '3 Series',
      '5 Series',
      '7 Series',
      'X1',
      'X3',
      'X5',
      'X6',
      'X7',
      'XM',
      'i4',
      'iX',
    ],
    'Mercedes-Benz': [
      'A-Class',
      'C-Class',
      'E-Class',
      'S-Class',
      'CLA',
      'GLA',
      'GLC',
      'GLE',
      'GLS',
      'G-Class',
      'V-Class',
      'EQE',
      'EQS',
    ],
    'Audi': [
      'A3',
      'A4',
      'A6',
      'A8',
      'Q3',
      'Q5',
      'Q7',
      'Q8',
      'e-tron',
      'RS Q8',
    ],
    'Volkswagen': [
      'Polo',
      'Golf',
      'Passat',
      'T-Roc',
      'Tiguan',
      'Teramont',
      'Touareg',
    ],
    'Porsche': [
      'Cayenne',
      'Macan',
      'Panamera',
      '911',
      'Taycan',
    ],
    'Land Rover': [
      'Defender',
      'Discovery',
      'Discovery Sport',
      'Range Rover',
      'Range Rover Sport',
      'Range Rover Velar',
      'Range Rover Evoque',
    ],
    'Tesla': [
      'Model 3',
      'Model Y',
      'Model S',
      'Model X',
      'Cybertruck',
    ],
    'Cadillac': [
      'XT4',
      'XT5',
      'XT6',
      'Escalade',
      'CT4',
      'CT5',
    ],
    'Lincoln': [
      'Corsair',
      'Nautilus',
      'Aviator',
      'Navigator',
    ],
    'Peugeot': [
      '208',
      '2008',
      '3008',
      '5008',
      'Landtrek',
    ],
    'Renault': [
      'Kwid',
      'Duster',
      'Koleos',
      'Megane',
      'Arkana',
    ],
    'MG': [
      'MG 5',
      'MG 6',
      'MG 7',
      'ZS',
      'HS',
      'RX5',
      'RX8',
      'Whale',
      'One',
    ],
    'Geely': [
      'Coolray',
      'Tugella',
      'Emgrand',
      'Okavango',
      'Monjaro',
      'Geometry C',
    ],
    'BYD': [
      'Atto 3',
      'Seal',
      'Han',
      'Song Plus',
      'Tang',
      'Dolphin',
    ],
    'Changan': [
      'Alsvin',
      'Eado Plus',
      'CS35 Plus',
      'CS55 Plus',
      'CS75 Plus',
      'UNI-K',
      'UNI-V',
    ],
    'Jetour': [
      'X70',
      'X70 Plus',
      'X90 Plus',
      'Dashing',
      'T2',
    ],
    'GAC': [
      'Empow',
      'Emkoo',
      'GS3',
      'GS4',
      'GS8',
      'M8',
    ],
    'Chery': [
      'Arrizo 5',
      'Arrizo 8',
      'Tiggo 2 Pro',
      'Tiggo 4 Pro',
      'Tiggo 7 Pro',
      'Tiggo 8 Pro',
    ],
    'Haval': [
      'Jolion',
      'H6',
      'Dargo',
      'H9',
    ],
    'Exeed': [
      'LX',
      'TXL',
      'RX',
      'VX',
    ],
    'Isuzu': [
      'D-Max',
      'MU-X',
    ],
    'JAC': [
      'J7',
      'JS4',
      'JS6',
      'T8',
    ],
  };

  static final _brands = <String>[
    _brandPlaceholder,
    ..._uaeCarModelsByBrand.keys,
  ];

  @override
  void initState() {
    super.initState();
    ServiceCatalog.fetchServices();
    _selectedLocation = AuthSession.currentLocationDetails;
    _selectedServiceType = _serviceTypePlaceholder;
    _selectedBrand = _brandPlaceholder;
    _selectedCar = _carPlaceholder;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _numberPlateController.dispose();
    super.dispose();
  }

  Future<void> _openLocationPicker() async {
    final selectedLocation = await context.pushToBookingLocation(
      _selectedLocation,
    );

    if (!mounted || selectedLocation == null) {
      return;
    }

    setState(() {
      _selectedLocation = selectedLocation;
    });
  }

  Future<void> _validateAndOpenBookingSchedule() async {
    FocusScope.of(context).unfocus();

    setState(() {
      _hasAttemptedSubmit = true;
    });

    final isFormValid = _formKey.currentState?.validate() ?? false;
    final isLocationValid = _validateLocation(_selectedLocation) == null;

    if (!isFormValid || !isLocationValid) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Please fill all required booking details'),
          ),
        );
      return;
    }

    await context.pushToBookingSchedule(_buildBookingFlowDetails());
  }

  BookingFlowDetails _buildBookingFlowDetails() {
    final customerName = _nameController.text.trim();
    final serviceType = _selectedServiceType == null ||
            _selectedServiceType == _serviceTypePlaceholder
        ? 'Basic Car Wash'
        : _selectedServiceType!;

    return BookingFlowDetails(
      provider: widget.provider,
      customerName: customerName,
      serviceType: serviceType,
      bookingLocation: _selectedLocation,
    );
  }

  String? _validateRequiredText(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }

    return null;
  }

  String? _validateRequiredSelection(String? value, String placeholder) {
    if (value == null || value == placeholder) {
      return 'Please select ${placeholder.replaceFirst('Select ', '').toLowerCase()}';
    }

    return null;
  }

  String? _validateLocation(AppLocationDetails? value) {
    if (value == null || value.displayLabel.trim().isEmpty) {
      return 'Please set location';
    }

    return null;
  }

  List<String> get _serviceTypes {
    final serviceLabels = ServiceCatalog.servicesGridList
        .map((service) => service.label.trim())
        .where((label) => label.isNotEmpty)
        .toSet()
        .toList(growable: false);

    return <String>[_serviceTypePlaceholder, ...serviceLabels];
  }

  List<String> get _availableCars {
    final selectedBrand = _selectedBrand;
    if (selectedBrand == null || selectedBrand == _brandPlaceholder) {
      return const [_carPlaceholder];
    }

    final models = _uaeCarModelsByBrand[selectedBrand] ?? const <String>[];
    return <String>[_carPlaceholder, ...models];
  }

  @override
  Widget build(BuildContext context) {
    final locationErrorText = _hasAttemptedSubmit
        ? _validateLocation(_selectedLocation)
        : null;

    return Scaffold(
      backgroundColor: AppColors.appBackground,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 54,
              child: Stack(
                children: [
                  Positioned(
                    left: 8,
                    top: 0,
                    bottom: 0,
                    child: IconButton(
                      key: const Key('booking_back_button'),
                      onPressed: () => context.pop(),
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: AppButtonColors.actionForeground,
                        size: 18,
                      ),
                    ),
                  ),
                  const Positioned.fill(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 56),
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          'Booking',
                          key: Key('booking_screen_title'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(
              height: 1,
              thickness: 0.8,
              color: AppColors.border,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 16),
                child: Form(
                  key: _formKey,
                  autovalidateMode: _hasAttemptedSubmit
                      ? AutovalidateMode.always
                      : AutovalidateMode.disabled,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _BookingFieldLabel('Name*'),
                      const SizedBox(height: 6),
                      _BookingTextField(
                        key: const Key('booking_name_field'),
                        controller: _nameController,
                        hintText: 'Customer name',
                        validator: (value) =>
                            _validateRequiredText(value, 'Name'),
                      ),
                      const SizedBox(height: 12),
                      _BookingFieldLabel('Location*'),
                      const SizedBox(height: 6),
                      _BookingLocationField(
                        key: const Key('booking_location_field'),
                        value: _selectedLocation?.displayLabel,
                        errorText: locationErrorText,
                        onTap: _openLocationPicker,
                        onTrailingIconTap: _openLocationPicker,
                      ),
                      const SizedBox(height: 12),
                      _BookingFieldLabel('Service Type*'),
                      const SizedBox(height: 6),
                      _BookingDropdownField(
                        key: const Key('booking_service_type_field'),
                        value: _selectedServiceType,
                        items: _serviceTypes,
                        validator: (value) => _validateRequiredSelection(
                          value,
                          _serviceTypePlaceholder,
                        ),
                        onChanged: (value) {
                          setState(() {
                            _selectedServiceType = value;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      _BookingFieldLabel('Add Vehicle*'),
                      const SizedBox(height: 10),
                      _BookingFieldLabel('Brand*', isSubLabel: true),
                      const SizedBox(height: 6),
                      _BookingDropdownField(
                        key: const Key('booking_brand_field'),
                        value: _selectedBrand,
                        items: _brands,
                        validator: (value) => _validateRequiredSelection(
                          value,
                          _brandPlaceholder,
                        ),
                        onChanged: (value) {
                          setState(() {
                            _selectedBrand = value;
                            _selectedCar = _carPlaceholder;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      _BookingFieldLabel('Car*', isSubLabel: true),
                      const SizedBox(height: 6),
                      _BookingDropdownField(
                        key: const Key('booking_car_field'),
                        value: _selectedCar,
                        items: _availableCars,
                        validator: (value) => _validateRequiredSelection(
                          value,
                          _carPlaceholder,
                        ),
                        onChanged: (value) {
                          setState(() {
                            _selectedCar = value;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      _BookingFieldLabel('Number Plate*', isSubLabel: true),
                      const SizedBox(height: 6),
                      _BookingTextField(
                        key: const Key('booking_number_plate_field'),
                        controller: _numberPlateController,
                        hintText: 'Car Number Plate',
                        validator: (value) => _validateRequiredText(
                          value,
                          'Number plate',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 22),
              child: AppPrimaryButton(
                key: const Key('booking_next_button'),
                label: 'Next',
                onPressed: _validateAndOpenBookingSchedule,
                height: 46,
                borderRadius: 6,
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BookingLocationField extends StatelessWidget {
  const _BookingLocationField({
    super.key,
    required this.value,
    this.errorText,
    required this.onTap,
    required this.onTrailingIconTap,
  });

  final String? value;
  final String? errorText;
  final VoidCallback onTap;
  final VoidCallback onTrailingIconTap;

  @override
  Widget build(BuildContext context) {
    final hasValue = value != null && value!.trim().isNotEmpty;
    final displayValue = hasValue ? value!.trim() : 'Set Location';

    return Material(
      color: Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Ink(
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: errorText == null
                    ? AppColors.border
                    : const Color(0xFFE53935),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: onTap,
                    borderRadius: const BorderRadius.horizontal(
                      left: Radius.circular(4),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 14,
                      ),
                      child: Text(
                        displayValue,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.5,
                          color: hasValue
                              ? AppColors.textSecondary
                              : AppColors.textMuted,
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 1,
                  height: 22,
                  color: AppColors.border,
                ),
                InkWell(
                  key: const Key('booking_location_icon_button'),
                  onTap: onTrailingIconTap,
                  borderRadius: const BorderRadius.horizontal(
                    right: Radius.circular(4),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    child: Icon(
                      Icons.my_location_outlined,
                      size: 18,
                      color: Color(0xFF8B8B8B),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (errorText != null) ...[
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                errorText!,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFFE53935),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _BookingFieldLabel extends StatelessWidget {
  const _BookingFieldLabel(this.label, {this.isSubLabel = false});

  final String label;
  final bool isSubLabel;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontSize: isSubLabel ? 12 : 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      ),
    );
  }
}

class _BookingTextField extends StatelessWidget {
  const _BookingTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.validator,
  });

  final TextEditingController controller;
  final String hintText;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      cursorColor: AppButtonColors.primaryBackground,
      style: const TextStyle(
        fontSize: 13.2,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      ),
      validator: validator,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(fontSize: 12.5, color: Color(0xFFB2B2B2)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
        filled: true,
        fillColor: AppColors.inputFill,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(
            color: AppButtonColors.primaryBackground,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: Color(0xFFE53935)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: Color(0xFFE53935)),
        ),
        errorStyle: const TextStyle(fontSize: 12),
      ),
    );
  }
}

class _BookingDropdownField extends StatelessWidget {
  const _BookingDropdownField({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    this.validator,
  });

  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      validator: validator,
      icon: const Icon(
        Icons.keyboard_arrow_down_rounded,
        color: Color(0xFF707070),
      ),
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        filled: true,
        fillColor: AppColors.inputFill,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(
            color: AppButtonColors.primaryBackground,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: Color(0xFFE53935)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: Color(0xFFE53935)),
        ),
        errorStyle: const TextStyle(fontSize: 12),
      ),
      style: const TextStyle(fontSize: 12.5, color: AppColors.textPrimary),
      dropdownColor: AppColors.surfaceElevated,
      items: items
          .map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: const TextStyle(
                  fontSize: 12.5,
                  color: AppColors.textPrimary,
                ),
              ),
            );
          })
          .toList(growable: false),
      onChanged: onChanged,
    );
  }
}
