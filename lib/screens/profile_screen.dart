import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authStoreProvider);
    final theme = ref.watch(themeStoreProvider);
    final user = auth.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: user == null
          ? const Center(child: Text('Not signed in'))
          : ListView(
              padding: const EdgeInsets.all(24),
              children: [
                const CircleAvatar(
                  radius: 40,
                  child: Icon(Icons.person, size: 40),
                ),
                const SizedBox(height: 16),
                Text(
                  user.displayName,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 24),
                ListTile(
                  leading: const Icon(Icons.badge_outlined),
                  title: const Text('User name'),
                  subtitle: Text(user.userName),
                ),
                ListTile(
                  leading: const Icon(Icons.fingerprint),
                  title: const Text('User id'),
                  subtitle: Text(user.id),
                ),
                const SizedBox(height: 16),
                Text(
                  'Appearance',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                SegmentedButton<ThemeMode>(
                  segments: const [
                    ButtonSegment(
                      value: ThemeMode.system,
                      label: Text('System'),
                      icon: Icon(Icons.brightness_auto_outlined),
                    ),
                    ButtonSegment(
                      value: ThemeMode.light,
                      label: Text('Light'),
                      icon: Icon(Icons.light_mode_outlined),
                    ),
                    ButtonSegment(
                      value: ThemeMode.dark,
                      label: Text('Dark'),
                      icon: Icon(Icons.dark_mode_outlined),
                    ),
                  ],
                  selected: {theme.mode},
                  onSelectionChanged: (selected) {
                    theme.setMode(selected.first);
                  },
                ),
                const SizedBox(height: 24),
                FilledButton.tonal(
                  onPressed: auth.logout,
                  child: const Text('Logout'),
                ),
              ],
            ),
    );
  }
}
