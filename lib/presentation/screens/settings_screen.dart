// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../data/services/security_service.dart';

import '../components/settings/general_settings_group.dart';
import '../components/settings/appearance_settings_group.dart';
import '../components/settings/notification_settings_group.dart';
import '../components/settings/security_settings_group.dart';
import '../components/settings/sync_settings_group.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _biometricsAvailable = false;

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
  }

  Future<void> _checkBiometrics() async {
    final available = await SecurityService.isBiometricAvailable();
    setState(() {
      _biometricsAvailable = available;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.w700)),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 24),
        children: [
          const GeneralSettingsGroup(),
          const Gap(24),
          const AppearanceSettingsGroup(),
          const Gap(24),
          const NotificationSettingsGroup(),
          const Gap(24),
          SecuritySettingsGroup(biometricsAvailable: _biometricsAvailable),
          const Gap(24),
          const SyncSettingsGroup(),
          const Gap(40),
          Center(
            child: Text(
              'Version 2.0.0',
              style: TextStyle(color: Colors.grey[400], fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
