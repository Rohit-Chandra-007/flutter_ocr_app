/// Splash state model
class SplashState {
  final bool isLoading;
  final bool hasError;
  final String errorMessage;

  const SplashState({
    this.isLoading = true,
    this.hasError = false,
    this.errorMessage = '',
  });

  SplashState copyWith({
    bool? isLoading,
    bool? hasError,
    String? errorMessage,
  }) {
    return SplashState(
      isLoading: isLoading ?? this.isLoading,
      hasError: hasError ?? this.hasError,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}