import 'package:car_wash/core/theme/app_colors.dart';
import 'package:car_wash/features/services/model/service_item.dart';
import 'package:flutter/material.dart';

class ServiceTile extends StatelessWidget {
  const ServiceTile({
    super.key,
    required this.service,
    this.width = 52,
    this.useGridStyle = false,
  });

  final ServiceItem service;
  final double width;
  final bool useGridStyle;

  @override
  Widget build(BuildContext context) {
    if (!useGridStyle) {
      return SizedBox(
        width: width,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: Icon(service.icon, color: service.iconColor, size: 22),
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

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.border.withValues(alpha: 0.8),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Center(
              child: Icon(service.icon, color: service.iconColor, size: 40),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          service.label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            height: 1.25,
            color: AppColors.textPrimary,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
