import 'package:car_wash/features/home/model/service_provider_profile.dart';

class BookingFlowDetails {
  const BookingFlowDetails({
    required this.provider,
    this.customerName = '',
    this.serviceType = '',
    this.bookingDate,
    this.bookingTime,
  });

  final ServiceProviderProfile provider;
  final String customerName;
  final String serviceType;
  final DateTime? bookingDate;
  final String? bookingTime;

  BookingFlowDetails copyWith({
    ServiceProviderProfile? provider,
    String? customerName,
    String? serviceType,
    DateTime? bookingDate,
    String? bookingTime,
  }) {
    return BookingFlowDetails(
      provider: provider ?? this.provider,
      customerName: customerName ?? this.customerName,
      serviceType: serviceType ?? this.serviceType,
      bookingDate: bookingDate ?? this.bookingDate,
      bookingTime: bookingTime ?? this.bookingTime,
    );
  }
}
