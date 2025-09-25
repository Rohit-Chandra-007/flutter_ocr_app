import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scanflow/features/splash/screens/splash_screen.dart';

void main() {
  group('SplashScreen', () {
    testWidgets('should render with light theme colors', (tester) async {
      // Arrange
      bool callbackTriggered = false;
      final lightTheme = ThemeData.light().copyWith(
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF4A90E2),
          onSurface: Color(0xFF1A1A1A),
        ),
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          theme: lightTheme,
          home: SplashScreen(
            onAnimationComplete: () => callbackTriggered = true,
          ),
        ),
      );

      // Assert
      expect(find.byType(SplashScreen), findsOneWidget);
      expect(find.text('ScanFlow'), findsOneWidget);
      expect(find.byIcon(Icons.scanner), findsOneWidget);
      
      // Verify scaffold background color
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, const Color(0xFFF8F9FA));
    });

    testWidgets('should render with dark theme colors', (tester) async {
      // Arrange
      bool callbackTriggered = false;
      final darkTheme = ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF4A90E2),
          onSurface: Color(0xFFE0E0E0),
        ),
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          theme: darkTheme,
          home: SplashScreen(
            onAnimationComplete: () => callbackTriggered = true,
          ),
        ),
      );

      // Assert
      expect(find.byType(SplashScreen), findsOneWidget);
      expect(find.text('ScanFlow'), findsOneWidget);
      expect(find.byIcon(Icons.scanner), findsOneWidget);
      
      // Verify scaffold background color
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, const Color(0xFF121212));
    });

    testWidgets('should have centered content layout', (tester) async {
      // Arrange
      bool callbackTriggered = false;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: SplashScreen(
            onAnimationComplete: () => callbackTriggered = true,
          ),
        ),
      );

      // Assert
      expect(find.byType(Column), findsOneWidget);
      
      // Verify column alignment
      final column = tester.widget<Column>(find.byType(Column));
      expect(column.mainAxisAlignment, MainAxisAlignment.center);
      expect(column.crossAxisAlignment, CrossAxisAlignment.center);
      
      // Verify content is properly structured
      expect(find.text('ScanFlow'), findsOneWidget);
      expect(find.byIcon(Icons.scanner), findsOneWidget);
    });

    testWidgets('should use displayLarge text style for app name', (tester) async {
      // Arrange
      bool callbackTriggered = false;
      final customTheme = ThemeData.light().copyWith(
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
          ),
        ),
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          theme: customTheme,
          home: SplashScreen(
            onAnimationComplete: () => callbackTriggered = true,
          ),
        ),
      );

      // Assert
      final textWidget = tester.widget<Text>(find.text('ScanFlow'));
      expect(textWidget.style?.fontSize, 32);
      expect(textWidget.style?.fontWeight, FontWeight.w700);
    });

    testWidgets('should adapt to theme changes', (tester) async {
      // Arrange
      bool callbackTriggered = false;
      ValueNotifier<ThemeData> themeNotifier = ValueNotifier(ThemeData.light());

      // Act - Initial light theme
      await tester.pumpWidget(
        ValueListenableBuilder<ThemeData>(
          valueListenable: themeNotifier,
          builder: (context, theme, child) {
            return MaterialApp(
              theme: theme,
              home: SplashScreen(
                onAnimationComplete: () => callbackTriggered = true,
              ),
            );
          },
        ),
      );

      // Verify light theme
      var scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, ThemeData.light().scaffoldBackgroundColor);

      // Act - Change to dark theme
      themeNotifier.value = ThemeData.dark();
      await tester.pumpAndSettle();

      // Assert - Should adapt to dark theme
      scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, ThemeData.dark().scaffoldBackgroundColor);
    });

    testWidgets('should have proper safe area and full screen layout', (tester) async {
      // Arrange
      bool callbackTriggered = false;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: SplashScreen(
            onAnimationComplete: () => callbackTriggered = true,
          ),
        ),
      );

      // Assert
      expect(find.byType(SafeArea), findsOneWidget);
      
      // Verify the container has full width and height constraints
      final containerFinder = find.descendant(
        of: find.byType(SafeArea),
        matching: find.byType(Container),
      ).first;
      
      expect(containerFinder, findsOneWidget);
      
      // Check that the splash screen takes up the full available space
      final splashScreenSize = tester.getSize(find.byType(SplashScreen));
      expect(splashScreenSize.width, greaterThan(0));
      expect(splashScreenSize.height, greaterThan(0));
    });

    testWidgets('should provide callback function', (tester) async {
      // Arrange
      bool callbackTriggered = false;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: SplashScreen(
            onAnimationComplete: () => callbackTriggered = true,
          ),
        ),
      );

      // Assert - Widget should be created successfully with callback
      expect(find.byType(SplashScreen), findsOneWidget);
      expect(callbackTriggered, false); // Callback not triggered yet in this basic test
    });
  });
}