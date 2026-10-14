import 'dart:async';

import 'package:in_app_purchase/in_app_purchase.dart';

import '../app_state.dart';

/// One-time "Lifetime Premium" purchase.
/// Create a managed product (one-time / in-app product) with this id in
/// Google Play Console -> Monetize -> Products -> In-app products.
class Purchases {
  static const lifetimeId = 'premium_lifetime';

  static final _iap = InAppPurchase.instance;
  static StreamSubscription<List<PurchaseDetails>>? _sub;
  static ProductDetails? product;
  static bool available = false;

  static Future<void> init() async {
    try {
      available = await _iap.isAvailable();
      _sub ??= _iap.purchaseStream.listen(_onPurchases, onError: (_) {});
      if (!available) return;
      final res = await _iap.queryProductDetails({lifetimeId});
      if (res.productDetails.isNotEmpty) product = res.productDetails.first;
    } catch (_) {
      available = false;
    }
  }

  static Future<void> _onPurchases(List<PurchaseDetails> list) async {
    for (final p in list) {
      if (p.productID == lifetimeId &&
          (p.status == PurchaseStatus.purchased || p.status == PurchaseStatus.restored)) {
        AppState.instance.update((s) => s.premium = true);
      }
      if (p.pendingCompletePurchase) {
        await _iap.completePurchase(p);
      }
    }
  }

  static Future<bool> buy() async {
    if (product == null) await init();
    final p = product;
    if (!available || p == null) return false;
    return _iap.buyNonConsumable(purchaseParam: PurchaseParam(productDetails: p));
  }

  static Future<void> restore() async {
    if (!available) await init();
    if (available) await _iap.restorePurchases();
  }
}
