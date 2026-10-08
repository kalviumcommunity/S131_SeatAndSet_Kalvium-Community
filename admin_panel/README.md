# Seat and Set • Admin Panel

This folder is dedicated to the **Admin Panel** for the **Seat & Set** system.

### Source Code Location
The Flutter mobile/cross-platform Admin screens and components are located in:
👉 [`../lib/admin_panel/`](file:///c:/Users/MARKOSE/OneDrive/Desktop/College/SEM-3/seat%20and%20set/lib/admin_panel/)

### Implemented Screens & Architecture

1. **Admin 01 – Login Screen** ([lib/admin_panel/screens/admin_login_screen.dart](file:///c:/Users/MARKOSE/OneDrive/Desktop/College/SEM-3/seat%20and%20set/lib/admin_panel/screens/admin_login_screen.dart))
   - Brand logo emblem with soft glow
   - Heading: "Seat and Set Admin • Operations at your fingertips"
   - Email input (pre-populated with `admin@seatandset.com` placeholder)
   - Password input with show/hide toggle
   - Glowing purple Login button
   - Forgot Password modal with reset email dispatch
   - Direct navigation to Sign Up

2. **Admin 02 – Sign Up Screen** ([lib/admin_panel/screens/admin_signup_screen.dart](file:///c:/Users/MARKOSE/OneDrive/Desktop/College/SEM-3/seat%20and%20set/lib/admin_panel/screens/admin_signup_screen.dart))
   - Header with back button and brand mark
   - Title: "Create Admin Account • Manage inventory, orders and deliveries."
   - Full Name field (`Irtaza Wani` placeholder)
   - Work Email field (`irtaza@seatandset.com` placeholder)
   - Admin Access Code validation field (default valid code: `SNS-ADM-2025`)
   - Password & Confirm Password with visibility toggles and matching validation
   - Security verification notice banner: *"Access code is shared by your organisation owner."*
   - Create Account button and quick switch back to Login

3. **Admin 03 – Dashboard Screen** ([lib/admin_panel/screens/admin_dashboard_screen.dart](file:///c:/Users/MARKOSE/OneDrive/Desktop/College/SEM-3/seat%20and%20set/lib/admin_panel/screens/admin_dashboard_screen.dart))
   - Header: "Dashboard • Mon, 15 Sep 2025" with notification bell badge & sign out menu
   - 4 KPI metric cards: **124** Total Items, **86** Rented, **28** Available, **10** In Transit
   - **Today** section: Deliveries (5) and Pickups (3) with *"No delays today"* green badge
   - **Recent Activity** list: Sofa delivered, Pickup scheduled, New booking
   - Floating Bottom Navigation Bar (Dashboard, Inventory, Orders, Customers, Reports)
   - Mock Data Model: [lib/admin_panel/models/dashboard_mock_data.dart](file:///c:/Users/MARKOSE/OneDrive/Desktop/College/SEM-3/seat%20and%20set/lib/admin_panel/models/dashboard_mock_data.dart) (ready for real API integration)

4. **Admin 04 – Inventory Screen** ([lib/admin_panel/screens/admin_inventory_screen.dart](file:///c:/Users/MARKOSE/OneDrive/Desktop/College/SEM-3/seat%20and%20set/lib/admin_panel/screens/admin_inventory_screen.dart))
   - Header: "Inventory" with purple circular notification bell and red indicator
   - Real-time search bar ("Search items...") with live SKU and name query filtering
   - Filter button with bottom sheet (All, Available, Rented, In Transit)
   - Custom vector furniture illustration thumbnails ([lib/admin_panel/widgets/furniture_thumbnail.dart](file:///c:/Users/MARKOSE/OneDrive/Desktop/College/SEM-3/seat%20and%20set/lib/admin_panel/widgets/furniture_thumbnail.dart)) for Sofa, Study Table, Office Chair, Bed, and Dining Table
   - Status badges: Rented (soft red), Available (soft green), In Transit (soft orange)
   - Action popup menu (`...`) per item (View Details, Edit Item, Change Status)
   - Seamless navigation connecting between Dashboard and Inventory tabs

5. **Backend Services & Theme**
   - **Authentication & Firestore**: [lib/admin_panel/services/admin_auth_service.dart](file:///c:/Users/MARKOSE/OneDrive/Desktop/College/SEM-3/seat%20and%20set/lib/admin_panel/services/admin_auth_service.dart) (Firebase Auth + writes admin records to Firestore `admins/{uid}`)
   - **Theme & Colors**: [lib/admin_panel/theme/admin_colors.dart](file:///c:/Users/MARKOSE/OneDrive/Desktop/College/SEM-3/seat%20and%20set/lib/admin_panel/theme/admin_colors.dart) (Dark indigo gradients, glowing purple buttons)
   - **Reusable Widgets**: [lib/admin_panel/widgets/admin_text_field.dart](file:///c:/Users/MARKOSE/OneDrive/Desktop/College/SEM-3/seat%20and%20set/lib/admin_panel/widgets/admin_text_field.dart), [lib/admin_panel/widgets/admin_button.dart](file:///c:/Users/MARKOSE/OneDrive/Desktop/College/SEM-3/seat%20and%20set/lib/admin_panel/widgets/admin_button.dart), [lib/admin_panel/widgets/admin_logo.dart](file:///c:/Users/MARKOSE/OneDrive/Desktop/College/SEM-3/seat%20and%20set/lib/admin_panel/widgets/admin_logo.dart)

### How to Run
```powershell
flutter run -d emulator-5554
# or for Chrome
flutter run -d chrome
```
