import 'package:car_wash/core/location/app_location_details.dart';
import 'package:car_wash/features/home/model/service_provider_profile.dart';

class BookingFlowDetails {
  const BookingFlowDetails({
    required this.provider,
    this.customerName = '',
    this.serviceType = '',
    this.bookingDate,
    this.bookingTime,
    this.bookingLocation,
  });

  final ServiceProviderProfile provider;
  final String customerName;
  final String serviceType;
  final DateTime? bookingDate;
  final String? bookingTime;
  final AppLocationDetails? bookingLocation;

  BookingFlowDetails copyWith({
    ServiceProviderProfile? provider,
    String? customerName,
    String? serviceType,
    DateTime? bookingDate,
    String? bookingTime,
    AppLocationDetails? bookingLocation,
  }) {
    return BookingFlowDetails(
      provider: provider ?? this.provider,
      customerName: customerName ?? this.customerName,
      serviceType: serviceType ?? this.serviceType,
      bookingDate: bookingDate ?? this.bookingDate,
      bookingTime: bookingTime ?? this.bookingTime,
      bookingLocation: bookingLocation ?? this.bookingLocation,
    );
  }
}
