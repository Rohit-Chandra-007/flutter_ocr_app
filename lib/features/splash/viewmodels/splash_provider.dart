import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:scanflow/core/core.dart';
import 'package:scanflow/features/splash/models/splash_state.dart';

part 'splash_provider.g.dart';


/// Splash provider that handles initialization logic
@riverpod
class Splash extends _$Splash {
  @override
  SplashState build() {
    _initialize();
    return const SplashState();
  }

  Future<void> _initialize() async {
    try {
      final results = await Future.wait([
        AppInitializationService.initialize(),
        Future.delayed(AppConstants.splashSequence),
      ]);

      final success = results[0] as bool;

      if (!success) {
        state = state.copyWith(
          isLoading: false,
          hasError: true,
          errorMessage: AppInitializationService.getUserFriendlyError(),
        );
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage: 'Unexpected error: ${e.toString()}',
      );
    }
  }

  void retry() {
    state = const SplashState();
    _initialize();
  }
}
