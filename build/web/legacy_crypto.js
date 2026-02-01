// Legacy decrypt for .txt backup files with 32-byte nonce
// DOM BRIDGE version - writes to HTML elements instead of returning
// Bypasses ALL JS↔Dart type conversion issues

(function() {
  console.log('[legacy_crypto.js] Loading DOM BRIDGE version...');

  // Main decrypt function - writes to DOM elements, no return value
  globalThis.decryptLegacyBackup = function(reqId, password, encryptedPayload) {
    console.log('[JS] ═══════════════════════════════════════════════');
    console.log('[JS] decryptLegacyBackup called (DOM BRIDGE)');
    console.log('[JS] reqId: ' + reqId);
    console.log('[JS] password length: ' + password.length);
    console.log('[JS] payload length: ' + encryptedPayload.length);

    try {
      // Parse payload: CIPHERTEXT.MAC format (2 parts)
      const parts = encryptedPayload.split('.');
      if (parts.length !== 2) {
        throw new Error('Invalid payload format - expected 2 parts, got ' + parts.length);
      }
      console.log('[JS] Payload parsed: 2 parts');

      // Decode base64 using forge
      const ciphertext = forge.util.decode64(parts[0]);  // Ciphertext only
      const authTag = forge.util.decode64(parts[1]);     // MAC/auth tag only

      console.log('[JS] ciphertext length: ' + ciphertext.length);
      console.log('[JS] authTag length: ' + authTag.length);

      // Hardcoded salt from original Dart implementation
      // MATCHES lib/services/encrypt.dart line 226
      const legacySaltB64 = 'RbRiYJBS2MWk5xNIFJrfRBZEqiI/RUE94Euj6cLWO5U=';
      const salt = forge.util.decode64(legacySaltB64);
      console.log('[JS] Using hardcoded legacy salt, length: ' + salt.length);

      // In legacy format, nonce IS the salt (32 bytes)
      // MATCHES lib/services/encrypt.dart line 233
      const nonce = salt;
      console.log('[JS] Nonce = salt (32 bytes)');

      // Derive key using PBKDF2 (SYNCHRONOUS - forge.pkcs5.pbkdf2)
      // SHA-256, 100000 iterations (matching Dart), 32 bytes
      // MATCHES lib/services/encrypt.dart line 260
      console.log('[JS] Deriving key with PBKDF2 (sync, 100000 iterations)...');
      const key = forge.pkcs5.pbkdf2(password, salt, 100000, 32, 'sha256');
      console.log('[JS] Key derived successfully');

      console.log('[JS] Decrypting with AES-GCM...');
      console.log('[JS]   key: ' + key.length + ' bytes');
      console.log('[JS]   nonce (IV): ' + nonce.length + ' bytes');
      console.log('[JS]   ciphertext: ' + ciphertext.length + ' bytes');
      console.log('[JS]   authTag: ' + authTag.length + ' bytes');

      // Create decipher
      const decipher = forge.cipher.createDecipher('AES-GCM', key);

      // Start decryption
      decipher.start({
        iv: nonce,
        tag: forge.util.createBuffer(authTag)
      });

      // Update with ciphertext
      decipher.update(forge.util.createBuffer(ciphertext));

      // Finalize
      const success = decipher.finish();

      if (!success) {
        throw new Error('Authentication tag mismatch - incorrect password or corrupted data');
      }

      // Get decrypted data as string
      const decrypted = decipher.output.toString('utf8');
      console.log('[JS] ✅ Decryption successful!');
      console.log('[JS] Decrypted string length: ' + decrypted.length);
      console.log('[JS] Decrypted string type: ' + typeof decrypted);
      console.log('[JS] Decrypted string value (first 50 chars): ' + decrypted.substring(0, 50));

      console.log('[JS] Writing to DOM elements...');

      // Write to DOM - bypasses all JS↔Dart type conversion
      document.getElementById('decrypt-req').value = reqId;
      document.getElementById('decrypt-result').value = decrypted;
      document.getElementById('decrypt-error').value = '';

      console.log('[JS] ✅ DOM write complete');
      console.log('[JS] ═══════════════════════════════════════════════');

    } catch (e) {
      console.error('[JS] ❌ Decrypt error:', e);
      console.error('[JS] Error stack:', e.stack);
      console.log('[JS] Writing error to DOM...');

      // Write error to DOM
      document.getElementById('decrypt-req').value = reqId;
      document.getElementById('decrypt-result').value = '';
      document.getElementById('decrypt-error').value = e.toString();

      console.log('[JS] ═══════════════════════════════════════════════');
    }
  };

  console.log('[legacy_crypto.js] globalThis.decryptLegacyBackup ready (DOM BRIDGE version)');
})();
