import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smarthub_flutter/screens/login_screen.dart';

class MockAuth extends Mock implements FirebaseAuth {}

class MockUserCredential extends Mock implements UserCredential {
  @override
  User user = MockUser();
}

class MockUser extends Mock implements User {
  @override
  String get uid => 'some-uid'; // Ensuring non-null return
}

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

String anyNonNullString({String defaultValue = ''}) => defaultValue;

void main() {
  late MockAuth mockAuth;
  late MockNavigatorObserver mockNavigatorObserver;

  setUp(() {
    mockAuth = MockAuth();
    mockNavigatorObserver = MockNavigatorObserver();

    when(mockAuth.signInWithEmailAndPassword(
            email: anyNonNullString(defaultValue: 'test@example.com'),
            password: anyNonNullString(defaultValue: 'password')))
        .thenAnswer((_) async => MockUserCredential());

    when(mockAuth.signInWithEmailAndPassword(
            email: anyNonNullString(defaultValue: 'empty@example.com'),
            password: anyNonNullString(defaultValue: '')))
        .thenReturn(
            Future.error(FirebaseAuthException(code: 'user-not-found')));
  });

  Widget makeTestableWidget({required Widget child}) {
    return MaterialApp(
      home: child,
      navigatorObservers: [mockNavigatorObserver],
    );
  }

  testWidgets('Empty email and password does not call signIn',
      (WidgetTester tester) async {
    await tester
        .pumpWidget(makeTestableWidget(child: LoginScreen(auth: mockAuth)));
    await tester.tap(find.byType(ElevatedButton).first);
    await tester.pump();

    verifyNever(mockAuth.signInWithEmailAndPassword(
        email: anyNonNullString(defaultValue: 'empty@example.com'),
        password: anyNonNullString(defaultValue: '')));
  });

  testWidgets('Non-empty email and password calls signIn',
      (WidgetTester tester) async {
    await tester
        .pumpWidget(makeTestableWidget(child: LoginScreen(auth: mockAuth)));
    await tester.enterText(
        find.byType(TextFormField).first, 'test@example.com');
    await tester.enterText(find.byType(TextFormField).at(1), 'password');
    await tester.tap(find.byType(ElevatedButton).first);
    await tester.pump();

    verify(mockAuth.signInWithEmailAndPassword(
            email: anyNonNullString(defaultValue: 'test@example.com'),
            password: anyNonNullString(defaultValue: 'password')))
        .called(1);
  });
}
