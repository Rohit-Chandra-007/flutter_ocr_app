class AppInfoModel {
  final String appName;
  final String version;
  final String description;
  final String tagline;

  const AppInfoModel({
    required this.appName,
    required this.version,
    required this.description,
    required this.tagline,
  });

  static const current = AppInfoModel(
    appName: 'ScanFlow',
    version: '1.0.0',
    description:
        'A beautiful, modern OCR mobile application with seamless user experience.',
    tagline:
        'Transform your device into a powerful document scanner with intelligent text recognition.',
  );
}
