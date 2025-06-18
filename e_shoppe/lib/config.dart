/// Global configuration values
/// Pass a different API base at runtime with:
/// flutter run --dart-define=API_BASE=https://api.myshop.com
const String kApiBase = String.fromEnvironment(
  'API_BASE',
  defaultValue: 'http://localhost:8080',
);
