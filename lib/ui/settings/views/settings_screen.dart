import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Dark Mode'),
            value: false, // TODO: connect to provider
            onChanged: (val) {},
          ),
          SwitchListTile(
            title: const Text('Enable Reminders'),
            value: true, // TODO: connect to provider
            onChanged: (val) {},
          ),
        ],
      ),
    );
  }
}
