import 'package:car_wash/core/router/app_navigation.dart';
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
      backgroundColor: Colors.white,
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
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              for (var i = 0; i < filteredServices.length; i++)
                                ...[
                                  ServiceTile(service: filteredServices[i]),
                                  if (i != filteredServices.length - 1)
                                    const SizedBox(width: 10),
                                ],
                            ],
                          ),
                        ),
                      const SizedBox(height: 18),
                      const _SectionHeader(
                        title: 'Popular Service Providers',
                        actionLabel: 'See all',
                        titleKey: Key('home_popular_providers_title'),
                      ),
                      const SizedBox(height: 10),
                      if (filteredProviders.isEmpty)
                        _EmptyResults(
                          message: hasQuery
                              ? 'No providers match "$_searchQuery".'
                              : 'No providers available right now.',
                        )
                      else
                        GridView.builder(
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

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({
    required this.searchController,
    required this.onSearchChanged,
  });

  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.brandGreen,
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
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Location',
                              key: Key('home_location_label'),
                              style: TextStyle(
                                fontSize: 21,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
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
                                    AuthSession.displayLocationLabel,
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
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFE8ECEA),
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x14000000),
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
                              color: AppColors.deepInk,
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
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: TextField(
                  key: const Key('home_search_input'),
                  controller: searchController,
                  onChanged: onSearchChanged,
                  cursorColor: AppColors.brandGreen,
                  decoration: const InputDecoration(
                    hintText: 'Search',
                    hintStyle: TextStyle(
                      fontSize: 13.5,
                      color: Color(0xFF9D9D9D),
                    ),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: AppColors.brandGreen,
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
              color: Colors.black,
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
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: const Color(0xFFE6E6E6),
            ),
          ),
          padding: const EdgeInsets.all(6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: double.infinity,
                  height: imageHeight,
                  child: Image.asset(
                    provider.imagePath,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      provider.name,
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Text(
                    provider.price,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: Color(0xFF3A3A3A),
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
                  fontSize: 10.2,
                  height: 1.25,
                  color: Color(0xFF707070),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Show more >',
                style: TextStyle(
                  fontSize: 10.4,
                  color: Color(0xFF3B3B3B),
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
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    provider.reviews,
                    style: const TextStyle(
                      fontSize: 10.5,
                      color: Color(0xFF5B5B5B),
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
                      color: AppColors.brandGreen,
                      borderRadius: BorderRadius.circular(4),
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
        color: const Color(0xFFF7F8F8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 13,
          color: Color(0xFF7A7A7A),
        ),
      ),
    );
  }
}
