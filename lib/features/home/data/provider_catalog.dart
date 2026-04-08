import 'package:car_wash/features/home/model/service_provider_profile.dart';
import 'package:flutter/foundation.dart';

class ProviderCatalog {
  ProviderCatalog._();

  static const fallbackProvider = ServiceProviderProfile(
    id: 'fallback_provider',
    name: 'Ahmed',
    price: '\$24',
    rating: '5',
    reviews: '13.7K',
    imagePath: 'assets/images/onboarding/pexels-bulat843-1243575272-28995187.jpg',
    mainImageUrl:
        'https://images.pexels.com/photos/6873132/pexels-photo-6873132.jpeg?auto=compress&cs=tinysrgb&w=1200',
    galleryImageUrls: [
      'https://images.pexels.com/photos/6873132/pexels-photo-6873132.jpeg?auto=compress&cs=tinysrgb&w=900',
    ],
    description:
        'Professional car wash service provider available near you.',
    searchTerms: ['ahmed', 'car wash'],
    location: 'California , USA',
    availability: '8:00pm - 11:00pm',
  );

  static const _seedProviders = <ServiceProviderProfile>[
    ServiceProviderProfile(
      id: '1',
      name: 'Ahmed',
      price: '\$24',
      rating: '5',
      reviews: '13.7K',
      imagePath: 'assets/images/onboarding/pexels-bulat843-1243575272-28995187.jpg',
      mainImageUrl:
          'https://images.pexels.com/photos/6873132/pexels-photo-6873132.jpeg?auto=compress&cs=tinysrgb&w=1200',
      galleryImageUrls: [
        'https://images.pexels.com/photos/6873132/pexels-photo-6873132.jpeg?auto=compress&cs=tinysrgb&w=900',
        'https://images.pexels.com/photos/4870700/pexels-photo-4870700.jpeg?auto=compress&cs=tinysrgb&w=900',
        'https://images.pexels.com/photos/4876676/pexels-photo-4876676.jpeg?auto=compress&cs=tinysrgb&w=900',
        'https://images.pexels.com/photos/4870671/pexels-photo-4870671.jpeg?auto=compress&cs=tinysrgb&w=900',
        'https://images.pexels.com/photos/4870740/pexels-photo-4870740.jpeg?auto=compress&cs=tinysrgb&w=900',
        'https://images.pexels.com/photos/7530997/pexels-photo-7530997.jpeg?auto=compress&cs=tinysrgb&w=900',
      ],
      description:
          'Lorem ipsum dolor sit amet consectetur. Ac et orci interdum ac nibh proin quis. Dis nulla ultrices pharetra lectus ipsum semper malesuada erat et. Netus sed nam faucibus dui id mattis. Nibh ultrices pretium amet nunc a urna.',
      searchTerms: ['ahmed', 'foam', 'wash', 'car washer', 'detail'],
      location: 'California , USA',
      availability: '8:00pm - 11:00pm',
    ),
    ServiceProviderProfile(
      id: '2',
      name: 'Youssef',
      price: '\$24',
      rating: '5',
      reviews: '13.7K',
      imagePath: 'assets/images/onboarding/pexels-bulat843-1243575272-31154194.jpg',
      mainImageUrl:
          'https://images.pexels.com/photos/7530997/pexels-photo-7530997.jpeg?auto=compress&cs=tinysrgb&w=1200',
      galleryImageUrls: [
        'https://images.pexels.com/photos/7530997/pexels-photo-7530997.jpeg?auto=compress&cs=tinysrgb&w=900',
        'https://images.pexels.com/photos/4870700/pexels-photo-4870700.jpeg?auto=compress&cs=tinysrgb&w=900',
        'https://images.pexels.com/photos/4876676/pexels-photo-4876676.jpeg?auto=compress&cs=tinysrgb&w=900',
        'https://images.pexels.com/photos/4870740/pexels-photo-4870740.jpeg?auto=compress&cs=tinysrgb&w=900',
        'https://images.pexels.com/photos/10804350/pexels-photo-10804350.jpeg?auto=compress&cs=tinysrgb&w=900',
        'https://images.pexels.com/photos/14231684/pexels-photo-14231684.jpeg?auto=compress&cs=tinysrgb&w=900',
      ],
      description:
          'Lorem ipsum dolor sit amet consectetur. Ac et orci interdum ac nibh proin quis. Dis nulla ultrices pharetra lectus ipsum semper malesuada erat et. Netus sed nam faucibus dui id mattis. Nibh ultrices pretium amet nunc a urna.',
      searchTerms: ['youssef', 'exterior', 'shine', 'detail'],
      location: 'California , USA',
      availability: '8:00pm - 11:00pm',
    ),
    ServiceProviderProfile(
      id: '3',
      name: 'Samir',
      price: '\$22',
      rating: '4.9',
      reviews: '10.2K',
      imagePath: 'assets/images/onboarding/pexels-karola-g-4870700.jpg',
      mainImageUrl:
          'https://images.pexels.com/photos/4870700/pexels-photo-4870700.jpeg?auto=compress&cs=tinysrgb&w=1200',
      galleryImageUrls: [
        'https://images.pexels.com/photos/4870700/pexels-photo-4870700.jpeg?auto=compress&cs=tinysrgb&w=900',
        'https://images.pexels.com/photos/4876676/pexels-photo-4876676.jpeg?auto=compress&cs=tinysrgb&w=900',
        'https://images.pexels.com/photos/10804350/pexels-photo-10804350.jpeg?auto=compress&cs=tinysrgb&w=900',
        'https://images.pexels.com/photos/14231684/pexels-photo-14231684.jpeg?auto=compress&cs=tinysrgb&w=900',
        'https://images.pexels.com/photos/4870671/pexels-photo-4870671.jpeg?auto=compress&cs=tinysrgb&w=900',
        'https://images.pexels.com/photos/6873132/pexels-photo-6873132.jpeg?auto=compress&cs=tinysrgb&w=900',
      ],
      description:
          'Lorem ipsum dolor sit amet consectetur. Ac et orci interdum ac nibh proin quis. Dis nulla ultrices pharetra lectus ipsum semper malesuada erat et. Netus sed nam faucibus dui id mattis. Nibh ultrices pretium amet nunc a urna.',
      searchTerms: ['samir', 'interior', 'vacuum', 'detail'],
      location: 'California , USA',
      availability: '8:00pm - 11:00pm',
    ),
    ServiceProviderProfile(
      id: '4',
      name: 'Omar',
      price: '\$26',
      rating: '5',
      reviews: '12.1K',
      imagePath: 'assets/images/onboarding/pexels-bulat843-1243575272-28995187.jpg',
      mainImageUrl:
          'https://images.pexels.com/photos/10804350/pexels-photo-10804350.jpeg?auto=compress&cs=tinysrgb&w=1200',
      galleryImageUrls: [
        'https://images.pexels.com/photos/10804350/pexels-photo-10804350.jpeg?auto=compress&cs=tinysrgb&w=900',
        'https://images.pexels.com/photos/14231684/pexels-photo-14231684.jpeg?auto=compress&cs=tinysrgb&w=900',
        'https://images.pexels.com/photos/7530997/pexels-photo-7530997.jpeg?auto=compress&cs=tinysrgb&w=900',
        'https://images.pexels.com/photos/4870700/pexels-photo-4870700.jpeg?auto=compress&cs=tinysrgb&w=900',
        'https://images.pexels.com/photos/4870740/pexels-photo-4870740.jpeg?auto=compress&cs=tinysrgb&w=900',
        'https://images.pexels.com/photos/4876676/pexels-photo-4876676.jpeg?auto=compress&cs=tinysrgb&w=900',
      ],
      description:
          'Lorem ipsum dolor sit amet consectetur. Ac et orci interdum ac nibh proin quis. Dis nulla ultrices pharetra lectus ipsum semper malesuada erat et. Netus sed nam faucibus dui id mattis. Nibh ultrices pretium amet nunc a urna.',
      searchTerms: ['omar', 'engine', 'premium', 'detail'],
      location: 'California , USA',
      availability: '8:00pm - 11:00pm',
    ),
  ];

