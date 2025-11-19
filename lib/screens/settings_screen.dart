import 'package:flutter/material.dart';
import '../utils/constants.dart';
import 'dashboard_screen.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pushNotifications = true;
  bool _inAppNotifications = true;
  bool _messageNotifications = true;
  bool _matchNotifications = true;
  bool _showOnlineStatus = true;
  bool _showLastSeen = true;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        elevation: 0,
      ),
      body: ListView(
        padding: EdgeInsets.all(AppConstants.padding),
        children: [
          _buildSection(
            title: 'Profile',
            children: [
              _buildListTile(
                icon: Icons.person,
                title: 'Edit Profile',
                subtitle: 'Update your photo, bio, and preferences',
                onTap: () {
                  _showEditProfileDialog();
                },
              ),
              _buildListTile(
                icon: Icons.photo_camera,
                title: 'Profile Photos',
                subtitle: 'Manage your profile pictures',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Photo management coming soon!'),
                      backgroundColor: AppConstants.primaryColor,
                    ),
                  );
                },
              ),
            ],
          ),
          SizedBox(height: 20),
          _buildSection(
            title: 'Notifications',
            children: [
              _buildSwitchTile(
                icon: Icons.notifications,
                title: 'Push Notifications',
                subtitle: 'Receive notifications when app is closed',
                value: _pushNotifications,
                onChanged: (value) {
                  setState(() {
                    _pushNotifications = value;
                  });
                },
              ),
              _buildSwitchTile(
                icon: Icons.notification_important,
                title: 'In-App Notifications',
                subtitle: 'Show notifications within the app',
                value: _inAppNotifications,
                onChanged: (value) {
                  setState(() {
                    _inAppNotifications = value;
                  });
                },
              ),
              _buildSwitchTile(
                icon: Icons.message,
                title: 'Message Notifications',
                subtitle: 'Get notified of new messages',
                value: _messageNotifications,
                onChanged: (value) {
                  setState(() {
                    _messageNotifications = value;
                  });
                },
              ),
              _buildSwitchTile(
                icon: Icons.favorite,
                title: 'Match Notifications',
                subtitle: 'Get notified of new matches',
                value: _matchNotifications,
                onChanged: (value) {
                  setState(() {
                    _matchNotifications = value;
                  });
                },
              ),
            ],
          ),
          SizedBox(height: 20),
          _buildSection(
            title: 'Privacy',
            children: [
              _buildSwitchTile(
                icon: Icons.visibility,
                title: 'Show Online Status',
                subtitle: 'Let others see when you\'re online',
                value: _showOnlineStatus,
                onChanged: (value) {
                  setState(() {
                    _showOnlineStatus = value;
                  });
                },
              ),
              _buildSwitchTile(
                icon: Icons.access_time,
                title: 'Show Last Seen',
                subtitle: 'Let others see when you were last active',
                value: _showLastSeen,
                onChanged: (value) {
                  setState(() {
                    _showLastSeen = value;
                  });
                },
              ),
              _buildListTile(
                icon: Icons.block,
                title: 'Blocked Users',
                subtitle: 'Manage your blocked users list',
                onTap: () {
                  _showBlockedUsersDialog();
                },
              ),
            ],
          ),
          SizedBox(height: 20),
          _buildSection(
            title: 'Support',
            children: [
              _buildListTile(
                icon: Icons.help,
                title: 'Help Center',
                subtitle: 'Get help and find answers',
                onTap: () {
                  _showHelpDialog();
                },
              ),
              _buildListTile(
                icon: Icons.feedback,
                title: 'Send Feedback',
                subtitle: 'Help us improve the app',
                onTap: () {
                  _showFeedbackDialog();
                },
              ),
              _buildListTile(
                icon: Icons.info,
                title: 'About',
                subtitle: 'App version and information',
                onTap: () {
                  _showAboutDialog();
                },
              ),
            ],
          ),
          SizedBox(height: 30),
          _buildDangerZone(),
        ],
      ),
    );
  }
  
  Widget _buildSection({required String title, required List<Widget> children}) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppConstants.primaryColor,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }
  
  Widget _buildListTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppConstants.primaryColor),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
  
  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppConstants.primaryColor),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppConstants.primaryColor,
      ),
    );
  }
  
  Widget _buildDangerZone() {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Account',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppConstants.errorColor,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.logout, color: AppConstants.errorColor),
            title: Text(
              'Logout',
              style: TextStyle(color: AppConstants.errorColor),
            ),
            subtitle: Text('Sign out of your account'),
            onTap: () {
              _showLogoutDialog();
            },
          ),
          ListTile(
            leading: Icon(Icons.delete_forever, color: AppConstants.errorColor),
            title: Text(
              'Delete Account',
              style: TextStyle(color: AppConstants.errorColor),
            ),
            subtitle: Text('Permanently delete your account'),
            onTap: () {
              _showDeleteAccountDialog();
            },
          ),
        ],
      ),
    );
  }
  
  void _showEditProfileDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Profile'),
        content: Text('Profile editing feature will be implemented in the next update.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
  
  void _showBlockedUsersDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Blocked Users'),
        content: Container(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('You haven\'t blocked anyone yet.'),
              SizedBox(height: 16),
              Text(
                'Blocked users cannot see your profile or send you messages.',
                style: TextStyle(color: AppConstants.textSecondaryColor),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
  
  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Help Center'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Frequently Asked Questions:'),
            SizedBox(height: 10),
            Text('• How do I start a voice call?'),
            Text('• How do I report inappropriate behavior?'),
            Text('• How do I change my preferences?'),
            Text('• How do I delete my account?'),
            SizedBox(height: 16),
            Text(
              'For more help, contact us at support@mhisa.com',
              style: TextStyle(color: AppConstants.primaryColor),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
  
  void _showFeedbackDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Send Feedback'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Tell us what you think...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Thank you for your feedback!'),
                  backgroundColor: AppConstants.primaryColor,
                ),
              );
            },
            child: Text('Send'),
          ),
        ],
      ),
    );
  }
  
  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: AppConstants.appName,
      applicationVersion: '1.0.0',
      applicationLegalese: '© 2024 BrainBox. All rights reserved.',
      children: [
        Text('\nMhisa is an innovative dating app focused on fostering genuine connections through real-time audio calls and text chats.'),
        SizedBox(height: 16),
        Text(
          AppConstants.tagline,
          style: TextStyle(
            fontStyle: FontStyle.italic,
            color: AppConstants.primaryColor,
          ),
        ),
      ],
    );
  }
  
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Logout'),
        content: Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => DashboardScreen()),
                (Route<dynamic> route) => false,
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Logged out successfully'),
                  backgroundColor: AppConstants.primaryColor,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.errorColor,
            ),
            child: Text('Logout'),
          ),
        ],
      ),
    );
  }
  
  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Account'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('This action cannot be undone. Deleting your account will:'),
            SizedBox(height: 10),
            Text('• Remove all your matches and chats'),
            Text('• Delete your profile permanently'),
            Text('• Cancel any active subscriptions'),
            SizedBox(height: 16),
            Text(
              'Are you sure you want to delete your account?',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Account deletion requested. You will receive a confirmation email.'),
                  backgroundColor: AppConstants.errorColor,
                  duration: Duration(seconds: 4),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.errorColor,
            ),
            child: Text('Delete Account'),
          ),
        ],
      ),
    );
  }
}