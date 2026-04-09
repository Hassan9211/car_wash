import 'dart:io';

import 'package:car_wash/core/location/app_location_details.dart';
import 'package:car_wash/core/router/app_navigation.dart';
import 'package:car_wash/core/services/app_permission_service.dart';
import 'package:car_wash/core/theme/app_button_colors.dart';
import 'package:car_wash/core/theme/app_colors.dart';
import 'package:car_wash/core/widgets/app_buttons.dart';
import 'package:car_wash/core/widgets/themed_google_map.dart';
import 'package:car_wash/features/authentication/data/auth_session.dart';
import 'package:car_wash/features/home/data/provider_catalog.dart';
import 'package:car_wash/features/home/model/service_provider_profile.dart';
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

  static const _steps = <_SetupStep>[
    _SetupStep.experience,
    _SetupStep.location,
    _SetupStep.idCard,
    _SetupStep.gallery,
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
        isClosed: false,
        startTime: const TimeOfDay(hour: 9, minute: 30),
        endTime: const TimeOfDay(hour: 13, minute: 30),
      ),
  };

  final ImagePicker _imagePicker = ImagePicker();

  int _currentStepIndex = 0;
  String _selectedExperience = _experienceOptions[1];
  String? _idCardImagePath;
  List<String> _galleryImagePaths = const [];
  bool _isPickingImage = false;
  bool _isSubmitting = false;

  bool get _isLastStep => _currentStepIndex == _steps.length - 1;

  _SetupStep get _currentStep => _steps[_currentStepIndex];

  @override
  void dispose() {
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
        if (_parseServiceCharge() == null) {
          return 'Please enter valid service charges.';
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
      case _SetupStep.gallery:
        if (_galleryImagePaths.isEmpty) {
          return 'Please upload at least one work image.';
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

  Future<void> _pickIdCardImage() async {
    await _pickSingleImage(
      onImagePicked: (path) {
        setState(() {
          _idCardImagePath = path;
        });
      },
    );
  }

  Future<void> _pickGalleryImages() async {
    if (_isPickingImage) {
      return;
    }

    setState(() {
      _isPickingImage = true;
    });

    try {
      final permissionStatus =
          await AppPermissionService.requestGalleryPermission();

      if (!mounted) {
        return;
      }

      if (permissionStatus == AppPermissionStatus.denied) {
        _showMessage(
          'Gallery access allow karein taake images choose kar saken.',
        );
        return;
      }

      if (permissionStatus == AppPermissionStatus.permanentlyDenied) {
        await AppPermissionService.openAppSettings();
        if (!mounted) {
          return;
        }
        _showMessage(
          'Gallery access settings mein allow karein taake images choose kar saken.',
        );
        return;
      }

      final pickedFiles = await _imagePicker.pickMultiImage(
        imageQuality: 85,
        maxWidth: 1400,
      );

      if (!mounted || pickedFiles.isEmpty) {
        return;
      }

      setState(() {
        _galleryImagePaths = {
          ..._galleryImagePaths,
          ...pickedFiles.map((file) => file.path),
        }.toList(growable: false);
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      _showMessage('Images upload nahi ho sakin. Dubara try karein.');
    } finally {
      if (mounted) {
        setState(() {
          _isPickingImage = false;
        });
      }
    }
  }

  Future<void> _pickSingleImage({
    required ValueChanged<String> onImagePicked,
  }) async {
    if (_isPickingImage) {
      return;
    }

    setState(() {
      _isPickingImage = true;
    });

    try {
      final permissionStatus =
          await AppPermissionService.requestGalleryPermission();

      if (!mounted) {
        return;
      }

      if (permissionStatus == AppPermissionStatus.denied) {
        _showMessage(
          'Gallery access allow karein taake image choose kar saken.',
        );
        return;
      }

      if (permissionStatus == AppPermissionStatus.permanentlyDenied) {
        await AppPermissionService.openAppSettings();
        if (!mounted) {
          return;
        }
        _showMessage(
          'Gallery access settings mein allow karein taake image choose kar saken.',
        );
        return;
      }

      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1400,
      );

      if (!mounted || pickedFile == null) {
        return;
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

  Future<void> _pickTime(_WeekDay day, bool isStartTime) async {
    final currentAvailability = _weeklyAvailability[day]!;
    final initialTime = isStartTime
        ? currentAvailability.startTime
        : currentAvailability.endTime;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(
              context,
            ).colorScheme.copyWith(primary: AppColors.brandGreen),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime == null) {
      return;
    }

    setState(() {
      _weeklyAvailability[day] = currentAvailability.copyWith(
        startTime: isStartTime ? pickedTime : currentAvailability.startTime,
        endTime: isStartTime ? currentAvailability.endTime : pickedTime,
      );
    });
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
    final providerImagePath = _galleryImagePaths.isNotEmpty
        ? _galleryImagePaths.first
        : _defaultProviderImagePath;
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
      galleryImageUrls: _galleryImagePaths.isNotEmpty
          ? List<String>.from(_galleryImagePaths)
          : const [_defaultProviderImagePath],
      description: _buildProviderDescription(),
      searchTerms: _buildSearchTerms(),
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

    return '$displayName is a newly joined service provider offering careful exterior washing, neat finishing, and doorstep support for customers in $area. ${_selectedExperience.toLowerCase()} experience on record.';
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

    final firstDay = openDays.first.value;
    final firstStart = _formatTimeLabel(firstDay.startTime);
    final firstEnd = _formatTimeLabel(firstDay.endTime);
    final sameHours = openDays.every(
      (entry) =>
          entry.value.startTime.hour == firstDay.startTime.hour &&
          entry.value.startTime.minute == firstDay.startTime.minute &&
          entry.value.endTime.hour == firstDay.endTime.hour &&
          entry.value.endTime.minute == firstDay.endTime.minute,
    );

    if (sameHours) {
      return '$firstStart - $firstEnd';
    }

    return '${openDays.length} days available each week';
  }

  String _formatServiceChargeLabel(double amount) {
    final wholeAmount = amount.roundToDouble() == amount;
    return wholeAmount
        ? '\$${amount.toStringAsFixed(0)}'
        : '\$${amount.toStringAsFixed(2)}';
  }

  String _formatTimeLabel(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  Future<void> _showCompletionDialog() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.34),
      builder: (dialogContext) {
        Future<void>.delayed(const Duration(milliseconds: 1700), () {
          if (dialogContext.mounted) {
            Navigator.of(dialogContext).pop();
          }
        });

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
          options: _experienceOptions,
          onChanged: (value) {
            setState(() {
              _selectedExperience = value;
            });
          },
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
          isUploading: _isPickingImage,
          onUpload: _pickIdCardImage,
        );
      case _SetupStep.gallery:
        return _GalleryStep(
          key: const ValueKey(_SetupStep.gallery),
          imagePaths: _galleryImagePaths,
          isUploading: _isPickingImage,
          onUpload: _pickGalleryImages,
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
  gallery,
  availability;

  String get topBarTitle {
    switch (this) {
      case _SetupStep.gallery:
        return 'Upload Image';
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
    required this.options,
    required this.onChanged,
  });

  final String selectedExperience;
  final TextEditingController serviceChargeController;
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
              prefixText: '\$ ',
              prefixStyle: TextStyle(
                fontSize: 13.8,
                fontWeight: FontWeight.w700,
                color: AppColors.brandGreenLight,
              ),
              hintText: '24',
              hintStyle: TextStyle(
                fontSize: 13.5,
                color: AppColors.textMuted,
              ),
              border: InputBorder.none,
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Customers will see this amount on your profile before booking.',
          style: TextStyle(
            fontSize: 12.2,
            height: 1.35,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
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
    required this.isUploading,
    required this.onUpload,
  });

  final String? imagePath;
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
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.brandGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(hasImage ? 'Replace' : 'Upload'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _GalleryStep extends StatelessWidget {
  const _GalleryStep({
    super.key,
    required this.imagePaths,
    required this.isUploading,
    required this.onUpload,
  });

  final List<String> imagePaths;
  final bool isUploading;
  final VoidCallback onUpload;

  @override
  Widget build(BuildContext context) {
    final previewImagePath = imagePaths.isNotEmpty ? imagePaths.first : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Upload your work images *',
          style: TextStyle(
            fontSize: 14.5,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          height: 250,
          decoration: BoxDecoration(
            color: AppColors.surfaceMuted,
            borderRadius: BorderRadius.circular(16),
          ),
          child: previewImagePath == null
              ? const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.photo_library_outlined,
                        size: 42,
                        color: AppColors.textMuted,
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Upload service images',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                )
              : ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.file(
                    File(previewImagePath),
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            const Text(
              'Gallery',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 18,
              color: AppColors.textMuted,
            ),
            const Spacer(),
            OutlinedButton.icon(
              onPressed: isUploading ? null : onUpload,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.brandGreen,
                side: const BorderSide(color: AppColors.brandGreen),
              ),
              icon: const Icon(Icons.add_photo_alternate_outlined, size: 18),
              label: const Text('Add photos'),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (imagePaths.isNotEmpty)
          SizedBox(
            height: 86,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: imagePaths.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    File(imagePaths[index]),
                    width: 86,
                    height: 86,
                    fit: BoxFit.cover,
                  ),
                );
              },
            ),
          ),
      ],
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
                    color: availability.isClosed
                        ? AppColors.brandGreen
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(2),
                    border: Border.all(
                      color: availability.isClosed
                          ? AppColors.brandGreen
                          : AppColors.border,
                    ),
                  ),
                  child: availability.isClosed
                      ? const Icon(Icons.check, size: 11, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Closed',
                  style: TextStyle(
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
