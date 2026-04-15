import 'package:flutter/material.dart';

class ServiceItem {
  const ServiceItem({
    this.id = '',
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.searchTerms,
    this.description = '',
  });

  final String id;
  final String label;
  final IconData icon;
  final Color iconColor;
  final List<String> searchTerms;
  final String description;

  factory ServiceItem.fromJson(Map<String, dynamic> json) {
    final label = _readLabel(json);
    return ServiceItem(
      id: _readString(json, ['id', 'service_id']),
      label: label,
      icon: _iconForLabel(label),
      iconColor: _colorForLabel(label),
      searchTerms: [
        label.toLowerCase(),
        ..._readList(json, ['search_terms', 'tags', 'keywords']),
      ],
    );
  }

  bool matches(String query) {
    return searchTerms.any(
      (term) => term.toLowerCase().contains(query),
    );
  }

  static String _readLabel(Map<String, dynamic> json) {
    return _readString(json, ['label', 'name', 'title'], fallback: 'Service');
  }

  static String _readString(
    Map<String, dynamic> json,
    List<String> keys, {
    String fallback = '',
  }) {
    for (final key in keys) {
      final value = json[key];
      if (value == null) {
        continue;
      }

      final asString = value.toString().trim();
      if (asString.isNotEmpty) {
        return asString;
      }
    }

    return fallback;
  }

  static List<String> _readList(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is List) {
        return value
            .map((item) => item.toString().toLowerCase())
            .where((item) => item.isNotEmpty)
            .toList(growable: false);
      }
    }

    return const [];
  }

  static IconData _iconForLabel(String label) {
    final normalized = label.toLowerCase();
    if (normalized.contains('foam')) {
      return Icons.bubble_chart_rounded;
    }
    if (normalized.contains('vacuum') || normalized.contains('interior')) {
      return Icons.cleaning_services_rounded;
    }
    if (normalized.contains('engine')) {
      return Icons.precision_manufacturing_rounded;
    }
    if (normalized.contains('wax') || normalized.contains('polish')) {
      return Icons.auto_awesome_rounded;
    }
    if (normalized.contains('glass')) {
      return Icons.window_rounded;
    }
    if (normalized.contains('tire') || normalized.contains('wheel')) {
      return Icons.tire_repair_rounded;
    }
    return Icons.local_car_wash_rounded;
  }

  static Color _colorForLabel(String label) {
    final normalized = label.toLowerCase();
    if (normalized.contains('foam')) {
      return const Color(0xFF0A9F59);
    }
    if (normalized.contains('vacuum') || normalized.contains('interior')) {
      return const Color(0xFF4E7D55);
    }
    if (normalized.contains('engine')) {
      return const Color(0xFF2E7B5C);
    }
    if (normalized.contains('wax') || normalized.contains('polish')) {
      return const Color(0xFFB8860B);
    }
    if (normalized.contains('glass')) {
      return const Color(0xFF3A8FA7);
    }
    return const Color(0xFF0F7D32);
  }
}
