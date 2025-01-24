import 'package:carousel/features/carousel/presentation/state/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
            )
          ],
        ),
      ),
    );
  }
}
