// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document_processor_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(DocumentProcessor)
const documentProcessorProvider = DocumentProcessorProvider._();

final class DocumentProcessorProvider
    extends $AsyncNotifierProvider<DocumentProcessor, void> {
  const DocumentProcessorProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'documentProcessorProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$documentProcessorHash();

  @$internal
  @override
  DocumentProcessor create() => DocumentProcessor();
}

String _$documentProcessorHash() => r'ce8465e3b5df12cda43a60e3e3f8cd00a032f518';

abstract class _$DocumentProcessor extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    build();
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<void>, void>,
        AsyncValue<void>,
        Object?,
        Object?>;
    element.handleValue(ref, null);
  }
}
