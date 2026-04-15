import 'dart:io';

import 'package:car_wash/core/router/app_navigation.dart';
import 'package:car_wash/core/services/app_current_location_updater.dart';
import 'package:car_wash/core/theme/app_colors.dart';
import 'package:car_wash/features/authentication/data/auth_session.dart';
import 'package:car_wash/features/home/data/provider_catalog.dart';
import 'package:car_wash/features/home/model/service_provider_profile.dart';
import 'package:car_wash/features/home/presentation/widgets/home_bottom_navigation_bar.dart';
import 'package:car_wash/features/services/data/service_catalog.dart';
import 'package:car_wash/features/services/presentation/widgets/service_tile.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    ServiceCatalog.fetchServices();
    ProviderCatalog.initialize();
    ProviderCatalog.fetchProviders();
  }

  List<ServiceProviderProfile> get _filteredProviders {
    if (_searchQuery.isEmpty) {
      return ProviderCatalog.providers;
    }

    return ProviderCatalog.providers
        .where((provider) => provider.matches(_searchQuery))
        .toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBackground,
      body: Column(
        children: [
          _HomeHeader(
            searchController: _searchController,
            onSearchChanged: (value) {
              setState(() {
                _searchQuery = value.trim().toLowerCase();
              });
            },
          ),
          Expanded(
            child: AnimatedBuilder(
              animation: Listenable.merge([
                ProviderCatalog.listenable,
                ServiceCatalog.listenable,
              ]),
              builder: (context, child) {
                final filteredServices = _searchQuery.isEmpty
                    ? ServiceCatalog.featuredServicesList
                    : ServiceCatalog.featuredServicesList
                        .where((service) => service.matches(_searchQuery))
                        .toList(growable: false);
                final filteredProviders = _filteredProviders;
                final hasQuery = _searchQuery.isNotEmpty;

                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionHeader(
                        title: 'Services',
                        actionLabel: 'See all',
                        actionKey: const Key('home_services_see_all_button'),
                        onActionTap: () => context.goToServices(),
                      ),
                      const SizedBox(height: 10),
                      if (filteredServices.isEmpty)
                        const _EmptyResults(
                          message: 'No services match your search.',
                        )
                      else
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            for (final service in filteredServices)
                              ServiceTile(service: service),
                          ],
                        ),
                      const SizedBox(height: 18),
                      const _SectionHeader(
                        title: 'Popular Service Providers',
                        actionLabel: 'See all',
                        titleKey: Key('home_popular_providers_title'),
                      ),
                      const SizedBox(height: 0),
                      if (filteredProviders.isEmpty)
                        _EmptyResults(
                          message: hasQuery
                              ? 'No providers match "$_searchQuery".'
                              : 'No providers available right now.',
                        )
                      else
                        Transform.translate(
                          offset: const Offset(0, -20),
                          child: GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: filteredProviders.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                  mainAxisExtent: 290,
                                ),
                            itemBuilder: (context, index) {
                              return _ProviderCard(
                                provider: filteredProviders[index],
                                onViewDetails: () => context.pushToServiceDetail(
                                  filteredProviders[index],
                                ),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: const HomeBottomNavigationBar(
        selectedTab: HomeBottomTab.home,
      ),
    );
  }
}

class _HomeHeader extends StatefulWidget {
  const _HomeHeader({
    required this.searchController,
    required this.onSearchChanged,
  });

  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;

  @override
  State<_HomeHeader> createState() => _HomeHeaderState();
}

class _HomeHeaderState extends State<_HomeHeader> {
  bool _updatingLocation = false;

  Future<void> _onLocationTap() async {
    if (_updatingLocation) return;
    setState(() => _updatingLocation = true);
    await updateCurrentLocation(context);
    if (mounted) setState(() => _updatingLocation = false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0E5F2D), AppColors.brandGreen, AppColors.deepInk],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ValueListenableBuilder<int>(
                      valueListenable: AuthSession.listenable,
                      builder: (context, value, child) {
                        return GestureDetector(
                          onTap: _onLocationTap,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  _updatingLocation
                                      ? const SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Icon(
                                          Icons.my_location_rounded,
                                          color: Colors.white,
                                          size: 22,
                                        ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      AuthSession.displayName,
                                      key: const Key('home_location_label'),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.location_on_rounded,
                                    color: Colors.red,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      AuthSession.displayLocationLabel.isEmpty
                                          ? 'Tap to set location'
                                          : AuthSession.displayLocationLabel,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 13.5,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      key: const Key('home_notification_button'),
                      onTap: () => context.pushToNotifications(),
                      customBorder: const CircleBorder(),
                      child: Ink(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.border,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.24),
                              blurRadius: 8,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: const [
                            Icon(
                              Icons.notifications_active_outlined,
                              color: AppColors.textPrimary,
                              size: 23,
                            ),
                            Positioned(
                              top: 10,
                              right: 10,
                              child: SizedBox(
                                width: 9,
                                height: 9,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: AppColors.brandGreenLight,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                key: const Key('home_search_bar'),
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                alignment: Alignment.center,
                child: TextField(
                  key: const Key('home_search_input'),
                  controller: widget.searchController,
                  onChanged: widget.onSearchChanged,
                  cursorColor: AppColors.brandGreen,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13.5,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Search',
                    hintStyle: TextStyle(
                      fontSize: 13.5,
                      color: AppColors.textMuted,
                    ),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: AppColors.brandGreenLight,
                      size: 22,
                    ),
                    suffixIcon: SizedBox.shrink(),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.actionLabel,
    this.titleKey,
    this.actionKey,
    this.onActionTap,
  });

  final String title;
  final String actionLabel;
  final Key? titleKey;
  final Key? actionKey;
  final VoidCallback? onActionTap;

  @override
  Widget build(BuildContext context) {
    final action = Text(
      actionLabel,
      key: actionKey,
      style: const TextStyle(
        fontSize: 11.5,
        fontWeight: FontWeight.w500,
        color: AppColors.brandGreenLight,
      ),
    );

    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            key: titleKey,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        if (onActionTap == null)
          action
        else
          GestureDetector(
            onTap: onActionTap,
            child: action,
          ),
      ],
    );
  }
}

class _ProviderCard extends StatelessWidget {
  const _ProviderCard({
    required this.provider,
    required this.onViewDetails,
  });

  final ServiceProviderProfile provider;
  final VoidCallback onViewDetails;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final imageHeight = (constraints.maxWidth * 0.72)
            .clamp(108.0, 132.0)
            .toDouble();

        return Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: AppColors.border,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.14),
                blurRadius: 14,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.all(6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Stack(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: imageHeight,
                      child: _ProviderPreviewImage(
                        imagePath: provider.imagePath,
                      ),
                    ),
                    if (provider.showNewBadge)
                      Positioned(
                        left: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.62),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: AppColors.brandGreenLight,
                            ),
                          ),
                          child: const Text(
                            'New Provider',
                            style: TextStyle(
                              fontSize: 9.6,
                              fontWeight: FontWeight.w700,
                              color: AppColors.brandGreenLight,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            provider.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        if (provider.isVerified) ...[
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.verified_rounded,
                            color: Color(0xFF1D9BF0),
                            size: 13,
                          ),
                        ],
                      ],
                    ),
                  ),
                  Text(
                    provider.price,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                provider.description,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 10.9,
                  height: 1.32,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Show more >',
                style: TextStyle(
                  fontSize: 10.4,
                  color: AppColors.brandGreenLight,
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  const Icon(
                    Icons.star_rounded,
                    color: AppColors.brandGreen,
                    size: 14,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    provider.rating,
                    style: const TextStyle(
                      fontSize: 10.5,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    provider.reviews,
                    style: const TextStyle(
                      fontSize: 10.5,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  key: Key('provider_view_details_${provider.detailsKeyName}'),
                  onTap: onViewDetails,
                  borderRadius: BorderRadius.circular(4),
                  child: Ink(
                    height: 28,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceHighlight,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AppColors.brandGreen),
                    ),
                    child: const Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'View Details',
                              style: TextStyle(
                                fontSize: 10.4,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(
                              Icons.chevron_right_rounded,
                              color: Colors.white,
                              size: 13,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ProviderPreviewImage extends StatelessWidget {
  const _ProviderPreviewImage({required this.imagePath});

  final String imagePath;

  @override
  Widget build(BuildContext context) {
    final normalizedPath = imagePath.trim();

    if (normalizedPath.startsWith('assets/')) {
      return Image.asset(normalizedPath, fit: BoxFit.cover);
    }

    if (normalizedPath.startsWith('http')) {
      return Image.network(
        normalizedPath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Image.asset(
            'assets/images/onboarding/pexels-bulat843-1243575272-28995187.jpg',
            fit: BoxFit.cover,
          );
        },
      );
    }

    return Image.file(
      File(normalizedPath),
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Image.asset(
          'assets/images/onboarding/pexels-bulat843-1243575272-28995187.jpg',
          fit: BoxFit.cover,
        );
      },
    );
  }
}

class _EmptyResults extends StatelessWidget {
  const _EmptyResults({
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 13,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
