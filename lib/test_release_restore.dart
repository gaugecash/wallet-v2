import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:wallet/services/encrypt.dart';
import 'package:flutter/foundation.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('GAUwallet Release Mode Logic Test', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              FutureBuilder<String>(
                future: _runTest(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }
                  if (snapshot.hasError) {
                    return Text('❌ FAILURE: ${snapshot.error}', style: const TextStyle(color: Colors.red));
                  }
                  return SelectableText('✅ SUCCESS!\n\nResult:\n${snapshot.data}', 
                    style: const TextStyle(color: Colors.green, fontFamily: 'JetBrainsMono'));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<String> _runTest() async {
    const encrypted = 'JftslCkE0cyA4X1sB46CGYrNG+2R54PCX2Cusv4pirAEIQeis7StBM9f54OTCsk6chg6x/eWupmLiRqrcdoZDFrkFQN9wwZgyBTBacZOsJkki/nXrJFSGceS0JHekHfG5l84FbtGtHbr5zSxjCd8/1imNpjSuY70qHlMokecY0OC/6C0UJyPCOHJ2fJBTKPZJb+UHaPB+BS3NJKDSspydiC3smxlw/d1gfE1tC3DtKNWbcGeLuZBkN4MpaMfKNe5EMm5qyp7.AuvR68MFv0GYOQSvzuuwkw==';
    const password = 'walleta';

    print('>>> STARTING RELEASE MODE DECRYPTION TEST');
    print('>>> kIsWeb: $kIsWeb');

    try {
      // This calls the actual service function we fixed
      final decrypted = await computeDecrypt(password, encrypted);
      
      print('>>> Decrypted: $decrypted');
      
      // The previous crash happened right here during jsonDecode
      final data = jsonDecode(decrypted);
      final mnemonic = data['mnemonic'];
      
      return 'Mnemonic: $mnemonic\n\nFull JSON: $decrypted';
    } catch (e, stack) {
      print('>>> ERROR: $e');
      print('>>> STACK: $stack');
      return 'ERROR: $e\n\nSTACK: $stack';
    }
  }
}
