// Safe helpers for legacy backup parsing on Flutter Web
// Prevents ALL throwing exceptions during JSON decode

import 'dart:convert';

/// ----------------------
/// Safe decode/coercion helpers
/// ----------------------

dynamic safeJsonDecode(String s) {
  final cleaned = cleanString(s);
  try {
    return jsonDecode(cleaned);
  } catch (_) {
    return <String, Object?>{};
  }
}

Map<String, Object?> coerceToStringKeyMap(dynamic v) {
  if (v is Map) {
    final out = <String, Object?>{};
    for (final entry in v.entries) {
      final k = entry.key?.toString();
      if (k == null || k.isEmpty) continue;
      out[k] = coerceValue(entry.value);
    }
    return out;
  }
  return <String, Object?>{};
}

Object? coerceValue(dynamic v) {
  if (v == null) return null;
  if (v is Map) return coerceToStringKeyMap(v);
  if (v is List) return v.map(coerceValue).toList(growable: false);
  return v;
}

String requireNonEmptyString(Object? v, {required String fieldName}) {
  final s = safeToString(v);
  if (s == null || s.isEmpty) {
    throw StateError('Missing required field "$fieldName" in legacy backup');
  }
  return s;
}

String? safeOptionalString(Object? v) {
  final s = safeToString(v);
  if (s == null || s.isEmpty) return null;
  return s;
}

int? safeInt(Object? v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is num) return v.toInt();
  final s = safeToString(v);
  if (s == null) return null;
  return int.tryParse(s);
}

DateTime? safeParseDateTime(Object? v) {
  if (v == null) return null;
  if (v is DateTime) return v;
  if (v is int) return epochToDateTime(v);
  if (v is num) return epochToDateTime(v.toInt());

  final s0 = safeToString(v);
  if (s0 == null) return null;

  final s = cleanString(s0);
  if (s.isEmpty) return null;

  // Try ISO first - NEVER throws
  final dt = DateTime.tryParse(s);
  if (dt != null) return dt;

  // Try with space instead of T
  final sSpace = s.replaceFirst(' ', 'T');
  final dt2 = DateTime.tryParse(sSpace);
  if (dt2 != null) return dt2;

  // Give up - return null, DON'T THROW
  return null;
}

DateTime epochToDateTime(int x) {
  if (x > 100000000000) {
    return DateTime.fromMillisecondsSinceEpoch(x, isUtc: true);
  }
  return DateTime.fromMillisecondsSinceEpoch(x * 1000, isUtc: true);
}

String? safeToString(Object? v) {
  if (v == null) return null;
  if (v is String) return v;
  try {
    return v.toString();
  } catch (_) {
    return null;
  }
}

String cleanString(String s) {
  var out = s;
  if (out.isNotEmpty && out.codeUnitAt(0) == 0xFEFF) {
    out = out.substring(1);
  }
  out = out.replaceAll('\u0000', '');
  out = out.trim();

  final sb = StringBuffer();
  for (final rune in out.runes) {
    if (rune == 0x09 || rune == 0x0A || rune == 0x0D) {
      sb.writeCharCode(rune);
      continue;
    }
    if (rune < 0x20) continue;
    sb.writeCharCode(rune);
  }
  return sb.toString();
}
