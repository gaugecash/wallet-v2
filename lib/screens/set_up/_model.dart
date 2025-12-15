import 'package:flutter/foundation.dart';

abstract class SetUpModel extends ChangeNotifier {
  bool get canContinue;

  int get currentPage;

  set canContinue(bool value);

  set currentPage(int value);
}
