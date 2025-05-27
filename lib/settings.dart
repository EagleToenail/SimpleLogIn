import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Business Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: ListView(
        children: [
          _buildSettingTile(
            icon: Icons.business,
            title: 'Business Name',
            subtitle: 'Alertline Security',
            trailingText: 'EDIT',
            onTap: () {
              // Navigate to edit business name page
            },
          ),
          _buildSettingTile(
            icon: Icons.groups,
            title: 'Number of Staff',
            subtitle: '5',
            trailingText: 'EDIT',
            onTap: () {
              // Navigate to edit staff count
            },
          ),
          _buildSettingTile(
            icon: Icons.attach_money,
            title: 'Current Plan',
            subtitle:
                'You are currently on the plan:\nPro Trial\n12 days remaining',
            trailingText: 'SUBSCRIBE',
            onTap: () {
              // Navigate to subscription page
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required String trailingText,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, size: 32, color: Colors.black87),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle),
      trailing: TextButton(
        onPressed: onTap,
        child: Text(
          trailingText,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple,
          ),
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      dense: false,
    );
  }
}
