import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../viewmodels/notification_settings_view_model.dart';

class NotificationSettingsScreen extends StatelessWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationSettingsViewModel>(
      builder: (context, vm, _) {
        if (vm.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return Scaffold(
          appBar: AppBar(
            title: const Text('Notifiche'),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (kIsWeb)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    'Le notifiche di sistema non sono disponibili sul Web; '
                    'usa l’app su Android o iOS.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ),
              SwitchListTile(
                title: const Text('Notifiche attive'),
                subtitle: const Text(
                  'Disattiva per non ricevere promemoria sul dispositivo.',
                ),
                value: vm.settings.enabled,
                onChanged: kIsWeb ? null : vm.setEnabled,
              ),
              SwitchListTile(
                title: const Text('Promemoria giorno prima della scadenza'),
                subtitle: const Text('Alle 9:00 del giorno precedente.'),
                value: vm.settings.remindDayBefore,
                onChanged:
                    kIsWeb || !vm.settings.enabled ? null : vm.setRemindDayBefore,
              ),
              SwitchListTile(
                title: const Text('Riepilogo giornaliero'),
                subtitle: const Text('Alle 8:00, con conteggi sintetici.'),
                value: vm.settings.dailyDigest,
                onChanged:
                    kIsWeb || !vm.settings.enabled ? null : vm.setDailyDigest,
              ),
              SwitchListTile(
                title: const Text('Includi prodotti in esaurimento nel riepilogo'),
                value: vm.settings.includeLowStockInDigest,
                onChanged: kIsWeb ||
                        !vm.settings.enabled ||
                        !vm.settings.dailyDigest
                    ? null
                    : vm.setIncludeLowStock,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: kIsWeb || vm.isSaving ? null : () => _save(context, vm),
                child: vm.isSaving
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Salva e applica'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _save(
    BuildContext context,
    NotificationSettingsViewModel vm,
  ) async {
    final err = await vm.save();
    if (!context.mounted) return;
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impostazioni salvate.')),
      );
    }
  }
}
