import 'package:flutter/material.dart';

import '../../layout/breakpoints.dart';
import 'location_inventory_screen.dart';
import 'location_list_screen.dart';
import 'product_list_screen.dart';

/// Shell principale: Inventario e Luoghi con [NavigationBar] o [NavigationRail].
class HomeShellScreen extends StatefulWidget {
  const HomeShellScreen({super.key});

  @override
  State<HomeShellScreen> createState() => _HomeShellScreenState();
}

class _HomeShellScreenState extends State<HomeShellScreen> {
  int _index = 0;

  late final List<Widget> _pages = [
    const ProductListScreen(),
    const LocationListScreen(),
    const LocationInventoryScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = isWideWidth(constraints.maxWidth);
        if (wide) {
          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: _index,
                  onDestinationSelected: (i) => setState(() => _index = i),
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
                  ],
                ),
                const VerticalDivider(width: 1, thickness: 1),
                Expanded(
                  child: IndexedStack(
                    index: _index,
                    children: _pages,
                  ),
                ),
              ],
            ),
          );
        }
        return Scaffold(
          body: IndexedStack(
            index: _index,
            children: _pages,
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: (i) => setState(() => _index = i),
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
            ],
          ),
        );
      },
    );
  }
}
