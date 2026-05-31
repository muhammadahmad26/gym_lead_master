import 'package:flutter/material.dart';
import 'package:gym_lead_master/src/presentation/pages/common/profile_page/contact_support_screen.dart';

// --- DATA MODELS ---
class FaqItem {
  final String question;
  final String answer;
  FaqItem({required this.question, required this.answer});
}

class FaqCategory {
  final String title;
  final IconData icon;
  final Color color;
  final List<FaqItem> items;
  FaqCategory({
    required this.title,
    required this.icon,
    required this.color,
    required this.items,
  });
}

// --- SCREEN ---
class HelpFaqScreen extends StatefulWidget {
  const HelpFaqScreen({super.key});

  @override
  State<HelpFaqScreen> createState() => _HelpFaqScreenState();
}

class _HelpFaqScreenState extends State<HelpFaqScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  final ScrollController _scrollController = ScrollController();

  // FAQ Data
  final List<FaqCategory> _categories = [
    FaqCategory(
      title: 'Account',
      icon: Icons.person_outline,
      color: Colors.blue,
      items: [
        FaqItem(
          question: 'How do I create an account?',
          answer: 'Go to the Sign Up page → Select your role (Admin/Member) → Enter your details → Press Sign Up.',
        ),
        FaqItem(
          question: 'How do I reset my password?',
          answer: 'On the Login page → Click "Forgot Password?" → Enter your email → Check your inbox for the reset link.',
        ),
        FaqItem(
          question: 'How do I update my profile?',
          answer: 'Open Profile Screen → Click Edit Profile → Update your information → Press Save.',
        ),
      ],
    ),
    FaqCategory(
      title: 'Membership',
      icon: Icons.card_membership_outlined,
      color: Colors.purple,
      items: [
        FaqItem(
          question: 'How do I join a gym membership?',
          answer: 'Ask your gym admin for the Gym ID → Sign up as a Member → Enter the Gym ID → Submit payment proof.',
        ),
        FaqItem(
          question: 'How can I renew my membership?',
          answer: 'Go to Payments → Select a plan → Upload payment proof → Wait for admin approval.',
        ),
        FaqItem(
          question: 'Can I cancel membership?',
          answer: 'Contact your gym admin directly. Cancellation policies depend on your gym\'s terms.',
        ),
      ],
    ),
    FaqCategory(
      title: 'Trainer',
      icon: Icons.fitness_center_outlined,
      color: Colors.orange,
      items: [
        FaqItem(
          question: 'How do trainers manage members?',
          answer: 'Trainers can view member lists, track attendance, and monitor workout progress from their dashboard.',
        ),
        FaqItem(
          question: 'How can trainers assign workout plans?',
          answer: 'Go to Member Profile → Click Assign Workout → Create or select a plan → Save.',
        ),
      ],
    ),
    FaqCategory(
      title: 'Payments',
      icon: Icons.payment_outlined,
      color: Colors.green,
      items: [
        FaqItem(
          question: 'How do I pay membership fees?',
          answer: 'Go to Payments → Select plan → Choose payment method → Upload screenshot → Submit.',
        ),
        FaqItem(
          question: 'Are payments refundable?',
          answer: 'Refund policies vary by gym. Please contact your gym admin for refund requests.',
        ),
      ],
    ),
    FaqCategory(
      title: 'Attendance',
      icon: Icons.access_time,
      color: Colors.red,
      items: [
        FaqItem(
          question: 'How does attendance tracking work?',
          answer: 'Click the Check-In button → Select your exercises → Submit. Your check-in time and exercises are recorded.',
        ),
      ],
    ),
  ];

  List<FaqCategory> get _filteredCategories {
    if (_searchQuery.isEmpty) return _categories;

    return _categories.map((category) {
      final filteredItems = category.items
          .where((item) =>
              item.question.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              item.answer.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();

      if (filteredItems.isEmpty) return null;
      return FaqCategory(
        title: category.title,
        icon: category.icon,
        color: category.color,
        items: filteredItems,
      );
    }).whereType<FaqCategory>().toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final filtered = _filteredCategories;

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: const Text('Help & FAQ'),
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 2,
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            color: theme.colorScheme.surface,
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: 'Search questions...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = "");
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: isDark ? Colors.grey[850] : Colors.grey[100],
              ),
            ),
          ),

          // FAQ List
          Expanded(
            child: filtered.isEmpty
                ? _buildEmptyState(theme)
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      return _buildCategoryCard(filtered[index], theme, isDark);
                    },
                  ),
          ),
        ],
      ),
      // Contact Support Button
      bottomNavigationBar: Container(
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
        child: FilledButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ContactSupportScreen()),
            );
          },
          icon: const Icon(Icons.headset_mic_outlined),
          label: const Text('Contact Support', style: TextStyle(fontSize: 16)),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCard(FaqCategory category, ThemeData theme, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
          initiallyExpanded: _searchQuery.isNotEmpty,
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: category.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(category.icon, color: category.color, size: 22),
          ),
          title: Text(
            category.title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          children: category.items.map((item) {
            return _buildFaqItem(item, theme, isDark);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildFaqItem(FaqItem item, ThemeData theme, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800]!.withOpacity(0.5) : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Theme(
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          leading: Icon(Icons.help_outline, size: 18, color: theme.colorScheme.onSurfaceVariant),
          title: Text(
            item.question,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.check_circle, size: 16, color: Colors.green[400]),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item.answer,
                    style: TextStyle(
                      fontSize: 13,
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: theme.disabledColor),
            const SizedBox(height: 16),
            Text(
              'No results found',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Try searching with different keywords',
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.disabledColor),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}