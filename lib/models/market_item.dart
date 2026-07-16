// lib/models/market_item.dart
import 'license_model.dart';

class MarketItem {
  final String id;
  final String title;
  final String description;
  final double price;
  final double rating;
  final int sales;
  final String authorId;

  final String previewImage;        // صورة العرض
  final String arPreviewFile;       // ملف AR للمعاينة (GLB / USDZ / Bundle)
  final List<String> files;         // الملفات اللي المستخدم يحملها بعد الشراء

  final List<String> tags;          // للبحث
  final String category;            // Portal, 3D Object, FX...

  final bool isFeatured;            // يظهر في Featured
  final DateTime createdAt;

  final double sizeMB;              // حجم الملفات
  final String version;             // اصدار العنصر
  final List<String> compatibility; // ARCore / ARKit / Unity

  final LicenseModel licenseType;   // الترخيص المرتبط بالمنتج

  const MarketItem({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.rating,
    required this.sales,
    required this.authorId,
    required this.previewImage,
    required this.arPreviewFile,
    required this.files,
    required this.tags,
    required this.category,
    required this.isFeatured,
    required this.createdAt,
    required this.sizeMB,
    required this.version,
    required this.compatibility,
    required this.licenseType,
  });

  // ------------------------------
  // JSON serialization
  // ------------------------------
  factory MarketItem.fromJson(Map<String, dynamic> json) {
    return MarketItem(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      price: (json['price'] as num).toDouble(),
      rating: (json['rating'] as num).toDouble(),
      sales: json['sales'],
      authorId: json['authorId'],
      previewImage: json['previewImage'],
      arPreviewFile: json['arPreviewFile'],
      files: List<String>.from(json['files']),
      tags: List<String>.from(json['tags']),
      category: json['category'],
      isFeatured: json['isFeatured'],
      createdAt: DateTime.parse(json['createdAt']),
      sizeMB: (json['sizeMB'] as num).toDouble(),
      version: json['version'],
      compatibility: List<String>.from(json['compatibility']),
      licenseType: LicenseModel.fromJson(json['licenseType']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'rating': rating,
      'sales': sales,
      'authorId': authorId,
      'previewImage': previewImage,
      'arPreviewFile': arPreviewFile,
      'files': files,
      'tags': tags,
      'category': category,
      'isFeatured': isFeatured,
      'createdAt': createdAt.toIso8601String(),
      'sizeMB': sizeMB,
      'version': version,
      'compatibility': compatibility,
      'licenseType': licenseType.toJson(),
    };
  }

  MarketItem copyWith({
    String? title,
    String? description,
    double? price,
    bool? isFeatured,
    String? version,
  }) {
    return MarketItem(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      rating: rating,
      sales: sales,
      authorId: authorId,
      previewImage: previewImage,
      arPreviewFile: arPreviewFile,
      files: files,
      tags: tags,
      category: category,
      isFeatured: isFeatured ?? this.isFeatured,
      createdAt: createdAt,
      sizeMB: sizeMB,
      version: version ?? this.version,
      compatibility: compatibility,
      licenseType: licenseType,
    );
  }
}
