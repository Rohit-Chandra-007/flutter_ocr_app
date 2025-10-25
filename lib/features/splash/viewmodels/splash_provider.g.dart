// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'splash_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Splash provider that handles initialization logic

@ProviderFor(Splash)
const splashProvider = SplashProvider._();

/// Splash provider that handles initialization logic
final class SplashProvider extends $NotifierProvider<Splash, SplashState> {
  /// Splash provider that handles initialization logic
  const SplashProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'splashProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$splashHash();

  @$internal
  @override
  Splash create() => Splash();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SplashState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SplashState>(value),
    );
  }
}

String _$splashHash() => r'250e0e4b66de57c2549d5b45887d3f3f3193d90a';

/// Splash provider that handles initialization logic

abstract class _$Splash extends $Notifier<SplashState> {
  SplashState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<SplashState, SplashState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<SplashState, SplashState>, SplashState, Object?, Object?>;
    element.handleValue(ref, created);
  }
}
