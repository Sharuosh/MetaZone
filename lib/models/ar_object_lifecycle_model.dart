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

  ARObjectLifecycleModel({
    required this.objectId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.expiresAt,
  });

  bool get isActive => status == ARObjectStatus.active;

  bool get isExpired =>
      expiresAt != null && DateTime.now().isAfter(expiresAt!);

  Map<String, dynamic> toMap() {
    return {
      'status': status.name,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'expiresAt': expiresAt,
    };
  }

  factory ARObjectLifecycleModel.fromMap(
      String id, Map<String, dynamic> data) {
    return ARObjectLifecycleModel(
      objectId: id,
      status: ARObjectStatus.values.firstWhere(
            (e) => e.name == data['status'],
        orElse: () => ARObjectStatus.active,
      ),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      expiresAt: data['expiresAt'] != null
          ? (data['expiresAt'] as Timestamp).toDate()
          : null,
    );
  }
}
