import 'package:cloud_firestore/cloud_firestore.dart';

enum ARObjectStatus {
  draft,
  active,
  locked,
  hidden,
  deleted,
  expired,
  reported,
}

class ARObjectLifecycleModel {
  final String objectId;
  final ARObjectStatus status;

  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? expiresAt;

  const ARObjectLifecycleModel({
    required this.objectId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.expiresAt,
  });

  bool get isActive => status == ARObjectStatus.active;

  bool get isExpired =>
      expiresAt != null &&
          DateTime.now().isAfter(expiresAt!);

  Map<String, dynamic> toMap() {
    return {
      'status': status.name,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'expiresAt': expiresAt,
    };
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;

    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    if (value is String) {
      return DateTime.tryParse(value);
    }

    return null;
  }

  factory ARObjectLifecycleModel.fromMap(
      String id,
      Map<String, dynamic> data,
      ) {
    return ARObjectLifecycleModel(
      objectId: id,
      status: ARObjectStatus.values.firstWhere(
            (e) => e.name == data['status'],
        orElse: () => ARObjectStatus.active,
      ),
      createdAt:
      _parseDate(data['createdAt']) ??
          DateTime.now(),
      updatedAt:
      _parseDate(data['updatedAt']) ??
          DateTime.now(),
      expiresAt:
      _parseDate(data['expiresAt']),
    );
  }

  ARObjectLifecycleModel copyWith({
    String? objectId,
    ARObjectStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? expiresAt,
  }) {
    return ARObjectLifecycleModel(
      objectId: objectId ?? this.objectId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }

  @override
  String toString() {
    return 'ARObjectLifecycleModel('
        'objectId: $objectId, '
        'status: $status, '
        'createdAt: $createdAt, '
        'updatedAt: $updatedAt, '
        'expiresAt: $expiresAt'
        ')';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ARObjectLifecycleModel &&
            runtimeType == other.runtimeType &&
            objectId == other.objectId &&
            status == other.status &&
            createdAt == other.createdAt &&
            updatedAt == other.updatedAt &&
            expiresAt == other.expiresAt;
  }

  @override
  int get hashCode =>
      Object.hash(
        objectId,
        status,
        createdAt,
        updatedAt,
        expiresAt,
      );
}