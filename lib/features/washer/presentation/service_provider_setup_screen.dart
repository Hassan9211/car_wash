import 'dart:io';

import 'package:car_wash/core/router/app_navigation.dart';
import 'package:car_wash/core/services/app_permission_service.dart';
import 'package:car_wash/core/theme/app_button_colors.dart';
import 'package:car_wash/core/theme/app_colors.dart';
import 'package:car_wash/core/widgets/app_buttons.dart';
import 'package:car_wash/features/authentication/data/auth_session.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ServiceProviderSetupScreen extends StatefulWidget {
  const ServiceProviderSetupScreen({super.key});

  @override
  State<ServiceProviderSetupScreen> createState() =>
      _ServiceProviderSetupScreenState();
}

class _ServiceProviderSetupScreenState
    extends State<ServiceProviderSetupScreen> {
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
        AuthSession.setCurrentLocationLabel(_addressController.text.trim());
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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _ProviderSetupTopBar(
              title: _currentStep.topBarTitle,
              onBack: _goBack,
            ),
            Divider(
              height: 1,
              thickness: 0.8,
              color: const Color(0xFFE9E6E3).withValues(alpha: 0.9),
            ),
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
                onPressed:
                    _isPickingImage || _isSubmitting ? null : _continue,
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
                    color: Colors.black,
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
                color: isActive
                    ? AppColors.brandGreen
                    : const Color(0xFFE5E7E4),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
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
              color: Color(0xFF202720),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Your Profile has been completed',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12.6, color: Color(0xFF7A867D)),
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
    required this.options,
    required this.onChanged,
  });

  final String selectedExperience;
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
            color: Color(0xFF222222),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE3E5E2)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedExperience,
              isExpanded: true,
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Color(0xFF7B7B7B),
              ),
              style: const TextStyle(fontSize: 13.5, color: Color(0xFF2B2B2B)),
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
      ],
    );
  }
}

class _LocationStep extends StatelessWidget {
  const _LocationStep({
    super.key,
    required this.addressController,
    required this.currentLocationLabel,
  });

  final TextEditingController addressController;
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
            color: Color(0xFF222222),
          ),
        ),
        const SizedBox(height: 12),
        const _LocationPreviewCard(),
        const SizedBox(height: 14),
        const Text(
          'Service provider Address',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF222222),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE5E7E4)),
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
                          color: Color(0xFF97A098),
                        ),
                      ),
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF29312B),
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
                  color: Color(0xFF7F8A83),
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
            color: Color(0xFF222222),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFA8C6AF)),
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
                  style: TextStyle(fontSize: 12.2, color: Color(0xFF889289)),
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
            color: Color(0xFF222222),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          height: 250,
          decoration: BoxDecoration(
            color: const Color(0xFFF2F4F1),
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
                        color: Color(0xFF869189),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Upload service images',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF4B5A50),
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
                color: Color(0xFF222222),
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 18,
              color: Color(0xFF6F776F),
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
            color: Color(0xFF222222),
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
              color: Color(0xFF282828),
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
                          : const Color(0xFFD7DCD8),
                    ),
                  ),
                  child: availability.isClosed
                      ? const Icon(Icons.check, size: 11, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Closed',
                  style: TextStyle(fontSize: 12.5, color: Color(0xFF4D5B52)),
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
            color: const Color(0xFFF9FBF8),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFDDE5DF)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 9.5, color: Color(0xFF7A8A7F)),
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
                        color: Color(0xFF223027),
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
  const _LocationPreviewCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 248,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _MapPreviewPainter())),
          const Center(
            child: Icon(
              Icons.location_on_rounded,
              size: 38,
              color: Color(0xFFE35B50),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapPreviewPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPaint = Paint()..color = const Color(0xFFEEF0EC);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(14)),
      backgroundPaint,
    );

    final linePaint = Paint()
      ..color = const Color(0xFFD9DDD7)
      ..strokeWidth = 2;

    for (var index = 0; index < 7; index++) {
      final dx = (size.width / 6) * index;
      canvas.drawLine(Offset(dx, 0), Offset(dx, size.height), linePaint);
    }

    for (var index = 0; index < 6; index++) {
      final dy = (size.height / 5) * index;
      canvas.drawLine(Offset(0, dy), Offset(size.width, dy), linePaint);
    }

    final roadPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 18
      ..strokeCap = StrokeCap.round;

    final roadShadowPaint = Paint()
      ..color = const Color(0x18000000)
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round;

    final roadPath = Path()
      ..moveTo(size.width * 0.04, size.height * 0.82)
      ..quadraticBezierTo(
        size.width * 0.25,
        size.height * 0.56,
        size.width * 0.42,
        size.height * 0.46,
      )
      ..quadraticBezierTo(
        size.width * 0.62,
        size.height * 0.34,
        size.width * 0.93,
        size.height * 0.12,
      );

    canvas.drawPath(roadPath, roadShadowPaint);
    canvas.drawPath(roadPath, roadPaint);

    final roadPathTwo = Path()
      ..moveTo(size.width * 0.12, size.height * 0.08)
      ..quadraticBezierTo(
        size.width * 0.26,
        size.height * 0.26,
        size.width * 0.46,
        size.height * 0.42,
      )
      ..quadraticBezierTo(
        size.width * 0.72,
        size.height * 0.62,
        size.width * 0.86,
        size.height * 0.92,
      );

    canvas.drawPath(roadPathTwo, roadShadowPaint);
    canvas.drawPath(roadPathTwo, roadPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
