class TelemetrySanitizeResult {
  final dynamic value;
  final int hitCount;

  const TelemetrySanitizeResult(this.value, this.hitCount);
}

class TelemetrySanitizer {
  // These patterns intentionally target credentials, long random secrets and
  // local file paths. WebDAV URLs are ordinary business fields for this feature
  // and must not be redacted just because they are URLs.
  static final RegExp _tokenPattern = RegExp(
    r'(api[_-]?key|authorization|bearer|token|password|passwd|pwd|cookie|secret)\s*[:=]\s*([^\s,;&]+)',
    caseSensitive: false,
  );
  static final RegExp _longRandomPattern = RegExp(
    r'\b[A-Za-z0-9_\-]{32,}\b',
  );
  static final RegExp _absolutePathPattern = RegExp(
    r'((/Users|/var|/private|/storage|/sdcard|/data/user|[A-Za-z]:\\)[^\s,;]+)',
  );

  static const Set<String> _sensitiveKeys = {
    'api_key',
    'apikey',
    'api-key',
    'authorization',
    'auth',
    'access_token',
    'refresh_token',
    'token',
    'password',
    'passwd',
    'pwd',
    'cookie',
    'secret',
    'client_secret',
  };

  const TelemetrySanitizer();

  TelemetrySanitizeResult sanitize(dynamic value) {
    var hits = 0;

    dynamic visit(dynamic input, [String? key]) {
      // Key-based redaction wins over value-based rules. If a field is named
      // password/token/cookie/etc, never keep the original value.
      if (_isSensitiveKey(key)) {
        hits++;
        return '[REDACTED]';
      }
      if (input is Map) {
        return input.map((mapKey, mapValue) {
          return MapEntry(
              mapKey.toString(), visit(mapValue, mapKey.toString()));
        });
      }
      if (input is Iterable) {
        return input.map((item) => visit(item, key)).toList();
      }
      if (input is String) {
        return _sanitizeString(input, () => hits++);
      }
      return input;
    }

    return TelemetrySanitizeResult(visit(value), hits);
  }

  bool _isSensitiveKey(String? key) {
    if (key == null) {
      return false;
    }
    final normalized = key.trim().toLowerCase();
    if (_sensitiveKeys.contains(normalized)) {
      return true;
    }
    return normalized.contains('token') ||
        normalized.contains('password') ||
        normalized.contains('cookie') ||
        normalized.contains('authorization') ||
        normalized.contains('secret');
  }

  String _sanitizeString(String value, void Function() onHit) {
    var result = value;
    // Value-based rules catch leaked credentials inside free-form error text or
    // stack traces where no structured key is available.
    result = result.replaceAllMapped(_tokenPattern, (match) {
      onHit();
      return '${match.group(1)}=[REDACTED]';
    });
    result = result.replaceAllMapped(_absolutePathPattern, (match) {
      onHit();
      return '[PATH_REDACTED]';
    });
    result = result.replaceAllMapped(_longRandomPattern, (match) {
      onHit();
      return '[TOKEN_REDACTED]';
    });
    return result;
  }
}
