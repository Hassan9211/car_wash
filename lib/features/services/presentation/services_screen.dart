import 'package:car_wash/core/router/app_navigation.dart';
import 'package:car_wash/core/theme/app_button_colors.dart';
import 'package:car_wash/core/theme/app_colors.dart';
import 'package:car_wash/features/services/data/service_catalog.dart';
import 'package:car_wash/features/services/model/service_item.dart';
import 'package:car_wash/features/services/presentation/widgets/service_tile.dart';
import 'package:flutter/material.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  @override
  void initState() {
    super.initState();
    ServiceCatalog.fetchServices();
  }

  void _goBack(BuildContext context) {
    context.goToHome();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBackground,
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
                      key: const Key('services_back_button'),
                      onPressed: () => _goBack(context),
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
                          'Services',
                          key: Key('services_screen_title'),
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
            Divider(height: 1, thickness: 0.8, color: AppColors.border),
            Expanded(
              child: ValueListenableBuilder<List<ServiceItem>>(
                valueListenable: ServiceCatalog.listenable,
                builder: (context, _, child) {
                  final services = ServiceCatalog.servicesGridList;

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    child: GridView.builder(
                      itemCount: services.length,
                      padding: const EdgeInsets.only(bottom: 30),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            mainAxisSpacing: 32,
                            crossAxisSpacing: 20,
                            childAspectRatio: 0.74,
                          ),
                      itemBuilder: (context, index) {
                        return ServiceTile(
                          service: services[index],
                          width: double.infinity,
                          useGridStyle: true,
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
