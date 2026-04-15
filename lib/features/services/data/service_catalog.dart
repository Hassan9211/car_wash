import 'package:car_wash/core/theme/app_colors.dart';
import 'package:car_wash/features/services/model/service_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class ServiceCatalog {
  ServiceCatalog._();

  static const featuredServices = <ServiceItem>[
    ServiceItem(
      label: 'Basic wash',
      icon: Icons.local_car_wash_rounded,
      iconColor: AppColors.brandGreen,
      searchTerms: ['basic wash', 'wash', 'car wash'],
      description: 'A quick exterior rinse and hand wash to remove dust and light dirt.',
    ),
    ServiceItem(
      label: 'Vacuum',
      icon: Icons.cleaning_services_rounded,
      iconColor: Color(0xFF4E7D55),
      searchTerms: ['vacuum', 'interior', 'dry clean'],
      description: 'Deep interior vacuuming of seats, floor mats, and cabin corners.',
    ),
    ServiceItem(
      label: 'Foam wash',
      icon: Icons.bubble_chart_rounded,
      iconColor: Color(0xFF0A9F59),
      searchTerms: ['foam wash', 'foam', 'soap'],
      description: 'Rich foam applied to the full exterior for a thorough deep clean.',
    ),
    ServiceItem(
      label: 'Engine',
      icon: Icons.precision_manufacturing_rounded,
      iconColor: Color(0xFF2E7B5C),
      searchTerms: ['engine', 'engine clean'],
      description: 'Safe engine bay cleaning to remove grease, dust, and buildup.',
    ),
    ServiceItem(
      label: 'Wax',
      icon: Icons.auto_awesome_rounded,
      iconColor: Color(0xFFB8860B),
      searchTerms: ['wax', 'polish', 'shine'],
      description: 'Protective wax coat applied to give your car a lasting shine.',
    ),
  ];

  static const allServices = <ServiceItem>[
    ServiceItem(
      label: 'Basic wash',
      icon: Icons.local_car_wash_rounded,
      iconColor: AppColors.brandGreen,
      searchTerms: ['basic wash', 'wash', 'car wash'],
      description: 'A quick exterior rinse and hand wash to remove dust and light dirt.',
    ),
    ServiceItem(
      label: 'Vacuum',
      icon: Icons.cleaning_services_rounded,
      iconColor: Color(0xFF4E7D55),
      searchTerms: ['vacuum', 'interior', 'dry clean'],
      description: 'Deep interior vacuuming of seats, floor mats, and cabin corners.',
    ),
    ServiceItem(
      label: 'Foam wash',
      icon: Icons.bubble_chart_rounded,
      iconColor: Color(0xFF0A9F59),
      searchTerms: ['foam wash', 'foam', 'soap'],
      description: 'Rich foam applied to the full exterior for a thorough deep clean.',
    ),
    ServiceItem(
      label: 'Engine',
      icon: Icons.precision_manufacturing_rounded,
      iconColor: Color(0xFF2E7B5C),
      searchTerms: ['engine', 'engine clean'],
      description: 'Safe engine bay cleaning to remove grease, dust, and buildup.',
    ),
    ServiceItem(
      label: 'Wax',
      icon: Icons.auto_awesome_rounded,
      iconColor: Color(0xFFB8860B),
      searchTerms: ['wax', 'polish', 'shine'],
      description: 'Protective wax coat applied to give your car a lasting shine.',
    ),
    ServiceItem(
      label: 'Tire shine',
      icon: Icons.tire_repair_rounded,
      iconColor: Color(0xFF446B60),
      searchTerms: ['tire shine', 'tire', 'wheel'],
      description: 'Tires cleaned and dressed for a glossy, like-new appearance.',
    ),
    ServiceItem(
      label: 'Glass clean',
      icon: Icons.window_rounded,
      iconColor: Color(0xFF3A8FA7),
      searchTerms: ['glass', 'window', 'windshield'],
      description: 'Streak-free cleaning of all windows and the windshield inside out.',
    ),
    ServiceItem(
      label: 'Interior',
      icon: Icons.weekend_rounded,
      iconColor: Color(0xFF5B6B3E),
      searchTerms: ['interior', 'inside', 'cabin'],
      description: 'Full interior wipe-down including dashboard, doors, and console.',
    ),
    ServiceItem(
      label: 'Seat shampoo',
      icon: Icons.event_seat_rounded,
      iconColor: Color(0xFF7F6A3D),
      searchTerms: ['seat shampoo', 'seats', 'fabric'],
      description: 'Fabric or leather seats shampooed to remove stains and odors.',
    ),
    ServiceItem(
      label: 'A/C freshen',
      icon: Icons.air_rounded,
      iconColor: Color(0xFF4D79A8),
      searchTerms: ['a/c', 'air', 'freshen', 'vent'],
      description: 'Air vents cleaned and deodorized for fresh, odor-free airflow.',
    ),
    ServiceItem(
      label: 'Pressure',
      icon: Icons.water_drop_rounded,
      iconColor: Color(0xFF1579C4),
      searchTerms: ['pressure', 'water', 'pressure wash'],
      description: 'High-pressure water wash to blast away mud, grime, and road salt.',
    ),
    ServiceItem(
      label: 'Dashboard',
      icon: Icons.space_dashboard_rounded,
      iconColor: Color(0xFF6B7D4A),
      searchTerms: ['dashboard', 'console', 'panel'],
      description: 'Dashboard and center console wiped, polished, and UV-protected.',
    ),
    ServiceItem(
      label: 'Sanitize',
      icon: Icons.sanitizer_rounded,
      iconColor: Color(0xFF3C9D73),
      searchTerms: ['sanitize', 'disinfect', 'hygiene'],
      description: 'Full interior disinfection to eliminate bacteria and allergens.',
    ),
    ServiceItem(
      label: 'Ceramic',
      icon: Icons.verified_user_rounded,
      iconColor: Color(0xFF607D8B),
      searchTerms: ['ceramic', 'coating', 'protection'],
      description: 'Ceramic coating applied for long-lasting paint protection and gloss.',
    ),
    ServiceItem(
      label: 'Headlights',
      icon: Icons.highlight_rounded,
      iconColor: Color(0xFFE0A100),
      searchTerms: ['headlights', 'lights', 'restore'],
      description: 'Headlight lenses polished and restored for improved clarity and brightness.',
    ),
  ];

  static List<ServiceItem> get servicesGrid => allServices;

  static final ValueNotifier<List<ServiceItem>> _servicesNotifier =
      ValueNotifier<List<ServiceItem>>(const []);
  static final ValueNotifier<bool> _loadingNotifier =
      ValueNotifier<bool>(false);
  static final ValueNotifier<String?> _errorNotifier =
      ValueNotifier<String?>(null);

  static ValueListenable<List<ServiceItem>> get listenable => _servicesNotifier;
  static ValueListenable<bool> get loadingListenable => _loadingNotifier;
  static ValueListenable<String?> get errorListenable => _errorNotifier;

  static List<ServiceItem> get featuredServicesList {
    if (_servicesNotifier.value.isNotEmpty) {
      return List.unmodifiable(_servicesNotifier.value.take(5).toList());
    }
    return featuredServices;
  }

  static List<ServiceItem> get servicesGridList {
    if (_servicesNotifier.value.isNotEmpty) {
      return List.unmodifiable(_servicesNotifier.value);
    }
    return servicesGrid;
  }

  static Future<void> fetchServices() async {
    _loadingNotifier.value = true;
    _errorNotifier.value = null;
    _servicesNotifier.value = allServices;
    _loadingNotifier.value = false;
  }
}
