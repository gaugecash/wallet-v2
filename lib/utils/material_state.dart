import 'package:flutter/material.dart';

extension ContainsOne on Set<MaterialState> {
  bool containsOne(List b) {
    for (final el in b) {
      if (contains(el)) {
        return true;
      }
    }
    return false;
  }
}
