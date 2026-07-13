import 'package:flutter/material.dart';
import 'package:gym_lead_master/src/presentation/routes/appRoutes.dart';

class TermsAndConditionsScreen extends StatefulWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  State<TermsAndConditionsScreen> createState() =>
      _TermsAndConditionsScreenState();
}

class _TermsAndConditionsScreenState extends State<TermsAndConditionsScreen> {
  final ScrollController _scrollController = ScrollController();
  double _scrollProgress = 0.0;
  bool _isAccepted = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.maxScrollExtent > 0) {
        setState(() {
          _scrollProgress =
              _scrollController.offset /
              _scrollController.position.maxScrollExtent;
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: const Text('Terms & Conditions'),
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 2,
      ),
      body: Column(
        children: [
          // Scroll Progress Indicator
          LinearProgressIndicator(
            value: _scrollProgress,
            backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
            color: theme.colorScheme.primary,
            minHeight: 3,
          ),

          // Content
          Expanded(
            child: Scrollbar(
              controller: _scrollController,
              child: ListView(
                controller: _scrollController,
                padding: const EdgeInsets.all(20),
                children: [
                  // Last Updated
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer.withOpacity(
                        0.3,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 18,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Last Updated: May 01, 2026',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Terms Sections
                  _buildTermSection(
                    context,
                    number: '1',
                    title: 'Account Responsibility',
                    content:
                        'Users are responsible for maintaining account security and password confidentiality. Any activity performed under your account is your responsibility.',
                  ),
                  _buildTermSection(
                    context,
                    number: '2',
                    title: 'Membership Rules',
                    content:
                        'Membership fees are non-refundable and subject to gym policies. Members must adhere to the gym\'s rules and regulations at all times.',
                  ),
                  _buildTermSection(
                    context,
                    number: '3',
                    title: 'Privacy Policy',
                    content:
                        'User information is securely stored and protected using Firebase security systems. We do not share your personal data with third parties without consent.',
                  ),
                  _buildTermSection(
                    context,
                    number: '4',
                    title: 'Prohibited Activities',
                    content:
                        'Fake accounts, abuse, spam, and unauthorized activities are strictly prohibited. Violations will result in immediate account suspension.',
                  ),
                  _buildTermSection(
                    context,
                    number: '5',
                    title: 'Trainer Responsibilities',
                    content:
                        'Trainers must manage members professionally and ethically. Harassment or unprofessional behavior will lead to termination of trainer privileges.',
                  ),
                  _buildTermSection(
                    context,
                    number: '6',
                    title: 'App Usage',
                    content:
                        'Gym Lead Master is intended only for gym management purposes. Misuse of the platform for illegal activities is strictly forbidden.',
                  ),
                  _buildTermSection(
                    context,
                    number: '7',
                    title: 'Data Protection',
                    content:
                        'The app uses secure Firebase Authentication, Firestore, and Storage systems. Data is encrypted in transit and at rest.',
                  ),
                  _buildTermSection(
                    context,
                    number: '8',
                    title: 'Account Suspension',
                    content:
                        'Violation of policies may result in temporary or permanent suspension. Suspended users will be notified via email.',
                  ),
                  const SizedBox(height: 30),

                  // Privacy Policy Button
                  Center(
                    child: TextButton.icon(
                      onPressed: () {
                        // NEW: Navigate to Privacy Policy Screen
                        Navigator.pushNamed(
                          context,
                          AppRoutes.privacyPolicyPage,
                        );
                      },
                      icon: const Icon(Icons.shield_outlined),
                      label: const Text('Read Full Privacy Policy'),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),

          // Accept Checkbox
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CheckboxListTile(
                  value: _isAccepted,
                  onChanged:
                      (val) => setState(() => _isAccepted = val ?? false),
                  title: const Text(
                    'I have read and agree to the Terms & Conditions',
                    style: TextStyle(fontSize: 14),
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed:
                        _isAccepted
                            ? () {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Terms Accepted!"),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                            : null,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Accept & Continue',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTermSection(
    BuildContext context, {
    required String number,
    required String title,
    required String content,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                number,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  content,
                  style: TextStyle(
                    height: 1.6,
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 14,
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
