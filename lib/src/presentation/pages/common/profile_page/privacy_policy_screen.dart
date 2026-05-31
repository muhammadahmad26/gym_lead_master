import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader("Privacy Policy", Icons.shield_outlined, theme),
            const SizedBox(height: 16),
            _buildDate("Effective Date: May 01, 2026"),
            const SizedBox(height: 24),

            _buildSection(
              "1. Introduction",
              "Welcome to Gym Lead Master ('we', 'our', 'us'). We respect your privacy and are committed to protecting the personal data you share with us. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our mobile application.",
            ),

            _buildSection(
              "2. Information We Collect",
              "We collect information that you provide directly to us, including:\n\n"
                  "• **Account Data:** Name, email address, and password when you register.\n"
                  "• **Profile Data:** Profile pictures, location, and phone numbers.\n"
                  "• **Gym Data:** Gym ID, workout preferences, and attendance check-ins.\n"
                  "• **Payment Data:** Payment method details and transaction screenshots.\n"
                  "• **Device Data:** IP address, device type, and operating system.",
            ),

            _buildSection(
              "3. How We Use Your Information",
              "We use the collected information for:\n\n"
                  "• To create and manage your account.\n"
                  "• To verify payments and activate memberships.\n"
                  "• To provide gym attendance tracking and live member counts.\n"
                  "• To facilitate communication between gym admin, trainers, and members.\n"
                  "• To improve our app's features and user experience.",
            ),

            _buildSection(
              "4. Data Sharing & Disclosure",
              "We do NOT sell your personal data. We may share your data only in the following circumstances:\n\n"
                  "• **With Your Gym:** Your attendance, payment status, and profile data are visible to your gym's authorized administrators.\n"
                  "• **Service Providers:** We use Firebase (Google) for secure data storage and authentication.\n"
                  "• **Legal Requirements:** If required by law or legal process.",
            ),

            _buildSection(
              "5. Data Security",
              "We use administrative, technical, and physical security measures to help protect your personal information, including end-to-end encryption for passwords and secure cloud infrastructure provided by Google Firebase.",
            ),

            _buildSection(
              "6. Data Retention",
              "We retain your personal data only for as long as necessary to fulfill the purposes outlined in this policy, or as required by law. If you delete your account, your data will be scheduled for deletion within 30 days.",
            ),

            _buildSection(
              "7. Your Rights",
              "You have the right to:\n\n"
                  "• Access the personal data we hold about you.\n"
                  "• Request correction or deletion of your data.\n"
                  "• Withdraw consent for data processing.\n"
                  "• Opt-out of communications at any time.",
            ),

            _buildSection(
              "8. Changes to This Policy",
              "We may update this Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page and updating the 'Effective Date' at the top.",
            ),

            _buildSection(
              "9. Contact Us",
              "If you have any questions about this Privacy Policy, please contact us at:\n\n"
                  "📧 Email: gymleadmaster.support@gmail.com\n"
                  "📞 Phone: +92 303 8933646",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String title, IconData icon, ThemeData theme) {
    return Row(
      children: [
        Icon(icon, size: 28, color: theme.colorScheme.primary),
        const SizedBox(width: 12),
        Text(
          title,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildDate(String date) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(
            date,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              height: 1.6,
              color: Colors.grey[700],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
