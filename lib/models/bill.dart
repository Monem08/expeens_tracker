import 'package:flutter/material.dart';

enum BillStatus { upcoming, paid, overdue, scheduled, priority }

class Bill {
  const Bill({
    required this.id,
    required this.name,
    required this.biller,
    required this.amount,
    required this.dueDate,
    required this.status,
    required this.icon,
    this.accountLast4,
    this.autoPay = false,
    this.billingPeriodStart,
    this.billingPeriodEnd,
    this.paymentHistory = const [],
  });

  final String id;
  final String name;
  final String biller;
  final double amount;
  final DateTime dueDate;
  final BillStatus status;
  final IconData icon;
  final String? accountLast4;
  final bool autoPay;
  final DateTime? billingPeriodStart;
  final DateTime? billingPeriodEnd;
  final List<BillPayment> paymentHistory;
}

class BillPayment {
  const BillPayment({
    required this.amount,
    required this.date,
    required this.succeeded,
  });

  final double amount;
  final DateTime date;
  final bool succeeded;
}
