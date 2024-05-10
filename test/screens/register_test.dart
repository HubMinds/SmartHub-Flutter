import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:smarthub_flutter/screens/register.dart';
import 'package:smarthub_flutter/screens/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mockito/mockito.dart';

class FirebaseAuthMock extends Mock implements FirebaseAuth {
  @override
  Future<UserCredential> createUserWithEmailAndPassword(
      {required String email, required String password}) {
    throw FirebaseAuthException(
        code: 'weak-password', message: 'The password is too weak.');
  }
}

void main() {
  group('RegisterScreen Tests', () {
    late MockFirebaseAuth mockAuth;

    setUp(() {
      mockAuth = MockFirebaseAuth(signedIn: false);
    });

    testWidgets('Successful registration navigates to home screen',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: RegisterScreen(auth: mockAuth),
      ));

      await tester.enterText(
          find.widgetWithText(TextFormField, 'Email'), 'test@example.com');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Password'), 'password123');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Confirm Password'),
          'password123');
      await tester.tap(
          find.widgetWithText(ElevatedButton, 'Register')); // Corrected line
      await tester.pumpAndSettle();

      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('Displays error on weak password', (WidgetTester tester) async {
      // Create a new mock for wrong authentication
      final wrongAuth = FirebaseAuthMock();

      await tester.pumpWidget(MaterialApp(
        home: RegisterScreen(auth: wrongAuth),
      ));

      await tester.enterText(
          find.widgetWithText(TextFormField, 'Email'), 'wrong@example.com');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Password'), 'weakPassword');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Confirm Password'),
          'weakPassword');
      await tester.tap(
          find.widgetWithText(ElevatedButton, 'Register')); // Corrected line
      await tester.pump(); // Trigger a frame
      await tester.pumpAndSettle(); // Wait for all animations and state updates

      // Check for error messages
      expect(
          find.text('Password must be at least 6 characters'), findsOneWidget);
    });
  });
}
