// lib/services/market_api.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../models/market_item.dart';
import '../../models/order_model.dart';
import '../../models/license_model.dart';

class MarketAPI {
  // Base URL — غيّره بحسب السيرفر بتاعك
  static const String baseUrl = "https://api.metazone.app";

  // --------------------------
  // ١) جلب كل العناصر
  // --------------------------
  static Future<List<MarketItem>> fetchAllItems() async {
    final res = await http.get(Uri.parse("$baseUrl/items"));
    if (res.statusCode != 200) throw Exception("Failed to load items");

    final list = jsonDecode(res.body) as List;
    return list.map((e) => MarketItem.fromJson(e)).toList();
  }

  // --------------------------
  // ٢) جلب عنصر واحد
  // --------------------------
  static Future<MarketItem> fetchItem(String id) async {
    final res = await http.get(Uri.parse("$baseUrl/items/$id"));
    if (res.statusCode != 200) throw Exception("Item not found");

    return MarketItem.fromJson(jsonDecode(res.body));
  }

  // --------------------------
  // ٣) بحث ذكي
  // --------------------------
  static Future<List<MarketItem>> searchItems(String query) async {
    final res = await http.get(Uri.parse("$baseUrl/items/search?q=$query"));
    if (res.statusCode != 200) throw Exception("Search failed");

    final list = jsonDecode(res.body) as List;
    return list.map((e) => MarketItem.fromJson(e)).toList();
  }

  // --------------------------
  // ٤) رفع منتج جديد (Upload Item Metadata Only)
  // --------------------------
  static Future<bool> uploadItem(MarketItem item) async {
    final res = await http.post(
      Uri.parse("$baseUrl/items"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(item.toJson()),
    );

    return res.statusCode == 201;
  }

  // --------------------------
  // ٥) تحديث عنصر
  // --------------------------
  static Future<bool> updateItem(MarketItem item) async {
    final res = await http.put(
      Uri.parse("$baseUrl/items/${item.id}"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(item.toJson()),
    );

    return res.statusCode == 200;
  }

  // --------------------------
  // ٦) حذف عنصر
  // --------------------------
  static Future<bool> deleteItem(String id) async {
    final res = await http.delete(Uri.parse("$baseUrl/items/$id"));
    return res.statusCode == 200;
  }

  // --------------------------
  // ٧) إنشاء طلب شراء (Checkout API)
  // --------------------------
  static Future<OrderModel> createOrder({
    required String userId,
    required MarketItem item,
    required String paymentMethod,
  }) async {
    final body = {
      "userId": userId,
      "itemId": item.id,
      "price": item.price,
      "paymentMethod": paymentMethod,
      "license": item.licenseType.toJson()
    };

    final res = await http.post(
      Uri.parse("$baseUrl/orders"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    if (res.statusCode != 201) throw Exception("Order creation failed");

    return OrderModel.fromJson(jsonDecode(res.body));
  }

  // --------------------------
  // ٨) جلب الطلبات الخاصة بالمستخدم
  // --------------------------
  static Future<List<OrderModel>> fetchUserOrders(String userId) async {
    final res = await http.get(Uri.parse("$baseUrl/orders/user/$userId"));
    if (res.statusCode != 200) throw Exception("Failed to load orders");

    final list = jsonDecode(res.body) as List;
    return list.map((e) => OrderModel.fromJson(e)).toList();
  }
}
