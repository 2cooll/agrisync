import 'dart:async';
import 'dart:math';
import '../config/env_config.dart';

enum PaymentMethodType {
  qris,
  bcaVa,
  mandiriVa,
  bniVa,
  briVa,
  gopay,
  ovo,
  shopeepay,
}

enum PaymentStatus {
  pending,
  settlement,
  expired,
  failed,
}

class PaymentTransaction {
  final String transactionId;
  final String orderId;
  final double grossAmount;
  final double platformFee;
  final double netAmount;
  final PaymentMethodType method;
  final PaymentStatus status;
  final String? vaNumber;
  final String? qrString;
  final DateTime createdAt;
  final DateTime? settledAt;

  const PaymentTransaction({
    required this.transactionId,
    required this.orderId,
    required this.grossAmount,
    required this.platformFee,
    required this.netAmount,
    required this.method,
    required this.status,
    this.vaNumber,
    this.qrString,
    required this.createdAt,
    this.settledAt,
  });

  Map<String, dynamic> toJson() => {
        'transactionId': transactionId,
        'orderId': orderId,
        'grossAmount': grossAmount,
        'platformFee': platformFee,
        'netAmount': netAmount,
        'method': method.name,
        'status': status.name,
        'vaNumber': vaNumber,
        'qrString': qrString,
        'createdAt': createdAt.toIso8601String(),
        'settledAt': settledAt?.toIso8601String(),
      };
}

class PaymentGatewayService {
  static double get standardCommissionRate => EnvConfig.paymentCommissionPercent / 100;
  static const double proCommissionRate = 0.010; // 1.0%

  /// Menghitung rincian pembayaran (Subtotal, Biaya Pengiriman, Komisi Platform, Total)
  static Map<String, double> calculateBreakdown({
    required double itemSubtotal,
    required double shippingFee,
    required bool isProUser,
  }) {
    final rate = isProUser ? proCommissionRate : standardCommissionRate;
    final platformFee = (itemSubtotal * rate).roundToDouble();
    final grossTotal = itemSubtotal + shippingFee + platformFee;

    return {
      'subtotal': itemSubtotal,
      'shippingFee': shippingFee,
      'platformFee': platformFee,
      'commissionRate': rate,
      'total': grossTotal,
    };
  }

  /// Membuat transaksi pembayaran secara instan (Synchronous)
  static PaymentTransaction createTransactionSync({
    required String orderId,
    required double amount,
    required bool isProUser,
    required PaymentMethodType method,
  }) {
    final rate = isProUser ? proCommissionRate : standardCommissionRate;
    final platformFee = (amount * rate).roundToDouble();
    final random = Random();
    final txId = 'TRX-${DateTime.now().millisecondsSinceEpoch}-${random.nextInt(9999)}';

    String? vaNum;
    String? qr;

    switch (method) {
      case PaymentMethodType.qris:
        qr = '00020101021226580016ID.CO.AGRISYNC.WWW01189360091100223344550215$txId';
        break;
      case PaymentMethodType.bcaVa:
        vaNum = '88012${1000000000 + random.nextInt(900000000)}';
        break;
      case PaymentMethodType.mandiriVa:
        vaNum = '89022${1000000000 + random.nextInt(900000000)}';
        break;
      case PaymentMethodType.bniVa:
        vaNum = '88088${1000000000 + random.nextInt(900000000)}';
        break;
      case PaymentMethodType.briVa:
        vaNum = '12345${1000000000 + random.nextInt(900000000)}';
        break;
      default:
        vaNum = '88012${1000000000 + random.nextInt(900000000)}';
        break;
    }

    return PaymentTransaction(
      transactionId: txId,
      orderId: orderId,
      grossAmount: amount + platformFee,
      platformFee: platformFee,
      netAmount: amount,
      method: method,
      status: PaymentStatus.pending,
      vaNumber: vaNum,
      qrString: qr,
      createdAt: DateTime.now(),
    );
  }

  /// Membuat transaksi pembayaran baru via Sandbox Engine (Async dengan simulasi latency)
  static Future<PaymentTransaction> createTransaction({
    required String orderId,
    required double amount,
    required bool isProUser,
    required PaymentMethodType method,
  }) async {
    // Simulasi Network Latency API Gateway
    await Future.delayed(const Duration(milliseconds: 300));
    return createTransactionSync(
      orderId: orderId,
      amount: amount,
      isProUser: isProUser,
      method: method,
    );
  }

  /// Simulasi verifikasi pelunasan pembayaran instan sandbox
  static Future<PaymentTransaction> simulateSettlement(PaymentTransaction tx) async {
    await Future.delayed(const Duration(milliseconds: 1200));
    return PaymentTransaction(
      transactionId: tx.transactionId,
      orderId: tx.orderId,
      grossAmount: tx.grossAmount,
      platformFee: tx.platformFee,
      netAmount: tx.netAmount,
      method: tx.method,
      status: PaymentStatus.settlement,
      vaNumber: tx.vaNumber,
      qrString: tx.qrString,
      createdAt: tx.createdAt,
      settledAt: DateTime.now(),
    );
  }
}
