import 'package:flutter/foundation.dart';

@immutable
class DemoEventLog {
  final String id;
  final String category;
  final String title;
  final String message;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;

  const DemoEventLog({
    required this.id,
    required this.category,
    required this.title,
    required this.message,
    required this.timestamp,
    this.metadata = const <String, dynamic>{},
  });

  bool get hasMetadata => metadata.isNotEmpty;

  DemoEventLog copyWith({
    String? id,
    String? category,
    String? title,
    String? message,
    DateTime? timestamp,
    Map<String, dynamic>? metadata,
  }) {
    return DemoEventLog(
      id: id ?? this.id,
      category: category ?? this.category,
      title: title ?? this.title,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'category': category,
      'title': title,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'metadata': metadata,
    };
  }

  factory DemoEventLog.fromMap(Map<String, dynamic> map) {
    final id = map['id'];
    final category = map['category'];
    final title = map['title'];
    final message = map['message'];
    final timestamp = map['timestamp'];
    final metadata = map['metadata'];

    if (id is! String || id.trim().isEmpty) {
      throw const FormatException(
        'DemoEventLog requires a non-empty string "id".',
      );
    }
    if (category is! String || category.trim().isEmpty) {
      throw const FormatException(
        'DemoEventLog requires a non-empty string "category".',
      );
    }
    if (title is! String || title.trim().isEmpty) {
      throw const FormatException(
        'DemoEventLog requires a non-empty string "title".',
      );
    }
    if (message is! String) {
      throw const FormatException(
        'DemoEventLog requires a string "message".',
      );
    }
    if (timestamp is! String || timestamp.trim().isEmpty) {
      throw const FormatException(
        'DemoEventLog requires a non-empty ISO string "timestamp".',
      );
    }

    DateTime parsedTimestamp;
    try {
      parsedTimestamp = DateTime.parse(timestamp);
    } catch (_) {
      throw const FormatException(
        'DemoEventLog "timestamp" must be a valid ISO-8601 string.',
      );
    }

    if (metadata != null && metadata is! Map<String, dynamic>) {
      throw const FormatException(
        'DemoEventLog "metadata" must be Map<String, dynamic> when provided.',
      );
    }

    return DemoEventLog(
      id: id,
      category: category,
      title: title,
      message: message,
      timestamp: parsedTimestamp,
      metadata: metadata ?? const <String, dynamic>{},
    );
  }

  @override
  String toString() {
    return 'DemoEventLog('
        'id: $id, '
        'category: $category, '
        'title: $title, '
        'timestamp: $timestamp, '
        'hasMetadata: $hasMetadata'
        ')';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is DemoEventLog &&
            other.id == id &&
            other.category == category &&
            other.title == title &&
            other.message == message &&
            other.timestamp == timestamp &&
            mapEquals(other.metadata, metadata));
  }

  @override
  int get hashCode => Object.hash(
    id,
    category,
    title,
    message,
    timestamp,
    Object.hashAll(
      metadata.entries.map((entry) => Object.hash(entry.key, entry.value)),
    ),
  );
}