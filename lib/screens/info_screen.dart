import 'dart:io';

import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// ymchat_flutter doesn't expose its version at runtime. Keep in sync with
/// pubspec.lock.
const ymchatFlutterVersion = '3.5.4';

class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Info')),
      body: FutureBuilder<PackageInfo>(
        future: PackageInfo.fromPlatform(),
        builder: (context, snapshot) {
          final info = snapshot.data;
          final rows = [
            (
              'App Version',
              info == null ? '-' : '${info.version} (${info.buildNumber})',
            ),
            ('ymchat_flutter', ymchatFlutterVersion),
            ('Platform', '${Platform.operatingSystem} '
                '${Platform.operatingSystemVersion.split(' ').first}'),
          ];
          return ListView(
            children: [
              for (final (label, value) in rows)
                ListTile(
                  title: Text(label),
                  trailing: Text(value,
                      style: Theme.of(context).textTheme.bodyLarge),
                ),
            ],
          );
        },
      ),
    );
  }
}
