import 'package:car_wash/core/theme/app_button_colors.dart';
import 'package:car_wash/core/theme/app_colors.dart';
import 'package:car_wash/core/services/app_permission_service.dart';
import 'package:car_wash/core/widgets/app_buttons.dart';
import 'package:car_wash/features/authentication/data/auth_session.dart';
import 'package:car_wash/features/authentication/utils/auth_validators.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController(
    text: AuthSession.displayName,
  );
  final TextEditingController _emailController = TextEditingController(
    text: AuthSession.displayEmail,
  );
  final TextEditingController _phoneController = TextEditingController(
    text: AuthSession.displayPhoneNumber,
  );
  late final TextEditingController _dateOfBirthController =
      TextEditingController(
    text: AuthSession.displayDateOfBirth,
  );

  late DateTime _selectedDateOfBirth = AuthSession.effectiveDateOfBirth;
  String? _selectedAvatarImagePath = AuthSession.currentAvatarImagePath;
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;
  bool _isPickingImage = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _recoverLostImage();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _dateOfBirthController.dispose();
    super.dispose();
  }

  Future<void> _pickDateOfBirth() async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateOfBirth,
      firstDate: DateTime(1950),
      lastDate: DateTime(now.year - 10, now.month, now.day),
      helpText: 'Select date of birth',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.brandGreen,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate == null || !mounted) {
      return;
    }

    setState(() {
      _selectedDateOfBirth = pickedDate;
      _dateOfBirthController.text = _formatDate(pickedDate);
    });
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      setState(() {
        _autovalidateMode = AutovalidateMode.onUserInteraction;
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      AuthSession.updateProfile(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        dateOfBirth: _selectedDateOfBirth,
        avatarImagePath: _selectedAvatarImagePath,
      );

      if (!mounted) {
        return;
      }

      context.pop(true);
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Future<void> _showPhotoSourceSheet() async {
    FocusScope.of(context).unfocus();

    await showModalBottomSheet<void>(
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
                    child: Divider(
                      thickness: 4,
                      color: AppColors.border,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Choose Photo',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 14),
                _ImageSourceTile(
                  icon: Icons.photo_library_outlined,
                  title: 'Choose from Gallery',
                  onTap: () {
                    Navigator.of(bottomSheetContext).pop();
                    _pickAvatar(ImageSource.gallery);
                  },
                ),
                const SizedBox(height: 10),
                _ImageSourceTile(
                  icon: Icons.photo_camera_outlined,
                  title: 'Open Camera',
                  onTap: () {
                    Navigator.of(bottomSheetContext).pop();
                    _pickAvatar(ImageSource.camera);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickAvatar(ImageSource source) async {
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
        _showImagePermissionMessage(
          source: source,
          openSettings: false,
        );
        return;
      }

      if (permissionStatus == AppPermissionStatus.permanentlyDenied) {
        await AppPermissionService.openAppSettings();
        if (!mounted) {
          return;
        }
        _showImagePermissionMessage(
          source: source,
          openSettings: true,
        );
        return;
      }

      final pickedFile = await ImagePicker().pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1200,
      );

      if (!mounted || pickedFile == null) {
        return;
      }

      setState(() {
        _selectedAvatarImagePath = pickedFile.path;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      _showImagePermissionMessage(
        source: source,
        openSettings: false,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isPickingImage = false;
        });
      }
    }
  }

  void _showImagePermissionMessage({
    required ImageSource source,
    required bool openSettings,
  }) {
    final message = switch ((source, openSettings)) {
      (ImageSource.camera, true) =>
        'Camera access settings mein allow karein taake photo le saken.',
      (ImageSource.camera, false) =>
        'Photo lene ke liye camera access allow karein.',
      (_, true) =>
        'Gallery access settings mein allow karein taake photo choose kar saken.',
      _ => 'Photo choose karne ke liye gallery access allow karein.',
    };

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _recoverLostImage() async {
    try {
      final response = await ImagePicker().retrieveLostData();
      if (!mounted || response.isEmpty) {
        return;
      }

      final file = response.files?.isNotEmpty == true
          ? response.files!.first
          : response.file;
      if (file == null) {
        return;
      }

      setState(() {
        _selectedAvatarImagePath = file.path;
      });
    } catch (_) {
      // Keep the current avatar if recovery fails.
    }
  }

  String? _validatePhoneNumber(String? value) {
    final trimmedValue = value?.trim() ?? '';
    if (trimmedValue.isEmpty) {
      return 'Phone number is required';
    }

    final digitsOnly = trimmedValue.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.length < 10) {
      return 'Enter a valid phone number';
    }

    return null;
  }

  String? _validateDateOfBirth(String? value) {
    final trimmedValue = value?.trim() ?? '';
    if (trimmedValue.isEmpty) {
      return 'Date of birth is required';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.appBackground,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 56,
              child: Stack(
                children: [
                  Positioned(
                    left: 8,
                    top: 0,
                    bottom: 0,
                    child: IconButton(
                      key: const Key('edit_profile_back_button'),
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
                          'User Profile',
                          key: Key('edit_profile_screen_title'),
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
              child: Form(
                key: _formKey,
                autovalidateMode: _autovalidateMode,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 18, 24, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Avatar',
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          _EditProfileAvatar(
                            imagePath: _selectedAvatarImagePath,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AuthSession.displayName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  width: double.infinity,
                                  child: FilledButton.icon(
                                    key: const Key(
                                      'edit_profile_change_avatar_button',
                                    ),
                                    onPressed: _isPickingImage
                                        ? null
                                        : _showPhotoSourceSheet,
                                    style: FilledButton.styleFrom(
                                      backgroundColor: AppColors.brandGreen,
                                      foregroundColor: Colors.white,
                                      minimumSize: const Size.fromHeight(42),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                    ),
                                    icon: const Icon(
                                      Icons.edit_rounded,
                                      size: 16,
                                    ),
                                    label: const Text(
                                      'Edit Profile',
                                      style: TextStyle(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      _ProfileFormField(
                        key: const Key('edit_profile_name_field'),
                        controller: _nameController,
                        label: 'Name',
                        validator: AuthValidators.validateName,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 16),
                      _ProfileFormField(
                        key: const Key('edit_profile_email_field'),
                        controller: _emailController,
                        label: 'Email Address',
                        keyboardType: TextInputType.emailAddress,
                        validator: AuthValidators.validateEmail,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 16),
                      _ProfileFormField(
                        key: const Key('edit_profile_phone_field'),
                        controller: _phoneController,
                        label: 'Phone Number',
                        keyboardType: TextInputType.phone,
                        validator: _validatePhoneNumber,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 16),
                      _ProfileFormField(
                        key: const Key('edit_profile_dob_field'),
                        controller: _dateOfBirthController,
                        label: 'DOB',
                        readOnly: true,
                        onTap: _pickDateOfBirth,
                        validator: _validateDateOfBirth,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              child: AppPrimaryButton(
                key: const Key('edit_profile_update_button'),
                label: _isSubmitting ? 'Updating...' : 'Update',
                onPressed: _isSubmitting ? null : _submit,
                borderRadius: 6,
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

  String _formatDate(DateTime value) {
    const monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${value.day} ${monthNames[value.month - 1]} ${value.year}';
  }
}

class _EditProfileAvatar extends StatelessWidget {
  const _EditProfileAvatar({
    this.imagePath,
  });

  final String? imagePath;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 58,
      height: 58,
      padding: const EdgeInsets.all(1.5),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: ClipOval(
        child: Image(
          image: imagePath != null && imagePath!.trim().isNotEmpty
              ? AuthSession.avatarImageFromPath(imagePath!)
              : AuthSession.avatarImage,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return DecoratedBox(
              decoration: const BoxDecoration(
                color: AppColors.surfaceMuted,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  AuthSession.initials,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.brandGreen,
                  ),
                ),
              ),
            );
          },
        ),
      ),
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
    return Material(
      color: AppColors.surfaceElevated,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: AppColors.brandGreen,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF7C7C7C),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileFormField extends StatelessWidget {
  const _ProfileFormField({
    super.key,
    required this.controller,
    required this.label,
    this.keyboardType,
    this.validator,
    this.onTap,
    this.readOnly = false,
    this.textInputAction,
  });

  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final VoidCallback? onTap;
  final bool readOnly;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14.5,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          onTap: onTap,
          readOnly: readOnly,
          textInputAction: textInputAction,
          cursorColor: AppColors.brandGreen,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.inputFill,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 16,
            ),
            hintStyle: const TextStyle(
              fontSize: 14,
              color: AppColors.textMuted,
            ),
            errorStyle: const TextStyle(
              fontSize: 11.5,
              height: 1.2,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(
                color: AppColors.border,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(
                color: AppColors.border,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(
                color: AppColors.brandGreen,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(
                color: AppButtonColors.destructiveForeground,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(
                color: AppButtonColors.destructiveForeground,
              ),
            ),
          ),
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
