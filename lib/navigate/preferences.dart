import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../controllers/preferences_controller.dart';
import '../controllers/profile_controller.dart';
import '../login/login_acc.dart';
import 'support_page.dart';

class PreferencesPage extends ConsumerWidget {
  const PreferencesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferencesState = ref.watch(preferencesControllerProvider);
    final preferencesController = ref.read(preferencesControllerProvider.notifier);
    final profileController = ref.read(profileControllerProvider.notifier);
    final userProfile = ref.watch(profileControllerProvider);
    
    // Load preferences once on first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!preferencesState.isLoading && preferencesState == PreferencesState()) {
        preferencesController.loadPreferences();
      }
    });

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.1),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Text(
                    'Preferences',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.settings,
                        color: Colors.deepPurple,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Account Settings Section
                    _buildSectionTitle('Account Settings'),
                    const SizedBox(height: 12),
                    _buildSettingsCard([
                      _buildSettingsTile(
                        icon: Icons.person_outline,
                        title: 'Edit Profile',
                        subtitle: 'Update your personal information',
                        onTap: () {
                          _showEditProfileOptions(context);
                        },
                      ),
                      _buildDivider(),
                      _buildSettingsTile(
                        icon: Icons.lock_outline,
                        title: 'Change Password',
                        subtitle: 'Update your password',
                        onTap: () {
                          _showChangePasswordDialog(context);
                        },
                      ),
                      _buildDivider(),
                      _buildSettingsTile(
                        icon: Icons.email_outlined,
                        title: 'Email Preferences',
                        subtitle: 'Manage email settings',
                        onTap: () {
                          _showEmailPreferencesDialog(context);
                        },
                      ),
                    ]),
                    
                    const SizedBox(height: 24),
                    
                    _buildSectionTitle('Notifications'),
                    const SizedBox(height: 12),
                    _buildSettingsCard([
                      _buildSwitchTile(
                        icon: Icons.notifications_outlined,
                        title: 'Push Notifications',
                        subtitle: 'Receive push notifications',
                        value: preferencesState.pushNotifications,
                        onChanged: (value) {
                          preferencesController.updatePreference('pushNotifications', value);
                        },
                      ),
                      _buildDivider(),
                      _buildSwitchTile(
                        icon: Icons.email_outlined,
                        title: 'Email Notifications',
                        subtitle: 'Receive email updates',
                        value: preferencesState.emailNotifications,
                        onChanged: (value) {
                          preferencesController.updatePreference('emailNotifications', value);
                        },
                      ),
                      _buildDivider(),
                      _buildSwitchTile(
                        icon: Icons.message_outlined,
                        title: 'Message Alerts',
                        subtitle: 'Get notified of new messages',
                        value: preferencesState.messageAlerts,
                        onChanged: (value) {
                          preferencesController.updatePreference('messageAlerts', value);
                        },
                      ),
                    ]),
                    
                    const SizedBox(height: 24),
                    
                    _buildSectionTitle('Display & Privacy'),
                    const SizedBox(height: 12),
                    _buildSettingsCard([
                      if (userProfile?.isWorkingAtCompany == true && userProfile?.companyName != null)
                        _buildSwitchTile(
                          icon: Icons.business_outlined,
                          title: 'Use Company Name',
                          subtitle: 'Display company name instead of personal name',
                          value: userProfile?.useCompanyName ?? true,
                          onChanged: (value) {
                            profileController.toggleDisplayName();
                          },
                        ),
                      if (userProfile?.isWorkingAtCompany == true && userProfile?.companyName != null)
                        _buildDivider(),
                      _buildSwitchTile(
                        icon: Icons.visibility_outlined,
                        title: 'Profile Visibility',
                        subtitle: 'Make your profile public',
                        value: preferencesState.profileVisibility,
                        onChanged: (value) {
                          preferencesController.updatePreference('profileVisibility', value);
                        },
                      ),
                      _buildDivider(),
                      _buildSwitchTile(
                        icon: Icons.share_outlined,
                        title: 'Data Sharing',
                        subtitle: 'Share analytics data',
                        value: preferencesState.dataSharing,
                        onChanged: (value) {
                          preferencesController.updatePreference('dataSharing', value);
                        },
                      ),
                      _buildDivider(),
                      _buildSettingsTile(
                        icon: Icons.block_outlined,
                        title: 'Blocked Users',
                        subtitle: 'Manage blocked accounts',
                        onTap: () {
                          _showBlockedUsersDialog(context);
                        },
                      ),
                    ]),
                    
                    const SizedBox(height: 24),

                    _buildSectionTitle('Appearance'),
                    const SizedBox(height: 12),
                    _buildSettingsCard([
                      _buildSwitchTile(
                        icon: Icons.dark_mode_outlined,
                        title: 'Dark Mode',
                        subtitle: 'Enable dark theme',
                        value: preferencesState.darkMode,
                        onChanged: (value) {
                          preferencesController.updatePreference('darkMode', value);
                        },
                      ),
                      _buildDivider(),
                      _buildSettingsTile(
                        icon: Icons.language_outlined,
                        title: 'Language',
                        subtitle: 'English (US)',
                        onTap: () {},
                      ),
                    ]),
                    
                    const SizedBox(height: 24),
                    
                    _buildSectionTitle('About'),
                    const SizedBox(height: 12),
                    _buildSettingsCard([
                      _buildSettingsTile(
                        icon: Icons.info_outline,
                        title: 'App Version',
                        subtitle: '1.0.0',
                        onTap: () {},
                        showArrow: false,
                      ),
                      _buildDivider(),
                      _buildSettingsTile(
                        icon: Icons.description_outlined,
                        title: 'Terms of Service',
                        subtitle: 'Read our terms',
                        onTap: () {},
                      ),
                      _buildDivider(),
                      _buildSettingsTile(
                        icon: Icons.privacy_tip_outlined,
                        title: 'Privacy Policy',
                        subtitle: 'Read our privacy policy',
                        onTap: () {},
                      ),
                      _buildDivider(),
                      _buildSettingsTile(
                        icon: Icons.help_outline,
                        title: 'Help & Support',
                        subtitle: 'Get help with the app',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const SupportPage()),
                          );
                        },
                      ),
                    ]),
                    
                    const SizedBox(height: 24),
                    
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withValues(alpha: 0.1),
                            spreadRadius: 1,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            _showLogoutDialog(context, ref);
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.logout,
                                  color: Colors.red[600],
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Logout',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.red[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool showArrow = true,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: Colors.deepPurple,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              if (showArrow)
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey[400],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.deepPurple.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Colors.deepPurple,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.deepPurple,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(
        height: 1,
        color: Colors.grey[200],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    final preferencesController = ref.read(preferencesControllerProvider.notifier);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Logout',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          content: const Text(
            'Are you sure you want to logout?',
            style: TextStyle(
              color: Colors.black87,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                
                // Sign out and navigate to login
                await preferencesController.signOut();
                
                // Force navigation to login screen
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (route) => false,
                  );
                }
              },
              child: const Text(
                'Logout',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
  
  void _showEditProfileOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Edit Profile',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Edit Name'),
              onTap: () {
                Navigator.pop(context);
                _showComingSoonSnackBar(context, 'Edit name');
              },
            ),
            ListTile(
              leading: const Icon(Icons.phone),
              title: const Text('Edit Phone Number'),
              onTap: () {
                Navigator.pop(context);
                _showComingSoonSnackBar(context, 'Edit phone number');
              },
            ),
            ListTile(
              leading: const Icon(Icons.location_on),
              title: const Text('Edit Location'),
              onTap: () {
                Navigator.pop(context);
                _showComingSoonSnackBar(context, 'Edit location');
              },
            ),
          ],
        ),
      ),
    );
  }
  
  void _showChangePasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: const Text('Password change feature coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
  
  void _showEmailPreferencesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Email Preferences'),
        content: const Text('Email preferences management coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
  
  void _showBlockedUsersDialog(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const BlockedUsersPage()),
    );
  }
  
  void _showComingSoonSnackBar(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature feature coming soon!'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

class BlockedUsersPage extends StatefulWidget {
  const BlockedUsersPage({super.key});

  @override
  State<BlockedUsersPage> createState() => _BlockedUsersPageState();
}

class _BlockedUsersPageState extends State<BlockedUsersPage> {
  final _currentUserId = FirebaseAuth.instance.currentUser?.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Text('Blocked Users', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            Container(
              color: Colors.white,
              child: const TabBar(
                labelColor: Colors.deepPurple,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.deepPurple,
                tabs: [
                  Tab(text: 'Personal'),
                  Tab(text: 'Company'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildBlockedUsersList('personal'),
                  _buildBlockedUsersList('company'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Unknown';
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildBlockedUsersList(String blockType) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('blocked_users')
          .where('blockerId', isEqualTo: _currentUserId)
          .where('blockType', isEqualTo: blockType)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final blockedUsers = snapshot.data!.docs;

        if (blockedUsers.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.block, size: 80, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text(
                  'No blocked $blockType users',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: blockedUsers.length,
          itemBuilder: (context, index) {
            final blockData = blockedUsers[index].data() as Map<String, dynamic>;
            final blockedUserId = blockData['blockedId'];

            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(blockedUserId)
                  .get(),
              builder: (context, userSnapshot) {
                if (!userSnapshot.hasData) {
                  return const SizedBox();
                }

                final userData = userSnapshot.data!.data() as Map<String, dynamic>?;
                final userName = userData?['name'] ?? 'Unknown User';
                final profilePicUrl = userData?['profilePicUrl'];

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.1),
                        spreadRadius: 1,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.deepPurple.withValues(alpha: 0.1),
                      backgroundImage: profilePicUrl != null ? NetworkImage(profilePicUrl) : null,
                      child: profilePicUrl == null
                          ? Text(
                              userName.substring(0, 1).toUpperCase(),
                              style: const TextStyle(
                                color: Colors.deepPurple,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                    title: Text(
                      userName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Blocked on ${_formatDate(blockData['blockedAt']?.toDate())}',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: blockType == 'company' ? Colors.blue.withValues(alpha: 0.1) : Colors.green.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            blockType.toUpperCase(),
                            style: TextStyle(
                              color: blockType == 'company' ? Colors.blue : Colors.green,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'unblock') {
                          _unblockUser(blockedUsers[index].id, userName);
                        } else if (value == 'report') {
                          _reportUser(blockedUserId, userName);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'unblock',
                          child: Row(
                            children: [
                              Icon(Icons.person, color: Colors.green),
                              SizedBox(width: 8),
                              Text('Unblock'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'report',
                          child: Row(
                            children: [
                              Icon(Icons.report, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Report'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Future<void> _unblockUser(String blockDocId, String userName) async {
    try {
      await FirebaseFirestore.instance
          .collection('blocked_users')
          .doc(blockDocId)
          .delete();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$userName has been unblocked'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to unblock user'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _reportUser(String userId, String userName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Report $userName'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Why are you reporting this user?'),
            const SizedBox(height: 16),
            ...['Harassment', 'Spam', 'Inappropriate Content', 'Other'].map(
              (reason) => ListTile(
                title: Text(reason),
                onTap: () {
                  Navigator.pop(context);
                  _submitReport(userId, userName, reason);
                },
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitReport(String userId, String userName, String reason) async {
    try {
      await FirebaseFirestore.instance.collection('user_reports').add({
        'reporterId': _currentUserId,
        'reportedUserId': userId,
        'reason': reason,
        'reportedAt': DateTime.now(),
        'status': 'pending',
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Report submitted for $userName'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to submit report'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}