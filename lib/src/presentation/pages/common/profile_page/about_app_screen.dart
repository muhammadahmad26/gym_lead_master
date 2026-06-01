import 'package:flutter/material.dart';
import 'dart:async'; // For Timer
import 'package:gym_lead_master/src/core/constants/appColor.dart';
import 'package:gym_lead_master/src/presentation/pages/common/profile_page/privacy_policy_screen.dart';
import 'package:gym_lead_master/src/presentation/pages/common/profile_page/term_and_conditions_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

class AboutAppScreen extends StatefulWidget {
  const AboutAppScreen({super.key});

  @override
  State<AboutAppScreen> createState() => _AboutAppScreenState();
}

class _AboutAppScreenState extends State<AboutAppScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  // Replace with your actual Play Store / App Store link
  final String _appStoreUrl =
      "https://play.google.com/store/apps/details?id=com.example.gymLeadMaster";

  int _rating = 0; // NEW: Track user's star rating
  bool _isLaunching = false; // NEW: Prevent multiple launches

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ✅ FIXED: Rate App - Try directly without canLaunchUrl check
  Future<void> _rateApp() async {
    if (_isLaunching) return;
    setState(() => _isLaunching = true);

    try {
      final Uri url = Uri.parse(_appStoreUrl);

      // ✅ FIX: Just try launching - don't check canLaunchUrl first
      await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      ).timeout(const Duration(seconds: 5), onTimeout: () => false);
      // Don't show error even if launch fails on some platforms
    } catch (e) {
      // Silently fail - user can search the app store manually
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Please search 'Gym Lead Master' on your app store."),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } finally {
      Timer(const Duration(seconds: 2), () {
        if (mounted) setState(() => _isLaunching = false);
      });
    }
  }

  // ✅ FIXED: Share App
  Future<void> _shareApp() async {
    try {
      await Share.share(
        'Check out Gym Lead Master - The ultimate gym management app! 💪 Download now: $_appStoreUrl',
        subject: 'Gym Lead Master App',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Sharing not available on this device.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Gradient Header with Animated Logo
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 70, 20, 40),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.tertiary,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 15,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.fitness_center,
                        size: 50,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Gym Lead Master',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Version 1.0.0',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // About Description
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'About',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Gym Lead Master is a modern gym management application designed for gym owners, trainers, and members. The app helps manage:',
                            style: theme.textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children:
                                [
                                      'Memberships',
                                      'Attendance',
                                      'Workout Plans',
                                      'Trainer Assignments',
                                      'Payments',
                                      'Notifications',
                                      'Member Progress',
                                    ]
                                    .map(
                                      (tag) => Chip(
                                        label: Text(
                                          tag,
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                        backgroundColor:
                                            theme.colorScheme.primaryContainer,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 4,
                                        ),
                                      ),
                                    )
                                    .toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // UPDATED: Interactive Rating Card
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Text(
                            'Enjoying the App?',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Interactive Stars (Visual feedback only)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(5, (index) {
                              return IconButton(
                                icon: Icon(
                                  index < _rating
                                      ? Icons.star
                                      : Icons.star_outline,
                                  color: Colors.amber,
                                  size: 36,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _rating = index + 1; // Update visual rating
                                  });
                                },
                              );
                            }),
                          ),

                          if (_rating > 0)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Text(
                                'You selected $_rating star${_rating > 1 ? "s" : ""}. Thank you!',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed:
                                  _rating > 0
                                      ? _rateApp
                                      : null, // Only enable if stars are selected
                              icon: const Icon(
                                Icons.star_rate,
                                color: Colors.white,
                              ),
                              label: const Text(
                                'Rate Us on Play Store',
                                style: TextStyle(color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.amber[700],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                disabledBackgroundColor: Colors.grey[300],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Developer Card
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Developer',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: CircleAvatar(
                              backgroundColor: theme.colorScheme.primary,
                              child: const Icon(
                                Icons.code,
                                color: Colors.white,
                              ),
                            ),
                            title: const Text(
                              'Gym Lead Master Team',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: const Text(
                              "gymleadmaster.support@gmail.com",
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Action Tiles
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          leading: Icon(
                            Icons.share_outlined,
                            color: AppColors.BrightBlue,
                          ),
                          title: const Text('Share App'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: _shareApp,
                        ),
                        const Divider(height: 0, indent: 16, endIndent: 16),
                        ListTile(
                          leading: Icon(
                            Icons.privacy_tip_outlined,
                            color: Colors.purple[400],
                          ),
                          title: const Text('Privacy Policy'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const PrivacyPolicyScreen(),
                              ),
                            );
                          },
                        ),
                        const Divider(height: 0, indent: 16, endIndent: 16),
                        ListTile(
                          leading: Icon(
                            Icons.description_outlined,
                            color: Colors.blue[400],
                          ),
                          title: const Text('Terms & Conditions'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) => const TermsAndConditionsScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),
                  Text(
                    '© ${DateTime.now().year} Gym Lead Master. All rights reserved.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.disabledColor,
                    ),
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
