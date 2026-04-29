import 'package:flutter/material.dart';

import 'screens/add_expense_screen.dart';
import 'screens/bills_screen.dart';
import 'screens/history_screen.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';
import 'theme/app_theme.dart';

/// Exposes `AppShell.of(context).switchTo(int)` to any descendant so cross-tab
/// navigation (e.g. Home → History "See All") works without a global state
/// container.
class AppShellController extends InheritedWidget {
  const AppShellController({
    super.key,
    required this.switchTo,
    required super.child,
  });

  final ValueChanged<int> switchTo;

  static AppShellController? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppShellController>();

  @override
  bool updateShouldNotify(AppShellController oldWidget) => false;
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  static const _pages = <Widget>[
    HomeScreen(),
    BillsScreen(),
    SizedBox(),
    HistoryScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return AppShellController(
      switchTo: (i) => setState(() => _index = i),
      child: Scaffold(
        extendBody: true,
        body: IndexedStack(index: _index, children: _pages),
        floatingActionButton: FloatingActionButton(
          shape: const CircleBorder(),
          onPressed: _openAddExpense,
          child: const Icon(Icons.add, size: 28),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: _BottomBar(
          index: _index,
          onChanged: (i) => setState(() => _index = i),
        ),
      ),
    );
  }

  Future<void> _openAddExpense() async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const AddExpenseScreen()));
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.index, required this.onChanged});

  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: AppColors.surface,
      height: 76,
      padding: EdgeInsets.zero,
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavItem(
            icon: Icons.grid_view,
            label: 'HOME',
            selected: index == 0,
            onTap: () => onChanged(0),
          ),
          _NavItem(
            icon: Icons.receipt_long_outlined,
            label: 'BILLS',
            selected: index == 1,
            onTap: () => onChanged(1),
          ),
          const SizedBox(width: 56), // gap for FAB
          _NavItem(
            icon: Icons.history,
            label: 'HISTORY',
            selected: index == 3,
            onTap: () => onChanged(3),
          ),
          _NavItem(
            icon: Icons.person_outline,
            label: 'PROFILE',
            selected: index == 4,
            onTap: () => onChanged(4),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? AppColors.mint
        : Theme.of(context).colorScheme.onSurfaceVariant;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
