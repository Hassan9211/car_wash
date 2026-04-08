import 'package:car_wash/core/router/app_navigation.dart';
import 'package:car_wash/core/theme/app_button_colors.dart';
import 'package:car_wash/core/widgets/app_buttons.dart';
import 'package:car_wash/features/home/booking/model/booking_flow_details.dart';
import 'package:car_wash/features/home/model/service_provider_profile.dart';
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
  String? _selectedLocation;
  String? _selectedServiceType;
  String? _selectedBrand;
  String? _selectedCar;

  static const _serviceTypes = [
    'Select Service type',
    'Basic wash',
    'Foam wash',
    'Interior',
    'Wax',
  ];

  static const _brands = ['Select Brand', 'Toyota', 'Honda', 'BMW', 'Mercedes'];

  static const _cars = ['Select Car', 'Corolla', 'Civic', 'X5', 'C-Class'];

  @override
  void initState() {
    super.initState();
    _selectedServiceType = _serviceTypes.first;
    _selectedBrand = _brands.first;
    _selectedCar = _cars.first;
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
            _selectedServiceType == _serviceTypes.first
        ? 'Basic Car Wash'
        : _selectedServiceType!;

    return BookingFlowDetails(
      provider: widget.provider,
      customerName: customerName,
      serviceType: serviceType,
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

  String? _validateLocation(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please set location';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final locationErrorText = _hasAttemptedSubmit
        ? _validateLocation(_selectedLocation)
        : null;

    return Scaffold(
      backgroundColor: Colors.white,
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
                            color: Colors.black,
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
              color: const Color(0xFFE9E6E3).withValues(alpha: 0.9),
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
                        value: _selectedLocation,
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
                          _serviceTypes.first,
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
                          _brands.first,
                        ),
                        onChanged: (value) {
                          setState(() {
                            _selectedBrand = value;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      _BookingFieldLabel('Car*', isSubLabel: true),
                      const SizedBox(height: 6),
                      _BookingDropdownField(
                        key: const Key('booking_car_field'),
                        value: _selectedCar,
                        items: _cars,
                        validator: (value) => _validateRequiredSelection(
                          value,
                          _cars.first,
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
                      const SizedBox(height: 34),
                      AppPrimaryButton(
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
                    ],
                  ),
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
              color: const Color(0xFFF7F7F7),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: errorText == null
                    ? const Color(0xFFE7E7E7)
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
                              ? const Color(0xFF6F6F6F)
                              : const Color(0xFFB2B2B2),
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 1,
                  height: 22,
                  color: const Color(0xFFE0E0E0),
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
        color: Colors.black,
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
      validator: validator,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(fontSize: 12.5, color: Color(0xFFB2B2B2)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
        filled: true,
        fillColor: const Color(0xFFF7F7F7),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: Color(0xFFE7E7E7)),
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
        fillColor: const Color(0xFFF7F7F7),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: Color(0xFFE7E7E7)),
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
      style: const TextStyle(fontSize: 12.5, color: Color(0xFF6F6F6F)),
      dropdownColor: Colors.white,
      items: items
          .map((item) {
            return DropdownMenuItem<String>(value: item, child: Text(item));
          })
          .toList(growable: false),
      onChanged: onChanged,
    );
  }
}
