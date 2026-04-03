import 'package:flutter/material.dart';

import '../widgets/stitch_top_app_bar.dart';
import 'location_list_screen.dart';
import 'settings/notification_settings_screen.dart';
import 'shopping/shopping_list_screen.dart';

/// Schermata secondaria per azioni non primarie della bottom navigation.
class MoreToolsScreen extends StatelessWidget {
  const MoreToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          children: [
            const StitchTopAppBar(title: 'Utilita'),
            _UtilityTile(
              icon: Icons.place_outlined,
              title: 'Gestione luoghi',
              subtitle: 'Crea, modifica ed elimina i luoghi di casa.',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const LocationListScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            _UtilityTile(
              icon: Icons.shopping_cart_outlined,
              title: 'Lista spesa',
              subtitle: 'Prodotti da acquistare e promemoria.',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const ShoppingListScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            _UtilityTile(
              icon: Icons.notifications_outlined,
              title: 'Notifiche',
              subtitle: 'Gestisci digest, scadenze e avvisi intelligenti.',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const NotificationSettingsScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _UtilityTile extends StatelessWidget {
  const _UtilityTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: scheme.onPrimaryContainer),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}
