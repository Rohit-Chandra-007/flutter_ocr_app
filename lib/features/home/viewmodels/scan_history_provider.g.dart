// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scan_history_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ScanHistory)
const scanHistoryProvider = ScanHistoryProvider._();

final class ScanHistoryProvider
    extends $AsyncNotifierProvider<ScanHistory, List<ScanDocument>> {
  const ScanHistoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'scanHistoryProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$scanHistoryHash();

  @$internal
  @override
  ScanHistory create() => ScanHistory();
}

String _$scanHistoryHash() => r'3eaffb23a65765be3baf0598fa222efa777b4875';

abstract class _$ScanHistory extends $AsyncNotifier<List<ScanDocument>> {
  FutureOr<List<ScanDocument>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref as $Ref<AsyncValue<List<ScanDocument>>, List<ScanDocument>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<List<ScanDocument>>, List<ScanDocument>>,
        AsyncValue<List<ScanDocument>>,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}
