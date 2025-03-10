import 'package:carousel/core/services/platform_service.dart';
import 'package:carousel/snackbar_service/snack_bar_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../theme/theme_manager.dart';
import '../state/settings_provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late SettingsProvider _settingsProvider;

  @override
  void didChangeDependencies() {
    _settingsProvider = Provider.of<SettingsProvider>(context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () async =>
                await PlatformService.requestBatteryOptimizationExemption().then((value) {
              SnackBarService.showBounce(
                  context, 'Battery Optimization Exemption Granted');
            }),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            SwitchListTile(
              value: _settingsProvider.isCarouselEnabled,
              onChanged: _settingsProvider.setCarouselEnabled,
              title: const Text("Lock Screen Carousel"),
            ),
            SwitchListTile(
              value: _settingsProvider.isRandom,
              onChanged: _settingsProvider.isCarouselEnabled
                  ? _settingsProvider.setIsRandom
                  : null,
              title: const Text("Change Random"),
            ),
            Consumer<ThemeManager>(builder: (context, themeProvider, child) {
              return SwitchListTile(
                value: themeProvider.isDarkMode,
                onChanged: (value) => themeProvider.toggleTheme(),
                title: const Text("Dark Theme"),
              );
            }),
          ],
        ),
      ),
    );
  }
}
