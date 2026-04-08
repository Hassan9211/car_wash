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
    ),
    ServiceItem(
      label: 'Vacuum',
      icon: Icons.cleaning_services_rounded,
      iconColor: Color(0xFF4E7D55),
      searchTerms: ['vacuum', 'interior', 'dry clean'],
    ),
    ServiceItem(
      label: 'Foam wash',
      icon: Icons.bubble_chart_rounded,
      iconColor: Color(0xFF0A9F59),
      searchTerms: ['foam wash', 'foam', 'soap'],
    ),
    ServiceItem(
      label: 'Engine',
      icon: Icons.precision_manufacturing_rounded,
      iconColor: Color(0xFF2E7B5C),
      searchTerms: ['engine', 'engine clean'],
    ),
    ServiceItem(
      label: 'Wax',
      icon: Icons.auto_awesome_rounded,
      iconColor: Color(0xFFB8860B),
      searchTerms: ['wax', 'polish', 'shine'],
    ),
  ];

  static const allServices = <ServiceItem>[
    ServiceItem(
      label: 'Basic wash',
      icon: Icons.local_car_wash_rounded,
      iconColor: AppColors.brandGreen,
      searchTerms: ['basic wash', 'wash', 'car wash'],
    ),
    ServiceItem(
      label: 'Vacuum',
      icon: Icons.cleaning_services_rounded,
      iconColor: Color(0xFF4E7D55),
      searchTerms: ['vacuum', 'interior', 'dry clean'],
    ),
    ServiceItem(
      label: 'Foam wash',
      icon: Icons.bubble_chart_rounded,
      iconColor: Color(0xFF0A9F59),
      searchTerms: ['foam wash', 'foam', 'soap'],
    ),
    ServiceItem(
      label: 'Engine',
      icon: Icons.precision_manufacturing_rounded,
      iconColor: Color(0xFF2E7B5C),
      searchTerms: ['engine', 'engine clean'],
    ),
    ServiceItem(
      label: 'Wax',
      icon: Icons.auto_awesome_rounded,
      iconColor: Color(0xFFB8860B),
      searchTerms: ['wax', 'polish', 'shine'],
    ),
    ServiceItem(
      label: 'Tire shine',
      icon: Icons.tire_repair_rounded,
      iconColor: Color(0xFF446B60),
      searchTerms: ['tire shine', 'tire', 'wheel'],
    ),
    ServiceItem(
      label: 'Glass clean',
      icon: Icons.window_rounded,
      iconColor: Color(0xFF3A8FA7),
      searchTerms: ['glass', 'window', 'windshield'],
    ),
    ServiceItem(
      label: 'Interior',
      icon: Icons.weekend_rounded,
      iconColor: Color(0xFF5B6B3E),
      searchTerms: ['interior', 'inside', 'cabin'],
    ),
    ServiceItem(
      label: 'Seat shampoo',
      icon: Icons.event_seat_rounded,
      iconColor: Color(0xFF7F6A3D),
      searchTerms: ['seat shampoo', 'seats', 'fabric'],
    ),
    ServiceItem(
      label: 'A/C freshen',
      icon: Icons.air_rounded,
      iconColor: Color(0xFF4D79A8),
      searchTerms: ['a/c', 'air', 'freshen', 'vent'],
    ),
    ServiceItem(
      label: 'Pressure',
      icon: Icons.water_drop_rounded,
      iconColor: Color(0xFF1579C4),
      searchTerms: ['pressure', 'water', 'pressure wash'],
    ),
    ServiceItem(
      label: 'Dashboard',
      icon: Icons.space_dashboard_rounded,
      iconColor: Color(0xFF6B7D4A),
      searchTerms: ['dashboard', 'console', 'panel'],
    ),
    ServiceItem(
      label: 'Sanitize',
      icon: Icons.sanitizer_rounded,
      iconColor: Color(0xFF3C9D73),
      searchTerms: ['sanitize', 'disinfect', 'hygiene'],
    ),
    ServiceItem(
      label: 'Ceramic',
      icon: Icons.verified_user_rounded,
      iconColor: Color(0xFF607D8B),
      searchTerms: ['ceramic', 'coating', 'protection'],
    ),
    ServiceItem(
      label: 'Headlights',
      icon: Icons.highlight_rounded,
      iconColor: Color(0xFFE0A100),
      searchTerms: ['headlights', 'lights', 'restore'],
    ),
  ];

  static List<ServiceItem> get servicesGrid {
    return allServices;
  }

  static final ValueNotifier<List<ServiceItem>> _servicesNotifier =
      ValueNotifier<List<ServiceItem>>(const []);
  static final ValueNotifier<bool> _loadingNotifier =
      ValueNotifier<bool>(false);
  static final ValueNotifier<String?> _errorNotifier =
      ValueNotifier<String?>(null);

  static ValueListenable<List<ServiceItem>> get listenable =>
      _servicesNotifier;
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
