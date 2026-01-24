import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:lingolearn/utilities/dio/api_request.dart';
import 'package:lingolearn/utilities/dio/api_end_points.dart';
import 'package:lingolearn/home_module/models/shop/shop_model.dart';

class IAPService extends GetxService {
  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _sub;

  final RxBool isAvailable = false.obs;
  final RxSet<String> inFlight = <String>{}.obs; // sku currently purchasing

  bool _initialized = false;

  final Map<String, int> _pendingOrderIdBySku = {};
  final Map<String, String> _pendingTypeBySku = {};

  @override
  void onInit() {
    super.onInit();
    _ensureReady();
  }

  Future<void> _ensureReady() async {
    if (_initialized) return;
    final available = await _iap.isAvailable();
    isAvailable.value = available;

    _sub ??= _iap.purchaseStream.listen(
      _onPurchaseUpdated,
      onDone: () => _sub?.cancel(),
      onError: (e) => debugPrint('purchaseStream error: $e'),
    );

    _initialized = true;
    debugPrint('[IAP] ready: $available');
  }

  Future<void> purchase(Datas item) async {
    try {
      await _ensureReady(); // <- wait for readiness

      final sku = (item.sku ?? '').toString();
      if (sku.isEmpty) {
        _toast('Error', 'Invalid product');
        return;
      }

      if (!isAvailable.value) {
        // Try one more time (some devices report late)
        final again = await _iap.isAvailable();
        isAvailable.value = again;
        if (!again) {
          _toast('Store unavailable',
              'Google Play not available on this device/build.');
          return;
        }
      }

      inFlight.add(sku);

      // 1) Query product
      final resp = await _iap.queryProductDetails({sku});
      if (resp.notFoundIDs.contains(sku) || resp.productDetails.isEmpty) {
        _toast('Not found',
            'Product $sku not found. Check Play Console & package name.');
        inFlight.remove(sku);
        return;
      }
      final prod = resp.productDetails.first;

      // 2) Create order on server
      final orderId = await _createOrder(itemId: (item.id ?? 0).toInt());

      // 3) Start purchase
      final purchaseParam = PurchaseParam(productDetails: prod);

      // Assume gems/hearts/booster are consumables
      final type = (item.type ?? '').toString();
      _pendingOrderIdBySku[sku] = orderId;
      _pendingTypeBySku[sku] = type;

      if (type == 'gems' || type == 'hearts' || type == 'booster') {
        await _iap.buyConsumable(
            purchaseParam: purchaseParam, autoConsume: false);
      } else {
        await _iap.buyNonConsumable(purchaseParam: purchaseParam);
      }
    } catch (e) {
      debugPrint('purchase() error: $e');
      _toast('Error', e.toString());
    }
  }

  Future<void> _onPurchaseUpdated(List<PurchaseDetails> purchases) async {
    for (final p in purchases) {
      final sku = p.productID;
      try {
        debugPrint('[IAP] update: $sku -> ${p.status}');
        if (p.status == PurchaseStatus.pending) continue;

        if (p.status == PurchaseStatus.error) {
          _toast('Purchase failed', p.error?.message ?? 'Unknown error');
          await _complete(p);
          inFlight.remove(sku);
          continue;
        }

        if (p.status == PurchaseStatus.canceled) {
          _toast('Canceled', 'Purchase canceled');
          await _complete(p);
          inFlight.remove(sku);
          continue;
        }

        if (p.status == PurchaseStatus.purchased ||
            p.status == PurchaseStatus.restored) {
          await _handlePurchased(p);
          inFlight.remove(sku);
        }
      } catch (e) {
        debugPrint('_onPurchaseUpdated error: $e');
        inFlight.remove(sku);
      }
    }
  }

  Future<void> _handlePurchased(PurchaseDetails p) async {
    final sku = p.productID;
    final orderId = _pendingOrderIdBySku[sku];
    final type = _pendingTypeBySku[sku];

    if (orderId == null) {
      // restore or missing local context
      await _complete(p);
      return;
    }

    final purchaseToken = p.verificationData.serverVerificationData;

    await _verifyWithServer(
      orderId: orderId,
      productId: sku,
      purchaseToken: purchaseToken,
    );

    if (p.pendingCompletePurchase) {
      await _complete(p);
    }

    if ((type == 'gems' || type == 'hearts' || type == 'booster') &&
        p is GooglePlayPurchaseDetails) {
      final androidAddition =
          _iap.getPlatformAddition<InAppPurchaseAndroidPlatformAddition>();
      await androidAddition.consumePurchase(p);
    }

    _pendingOrderIdBySku.remove(sku);
    _pendingTypeBySku.remove(sku);

    _toast('Success', 'Purchase verified and credited');
    // TODO: optionally refresh wallet/stats here
  }

  Future<void> _complete(PurchaseDetails p) async {
    try {
      await _iap.completePurchase(p);
    } catch (e) {
      debugPrint('completePurchase error: $e');
    }
  }

  // ---- server calls ----
  Future<int> _createOrder({required int itemId}) async {
    final res = await postRequest(
      apiEndPoint: APIEndPoints.createShopOrder, // e.g. '/api/shop/orders'
      postData: {'shop_item_id': itemId},
    );
    final body = res.data is String ? jsonDecode(res.data) : res.data;
    if (body['status'] == true && body['data']?['id'] != null) {
      return (body['data']['id'] as num).toInt();
    }
    throw Exception(body['message'] ?? 'Failed to create order');
  }

  Future<void> _verifyWithServer({
    required int orderId,
    required String productId,
    required String purchaseToken,
  }) async {
    final res = await postRequest(
      apiEndPoint: APIEndPoints.verifyShopPurchase, // e.g. '/api/shop/verify'
      postData: {
        'orderId': orderId,
        'productId': productId,
        'purchaseToken': purchaseToken,
      },
    );
    final body = res.data is String ? jsonDecode(res.data) : res.data;
    if (body['status'] != true) {
      throw Exception(body['message'] ?? 'Verify failed');
    }
  }

  void _toast(String title, String msg) {
    debugPrint(msg);
    Get.snackbar(title, msg);
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }
}
