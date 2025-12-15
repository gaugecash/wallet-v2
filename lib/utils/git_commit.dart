import 'package:flutter/services.dart';

Future<String> getGitCommit() async {
  final commit = await rootBundle.loadString('.git/refs/heads/main');

  return commit.trim().substring(0, 7);
}
