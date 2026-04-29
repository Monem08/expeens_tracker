import 'package:flutter/material.dart';

enum BillStatus { upcoming, paid, overdue, scheduled, priority }

/// Serializable subset of icons usable for bills. Storing the enum name
/// keeps us safe from Flutter's icon tree-shaking (which rejects dynamic
/// `IconData` constants at runtime).
enum BillIconKind {
  bolt(Icons.bolt_outlined),
  wifi(Icons.wifi),
  apartment(Icons.apartment_outlined),
  shield(Icons.shield_outlined),
  water(Icons.water_drop_outlined),
  phone(Icons.phone_android_outlined),
  creditCard(Icons.credit_card_outlined),
  generic(Icons.receipt_long_outlined);

  const BillIconKind(this.icon);
  final IconData icon;
}

class Bill {
  const Bill({
    required this.id,
    required this.name,
    required this.biller,
    required this.amount,
    required this.dueDate,
    required this.status,
    required this.iconKind,
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
  final BillIconKind iconKind;
  final String? accountLast4;
  final bool autoPay;
  final DateTime? billingPeriodStart;
  final DateTime? billingPeriodEnd;
  final List<BillPayment> paymentHistory;

  IconData get icon => iconKind.icon;

  /// Returns a copy marked as paid with a successful [BillPayment] for the
  /// full bill amount appended to [paymentHistory].
  Bill markedPaid({DateTime? when}) {
    final ts = when ?? DateTime.now();
    return copyWith(
      status: BillStatus.paid,
      paymentHistory: [
        BillPayment(amount: amount, date: ts, succeeded: true),
        ...paymentHistory,
      ],
    );
  }

  Bill copyWith({
    String? id,
    String? name,
    String? biller,
    double? amount,
    DateTime? dueDate,
    BillStatus? status,
    BillIconKind? iconKind,
    String? accountLast4,
    bool? autoPay,
    DateTime? billingPeriodStart,
    DateTime? billingPeriodEnd,
    List<BillPayment>? paymentHistory,
  }) {
    return Bill(
      id: id ?? this.id,
      name: name ?? this.name,
      biller: biller ?? this.biller,
      amount: amount ?? this.amount,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      iconKind: iconKind ?? this.iconKind,
      accountLast4: accountLast4 ?? this.accountLast4,
      autoPay: autoPay ?? this.autoPay,
      billingPeriodStart: billingPeriodStart ?? this.billingPeriodStart,
      billingPeriodEnd: billingPeriodEnd ?? this.billingPeriodEnd,
      paymentHistory: paymentHistory ?? this.paymentHistory,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'name': name,
      'biller': biller,
      'amount': amount,
      'due_date': dueDate.millisecondsSinceEpoch,
      'status': status.name,
      'icon_kind': iconKind.name,
      'account_last4': accountLast4,
      'auto_pay': autoPay ? 1 : 0,
      'billing_period_start': billingPeriodStart?.millisecondsSinceEpoch,
      'billing_period_end': billingPeriodEnd?.millisecondsSinceEpoch,
    };
  }

  static Bill fromMap(
    Map<String, Object?> map, {
    List<BillPayment> payments = const [],
  }) {
    return Bill(
      id: map['id']! as String,
      name: map['name']! as String,
      biller: map['biller']! as String,
      amount: (map['amount']! as num).toDouble(),
      dueDate: DateTime.fromMillisecondsSinceEpoch(map['due_date']! as int),
      status: BillStatus.values.byName(map['status']! as String),
      iconKind: BillIconKind.values.byName(map['icon_kind']! as String),
      accountLast4: map['account_last4'] as String?,
      autoPay: (map['auto_pay']! as int) == 1,
      billingPeriodStart: map['billing_period_start'] == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(
              map['billing_period_start']! as int,
            ),
      billingPeriodEnd: map['billing_period_end'] == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(
              map['billing_period_end']! as int,
            ),
      paymentHistory: payments,
    );
  }
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

  Map<String, Object?> toMap(String billId) {
    return {
      'bill_id': billId,
      'amount': amount,
      'date': date.millisecondsSinceEpoch,
      'succeeded': succeeded ? 1 : 0,
    };
  }

  static BillPayment fromMap(Map<String, Object?> map) {
    return BillPayment(
      amount: (map['amount']! as num).toDouble(),
      date: DateTime.fromMillisecondsSinceEpoch(map['date']! as int),
      succeeded: (map['succeeded']! as int) == 1,
    );
  }
}
