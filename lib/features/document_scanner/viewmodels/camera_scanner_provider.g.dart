// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'camera_scanner_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CameraScanner)
const cameraScannerProvider = CameraScannerProvider._();

final class CameraScannerProvider
    extends $NotifierProvider<CameraScanner, ScannerState> {
  const CameraScannerProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'cameraScannerProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$cameraScannerHash();

  @$internal
  @override
  CameraScanner create() => CameraScanner();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ScannerState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ScannerState>(value),
    );
  }
}

String _$cameraScannerHash() => r'28cca5b3e825fcf8adb70ff82024b4a3c8fcf5dc';

abstract class _$CameraScanner extends $Notifier<ScannerState> {
  ScannerState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<ScannerState, ScannerState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<ScannerState, ScannerState>,
        ScannerState,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}
