import 'package:car_wash/core/theme/app_colors.dart';
import 'package:car_wash/features/services/model/service_item.dart';
import 'package:flutter/material.dart';

class ServiceTile extends StatelessWidget {
  const ServiceTile({
    super.key,
    required this.service,
    this.width = 58,
  });

  final ServiceItem service;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.border,
              ),
            ),
            child: Icon(
              service.icon,
              color: service.iconColor,
              size: 22,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            service.label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 9.8,
              height: 1.15,
              color: AppColors.textPrimary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
