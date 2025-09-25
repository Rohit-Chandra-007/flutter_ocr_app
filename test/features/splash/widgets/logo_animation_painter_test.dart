import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scanflow/features/splash/widgets/logo_animation_painter.dart';

void main() {
  group('LogoAnimationPainter', () {
    const testSize = Size(200, 300);
    const logoColor = Colors.blue;
    const glowColor = Colors.lightBlue;
    
    group('constructor and properties', () {
      test('should create painter with required properties', () {
        const painter = LogoAnimationPainter(
          revealProgress: 0.5,
          logoColor: logoColor,
          glowColor: glowColor,
        );
        
        expect(painter.revealProgress, equals(0.5));
        expect(painter.logoColor, equals(logoColor));
        expect(painter.glowColor, equals(glowColor));
        expect(painter.glowIntensity, equals(0.3)); // default value
        expect(painter.strokeWidth, equals(4.0)); // default value
        expect(painter.showGlow, isTrue); // default value
      });
      
      test('should create painter with custom properties', () {
        const painter = LogoAnimationPainter(
          revealProgress: 0.8,
          logoColor: logoColor,
          glowColor: glowColor,
          glowIntensity: 0.5,
          strokeWidth: 6.0,
          showGlow: false,
        );
        
        expect(painter.revealProgress, equals(0.8));
        expect(painter.glowIntensity, equals(0.5));
        expect(painter.strokeWidth, equals(6.0));
        expect(painter.showGlow, isFalse);
      });
    });
    
    group('shouldRepaint', () {
      test('should repaint when reveal progress changes', () {
        const painter1 = LogoAnimationPainter(
          revealProgress: 0.3,
          logoColor: logoColor,
          glowColor: glowColor,
        );
        
        const painter2 = LogoAnimationPainter(
          revealProgress: 0.7,
          logoColor: logoColor,
          glowColor: glowColor,
        );
        
        expect(painter1.shouldRepaint(painter2), isTrue);
      });
      
      test('should repaint when colors change', () {
        const painter1 = LogoAnimationPainter(
          revealProgress: 0.5,
          logoColor: Colors.blue,
          glowColor: Colors.lightBlue,
        );
        
        const painter2 = LogoAnimationPainter(
          revealProgress: 0.5,
          logoColor: Colors.red,
          glowColor: Colors.lightBlue,
        );
        
        expect(painter1.shouldRepaint(painter2), isTrue);
      });
      
      test('should repaint when glow properties change', () {
        const painter1 = LogoAnimationPainter(
          revealProgress: 0.5,
          logoColor: logoColor,
          glowColor: glowColor,
          glowIntensity: 0.3,
        );
        
        const painter2 = LogoAnimationPainter(
          revealProgress: 0.5,
          logoColor: logoColor,
          glowColor: glowColor,
          glowIntensity: 0.5,
        );
        
        expect(painter1.shouldRepaint(painter2), isTrue);
      });
      
      test('should not repaint when properties are identical', () {
        const painter1 = LogoAnimationPainter(
          revealProgress: 0.5,
          logoColor: logoColor,
          glowColor: glowColor,
          glowIntensity: 0.3,
          strokeWidth: 4.0,
          showGlow: true,
        );
        
        const painter2 = LogoAnimationPainter(
          revealProgress: 0.5,
          logoColor: logoColor,
          glowColor: glowColor,
          glowIntensity: 0.3,
          strokeWidth: 4.0,
          showGlow: true,
        );
        
        expect(painter1.shouldRepaint(painter2), isFalse);
      });
    });
    
    group('getLogoBounds', () {
      test('should return valid bounds', () {
        const painter = LogoAnimationPainter(
          revealProgress: 0.5,
          logoColor: logoColor,
          glowColor: glowColor,
        );
        
        final bounds = painter.getLogoBounds(testSize);
        
        expect(bounds.isEmpty, isFalse);
        expect(bounds.width, greaterThan(0));
        expect(bounds.height, greaterThan(0));
      });
    });
    
    group('paint method behavior', () {
      late Canvas canvas;
      late ui.PictureRecorder recorder;
      
      setUp(() {
        recorder = ui.PictureRecorder();
        canvas = Canvas(recorder);
      });
      
      test('should not paint when reveal progress is 0', () {
        const painter = LogoAnimationPainter(
          revealProgress: 0.0,
          logoColor: logoColor,
          glowColor: glowColor,
        );
        
        // This should not throw and should complete quickly
        expect(() => painter.paint(canvas, testSize), returnsNormally);
      });
      
      test('should paint when reveal progress is greater than 0', () {
        const painter = LogoAnimationPainter(
          revealProgress: 0.5,
          logoColor: logoColor,
          glowColor: glowColor,
        );
        
        // This should not throw
        expect(() => painter.paint(canvas, testSize), returnsNormally);
      });
    });
  });
  
  group('ScannerLinePainter', () {
    const testSize = Size(200, 300);
    const scannerColor = Colors.cyan;
    const glowColor = Colors.lightBlue;
    
    group('constructor and properties', () {
      test('should create painter with required properties', () {
        const painter = ScannerLinePainter(
          progress: 0.5,
          scannerColor: scannerColor,
          glowColor: glowColor,
        );
        
        expect(painter.progress, equals(0.5));
        expect(painter.scannerColor, equals(scannerColor));
        expect(painter.glowColor, equals(glowColor));
        expect(painter.glowIntensity, equals(0.5)); // default value
        expect(painter.lineHeight, equals(2.0)); // default value
      });
      
      test('should create painter with custom properties', () {
        const painter = ScannerLinePainter(
          progress: 0.8,
          scannerColor: scannerColor,
          glowColor: glowColor,
          glowIntensity: 0.7,
          lineHeight: 3.0,
        );
        
        expect(painter.progress, equals(0.8));
        expect(painter.glowIntensity, equals(0.7));
        expect(painter.lineHeight, equals(3.0));
      });
    });
    
    group('shouldRepaint', () {
      test('should repaint when progress changes', () {
        const painter1 = ScannerLinePainter(
          progress: 0.3,
          scannerColor: scannerColor,
          glowColor: glowColor,
        );
        
        const painter2 = ScannerLinePainter(
          progress: 0.7,
          scannerColor: scannerColor,
          glowColor: glowColor,
        );
        
        expect(painter1.shouldRepaint(painter2), isTrue);
      });
      
      test('should repaint when colors change', () {
        const painter1 = ScannerLinePainter(
          progress: 0.5,
          scannerColor: Colors.cyan,
          glowColor: glowColor,
        );
        
        const painter2 = ScannerLinePainter(
          progress: 0.5,
          scannerColor: Colors.red,
          glowColor: glowColor,
        );
        
        expect(painter1.shouldRepaint(painter2), isTrue);
      });
      
      test('should not repaint when properties are identical', () {
        const painter1 = ScannerLinePainter(
          progress: 0.5,
          scannerColor: scannerColor,
          glowColor: glowColor,
          glowIntensity: 0.5,
          lineHeight: 2.0,
        );
        
        const painter2 = ScannerLinePainter(
          progress: 0.5,
          scannerColor: scannerColor,
          glowColor: glowColor,
          glowIntensity: 0.5,
          lineHeight: 2.0,
        );
        
        expect(painter1.shouldRepaint(painter2), isFalse);
      });
    });
    
    group('paint method behavior', () {
      late Canvas canvas;
      late ui.PictureRecorder recorder;
      
      setUp(() {
        recorder = ui.PictureRecorder();
        canvas = Canvas(recorder);
      });
      
      test('should not paint when progress is 0', () {
        const painter = ScannerLinePainter(
          progress: 0.0,
          scannerColor: scannerColor,
          glowColor: glowColor,
        );
        
        // This should not throw and should complete quickly
        expect(() => painter.paint(canvas, testSize), returnsNormally);
      });
      
      test('should paint when progress is greater than 0', () {
        const painter = ScannerLinePainter(
          progress: 0.5,
          scannerColor: scannerColor,
          glowColor: glowColor,
        );
        
        // This should not throw
        expect(() => painter.paint(canvas, testSize), returnsNormally);
      });
      
      test('should handle edge cases', () {
        const painter1 = ScannerLinePainter(
          progress: 1.0,
          scannerColor: scannerColor,
          glowColor: glowColor,
        );
        
        const painter2 = ScannerLinePainter(
          progress: -0.1,
          scannerColor: scannerColor,
          glowColor: glowColor,
        );
        
        expect(() => painter1.paint(canvas, testSize), returnsNormally);
        expect(() => painter2.paint(canvas, testSize), returnsNormally);
      });
    });
  });
}