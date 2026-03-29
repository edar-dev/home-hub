import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../layout/breakpoints.dart';
import '../../viewmodels/home_shell_tab_controller.dart';
import 'analytics/analytics_dashboard_screen.dart';
import 'location_inventory_screen.dart';
import 'location_list_screen.dart';
import 'product_list_screen.dart';
import 'settings/notification_settings_screen.dart';
import 'shopping/shopping_list_screen.dart';

/// Shell principale: Inventario, Luoghi, Riepilogo, Analytics, Lista spesa, Notifiche.
class HomeShellScreen extends StatelessWidget {
  const HomeShellScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeShellTabController>(
      builder: (context, tab, _) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final wide = isWideWidth(constraints.maxWidth);
            if (wide) {
              return Scaffold(
                body: Row(
                  children: [
                    NavigationRail(
                      selectedIndex: tab.index,
                      onDestinationSelected: tab.setIndex,
                      labelType: NavigationRailLabelType.all,
                      destinations: const [
                        NavigationRailDestination(
                          icon: Icon(Icons.inventory_2_outlined),
                          selectedIcon: Icon(Icons.inventory_2),
                          label: Text('Inventario'),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.place_outlined),
                          selectedIcon: Icon(Icons.place),
                          label: Text('Luoghi'),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.home_work_outlined),
                          selectedIcon: Icon(Icons.home_work),
                          label: Text('Riepilogo'),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.insights_outlined),
                          selectedIcon: Icon(Icons.insights),
                          label: Text('Analytics'),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.shopping_cart_outlined),
                          selectedIcon: Icon(Icons.shopping_cart),
                          label: Text('Lista spesa'),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.notifications_outlined),
                          selectedIcon: Icon(Icons.notifications),
                          label: Text('Notifiche'),
                        ),
                      ],
                    ),
                    const VerticalDivider(width: 1, thickness: 1),
                    Expanded(
                      child: IndexedStack(
                        index: tab.index,
                        children: _pages,
                      ),
                    ),
                  ],
                ),
              );
            }
            return Scaffold(
              body: IndexedStack(
                index: tab.index,
                children: _pages,
              ),
              bottomNavigationBar: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(32),
                ),
                child: NavigationBar(
                  selectedIndex: tab.index,
                  onDestinationSelected: tab.setIndex,
                  destinations: const [
                  NavigationDestination(
                    icon: Icon(Icons.inventory_2_outlined),
                    selectedIcon: Icon(Icons.inventory_2),
                    label: 'Inventario',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.place_outlined),
                    selectedIcon: Icon(Icons.place),
                    label: 'Luoghi',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.home_work_outlined),
                    selectedIcon: Icon(Icons.home_work),
                    label: 'Riepilogo',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.insights_outlined),
                    selectedIcon: Icon(Icons.insights),
                    label: 'Analytics',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.shopping_cart_outlined),
                    selectedIcon: Icon(Icons.shopping_cart),
                    label: 'Lista spesa',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.notifications_outlined),
                    selectedIcon: Icon(Icons.notifications),
                    label: 'Notifiche',
                  ),
                ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

const List<Widget> _pages = [
  ProductListScreen(),
  LocationListScreen(),
  LocationInventoryScreen(),
  AnalyticsDashboardScreen(),
  ShoppingListScreen(),
  NotificationSettingsScreen(),
];
