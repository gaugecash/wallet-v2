// JS interop for legacy decrypt on web platform
// DOM BRIDGE version - reads from HTML elements instead of return values
// Bypasses ALL JS↔Dart type conversion issues

import 'dart:html' as html;
import 'dart:js' as js;

/// Decrypts legacy backup using JavaScript via DOM bridge
/// Returns the decrypted JSON string
/// Throws Exception on error
String decryptLegacyBackupJS(String password, String payload) {
  // Generate unique request ID to prevent race conditions
  final reqId = DateTime.now().microsecondsSinceEpoch.toString();

  print('[DART] DOM Bridge: Calling JS with reqId: $reqId');
  print('[DART] Password length: ${password.length}');
  print('[DART] Payload length: ${payload.length}');

  // Call JS function - it writes to DOM elements, doesn't return
  js.context.callMethod('decryptLegacyBackup', [reqId, password, payload]);

  print('[DART] Reading from DOM elements...');

  // Read from DOM elements - NO INTEROP TYPE CONVERSION
  final reqEl = html.document.getElementById('decrypt-req') as html.InputElement;
  final errEl = html.document.getElementById('decrypt-error') as html.InputElement;
  final resEl = html.document.getElementById('decrypt-result') as html.InputElement;

  // Verify request ID matches (prevents race conditions)
  final returnedReqId = reqEl.value ?? '';
  if (returnedReqId != reqId) {
    throw Exception('Request ID mismatch: expected $reqId, got $returnedReqId');
  }

  print('[DART] Request ID verified: $returnedReqId');

  // Check for error
  final error = errEl.value ?? '';
  if (error.isNotEmpty) {
    print('[DART] ❌ Error from JS: $error');

    // Clear sensitive data from DOM
    resEl.value = '';
    errEl.value = '';
    reqEl.value = '';

    throw Exception(error);
  }

  // Get result
  final result = resEl.value ?? '';

  // Clear sensitive data from DOM immediately
  resEl.value = '';
  errEl.value = '';
  reqEl.value = '';

  if (result.isEmpty) {
    throw Exception('No result from JS decrypt');
  }

  print('[DART] ✅ Got result from DOM, length: ${result.length}');

  return result;
}
