// ignore_for_file: unnecessary_underscores

import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:car_wash/core/location/app_location_details.dart';
import 'package:car_wash/core/router/app_navigation.dart';
import 'package:car_wash/core/scheduling/business_hours.dart';
import 'package:car_wash/core/services/app_permission_service.dart';
import 'package:car_wash/core/theme/app_button_colors.dart';
import 'package:car_wash/core/theme/app_button_styles.dart';
import 'package:car_wash/core/theme/app_colors.dart';
import 'package:car_wash/core/widgets/app_buttons.dart';
import 'package:car_wash/core/widgets/themed_google_map.dart';
import 'package:car_wash/features/authentication/data/auth_session.dart';
import 'package:car_wash/features/home/data/provider_catalog.dart';
import 'package:car_wash/features/home/model/service_provider_profile.dart';
import 'package:car_wash/features/services/data/service_catalog.dart';
import 'package:car_wash/features/services/model/service_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ServiceProviderSetupScreen extends StatefulWidget {
  const ServiceProviderSetupScreen({super.key});

  @override
  State<ServiceProviderSetupScreen> createState() =>
      _ServiceProviderSetupScreenState();
}

class _ServiceProviderSetupScreenState
    extends State<ServiceProviderSetupScreen> {
  static const _defaultProviderImagePath =
      'assets/images/onboarding/pexels-bulat843-1243575272-28995187.jpg';
  static const _experienceOptions = <String>[
    'Less than 1 year',
    '1-2 years',
    '2-4 years',
    '5+ years',
  ];
  static const _experienceChargeLimits = <String, double>{
    'Less than 1 year': 20,
    '1-2 years': 30,
    '2-4 years': 40,
    '5+ years': 50,
  };

  static const _steps = <_SetupStep>[
    _SetupStep.experience,
    _SetupStep.location,
    _SetupStep.idCard,
    _SetupStep.services,
    _SetupStep.availability,
  ];

  late final TextEditingController _addressController = TextEditingController(
    text: AuthSession.displayLocationLabel,
  );
  late final TextEditingController _serviceChargeController =
      TextEditingController(text: '24');

  late final Map<_WeekDay, _DayAvailability> _weeklyAvailability = {
    for (final day in _WeekDay.values)
      day: _DayAvailability(
        isClosed: true,
        startTime: BusinessHours.openingTime,
        endTime: BusinessHours.closingTime,
      ),
  };

  final ImagePicker _imagePicker = ImagePicker();

  int _currentStepIndex = 0;
  String _selectedExperience = _experienceOptions[1];
  String? _idCardImagePath;
  String? _idCardValidationMessage;
  List<String> _selectedServiceLabels = const [];
  bool _isPickingImage = false;
  bool _isSubmitting = false;

  bool get _isLastStep => _currentStepIndex == _steps.length - 1;

  _SetupStep get _currentStep => _steps[_currentStepIndex];

  double get _selectedExperienceChargeLimit =>
      _experienceChargeLimits[_selectedExperience] ?? 50;

  @override
  void initState() {
    super.initState();
    _serviceChargeController.addListener(_handleServiceChargeChanged);
  }

  @override
  void dispose() {
    _serviceChargeController.removeListener(_handleServiceChargeChanged);
    _addressController.dispose();
    _serviceChargeController.dispose();
    super.dispose();
  }

  void _goBack() {
    if (_currentStepIndex == 0) {
      context.goToLocationAccess();
      return;
    }

    setState(() {
      _currentStepIndex--;
    });
  }

  Future<void> _continue() async {
    FocusScope.of(context).unfocus();

    final validationMessage = _validateCurrentStep();
    if (validationMessage != null) {
      _showMessage(validationMessage);
      return;
    }

    if (_isLastStep) {
      setState(() {
        _isSubmitting = true;
      });

      try {
        final currentLocation = AuthSession.currentLocationDetails;
        if (currentLocation != null) {
          AuthSession.setCurrentLocationDetails(
            currentLocation.copyWith(label: _addressController.text.trim()),
          );
        } else {
          AuthSession.setCurrentLocationLabel(_addressController.text.trim());
        }
        await ProviderCatalog.saveOrUpdateProvider(_buildProviderProfile());
        AuthSession.setAuthenticated(true);
        AuthSession.setProviderSetupCompleted(true);

        if (!mounted) {
          return;
        }

        await _showCompletionDialog();
        if (!mounted) {
          return;
        }
        context.goToHome();
      } finally {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });
        }
      }
      return;
    }

    setState(() {
      _currentStepIndex++;
    });
  }

  String? _validateCurrentStep() {
    switch (_currentStep) {
      case _SetupStep.experience:
        if (_selectedExperience.trim().isEmpty) {
          return 'Please select your experience.';
        }
        final serviceCharge = _parseServiceCharge();
        if (serviceCharge == null) {
          return 'Please enter valid service charges.';
        }
        if (serviceCharge > _selectedExperienceChargeLimit) {
          return 'For $_selectedExperience, service charges cannot be more than ${_formatCurrencyLabel(_selectedExperienceChargeLimit)}.';
        }
        return null;
      case _SetupStep.location:
        if (_addressController.text.trim().isEmpty) {
          return 'Please enter your service provider address.';
        }
        return null;
      case _SetupStep.idCard:
        if (_idCardImagePath == null || _idCardImagePath!.trim().isEmpty) {
          return 'Please upload your ID card.';
        }
        return null;
      case _SetupStep.services:
        if (_selectedServiceLabels.isEmpty) {
          return 'Please select at least one service.';
        }
        return null;
      case _SetupStep.availability:
        final openDays = _weeklyAvailability.entries
            .where((entry) => !entry.value.isClosed)
            .toList(growable: false);

        if (openDays.isEmpty) {
          return 'Please keep at least one day available.';
        }

        for (final entry in openDays) {
          if (!_isValidTimeRange(entry.value)) {
            return 'End time must be after start time for ${entry.key.label}.';
          }
        }

        return null;
    }
  }

  bool _isValidTimeRange(_DayAvailability availability) {
    final startMinutes =
        (availability.startTime.hour * 60) + availability.startTime.minute;
    final endMinutes =
        (availability.endTime.hour * 60) + availability.endTime.minute;
    return endMinutes > startMinutes;
  }

  void _handleServiceChargeChanged() {
    final didClamp = _enforceServiceChargeLimit();
    if (!didClamp && mounted) {
      setState(() {});
    }
  }

  bool _enforceServiceChargeLimit() {
    final serviceCharge = _parseServiceCharge();
    if (serviceCharge == null ||
        serviceCharge <= _selectedExperienceChargeLimit) {
      return false;
    }

    final limitedValue = _selectedExperienceChargeLimit % 1 == 0
        ? _selectedExperienceChargeLimit.toStringAsFixed(0)
        : _selectedExperienceChargeLimit.toStringAsFixed(2);

    _serviceChargeController.value = TextEditingValue(
      text: limitedValue,
      selection: TextSelection.collapsed(offset: limitedValue.length),
    );

    if (mounted) {
      setState(() {});
    }

    return true;
  }

  void _handleExperienceChanged(String value) {
    setState(() {
      _selectedExperience = value;
    });

    final didClamp = _enforceServiceChargeLimit();
    if (didClamp) {
      _showMessage(
        'For $value, maximum service charge is ${_formatCurrencyLabel(_selectedExperienceChargeLimit)}.',
      );
    }
  }

  Future<void> _pickIdCardImage() async {
    FocusScope.of(context).unfocus();

    final source = await _showImageSourceSheet();
    if (!mounted || source == null) {
      return;
    }

    await _pickSingleImage(
      source: source,
      validateAsIdCard: true,
      onImagePicked: (path) {
        setState(() {
          _idCardImagePath = path;
          _idCardValidationMessage = null;
        });
      },
    );
  }

  Future<void> _pickSingleImage({
    required ImageSource source,
    required ValueChanged<String> onImagePicked,
    bool validateAsIdCard = false,
  }) async {
    if (_isPickingImage) {
      return;
    }

    setState(() {
      _isPickingImage = true;
    });

    try {
      final permissionStatus = source == ImageSource.camera
          ? await AppPermissionService.requestCameraPermission()
          : await AppPermissionService.requestGalleryPermission();

      if (!mounted) {
        return;
      }

      if (permissionStatus == AppPermissionStatus.denied) {
        _showImagePermissionMessage(source: source, openSettings: false);
        return;
      }

      if (permissionStatus == AppPermissionStatus.permanentlyDenied) {
        await AppPermissionService.openAppSettings();
        if (!mounted) {
          return;
        }
        _showImagePermissionMessage(source: source, openSettings: true);
        return;
      }

      final pickedFile = await _imagePicker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1400,
      );

      if (!mounted || pickedFile == null) {
        return;
      }

      if (validateAsIdCard) {
        final validationMessage = await _validatePickedIdCard(pickedFile.path);
        if (!mounted) {
          return;
        }

        if (validationMessage != null) {
          setState(() {
            _idCardImagePath = null;
            _idCardValidationMessage = validationMessage;
          });
          _showMessage(validationMessage);
          return;
        }
      }

      onImagePicked(pickedFile.path);
    } catch (_) {
      if (!mounted) {
        return;
      }
      _showMessage('Image upload nahi ho saki. Dubara try karein.');
    } finally {
      if (mounted) {
        setState(() {
          _isPickingImage = false;
        });
      }
    }
  }

  Future<ImageSource?> _showImageSourceSheet() {
    return showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: AppColors.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (bottomSheetContext) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: SizedBox(
                    width: 46,
                    child: Divider(thickness: 4, color: AppColors.border),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Choose ID Card Image',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Choose a clear close-up photo of your original ID card only.',
                  style: TextStyle(
                    fontSize: 12.5,
                    height: 1.35,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 14),
                _ImageSourceTile(
                  icon: Icons.photo_library_outlined,
                  title: 'Choose from Gallery',
                  onTap: () =>
                      Navigator.of(bottomSheetContext).pop(ImageSource.gallery),
                ),
                const SizedBox(height: 10),
                _ImageSourceTile(
                  icon: Icons.photo_camera_outlined,
                  title: 'Open Camera',
                  onTap: () =>
                      Navigator.of(bottomSheetContext).pop(ImageSource.camera),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showImagePermissionMessage({
    required ImageSource source,
    required bool openSettings,
  }) {
    final message = switch ((source, openSettings)) {
      (ImageSource.camera, true) =>
        'Allow camera access in settings so you can capture your ID card.',
      (ImageSource.camera, false) =>
        'Allow camera access to capture your ID card.',
      (_, true) =>
        'Allow gallery access in settings so you can choose your ID card image.',
      _ => 'Allow gallery access to choose your ID card image.',
    };

    _showMessage(message);
  }

  Future<String?> _validatePickedIdCard(String imagePath) async {
    try {
      final imageFile = File(imagePath);
      final fileSize = await imageFile.length();
      if (fileSize < 45 * 1024) {
        return 'Upload a clear ID card image. The file looks too small.';
      }

      final imageBytes = await imageFile.readAsBytes();
      final buffer = await ui.ImmutableBuffer.fromUint8List(imageBytes);
      final descriptor = await ui.ImageDescriptor.encoded(buffer);

      final width = descriptor.width.toDouble();
      final height = descriptor.height.toDouble();

      buffer.dispose();
      descriptor.dispose();

      if (width < 700 || height < 420) {
        return 'Upload a clear close-up image of your ID card.';
      }

      if (width <= height) {
        return 'Capture the ID card straight and in landscape view.';
      }

      final aspectRatio = width / height;
      if (aspectRatio < 1.38 || aspectRatio > 1.72) {
        return 'Upload only a close-up photo of the ID card. Other pictures will not be accepted.';
      }

      return null;
    } catch (_) {
      return 'We could not verify the ID card image. Please upload a clear close-up photo again.';
    }
  }

  Future<void> _pickTime(_WeekDay day, bool isStartTime) async {
    final currentAvailability = _weeklyAvailability[day]!;
    final initialTime = isStartTime
        ? currentAvailability.startTime
        : currentAvailability.endTime;

    final selectedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.brandGreen,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedTime != null && mounted) {
      final int pickedMinutes = selectedTime.hour * 60 + selectedTime.minute;
      final int minMinutes = 9 * 60; // 9:00 AM
      final int maxMinutes = 17 * 60; // 5:00 PM

      if (pickedMinutes < minMinutes || pickedMinutes > maxMinutes) {
        _showMessage('You can only select a time between 9:00 AM and 5:00 PM.');
        return;
      }

      setState(() {
        if (isStartTime) {
          _weeklyAvailability[day] =
              currentAvailability.copyWith(startTime: selectedTime);
        } else {
          _weeklyAvailability[day] =
              currentAvailability.copyWith(endTime: selectedTime);
        }
      });
    }
  }

  void _toggleClosed(_WeekDay day, bool isClosed) {
    final currentAvailability = _weeklyAvailability[day]!;
    setState(() {
      _weeklyAvailability[day] = currentAvailability.copyWith(
        isClosed: isClosed,
      );
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _toggleSelectedService(String serviceLabel) {
    setState(() {
      if (_selectedServiceLabels.contains(serviceLabel)) {
        _selectedServiceLabels = _selectedServiceLabels
            .where((label) => label != serviceLabel)
            .toList(growable: false);
      } else {
        _selectedServiceLabels = [..._selectedServiceLabels, serviceLabel];
      }
    });
  }

  double? _parseServiceCharge() {
    final normalizedValue = _serviceChargeController.text
        .replaceAll(RegExp(r'[^0-9.]'), '')
        .trim();
    if (normalizedValue.isEmpty) {
      return null;
    }

    final amount = double.tryParse(normalizedValue);
    if (amount == null || amount <= 0) {
      return null;
    }

    return amount;
  }

  ServiceProviderProfile _buildProviderProfile() {
    final joinedAt = DateTime.now();
    final providerImagePath = _defaultProviderImagePath;
    final availabilityLabel = _buildAvailabilityLabel();
    final serviceCharge = _parseServiceCharge() ?? 24;

    return ServiceProviderProfile(
      id: ProviderCatalog.currentSessionProviderId,
      name: AuthSession.displayName,
      price: _formatServiceChargeLabel(serviceCharge),
      rating: '5.0',
      reviews: 'New',
      imagePath: providerImagePath,
      mainImageUrl: providerImagePath,
      galleryImageUrls: const [_defaultProviderImagePath],
      description: _buildProviderDescription(),
      searchTerms: _buildSearchTerms(),
      supportedServices: List<String>.from(_selectedServiceLabels),
      location: _addressController.text.trim(),
      availability: availabilityLabel,
      latitude: AuthSession.currentLatitude,
      longitude: AuthSession.currentLongitude,
      isNewProvider: true,
      joinedAt: joinedAt,
    );
  }

  String _buildProviderDescription() {
    final displayName = AuthSession.displayName;
    final area = _addressController.text.trim().isNotEmpty
        ? _addressController.text.trim()
        : AuthSession.displayLocationLabel;
    final servicesSummary = _selectedServiceLabels.isEmpty
        ? 'general car wash services'
        : _selectedServiceLabels.join(', ');

    return '$displayName is a newly joined service provider offering $servicesSummary with careful finishing and doorstep support for customers in $area. ${_selectedExperience.toLowerCase()} experience on record.';
  }

  List<String> _buildSearchTerms() {
    final terms = <String>{
      ...AuthSession.displayName
          .toLowerCase()
          .split(RegExp(r'[^a-z0-9]+'))
          .where((item) => item.isNotEmpty),
      ..._addressController.text
          .toLowerCase()
          .split(RegExp(r'[^a-z0-9]+'))
          .where((item) => item.isNotEmpty),
      'car wash',
      'new provider',
      'service provider',
      'detail',
      'foam',
      ..._selectedServiceLabels
          .map((label) => label.toLowerCase())
          .expand((label) => label.split(RegExp(r'[^a-z0-9]+')))
          .where((item) => item.isNotEmpty),
    };

    return terms.toList(growable: false);
  }

  String _buildAvailabilityLabel() {
    final openDays = _weeklyAvailability.entries
        .where((entry) => !entry.value.isClosed)
        .toList(growable: false);

    if (openDays.isEmpty) {
      return 'Availability updates soon';
    }

    return BusinessHours.label;
  }

  String _formatServiceChargeLabel(double amount) {
    final wholeAmount = amount.roundToDouble() == amount;
    return wholeAmount
        ? '\$${amount.toStringAsFixed(0)}'
        : '\$${amount.toStringAsFixed(2)}';
  }

  String _formatCurrencyLabel(double amount) {
    final wholeAmount = amount.roundToDouble() == amount;
    return wholeAmount
        ? '\$${amount.toStringAsFixed(0)}'
        : '\$${amount.toStringAsFixed(2)}';
  }

  Future<void> _showCompletionDialog() async {
    if (!mounted) return;
    final completer = Completer<void>();

    Future<void>.delayed(const Duration(milliseconds: 1700), () {
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      if (!completer.isCompleted) completer.complete();
    });

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.34),
      builder: (dialogContext) {
        return const Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: EdgeInsets.symmetric(horizontal: 36),
          child: _SetupCompleteDialog(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBackground,
      body: SafeArea(
        child: Column(
          children: [
            _ProviderSetupTopBar(
              title: _currentStep.topBarTitle,
              onBack: _goBack,
            ),
            Divider(height: 1, thickness: 0.8, color: AppColors.border),
            _SetupProgressHeader(
              currentStepIndex: _currentStepIndex,
              totalSteps: _steps.length,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  child: _buildStepContent(),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 22),
              child: AppPrimaryButton(
                key: const Key('service_provider_setup_next_button'),
                label: _isSubmitting ? 'Saving...' : 'Next',
                onPressed: _isPickingImage || _isSubmitting ? null : _continue,
                textStyle: const TextStyle(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case _SetupStep.experience:
        return _ExperienceStep(
          key: const ValueKey(_SetupStep.experience),
          selectedExperience: _selectedExperience,
          serviceChargeController: _serviceChargeController,
          maxChargeLimit: _selectedExperienceChargeLimit,
          options: _experienceOptions,
          onChanged: _handleExperienceChanged,
        );
      case _SetupStep.location:
        return _LocationStep(
          key: const ValueKey(_SetupStep.location),
          addressController: _addressController,
          currentLocation: AuthSession.currentLocationDetails,
          currentLocationLabel: AuthSession.displayLocationLabel,
        );
      case _SetupStep.idCard:
        return _IdCardStep(
          key: const ValueKey(_SetupStep.idCard),
          imagePath: _idCardImagePath,
          validationMessage: _idCardValidationMessage,
          isUploading: _isPickingImage,
          onUpload: _pickIdCardImage,
        );
      case _SetupStep.services:
        return _ServicesStep(
          key: const ValueKey(_SetupStep.services),
          services: ServiceCatalog.allServices,
          selectedServices: _selectedServiceLabels,
          onToggleService: _toggleSelectedService,
        );
      case _SetupStep.availability:
        return _AvailabilityStep(
          key: const ValueKey(_SetupStep.availability),
          availability: _weeklyAvailability,
          onToggleClosed: _toggleClosed,
          onPickTime: _pickTime,
        );
    }
  }
}

enum _SetupStep {
  experience,
  location,
  idCard,
  services,
  availability;

  String get topBarTitle {
    switch (this) {
      case _SetupStep.services:
        return 'Services';
      case _SetupStep.experience:
      case _SetupStep.location:
      case _SetupStep.idCard:
      case _SetupStep.availability:
        return 'Profile';
    }
  }
}

enum _WeekDay {
  sunday('Sunday'),
  monday('Monday'),
  tuesday('Tuesday'),
  wednesday('Wednesday'),
  thursday('Thursday'),
  friday('Friday'),
  saturday('Saturday');

  const _WeekDay(this.label);

  final String label;
}

class _DayAvailability {
  const _DayAvailability({
    required this.isClosed,
    required this.startTime,
    required this.endTime,
  });

  final bool isClosed;
  final TimeOfDay startTime;
  final TimeOfDay endTime;

  _DayAvailability copyWith({
    bool? isClosed,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
  }) {
    return _DayAvailability(
      isClosed: isClosed ?? this.isClosed,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
    );
  }
}

class _ProviderSetupTopBar extends StatelessWidget {
  const _ProviderSetupTopBar({required this.title, required this.onBack});

  final String title;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: Stack(
        children: [
          Positioned(
            left: 8,
            top: 0,
            bottom: 0,
            child: IconButton(
              onPressed: onBack,
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppButtonColors.actionForeground,
                size: 18,
              ),
            ),
          ),
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 56),
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SetupProgressHeader extends StatelessWidget {
  const _SetupProgressHeader({
    required this.currentStepIndex,
    required this.totalSteps,
  });

  final int currentStepIndex;
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 8),
      child: Row(
        children: List.generate(totalSteps, (index) {
          final isActive = index <= currentStepIndex;
          return Expanded(
            child: Container(
              height: 3,
              margin: EdgeInsets.only(right: index == totalSteps - 1 ? 0 : 6),
              decoration: BoxDecoration(
                color: isActive ? AppColors.brandGreen : AppColors.border,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _SetupCompleteDialog extends StatelessWidget {
  const _SetupCompleteDialog();

  @override
  Widget build(BuildContext context) {
    const dotOffsets = <Offset>[
      Offset(-58, -26),
      Offset(-42, -4),
      Offset(-20, -38),
      Offset(18, -40),
      Offset(40, -8),
      Offset(58, -28),
      Offset(-30, 30),
      Offset(34, 28),
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.22),
            blurRadius: 30,
            offset: Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 140,
            height: 120,
            child: Stack(
              alignment: Alignment.center,
              children: [
                for (final offset in dotOffsets)
                  Transform.translate(
                    offset: offset,
                    child: Container(
                      width: offset.dx.abs() > 50 ? 4 : 6,
                      height: offset.dx.abs() > 50 ? 4 : 6,
                      decoration: const BoxDecoration(
                        color: AppColors.brandGreen,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                Container(
                  width: 70,
                  height: 70,
                  decoration: const BoxDecoration(
                    color: AppColors.brandGreen,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.14),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Congratulations!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Your Profile has been completed',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12.6, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _ExperienceStep extends StatelessWidget {
  const _ExperienceStep({
    super.key,
    required this.selectedExperience,
    required this.serviceChargeController,
    required this.maxChargeLimit,
    required this.options,
    required this.onChanged,
  });

  final String selectedExperience;
  final TextEditingController serviceChargeController;
  final double maxChargeLimit;
  final List<String> options;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'How much is your experience? *',
          style: TextStyle(
            fontSize: 14.5,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedExperience,
              isExpanded: true,
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.textMuted,
              ),
              dropdownColor: AppColors.surfaceElevated,
              style: const TextStyle(
                fontSize: 13.5,
                color: AppColors.textPrimary,
              ),
              items: options
                  .map(
                    (option) => DropdownMenuItem<String>(
                      value: option,
                      child: Text(option),
                    ),
                  )
                  .toList(growable: false),
              onChanged: (value) {
                if (value != null) {
                  onChanged(value);
                }
              },
            ),
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'Set your service charges *',
          style: TextStyle(
            fontSize: 14.5,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: TextField(
            controller: serviceChargeController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
            ],
            cursorColor: AppColors.brandGreen,
            style: const TextStyle(
              fontSize: 13.8,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            decoration: const InputDecoration(
              filled: false,
              prefixText: '\$ ',
              prefixStyle: TextStyle(
                fontSize: 13.8,
                fontWeight: FontWeight.w700,
                color: AppColors.brandGreenLight,
              ),
              hintText: '24',
              hintStyle: TextStyle(fontSize: 13.5, color: AppColors.textMuted),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Customers will see this amount on your profile before booking. Max allowed for $selectedExperience is ${_formatCurrencyLabel(maxChargeLimit)}.',
          style: const TextStyle(
            fontSize: 12.2,
            height: 1.35,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  String _formatCurrencyLabel(double amount) {
    final wholeAmount = amount.roundToDouble() == amount;
    return wholeAmount
        ? '\$${amount.toStringAsFixed(0)}'
        : '\$${amount.toStringAsFixed(2)}';
  }
}

class _LocationStep extends StatelessWidget {
  const _LocationStep({
    super.key,
    required this.addressController,
    required this.currentLocation,
    required this.currentLocationLabel,
  });

  final TextEditingController addressController;
  final AppLocationDetails? currentLocation;
  final String currentLocationLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select the Location *',
          style: TextStyle(
            fontSize: 14.5,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        _LocationPreviewCard(currentLocation: currentLocation),
        const SizedBox(height: 14),
        const Text(
          'Service provider Address',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 3),
                    child: Icon(
                      Icons.location_on_rounded,
                      size: 18,
                      color: AppColors.brandGreen,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: addressController,
                      minLines: 1,
                      maxLines: 2,
                      cursorColor: AppColors.brandGreen,
                      decoration: const InputDecoration(
                        isDense: true,
                        border: InputBorder.none,
                        hintText: 'Enter your address',
                        hintStyle: TextStyle(
                          fontSize: 13.5,
                          color: AppColors.textMuted,
                        ),
                      ),
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Current detected location: $currentLocationLabel',
                style: const TextStyle(
                  fontSize: 12.2,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _IdCardStep extends StatelessWidget {
  const _IdCardStep({
    super.key,
    required this.imagePath,
    required this.validationMessage,
    required this.isUploading,
    required this.onUpload,
  });

  final String? imagePath;
  final String? validationMessage;
  final bool isUploading;
  final VoidCallback onUpload;

  @override
  Widget build(BuildContext context) {
    final hasImage = imagePath != null && imagePath!.trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Provide your ID card *',
          style: TextStyle(
            fontSize: 14.5,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              if (hasImage)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    File(imagePath!),
                    height: 170,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                )
              else ...[
                Container(
                  width: 42,
                  height: 42,
                  decoration: const BoxDecoration(
                    color: AppColors.brandGreen,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.add_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Add ID card',
                  style: TextStyle(
                    fontSize: 13.2,
                    fontWeight: FontWeight.w600,
                    color: AppColors.brandGreen,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Add image of your ID card',
                  style: TextStyle(
                    fontSize: 12.2,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              SizedBox(
                width: 132,
                child: FilledButton(
                  onPressed: isUploading ? null : onUpload,
                  style: AppButtonStyles.filled(),
                  child: Text(hasImage ? 'Replace' : 'Upload'),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                validationMessage ??
                    'Upload only a clear close-up ID card image from your gallery or camera.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11.8,
                  height: 1.35,
                  color: validationMessage == null
                      ? AppColors.textSecondary
                      : const Color(0xFFFF8A80),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ImageSourceTile extends StatelessWidget {
  const _ImageSourceTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.inputFill,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.brandGreen),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}

class _ServicesStep extends StatelessWidget {
  const _ServicesStep({
    super.key,
    required this.services,
    required this.selectedServices,
    required this.onToggleService,
  });

  final List<ServiceItem> services;
  final List<String> selectedServices;
  final ValueChanged<String> onToggleService;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select the services you provide *',
          style: TextStyle(
            fontSize: 14.5,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Choose all services you want customers to book from your profile.',
          style: TextStyle(
            fontSize: 12,
            height: 1.4,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, constraints) {
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              itemCount: services.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 24,
                crossAxisSpacing: 18,
                childAspectRatio: 0.72,
              ),
              itemBuilder: (context, index) {
                final service = services[index];
                return _ServiceSelectionChip(
                  service: service,
                  isSelected: selectedServices.contains(service.label),
                  onTap: () => onToggleService(service.label),
                );
              },
            );
          },
        ),
        if (selectedServices.isNotEmpty) ...[
          const SizedBox(height: 14),
          Text(
            "Selected: ${selectedServices.join(', ')}",
            style: const TextStyle(
              fontSize: 12.4,
              height: 1.35,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}

class _ServiceSelectionChip extends StatelessWidget {
  const _ServiceSelectionChip({
    required this.service,
    required this.isSelected,
    required this.onTap,
  });

  final ServiceItem service;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.surfaceHighlight
              : AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.brandGreen : AppColors.border,
            width: isSelected ? 1.3 : 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.brandGreen
                      : AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  service.icon,
                  color: isSelected ? Colors.white : service.iconColor,
                  size: 28,
                ),
              ),
              const SizedBox(height: 4),
              Expanded(
                child: Center(
                  child: Text(
                    service.label,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                      color: isSelected
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Icon(
                isSelected
                    ? Icons.check_circle_rounded
                    : Icons.add_circle_outline_rounded,
                size: 18,
                color: isSelected
                    ? AppColors.brandGreenLight
                    : AppColors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AvailabilityStep extends StatelessWidget {
  const _AvailabilityStep({
    super.key,
    required this.availability,
    required this.onToggleClosed,
    required this.onPickTime,
  });

  final Map<_WeekDay, _DayAvailability> availability;
  final void Function(_WeekDay day, bool isClosed) onToggleClosed;
  final Future<void> Function(_WeekDay day, bool isStartTime) onPickTime;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select your hourly availability',
          style: TextStyle(
            fontSize: 14.5,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Service providers are available from 9:00 AM to 5:00 PM. Select the days you are available for booking.',
          style: TextStyle(
            fontSize: 12,
            height: 1.4,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 14),
        for (var index = 0; index < _WeekDay.values.length; index++) ...[
          _AvailabilityDayRow(
            day: _WeekDay.values[index],
            availability: availability[_WeekDay.values[index]]!,
            onToggleClosed: (value) =>
                onToggleClosed(_WeekDay.values[index], value),
            onPickStartTime: () => onPickTime(_WeekDay.values[index], true),
            onPickEndTime: () => onPickTime(_WeekDay.values[index], false),
          ),
          if (index != _WeekDay.values.length - 1) const SizedBox(height: 14),
        ],
      ],
    );
  }
}

class _AvailabilityDayRow extends StatelessWidget {
  const _AvailabilityDayRow({
    required this.day,
    required this.availability,
    required this.onToggleClosed,
    required this.onPickStartTime,
    required this.onPickEndTime,
  });

  final _WeekDay day;
  final _DayAvailability availability;
  final ValueChanged<bool> onToggleClosed;
  final VoidCallback onPickStartTime;
  final VoidCallback onPickEndTime;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 78,
          child: Text(
            day.label,
            style: const TextStyle(
              fontSize: 12.8,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        SizedBox(
          width: 88,
          child: InkWell(
            onTap: () => onToggleClosed(!availability.isClosed),
            borderRadius: BorderRadius.circular(6),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: !availability.isClosed
                        ? AppColors.brandGreen
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(2),
                    border: Border.all(
                      color: !availability.isClosed
                          ? AppColors.brandGreen
                          : AppColors.border,
                    ),
                  ),
                  child: !availability.isClosed
                      ? const Icon(Icons.check, size: 11, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 8),
                Text(
                  !availability.isClosed ? 'Open' : 'Closed',
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: _TimeCard(
                  label: 'Start time',
                  value: _formatTime(availability.startTime),
                  isDisabled: availability.isClosed,
                  onTap: onPickStartTime,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _TimeCard(
                  label: 'End time',
                  value: _formatTime(availability.endTime),
                  isDisabled: availability.isClosed,
                  onTap: onPickEndTime,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }
}

class _TimeCard extends StatelessWidget {
  const _TimeCard({
    required this.label,
    required this.value,
    required this.isDisabled,
    required this.onTap,
  });

  final String label;
  final String value;
  final bool isDisabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isDisabled ? 0.55 : 1,
      child: InkWell(
        onTap: isDisabled ? null : onTap,
        borderRadius: BorderRadius.circular(8),
        child: Ink(
          padding: const EdgeInsets.fromLTRB(8, 7, 8, 7),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 9.5,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      value,
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.access_time_rounded,
                    size: 14,
                    color: AppColors.brandGreen,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LocationPreviewCard extends StatelessWidget {
  const _LocationPreviewCard({required this.currentLocation});

  final AppLocationDetails? currentLocation;

  @override
  Widget build(BuildContext context) {
    final previewLocation = currentLocation;

    return Container(
      width: double.infinity,
      height: 248,
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: previewLocation == null
          ? const Center(
              child: Text(
                'Current location unavailable',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            )
          : Stack(
              children: [
                Positioned.fill(
                  child: ThemedGoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(
                        previewLocation.latitude,
                        previewLocation.longitude,
                      ),
                      zoom: 15.3,
                    ),
                    scrollGesturesEnabled: false,
                    zoomGesturesEnabled: false,
                    rotateGesturesEnabled: false,
                    tiltGesturesEnabled: false,
                    markers: {
                      Marker(
                        markerId: const MarkerId('provider_setup_location'),
                        position: LatLng(
                          previewLocation.latitude,
                          previewLocation.longitude,
                        ),
                        infoWindow: InfoWindow(
                          title: 'Current provider location',
                          snippet: previewLocation.displayLabel,
                        ),
                      ),
                    },
                  ),
                ),
                Positioned(
                  left: 12,
                  right: 12,
                  top: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated.withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'This map is using the exact location captured from the device permission flow.',
                      style: TextStyle(
                        fontSize: 11.8,
                        height: 1.3,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
