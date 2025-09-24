import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/models/scan_document.dart';
import '../../../features/ocr/services/ocr_service.dart';
import '../../scan_history/providers/scan_history_provider.dart';
import '../widgets/capture_button.dart';
import '../widgets/camera_overlay.dart';

class CameraScreen extends ConsumerStatefulWidget {
  const CameraScreen({super.key});

  @override
  ConsumerState<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends ConsumerState<CameraScreen>
    with TickerProviderStateMixin {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;
  bool _isCapturing = false;
  bool _hasPermission = false;
  bool _isLoading = true;
  String? _errorMessage;
  FlashMode _flashMode = FlashMode.off;
  int _selectedCameraIndex = 0;
  late AnimationController _captureAnimationController;
  late AnimationController _flashAnimationController;

  @override
  void initState() {
    super.initState();
    _captureAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _flashAnimationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Check and request camera permission
      final permissionStatus = await Permission.camera.request();
      
      if (permissionStatus != PermissionStatus.granted) {
        setState(() {
          _hasPermission = false;
          _isLoading = false;
          _errorMessage = 'Camera permission is required to scan documents';
        });
        return;
      }

      setState(() => _hasPermission = true);

      // Get available cameras
      _cameras = await availableCameras();
      
      if (_cameras == null || _cameras!.isEmpty) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'No cameras found on this device';
        });
        return;
      }

      // Setup the camera
      await _setupCamera(_selectedCameraIndex);
      
    } catch (e) {
      debugPrint('Error initializing camera: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to initialize camera: ${e.toString()}';
      });
    }
  }

  Future<void> _setupCamera(int cameraIndex) async {
    try {
      if (_cameraController != null) {
        await _cameraController!.dispose();
      }

      _cameraController = CameraController(
        _cameras![cameraIndex],
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _cameraController!.initialize();
      
      if (_cameraController!.value.isInitialized) {
        await _cameraController!.setFlashMode(_flashMode);
        
        if (mounted) {
          setState(() {
            _isInitialized = true;
            _isLoading = false;
            _errorMessage = null;
          });
        }
      } else {
        throw Exception('Camera failed to initialize');
      }
    } catch (e) {
      debugPrint('Error setting up camera: $e');
      setState(() {
        _isInitialized = false;
        _isLoading = false;
        _errorMessage = 'Failed to setup camera: ${e.toString()}';
      });
    }
  }

  Future<void> _capturePhoto() async {
    if (!_isInitialized || _isCapturing || _cameraController == null) return;

    try {
      setState(() => _isCapturing = true);
      
      // Animate capture button
      await _captureAnimationController.forward();
      
      // Flash animation
      _flashAnimationController.forward().then((_) {
        _flashAnimationController.reverse();
      });

      final XFile photo = await _cameraController!.takePicture();
      
      // Process the captured image
      await _processImage(photo.path);
      
    } catch (e) {
      debugPrint('Error capturing photo: $e');
      _showError('Failed to capture photo: ${e.toString()}');
    } finally {
      setState(() => _isCapturing = false);
      _captureAnimationController.reverse();
    }
  }

  Future<void> _processImage(String imagePath) async {
    try {
      // Show processing dialog
      _showProcessingDialog();

      // Extract text using OCR
      final extractedText = await OCRService.extractTextFromImage(imagePath);
      
      // Create document title from first few words or use default
      String title = 'Scanned Document';
      if (extractedText.isNotEmpty) {
        final words = extractedText.split(' ').take(4).join(' ');
        if (words.isNotEmpty) {
          title = words.length > 30 ? '${words.substring(0, 30)}...' : words;
        }
      }

      // Create scan document
      final document = ScanDocument(
        title: title,
        extractedText: extractedText,
        imagePaths: [imagePath],
      );

      // Save to database
      await ref.read(scanHistoryProvider.notifier).addScanDocument(document);

      // Close processing dialog
      if (mounted) Navigator.of(context).pop();

      // Show success and navigate back
      _showSuccess('Document scanned successfully!');
      
      // Navigate back to home after a short delay
      await Future.delayed(const Duration(milliseconds: 1500));
      if (mounted) Navigator.of(context).pop();

    } catch (e) {
      // Close processing dialog
      if (mounted) Navigator.of(context).pop();
      _showError('Failed to process image: ${e.toString()}');
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      
      if (image != null) {
        await _processImage(image.path);
      }
    } catch (e) {
      _showError('Failed to pick image: ${e.toString()}');
    }
  }

  Future<void> _toggleFlash() async {
    if (!_isInitialized || _cameraController == null) return;

    try {
      setState(() {
        switch (_flashMode) {
          case FlashMode.off:
            _flashMode = FlashMode.auto;
            break;
          case FlashMode.auto:
            _flashMode = FlashMode.always;
            break;
          case FlashMode.always:
            _flashMode = FlashMode.off;
            break;
          case FlashMode.torch:
            _flashMode = FlashMode.off;
            break;
        }
      });

      await _cameraController!.setFlashMode(_flashMode);
    } catch (e) {
      debugPrint('Error toggling flash: $e');
    }
  }

  Future<void> _switchCamera() async {
    if (_cameras == null || _cameras!.length < 2) return;

    setState(() {
      _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras!.length;
      _isInitialized = false;
      _isLoading = true;
    });

    await _setupCamera(_selectedCameraIndex);
  }

  Future<void> _requestPermission() async {
    final status = await Permission.camera.request();
    if (status == PermissionStatus.granted) {
      _initializeCamera();
    }
  }

  IconData _getFlashIcon() {
    switch (_flashMode) {
      case FlashMode.off:
        return Icons.flash_off;
      case FlashMode.auto:
        return Icons.flash_auto;
      case FlashMode.always:
        return Icons.flash_on;
      case FlashMode.torch:
        return Icons.flashlight_on;
    }
  }

  void _showProcessingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Processing image...',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _captureAnimationController.dispose();
    _flashAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Scan Document',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          if (_isInitialized)
            IconButton(
              icon: Icon(_getFlashIcon(), color: Colors.white),
              onPressed: _toggleFlash,
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    // Show error state
    if (_errorMessage != null) {
      return _buildErrorState();
    }

    // Show loading state
    if (_isLoading) {
      return _buildLoadingState();
    }

    // Show permission denied state
    if (!_hasPermission) {
      return _buildPermissionState();
    }

    // Show camera preview
    if (_isInitialized && _cameraController != null) {
      return _buildCameraPreview();
    }

    // Default loading state
    return _buildLoadingState();
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.white,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'Camera Error',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _initializeCamera,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.white),
          SizedBox(height: 16),
          Text(
            'Initializing camera...',
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.camera_alt,
              color: Colors.white,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'Camera Permission Required',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'ScanFlow needs camera access to scan documents',
              style: TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _requestPermission,
              child: const Text('Grant Permission'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraPreview() {
    return Stack(
      children: [
        // Camera preview
        Positioned.fill(
          child: CameraPreview(_cameraController!),
        ),
        
        // Flash overlay
        AnimatedBuilder(
          animation: _flashAnimationController,
          builder: (context, child) {
            return _flashAnimationController.value > 0
                ? Positioned.fill(
                    child: Container(
                      color: Colors.white.withValues(
                        alpha: _flashAnimationController.value * 0.7,
                      ),
                    ),
                  )
                : const SizedBox.shrink();
          },
        ),
        
        // Camera overlay with guidelines
        const CameraOverlay(),
        
        // Bottom controls
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(AppTheme.spacing24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.7),
                ],
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Gallery button
                IconButton(
                  onPressed: _pickFromGallery,
                  icon: const Icon(
                    Icons.photo_library,
                    color: Colors.white,
                    size: 32,
                  ),
                ).animate()
                 .fadeIn(delay: 200.ms)
                 .slideY(begin: 0.3, end: 0),
                
                // Capture button
                CaptureButton(
                  onPressed: _capturePhoto,
                  isCapturing: _isCapturing,
                  animationController: _captureAnimationController,
                ).animate()
                 .fadeIn(delay: 300.ms)
                 .scale(delay: 300.ms),
                
                // Switch camera button
                IconButton(
                  onPressed: _cameras != null && _cameras!.length > 1 
                      ? _switchCamera 
                      : null,
                  icon: Icon(
                    Icons.flip_camera_ios,
                    color: _cameras != null && _cameras!.length > 1 
                        ? Colors.white 
                        : Colors.grey,
                    size: 32,
                  ),
                ).animate()
                 .fadeIn(delay: 400.ms)
                 .slideY(begin: 0.3, end: 0),
              ],
            ),
          ),
        ),
      ],
    );
  }
}