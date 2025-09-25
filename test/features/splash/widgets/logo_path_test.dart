import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scanflow/features/splash/widgets/logo_path.dart';

void main() {
  group('LogoPath', () {
    const testSize = Size(200, 300);
    
    group('getSLogoPath', () {
      test('should return a valid path for given size', () {
        final path = LogoPath.getSLogoPath(testSize);
        
        expect(path, isNotNull);
        expect(path.getBounds().isEmpty, isFalse);
      });
      
      test('should create path within reasonable bounds', () {
        final path = LogoPath.getSLogoPath(testSize);
        final bounds = path.getBounds();
        
        // Logo should be centered and take up reasonable portion of size
        expect(bounds.center.dx, closeTo(testSize.width / 2, 10));
        expect(bounds.center.dy, closeTo(testSize.height / 2, 10));
        expect(bounds.width, lessThan(testSize.width));
        expect(bounds.height, lessThan(testSize.height));
      });
      
      test('should scale proportionally with different sizes', () {
        const smallSize = Size(100, 150);
        const largeSize = Size(400, 600);
        
        final smallPath = LogoPath.getSLogoPath(smallSize);
        final largePath = LogoPath.getSLogoPath(largeSize);
        
        final smallBounds = smallPath.getBounds();
        final largeBounds = largePath.getBounds();
        
        // Aspect ratio should be maintained
        final smallRatio = smallBounds.width / smallBounds.height;
        final largeRatio = largeBounds.width / largeBounds.height;
        
        expect(smallRatio, closeTo(largeRatio, 0.1));
      });
    });
    
    group('getScannerPath', () {
      test('should return non-empty list of points', () {
        final scannerPoints = LogoPath.getScannerPath(testSize);
        
        expect(scannerPoints, isNotEmpty);
        expect(scannerPoints.length, greaterThan(10));
      });
      
      test('should return points sorted by Y coordinate', () {
        final scannerPoints = LogoPath.getScannerPath(testSize);
        
        for (int i = 1; i < scannerPoints.length; i++) {
          expect(
            scannerPoints[i].dy,
            greaterThanOrEqualTo(scannerPoints[i - 1].dy),
            reason: 'Points should be sorted by Y coordinate',
          );
        }
      });
      
      test('should return points within logo bounds', () {
        final scannerPoints = LogoPath.getScannerPath(testSize);
        final logoBounds = LogoPath.getLogoBounds(testSize);
        
        for (final point in scannerPoints) {
          expect(point.dx, greaterThanOrEqualTo(0));
          expect(point.dx, lessThanOrEqualTo(testSize.width));
          expect(point.dy, greaterThanOrEqualTo(logoBounds.top - 10));
          expect(point.dy, lessThanOrEqualTo(logoBounds.bottom + 10));
        }
      });
    });
    
    group('getLogoBounds', () {
      test('should return valid bounds', () {
        final bounds = LogoPath.getLogoBounds(testSize);
        
        expect(bounds.isEmpty, isFalse);
        expect(bounds.width, greaterThan(0));
        expect(bounds.height, greaterThan(0));
      });
      
      test('should be consistent with path bounds', () {
        final path = LogoPath.getSLogoPath(testSize);
        final pathBounds = path.getBounds();
        final logoBounds = LogoPath.getLogoBounds(testSize);
        
        expect(logoBounds.left, closeTo(pathBounds.left, 0.1));
        expect(logoBounds.top, closeTo(pathBounds.top, 0.1));
        expect(logoBounds.right, closeTo(pathBounds.right, 0.1));
        expect(logoBounds.bottom, closeTo(pathBounds.bottom, 0.1));
      });
    });
    
    group('getScannerYPosition', () {
      test('should return position within expected range', () {
        final bounds = LogoPath.getLogoBounds(testSize);
        
        // Test progress boundaries
        final startY = LogoPath.getScannerYPosition(testSize, 0.0);
        final endY = LogoPath.getScannerYPosition(testSize, 1.0);
        
        expect(startY, lessThan(bounds.top));
        expect(endY, greaterThan(bounds.bottom));
        expect(endY, greaterThan(startY));
      });
      
      test('should progress linearly', () {
        final y25 = LogoPath.getScannerYPosition(testSize, 0.25);
        final y50 = LogoPath.getScannerYPosition(testSize, 0.5);
        final y75 = LogoPath.getScannerYPosition(testSize, 0.75);
        
        expect(y50 - y25, closeTo(y75 - y50, 1.0));
      });
    });
    
    group('getScannerLineWidth', () {
      test('should return reasonable width relative to size', () {
        final lineWidth = LogoPath.getScannerLineWidth(testSize);
        
        expect(lineWidth, greaterThan(0));
        expect(lineWidth, lessThanOrEqualTo(testSize.width));
        expect(lineWidth, closeTo(testSize.width * 0.8, 1.0));
      });
    });
    
    group('getLogoRevealProgress', () {
      test('should return 0 for early scanner progress', () {
        final revealProgress = LogoPath.getLogoRevealProgress(testSize, 0.1);
        expect(revealProgress, equals(0.0));
      });
      
      test('should return 1 for late scanner progress', () {
        final revealProgress = LogoPath.getLogoRevealProgress(testSize, 0.9);
        expect(revealProgress, equals(1.0));
      });
      
      test('should progress smoothly in middle range', () {
        final reveal40 = LogoPath.getLogoRevealProgress(testSize, 0.4);
        final reveal50 = LogoPath.getLogoRevealProgress(testSize, 0.5);
        final reveal60 = LogoPath.getLogoRevealProgress(testSize, 0.6);
        
        expect(reveal40, greaterThan(0.0));
        expect(reveal40, lessThan(1.0));
        expect(reveal50, greaterThan(reveal40));
        expect(reveal60, greaterThan(reveal50));
        expect(reveal60, lessThan(1.0));
      });
      
      test('should handle edge cases', () {
        expect(LogoPath.getLogoRevealProgress(testSize, 0.0), equals(0.0));
        expect(LogoPath.getLogoRevealProgress(testSize, 1.0), equals(1.0));
        expect(LogoPath.getLogoRevealProgress(testSize, 0.2), equals(0.0));
        expect(LogoPath.getLogoRevealProgress(testSize, 0.8), equals(1.0));
      });
    });
  });
}