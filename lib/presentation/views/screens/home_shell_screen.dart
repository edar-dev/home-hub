import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../layout/breakpoints.dart';
import '../../viewmodels/home_shell_tab_controller.dart';
import 'analytics/analytics_dashboard_screen.dart';
import 'location_list_screen.dart';
import 'more_tools_screen.dart';
import 'product_list_screen.dart';

/// Shell principale: IA semplificata con 4 destinazioni primarie.
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
                          icon: Icon(Icons.insights_outlined),
                          selectedIcon: Icon(Icons.insights),
                          label: Text('Analytics'),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.tune_outlined),
                          selectedIcon: Icon(Icons.tune),
                          label: Text('Utilita'),
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
              bottomNavigationBar: SafeArea(
                top: false,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                  child: NavigationBar(
                    selectedIndex: tab.index,
                    onDestinationSelected: tab.setIndex,
                    labelBehavior:
                        NavigationDestinationLabelBehavior.alwaysShow,
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
                    icon: Icon(Icons.insights_outlined),
                    selectedIcon: Icon(Icons.insights),
                    label: 'Analytics',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.tune_outlined),
                    selectedIcon: Icon(Icons.tune),
                    label: 'Utilita',
                  ),
                ],
                  ),
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
  AnalyticsDashboardScreen(),
  MoreToolsScreen(),
];
