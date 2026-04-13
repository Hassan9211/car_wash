import 'package:car_wash/core/router/app_navigation.dart';
import 'package:car_wash/core/theme/app_button_colors.dart';
import 'package:car_wash/core/theme/app_button_styles.dart';
import 'package:car_wash/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _LegalArticleScreen(
      title: 'Terms & Conditions',
      summary:
          'These terms explain how bookings, payments, cancellations, and acceptable app use work inside Car Wash.',
      lastUpdated: 'Last updated: April 8, 2026',
      heroIcon: Icons.article_outlined,
      heroTint: AppColors.brandGreen,
      heroBackground: Color(0xFFEAF7EE),
      sections: [
        _ArticleSection(
          title: 'Using the app',
          paragraphs: [
            'By creating an account or placing a booking, you agree to provide accurate profile, vehicle, and contact information so providers can complete the requested service.',
            'You are responsible for keeping your login details secure and for activity that happens through your account.',
          ],
          bullets: [
            'Use a valid name, phone number, and reachable booking address.',
            'Only schedule services for vehicles you are authorized to manage.',
            'Keep parking notes, gate codes, and access instructions updated.',
          ],
        ),
        _ArticleSection(
          title: 'Bookings and arrival',
          paragraphs: [
            'Booking times depend on provider availability, traffic, weather, and service duration. Providers may contact you before arrival to confirm access or service details.',
            'If the vehicle is unavailable or unsafe to access, the booking may need to be rescheduled or cancelled.',
          ],
          bullets: [
            'Keep your phone available near the scheduled time.',
            'Prepare the vehicle and location before the provider arrives.',
            'Repeated missed appointments may lead to temporary restrictions.',
          ],
          noteTitle: 'Important',
          noteMessage:
              'If the provider has already been dispatched, late cancellations may include a service fee.',
        ),
        _ArticleSection(
          title: 'Payments and refunds',
          paragraphs: [
            'Payments are authorized at checkout using the method you save or select in the app. Any extra add-on must be approved by you before it is charged.',
            'Refunds are returned to the original payment method when required by our cancellation or service-quality policies.',
          ],
          bullets: [
            'Cancel before dispatch for the best chance of a full refund.',
            'Refunds usually appear within 3 to 5 business days.',
            'Tips paid outside the app are not covered by refund protection.',
          ],
        ),
        _ArticleSection(
          title: 'Safety and account action',
          paragraphs: [
            'Car Wash is built for respectful, lawful use. Fraudulent payments, abusive behavior, unsafe work conditions, or illegal requests are not allowed.',
            'We may pause or permanently close accounts that create risk for customers, providers, or the platform.',
          ],
          bullets: [
            'Do not use false identities, stolen cards, or misleading booking details.',
            'Do not pressure providers to perform unsafe or unapproved services.',
            'Report serious incidents through Help Center for investigation.',
          ],
        ),
      ],
    );
  }
}

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _LegalArticleScreen(
      title: 'Privacy Policy',
      summary:
          'This policy describes what personal, booking, location, and payment-related information we collect and how we use it.',
      lastUpdated: 'Last updated: April 8, 2026',
      heroIcon: Icons.privacy_tip_outlined,
      heroTint: Color(0xFF8A5D0A),
      heroBackground: Color(0xFFFFF6DE),
      sections: [
        _ArticleSection(
          title: 'Information we collect',
          paragraphs: [
            'We collect the details needed to create your account, process bookings, and connect you with a nearby service provider. This may include your name, email, phone number, booking addresses, and saved preferences.',
            'When you enable permissions, we may also collect approximate or precise location, device details, and notification preferences to improve scheduling and service updates.',
          ],
          bullets: [
            'Account information such as name, email, and profile image.',
            'Booking details including vehicle type, service history, addresses, and notes.',
            'Payment-related metadata from checkout and refund activity.',
          ],
        ),
        _ArticleSection(
          title: 'How we use your information',
          paragraphs: [
            'Your information helps us confirm bookings, route providers, send receipts, prevent fraud, and improve reliability across the app.',
            'Service history and support conversations may also be used to resolve disputes and improve customer support.',
          ],
          bullets: [
            'Send booking confirmations, live updates, and payment receipts.',
            'Match you with available providers in your selected area.',
            'Protect the platform against abuse and suspicious activity.',
          ],
        ),
        _ArticleSection(
          title: 'Sharing, security, and control',
          paragraphs: [
            'We only share the information needed to operate the service. Providers receive booking details required to complete a wash or detailing appointment.',
            'Sensitive payment handling is processed through secure payment partners. We do not sell your personal information.',
          ],
          bullets: [
            'Access is limited to teams or partners who need it to perform their role.',
            'Closed accounts may retain limited records for legal or fraud-prevention reasons.',
            'You can review profile details and revoke location permission in device settings.',
          ],
          noteTitle: 'Need help?',
          noteMessage:
              'For data questions, deletion requests, or privacy concerns, contact support through Help Center and include the email linked to your account.',
        ),
      ],
    );
  }
}

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  static const _faqItems = <_FaqItem>[
    _FaqItem(
      question: 'How do I reschedule a booking?',
      answer:
          'Open your booking details before the provider arrives and choose a new time slot. If the provider is already on the way, support may need to help you reschedule.',
    ),
    _FaqItem(
      question: 'When will a cancelled booking refund appear?',
      answer:
          'Refunds usually return to the original payment method within 3 to 5 business days, depending on your bank or card issuer.',
    ),
    _FaqItem(
      question: 'How can I track my provider?',
      answer:
          'Booking notifications and the tracking screen show when the provider is on the way, in progress, or has completed the service.',
    ),
    _FaqItem(
      question: 'What should I do if payment fails?',
      answer:
          'Try another saved method or add a new card. If you still see a pending charge, contact support with the booking ID and payment time.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8F6),
      body: SafeArea(
        child: Column(
          children: [
            const _SupportTopBar(title: 'Help Center'),
            Divider(
              height: 1,
              thickness: 0.8,
              color: const Color(0xFFE9E6E3).withValues(alpha: 0.9),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                children: [
                  const _HelpHeroCard(),
                  const SizedBox(height: 18),
                  const Text(
                    'Quick help',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E2A22),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const _HelpTopicCard(
                    icon: Icons.calendar_today_outlined,
                    title: 'Booking and scheduling',
                    description:
                        'Get help with confirmations, reschedules, missed arrivals, or service tracking.',
                    highlights: [
                      'Reschedule a wash',
                      'Late provider',
                      'Track booking',
                    ],
                    iconTint: AppColors.brandGreen,
                    iconBackground: Color(0xFFEAF7EE),
                  ),
                  const SizedBox(height: 12),
                  const _HelpTopicCard(
                    icon: Icons.credit_card_rounded,
                    title: 'Payments and refunds',
                    description:
                        'Understand checkout issues, saved cards, duplicate charges, and refund timelines.',
                    highlights: [
                      'Failed payment',
                      'Refund status',
                      'View receipt',
                    ],
                    iconTint: Color(0xFF8A5D0A),
                    iconBackground: Color(0xFFFFF6DE),
                  ),
                  const SizedBox(height: 12),
                  const _HelpTopicCard(
                    icon: Icons.manage_accounts_outlined,
                    title: 'Account and privacy',
                    description:
                        'Update profile information, adjust permissions, or learn how your data is handled.',
                    highlights: [
                      'Edit profile',
                      'Privacy controls',
                      'Delete account',
                    ],
                    iconTint: Color(0xFF176B87),
                    iconBackground: Color(0xFFE8F5FA),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Frequently asked questions',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E2A22),
                    ),
                  ),
                  const SizedBox(height: 10),
                  for (var index = 0; index < _faqItems.length; index++) ...[
                    _FaqCard(item: _faqItems[index]),
                    if (index != _faqItems.length - 1)
                      const SizedBox(height: 10),
                  ],
                  const SizedBox(height: 18),
                  _SupportContactCard(
                    onPrivacyTap: context.pushToPrivacyPolicy,
                    onTermsTap: context.pushToTermsConditions,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegalArticleScreen extends StatelessWidget {
  const _LegalArticleScreen({
    required this.title,
    required this.summary,
    required this.lastUpdated,
    required this.heroIcon,
    required this.heroTint,
    required this.heroBackground,
    required this.sections,
  });

  final String title;
  final String summary;
  final String lastUpdated;
  final IconData heroIcon;
  final Color heroTint;
  final Color heroBackground;
  final List<_ArticleSection> sections;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8F6),
      body: SafeArea(
        child: Column(
          children: [
            _SupportTopBar(title: title),
            Divider(
              height: 1,
              thickness: 0.8,
              color: const Color(0xFFE9E6E3).withValues(alpha: 0.9),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _LegalHeroCard(
                      title: title,
                      summary: summary,
                      lastUpdated: lastUpdated,
                      icon: heroIcon,
                      iconTint: heroTint,
                      iconBackground: heroBackground,
                    ),
                    const SizedBox(height: 18),
                    for (var index = 0; index < sections.length; index++) ...[
                      _ArticleSectionCard(section: sections[index]),
                      if (index != sections.length - 1)
                        const SizedBox(height: 12),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SupportTopBar extends StatelessWidget {
  const _SupportTopBar({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      child: Stack(
        children: [
          Positioned(
            left: 8,
            top: 0,
            bottom: 0,
            child: IconButton(
              onPressed: () => context.pop(),
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppButtonColors.actionForeground,
                size: 18,
              ),
            ),
          ),
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 56),
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LegalHeroCard extends StatelessWidget {
  const _LegalHeroCard({
    required this.title,
    required this.summary,
    required this.lastUpdated,
    required this.icon,
    required this.iconTint,
    required this.iconBackground,
  });

  final String title;
  final String summary;
  final String lastUpdated;
  final IconData icon;
  final Color iconTint;
  final Color iconBackground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE7EBE8)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0E000000),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: iconTint, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1F2A22),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              lastUpdated,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: iconTint,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            summary,
            style: const TextStyle(
              fontSize: 13,
              height: 1.5,
              color: Color(0xFF607068),
            ),
          ),
        ],
      ),
    );
  }
}

class _ArticleSectionCard extends StatelessWidget {
  const _ArticleSectionCard({required this.section});

  final _ArticleSection section;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE7EBE8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            section.title,
            style: const TextStyle(
              fontSize: 15.5,
              fontWeight: FontWeight.w700,
              color: Color(0xFF243128),
            ),
          ),
          const SizedBox(height: 10),
          for (final paragraph in section.paragraphs) ...[
            Text(
              paragraph,
              style: const TextStyle(
                fontSize: 12.8,
                height: 1.55,
                color: Color(0xFF67756E),
              ),
            ),
            const SizedBox(height: 10),
          ],
          for (final bullet in section.bullets) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 5),
                  child: Icon(
                    Icons.circle,
                    size: 7,
                    color: AppColors.brandGreen,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    bullet,
                    style: const TextStyle(
                      fontSize: 12.8,
                      height: 1.5,
                      color: Color(0xFF67756E),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
          if (section.noteTitle != null && section.noteMessage != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF4F8F5),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFDCEBDF)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    section.noteTitle!,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.brandGreen,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    section.noteMessage!,
                    style: const TextStyle(
                      fontSize: 12.4,
                      height: 1.45,
                      color: Color(0xFF5D6B63),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _HelpHeroCard extends StatelessWidget {
  const _HelpHeroCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: [Color(0xFFF8FCF9), Color(0xFFEEF8F1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: const Color(0xFFDCEBDF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.brandGreen,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.support_agent_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Need help with a wash, payment, or account detail?',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1F2A22),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Browse the topics below for quick answers. If you still need help, contact support and include your booking ID for faster assistance.',
            style: TextStyle(
              fontSize: 13,
              height: 1.5,
              color: Color(0xFF607068),
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: const [
              _HeroTag(label: 'Booking help'),
              _HeroTag(label: 'Payments and refunds'),
              _HeroTag(label: 'Account and privacy'),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroTag extends StatelessWidget {
  const _HeroTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFD7E7DB)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11.8,
          fontWeight: FontWeight.w600,
          color: AppColors.brandGreen,
        ),
      ),
    );
  }
}

class _HelpTopicCard extends StatelessWidget {
  const _HelpTopicCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.highlights,
    required this.iconTint,
    required this.iconBackground,
  });

  final IconData icon;
  final String title;
  final String description;
  final List<String> highlights;
  final Color iconTint;
  final Color iconBackground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE7EBE8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: iconTint, size: 21),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1F2A22),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: const TextStyle(
              fontSize: 12.6,
              height: 1.45,
              color: Color(0xFF67756E),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final item in highlights)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: iconBackground,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    item,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: iconTint,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FaqCard extends StatelessWidget {
  const _FaqCard({required this.item});

  final _FaqItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE7EBE8)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          iconColor: AppColors.brandGreen,
          collapsedIconColor: const Color(0xFF718078),
          title: Text(
            item.question,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF253129),
            ),
          ),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                item.answer,
                style: const TextStyle(
                  fontSize: 12.6,
                  height: 1.5,
                  color: Color(0xFF68766F),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SupportContactCard extends StatelessWidget {
  const _SupportContactCard({
    required this.onPrivacyTap,
    required this.onTermsTap,
  });

  final VoidCallback onPrivacyTap;
  final VoidCallback onTermsTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE7EBE8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Still need support?',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF223027),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Email support@carwash.app and include your booking ID, payment amount, or service date. Our team usually replies within 1 business day.',
            style: TextStyle(
              fontSize: 12.6,
              height: 1.5,
              color: Color(0xFF68766F),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: const [
              Icon(
                Icons.schedule_rounded,
                size: 16,
                color: AppColors.brandGreen,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Support hours: Mon-Sat, 9:00 AM to 7:00 PM',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4E6056),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onPrivacyTap,
                  style: AppButtonStyles.outlined(
                    foregroundColor: AppColors.brandGreen,
                    borderColor: AppColors.brandGreen,
                    height: 44,
                  ),
                  child: const Text(
                    'Privacy Policy',
                    style: TextStyle(
                      fontSize: 12.8,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton(
                  onPressed: onTermsTap,
                  style: AppButtonStyles.filled(height: 44),
                  child: const Text(
                    'Terms & Conditions',
                    style: TextStyle(
                      fontSize: 12.8,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ArticleSection {
  const _ArticleSection({
    required this.title,
    required this.paragraphs,
    this.bullets = const [],
    this.noteTitle,
    this.noteMessage,
  });

  final String title;
  final List<String> paragraphs;
  final List<String> bullets;
  final String? noteTitle;
  final String? noteMessage;
}

class _FaqItem {
  const _FaqItem({required this.question, required this.answer});

  final String question;
  final String answer;
}
