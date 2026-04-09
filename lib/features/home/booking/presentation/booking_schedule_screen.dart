import 'package:car_wash/core/router/app_navigation.dart';
import 'package:car_wash/core/theme/app_button_colors.dart';
import 'package:car_wash/core/theme/app_colors.dart';
import 'package:car_wash/core/widgets/app_buttons.dart';
import 'package:car_wash/features/home/booking/model/booking_flow_details.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BookingScheduleScreen extends StatefulWidget {
  const BookingScheduleScreen({
    super.key,
    required this.details,
  });

  final BookingFlowDetails details;

  @override
  State<BookingScheduleScreen> createState() => _BookingScheduleScreenState();
}

class _BookingScheduleScreenState extends State<BookingScheduleScreen> {
  static const _weekdays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
  static const _timeSlots = [
    '04:00 PM',
    '05:00 PM',
    '06:00 PM',
    '07:00 PM',
    '08:00 PM',
    '09:00 PM',
  ];

  late DateTime _displayedMonth;
  late DateTime _selectedDate;
  String _selectedTime = _timeSlots.last;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.details.bookingDate ?? DateTime.now();
    _displayedMonth = DateTime(_selectedDate.year, _selectedDate.month);
    _selectedTime = widget.details.bookingTime ?? _timeSlots.last;
  }

  void _changeMonth(int delta) {
    final nextMonth = DateTime(
      _displayedMonth.year,
      _displayedMonth.month + delta,
    );

    setState(() {
      _displayedMonth = DateTime(nextMonth.year, nextMonth.month);

      if (_selectedDate.year != _displayedMonth.year ||
          _selectedDate.month != _displayedMonth.month) {
        _selectedDate = DateTime(_displayedMonth.year, _displayedMonth.month, 1);
      }
    });
  }

  List<_CalendarDay?> _buildCalendarDays() {
    final firstDayOfMonth = DateTime(
      _displayedMonth.year,
      _displayedMonth.month,
      1,
    );
    final daysInMonth = DateUtils.getDaysInMonth(
      _displayedMonth.year,
      _displayedMonth.month,
    );
    final leadingEmptyCells = (firstDayOfMonth.weekday + 6) % 7;
    final totalUsedCells = leadingEmptyCells + daysInMonth;
    final trailingEmptyCells = (7 - totalUsedCells % 7) % 7;
    final cells = <_CalendarDay?>[];

    for (var i = 0; i < leadingEmptyCells; i++) {
      cells.add(null);
    }

    for (var day = 1; day <= daysInMonth; day++) {
      final date = DateTime(_displayedMonth.year, _displayedMonth.month, day);
      cells.add(
        _CalendarDay(
          date: date,
          isWeekend: date.weekday == DateTime.saturday ||
              date.weekday == DateTime.sunday,
        ),
      );
    }

    for (var i = 0; i < trailingEmptyCells; i++) {
      cells.add(null);
    }

    return cells;
  }

  bool _isSameDate(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }

  Future<void> _openPaymentScreen() async {
    await context.pushToBookingPayment(
      widget.details.copyWith(
        bookingDate: _selectedDate,
        bookingTime: _selectedTime,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final calendarDays = _buildCalendarDays();

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
                      key: const Key('booking_schedule_back_button'),
                      onPressed: () => context.pop(),
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
                          'Booking',
                          key: Key('booking_schedule_title'),
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
            Divider(
              height: 1,
              thickness: 0.8,
              color: AppColors.border,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _SectionLabel(
                      label: 'Select Date',
                      icon: Icons.calendar_month_outlined,
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              _MonthNavButton(
                                icon: Icons.chevron_left_rounded,
                                onTap: () => _changeMonth(-1),
                              ),
                              Expanded(
                                child: Text(
                                  _monthTitle(_displayedMonth),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              _MonthNavButton(
                                icon: Icons.chevron_right_rounded,
                                onTap: () => _changeMonth(1),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: _weekdays
                                .map(
                                  (day) => Expanded(
                                    child: Center(
                                      child: Text(
                                        day,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: day == 'S'
                                              ? AppButtonColors.primaryBackground
                                              : AppColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                                .toList(growable: false),
                          ),
                          const SizedBox(height: 10),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: calendarDays.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 7,
                                  mainAxisSpacing: 8,
                                  crossAxisSpacing: 6,
                                  childAspectRatio: 1,
                                ),
                            itemBuilder: (context, index) {
                              final calendarDay = calendarDays[index];

                              if (calendarDay == null) {
                                return const SizedBox.shrink();
                              }

                              final isSelected = _isSameDate(
                                calendarDay.date,
                                _selectedDate,
                              );

                              return _CalendarDateButton(
                                label: calendarDay.date.day.toString(),
                                isSelected: isSelected,
                                isWeekend: calendarDay.isWeekend,
                                onTap: () {
                                  setState(() {
                                    _selectedDate = calendarDay.date;
                                  });
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const _SectionLabel(
                      label: 'Service Time',
                      starColor: Color(0xFFE53935),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: _timeSlots
                          .map(
                            (time) => _TimeSlotButton(
                              label: time,
                              isSelected: _selectedTime == time,
                              onTap: () {
                                setState(() {
                                  _selectedTime = time;
                                });
                              },
                            ),
                          )
                          .toList(growable: false),
                    ),
                    const SizedBox(height: 42),
                    AppPrimaryButton(
                      key: const Key('booking_schedule_next_button'),
                      label: 'Next',
                      onPressed: _openPaymentScreen,
                      height: 46,
                      borderRadius: 6,
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _monthTitle(DateTime month) {
    const monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return '${monthNames[month.month - 1]} ${month.year}';
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({
    required this.label,
    this.icon,
    this.starColor = AppButtonColors.primaryBackground,
  });

  final String label;
  final IconData? icon;
  final Color starColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text.rich(
          TextSpan(
            text: label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
            children: [
              TextSpan(
                text: '*',
                style: TextStyle(color: starColor),
              ),
            ],
          ),
        ),
        if (icon != null) ...[
          const SizedBox(width: 6),
          Icon(
            icon,
            size: 18,
            color: AppColors.textMuted,
          ),
        ],
      ],
    );
  }
}

class _MonthNavButton extends StatelessWidget {
  const _MonthNavButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Icon(icon, color: AppColors.textPrimary, size: 22),
      ),
    );
  }
}

class _CalendarDateButton extends StatelessWidget {
  const _CalendarDateButton({
    required this.label,
    required this.isSelected,
    required this.isWeekend,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final bool isWeekend;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textColor = isSelected
        ? Colors.white
        : isWeekend
        ? AppButtonColors.primaryBackground
        : AppColors.textPrimary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Center(
        child: Container(
          width: 34,
          height: 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected
                ? AppButtonColors.primaryBackground
                : Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}

class _TimeSlotButton extends StatelessWidget {
  const _TimeSlotButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 76,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Ink(
          height: 24,
          decoration: BoxDecoration(
            color: isSelected
                ? AppButtonColors.primaryBackground
                : Colors.white,
            borderRadius: BorderRadius.circular(4),
            boxShadow: isSelected
                ? null
                : const [
                    BoxShadow(
                      color: Color(0x12000000),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CalendarDay {
  const _CalendarDay({
    required this.date,
    required this.isWeekend,
  });

  final DateTime date;
  final bool isWeekend;
}
