// File: lib/screens/wallet/payment_methods/widgets/payment_provider_icon.dart
// MetaZone Wallet — Payment Provider Icon (Neon Clean UI)

import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

class PaymentProviderIcon extends StatelessWidget {
  final String type;

  const PaymentProviderIcon({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;

    switch (type.toLowerCase()) {
      case "visa":
        icon = Icons.credit_card_rounded;
        color = Colors.blueAccent;
        break;

      case "mastercard":
        icon = Icons.credit_card_rounded;
        color = Colors.deepOrangeAccent;
        break;

      case "paypal":
        icon = Icons.account_balance_wallet_rounded;
        color = Colors.lightBlueAccent;
        break;

      case "apple pay":
        icon = Icons.phone_iphone_rounded;
        color = Colors.white;
        break;

      case "google pay":
        icon = Icons.android_rounded;
        color = Colors.greenAccent;
        break;

      case "meta credits":
        icon = Icons.token_rounded;
        color = AppColors.primary;
        break;

      default:
        icon = Icons.payment_rounded;
        color = Colors.white70;
    }

    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        color: AppColors.card.withOpacity(.2),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border.withOpacity(.4)),
      ),
      child: Center(
        child: Icon(icon, size: 28, color: color),
      ),
    );
  }
}
