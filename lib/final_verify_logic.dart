import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:wallet/services/encrypt.dart';
import 'package:flutter/foundation.dart';

void main() {
  runApp(const FinalVerifyApp());
}

class FinalVerifyApp extends StatelessWidget {
  const FinalVerifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Final Build 175 Verification', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 30),
              FutureBuilder<String>(
                future: _performTest(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }
                  if (snapshot.hasError) {
                    return Text('❌ TEST CRASHED: ${snapshot.error}', style: const TextStyle(color: Colors.red));
                  }
                  return SelectableText(snapshot.data!,
                    style: const TextStyle(fontSize: 16, fontFamily: 'JetBrainsMono'));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

    Future<String> _performTest() async {
      const encrypted = 'JftslCkE0cyA4X1sB46CGYrNG+2R54PCX2Cusv4pirAEIQeis7StBM9f54OTCsk6chg6x/eWupmLiRqrcdoZDFrkFQN9wwZgyBTBacZOsJkki/nXrJFSGceS0JHekHfG5l84FbtGtHbr5zSxjCd8/1imNpjSuY70qHlMokecY0OC/6C0UJyPCOHJ2fJBTKPZJb+UHaPB+BS3NJKDSspydiC3smxlw/d1gfE1tC3DtKNWbcGeLuZBkN4MpaMfKNe5EMm5qyp7.AuvR68MFv0GYOQSvzuuwkw==';
      const password = 'walleta';
  
      try {
        print('>>> [START] computeDecrypt');
        final dynamic result = await computeDecrypt(password, encrypted);
        
        print('>>> [RESULT TYPE] ${result.runtimeType}');
        String finalString;
        
        if (result is Future) {
          print('>>> [WARN] Nested Future detected! Flattening...');
          finalString = await result;
        } else {
          finalString = result.toString();
        }
  
        print('>>> [FINAL STRING TYPE] ${finalString.runtimeType}');
        print('>>> [JSON DECODE START]');
        
        final data = jsonDecode(finalString);
        print('>>> [JSON DECODE SUCCESS]');
        
        return '✅ SUCCESS!\\n\\n'
               'Type: ${result.runtimeType}\\n'
               'Mnemonic: ${data['mnemonic']}\\n\\n'
               'The "subtype of String" bug is FIXED.';
               
      } catch (e, stack) {
        print('>>> [FAILURE] $e');
        return '❌ FAILURE: $e\\n\\nSTACK: $stack';
      }
    }}