  static final ValueNotifier<List<ServiceProviderProfile>> _providersNotifier =
      ValueNotifier<List<ServiceProviderProfile>>(const []);
  static final ValueNotifier<bool> _loadingNotifier =
      ValueNotifier<bool>(false);
  static final ValueNotifier<String?> _errorNotifier =
      ValueNotifier<String?>(null);

  static ValueListenable<List<ServiceProviderProfile>> get listenable =>
      _providersNotifier;
  static ValueListenable<bool> get loadingListenable => _loadingNotifier;
  static ValueListenable<String?> get errorListenable => _errorNotifier;

  static List<ServiceProviderProfile> get providers {
    if (_providersNotifier.value.isNotEmpty) {
      return List.unmodifiable(_providersNotifier.value);
    }

    return List.unmodifiable(_seedProviders);
  }

  static Future<void> fetchProviders({
    String search = '',
    String serviceType = '',
  }) async {
    _loadingNotifier.value = true;
    _errorNotifier.value = null;

    final normalizedSearch = search.trim().toLowerCase();
    final normalizedServiceType = serviceType.trim().toLowerCase();

    _providersNotifier.value = _seedProviders.where((provider) {
      final matchesSearch = normalizedSearch.isEmpty
          ? true
          : provider.matches(normalizedSearch) ||
              provider.name.toLowerCase().contains(normalizedSearch) ||
              provider.location.toLowerCase().contains(normalizedSearch);
      final matchesServiceType = normalizedServiceType.isEmpty
          ? true
          : provider.searchTerms.any(
              (term) => term.toLowerCase().contains(normalizedServiceType),
            ) ||
              provider.categoryLabel.toLowerCase().contains(
                normalizedServiceType,
              );
      return matchesSearch && matchesServiceType;
    }).toList(growable: false);

    _loadingNotifier.value = false;
  }

  static Future<ServiceProviderProfile> fetchProviderById(String id) async {
    return providers.firstWhere(
      (item) => item.id == id,
      orElse: () => fallbackProvider,
    );
  }
}
