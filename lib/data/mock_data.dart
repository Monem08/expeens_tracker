import 'package:flutter/material.dart';

import '../models/bill.dart';
import '../models/category.dart';
import '../models/transaction.dart';

class MockData {
  const MockData._();

  static const double totalBalance = 12450.80;
  static const double monthlyProfitPct = 12.5;

  static const List<ExpenseCategory> homeCategories = [
    ExpenseCategory.food,
    ExpenseCategory.transport,
    ExpenseCategory.bills,
    ExpenseCategory.shopping,
  ];

  /// Weekly spending for the bar chart (Mon..Sun). Friday is the peak.
  static const List<double> weeklySpending = [
    42.0,
    68.0,
    55.0,
    96.0,
    148.0,
    61.0,
    34.0,
  ];

  static List<Transaction> get recentTransactions {
    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));
    return [
      Transaction(
        id: 't1',
        title: 'Apple Store',
        category: ExpenseCategory.shopping,
        amount: -99.00,
        date: today.copyWith(hour: 14, minute: 45),
        note: 'Today, 2:45 PM',
      ),
      Transaction(
        id: 't2',
        title: 'Salary Deposit',
        category: ExpenseCategory.income,
        amount: 4200.00,
        date: yesterday,
        note: 'Yesterday',
      ),
      Transaction(
        id: 't3',
        title: 'Chevron Gas',
        category: ExpenseCategory.transport,
        amount: -54.20,
        date: DateTime(2023, 11, 12),
        note: 'Nov 12, 2023',
      ),
    ];
  }

  static List<Transaction> get historyTransactions {
    final today = DateTime(2023, 10, 24);
    final yesterday = DateTime(2023, 10, 23);
    return [
      Transaction(
        id: 'h1',
        title: 'Apple Store',
        category: ExpenseCategory.electronics,
        amount: -1299.00,
        date: today.copyWith(hour: 14, minute: 34),
      ),
      Transaction(
        id: 'h2',
        title: 'Starbucks',
        category: ExpenseCategory.coffee,
        amount: -6.50,
        date: today.copyWith(hour: 8, minute: 15),
      ),
      Transaction(
        id: 'h3',
        title: 'Salary Deposit',
        category: ExpenseCategory.income,
        amount: 4500.00,
        date: yesterday.copyWith(hour: 9),
      ),
      Transaction(
        id: 'h4',
        title: 'Uber Ride',
        category: ExpenseCategory.transport,
        amount: -24.30,
        date: yesterday.copyWith(hour: 18, minute: 45),
      ),
    ];
  }

  // --- Bills ----------------------------------------------------------------

  static const double totalMonthlyBills = 2840.00;
  static const double paidThisMonth = 1846.00;
  static const double remainingThisMonth = 994.00;
  static const int autoPayCount = 6;

  static List<Bill> get upcomingBills {
    final today = DateTime(2023, 10, 24);
    return [
      Bill(
        id: 'b1',
        name: 'Electricity Bill',
        biller: 'City Grid Electric',
        amount: 142.50,
        dueDate: today.add(const Duration(days: 2)),
        status: BillStatus.priority,
        icon: Icons.bolt_outlined,
        accountLast4: '8842',
        autoPay: true,
        billingPeriodStart: DateTime(2023, 9, 20),
        billingPeriodEnd: DateTime(2023, 10, 20),
        paymentHistory: [
          BillPayment(
            amount: 138.20,
            date: DateTime(2023, 9, 26, 10, 42),
            succeeded: true,
          ),
          BillPayment(
            amount: 145.10,
            date: DateTime(2023, 8, 26, 9, 15),
            succeeded: true,
          ),
        ],
      ),
      Bill(
        id: 'b2',
        name: 'Internet & TV',
        biller: 'SkyFiber',
        amount: 89.00,
        dueDate: today,
        status: BillStatus.upcoming,
        icon: Icons.wifi,
      ),
      Bill(
        id: 'b3',
        name: 'Monthly Rent',
        biller: 'Palmwood Apartments',
        amount: 1200.00,
        dueDate: today.add(const Duration(days: 4)),
        status: BillStatus.scheduled,
        icon: Icons.apartment_outlined,
      ),
      Bill(
        id: 'b4',
        name: 'Car Insurance',
        biller: 'SafeDrive Co.',
        amount: 215.00,
        dueDate: today.subtract(const Duration(days: 3)),
        status: BillStatus.overdue,
        icon: Icons.shield_outlined,
      ),
    ];
  }
}
