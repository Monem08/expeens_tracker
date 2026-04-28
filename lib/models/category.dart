import 'package:flutter/material.dart';

enum ExpenseCategory {
  food(label: 'Food', icon: Icons.restaurant),
  transport(label: 'Transport', icon: Icons.directions_car_filled),
  shopping(label: 'Shopping', icon: Icons.shopping_bag_outlined),
  bills(label: 'Bills', icon: Icons.receipt_long_outlined),
  fun(label: 'Fun', icon: Icons.theater_comedy_outlined),
  travel(label: 'Travel', icon: Icons.flight_takeoff),
  electronics(label: 'Electronics', icon: Icons.devices_other_outlined),
  coffee(label: 'Food & Drink', icon: Icons.local_cafe_outlined),
  income(label: 'Income', icon: Icons.savings_outlined);

  const ExpenseCategory({required this.label, required this.icon});

  final String label;
  final IconData icon;
}
