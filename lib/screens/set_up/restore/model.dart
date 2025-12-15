import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:wallet/screens/set_up/_model.dart';

final setUpRestoreProvider =
    ChangeNotifierProvider<SetUpRestoreModel>((ref) => SetUpRestoreModel());

class SetUpRestoreModel extends SetUpModel {
  bool _canContinue = false;
  int _currentPage = 0;
  String? backupFile;
  String? password;

  @override
  bool get canContinue => _canContinue;

  @override
  int get currentPage => _currentPage;

  @override
  set canContinue(bool value) {
    _canContinue = value;
    notifyListeners();
  }

  @override
  set currentPage(int value) {
    _currentPage = value;
    notifyListeners();
  }
}
