import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:seat_and_set/models/furniture.dart';
import 'package:seat_and_set/screens/home_screen.dart';
import 'package:seat_and_set/screens/orders_screen.dart';
import 'package:seat_and_set/screens/product_details_screen.dart';
import 'package:seat_and_set/screens/sign_in_screen.dart';
import 'package:seat_and_set/screens/sign_up_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Customer App Widget Tests', () {
    testWidgets('Sign In screen renders correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SignInScreen(),
        ),
      );

      expect(find.text('Welcome Back'), findsOneWidget);
      expect(find.text('Email or Phone'), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);
    });

    testWidgets('Sign Up screen renders correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SignUpScreen(),
        ),
      );

      expect(find.text('Create Account'), findsWidgets);
      expect(find.text('Full Name'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
    });

    testWidgets('Home screen displays live furniture catalog', (tester) async {
      final firestore = FakeFirebaseFirestore();
      await firestore.collection('furniture').doc('sofa-1').set({
        'name': 'Luxury Velvet Sofa',
        'sku': 'SOFA100',
        'status': 'available',
        'type': 'sofa',
        'createdAt': DateTime.now(),
        'updatedAt': DateTime.now(),
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.text('Search furniture (e.g. sofa, bed...)'), findsOneWidget);
    });

    testWidgets('Product Details screen displays furniture details', (tester) async {
      const item = Furniture(
        id: 'sofa-1',
        name: 'Luxury Velvet Sofa',
        category: 'Sofas',
        price: '₹999/mo',
        imageAsset: 'assets/images/home_product_sofa_clean.png',
        description: 'A luxurious velvet sofa.',
        rating: 4.8,
        reviewCount: 45,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: ProductDetailsScreen(item: item),
        ),
      );

      expect(find.text('Luxury Velvet Sofa'), findsOneWidget);
      expect(find.textContaining('999'), findsWidgets);
      expect(find.text('Add to Cart'), findsOneWidget);
    });

    testWidgets('My Rentals screen renders empty state when no bookings', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: OrdersScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('My Rentals'), findsOneWidget);
      expect(find.text('No rentals yet'), findsOneWidget);
    });
  });
}
