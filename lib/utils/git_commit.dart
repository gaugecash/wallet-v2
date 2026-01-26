// Git commit hash - generated at build time
// This is a constant to avoid runtime asset loading which freezes in Release mode
// To update: Run `git rev-parse --short HEAD` and paste result below
const String _buildCommit = '4b9a192';

Future<String> getGitCommit() async {
  // Return build-time constant instead of reading from assets
  // (Reading .git files from rootBundle freezes in Release mode)
  return _buildCommit;
}
