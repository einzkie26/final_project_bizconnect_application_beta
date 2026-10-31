import 'package:flutter/material.dart';
import 'login_acc.dart';

class ManualStep {
  final String title;
  final IconData icon;
  final String description;
  final int stepNumber;

  ManualStep({
    required this.title,
    required this.icon,
    required this.description,
    required this.stepNumber,
  });
}

class ManualPage {
  final String pageTitle;
  final String subtitle;
  final List<ManualStep> steps;

  ManualPage({
    required this.pageTitle,
    required this.subtitle,
    required this.steps,
  });
}

class UserManual extends StatefulWidget {
  const UserManual({super.key});

  @override
  State<UserManual> createState() => _UserManualState();
}

class _UserManualState extends State<UserManual> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<ManualPage> _pages = [
    ManualPage(
      pageTitle: 'Getting Started',
      subtitle: 'Follow these simple steps to create your account',
      steps: [
        ManualStep(stepNumber: 1, title: 'Register', icon: Icons.person_add, description: 'Tap "Register" and fill in your details'),
        ManualStep(stepNumber: 2, title: 'Complete Profile', icon: Icons.edit_document, description: 'Add your information and preferences'),
      ],
    ),
    ManualPage(
      pageTitle: 'Explore Features',
      subtitle: 'Discover what you can do with the app',
      steps: [
        ManualStep(stepNumber: 1, title: 'Browse', icon: Icons.business, description: 'Discover companies in your area'),
        ManualStep(stepNumber: 2, title: 'Search', icon: Icons.search, description: 'Find companies and entrepreneurs'),
        ManualStep(stepNumber: 3, title: 'Connect', icon: Icons.message, description: 'Start conversations and network'),
      ],
    ),
    ManualPage(
      pageTitle: 'Manage Profile',
      subtitle: 'Keep your information up to date',
      steps: [
        ManualStep(stepNumber: 1, title: 'Edit Profile', icon: Icons.person, description: 'Update your personal information'),
        ManualStep(stepNumber: 2, title: 'Company Profile', icon: Icons.store, description: 'Switch to manage your business'),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color(0xFF6A5AE0),
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
        title: const Text('User Manual', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600)),
        actions: [
          TextButton(
            onPressed: () => _showAuthOptions(context),
            child: const Text('Skip', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
          )
        ],
      ),
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [Color(0xFF6A5AE0), Color(0xFFE91E63)]),
            ),
            child: Column(
              children: [
                Text(_pages[_currentPage].pageTitle,
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white), textAlign: TextAlign.center),
                const SizedBox(height: 8),
                Text(_pages[_currentPage].subtitle,
                    style: TextStyle(fontSize: 16, color: Colors.white.withValues(alpha: 0.9)), textAlign: TextAlign.center),
              ],
            ),
          ),

          // Progress Info
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Color(0xFF6A5AE0), size: 20),
                const SizedBox(width: 8),
                Text('Step ${_currentPage + 1} of ${_pages.length}',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF6A5AE0))),
                const Spacer(),
                Text('${((_currentPage + 1) / _pages.length * 100).toInt()}% Complete',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600])),
              ],
            ),
          ),

          // Main Content
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (i) => setState(() => _currentPage = i),
              itemCount: _pages.length,
              itemBuilder: (context, pageIndex) {
                final steps = _pages[pageIndex].steps;
                return Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(30),
                    child: Wrap(
                      spacing: 32,
                      runSpacing: 32,
                      alignment: WrapAlignment.center,
                      children: steps.map((step) => _buildStepCard(step)).toList(),
                    ),
                  ),
                );
              },
            ),
          ),

          // Indicators
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pages.length, (index) {
                bool isCurrent = index == _currentPage;
                bool isCompleted = index < _currentPage;

                return GestureDetector(
                  onTap: () => _pageController.animateToPage(index,
                      duration: const Duration(milliseconds: 400), curve: Curves.easeInOut),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.ease,
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    width: isCurrent ? 40 : (isCompleted ? 20 : 12),
                    height: 12,
                    decoration: BoxDecoration(
                      gradient: isCurrent || isCompleted
                          ? const LinearGradient(colors: [Color(0xFF6A5AE0), Color(0xFFE91E63)])
                          : null,
                      color: isCurrent || isCompleted ? null : Colors.grey[400],
                      borderRadius: BorderRadius.circular(12),
                      border: !isCurrent && !isCompleted
                          ? Border.all(color: Colors.grey[500]!, width: 2)
                          : null,
                    ),
                  ),
                );
              }),
            ),
          ),

          // Bottom Buttons
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentPage > 0)
                  OutlinedButton.icon(
                    onPressed: () => _pageController.previousPage(
                        duration: const Duration(milliseconds: 300), curve: Curves.easeInOut),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('BACK'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF6A5AE0),
                      side: const BorderSide(color: Color(0xFF6A5AE0), width: 2),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                  )
                else
                  const SizedBox(width: 80),

                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF6A5AE0), Color(0xFFE91E63)]),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [BoxShadow(color: const Color(0xFF6A5AE0).withValues(alpha: 0.4), blurRadius: 12, offset: const Offset(0, 6))],
                  ),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (_currentPage < _pages.length - 1) {
                        _pageController.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
                      } else {
                        _showAuthOptions(context);
                      }
                    },
                    icon: Icon(_currentPage == _pages.length - 1 ? Icons.check_circle : Icons.arrow_forward),
                    label: Text(
                      _currentPage == _pages.length - 1 ? 'GET STARTED' : 'NEXT',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
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

  // CLEAN ICON (NO NUMBERS INSIDE)
  Widget _buildStepCard(ManualStep step) {
    return Container(
      width: 210,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF6A5AE0).withValues(alpha: 0.3), width: 2),
        boxShadow: [
          BoxShadow(color: Colors.grey.withValues(alpha: 0.15), blurRadius: 12, offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Step Badge (still visible)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF6A5AE0), Color(0xFFE91E63)]),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'STEP ${step.stepNumber}',
              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 20),

          // CLEAN CIRCLE ICON (NO NUMBERS)
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF6A5AE0), width: 4),
            ),
            alignment: Alignment.center,
            child: Icon(step.icon, size: 50, color: const Color(0xFF6A5AE0)),
          ),

          const SizedBox(height: 20),

          Text(step.title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Color(0xFF6A5AE0))),
          const SizedBox(height: 12),

          Text(step.description,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.5)),
        ],
      ),
    );
  }

  void _showAuthOptions(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
