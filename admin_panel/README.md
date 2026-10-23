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

5. **Admin 05 – Deliveries & Pickups (Orders) Screen** ([lib/admin_panel/screens/admin_orders_screen.dart](file:///c:/Users/MARKOSE/OneDrive/Desktop/College/SEM-3/seat%20and%20set/lib/admin_panel/screens/admin_orders_screen.dart))
   - Header: "Deliveries & Pickups"
   - Interactive segmented pill tabs: "Today", "Upcoming", "Completed" with smooth animated transitions
   - Order & Delivery Cards matching Figma Admin 05 design:
     - Delivery cards with lavender background badges and shipping truck icons
     - Pickup cards with peach background badges and storefront/warehouse icons
     - Recipient & source information ("To: Rahul Sharma", "From: Priya Mehta", etc.)
     - Scheduled time display with clock icon
     - Outlined "Navigate" action buttons opening live modal sheet with directions, GPS routing, and customer calling
     - 3-dots popup menu per order item (View Details, Directions, Call Customer, Status updates)
   - Order Model & Data: [lib/admin_panel/models/order_delivery_item.dart](file:///c:/Users/MARKOSE/OneDrive/Desktop/College/SEM-3/seat%20and%20set/lib/admin_panel/models/order_delivery_item.dart)
   - Bottom navigation integration with "Orders" tab active, seamlessly wired to Dashboard and Inventory

6. **Admin 06 – Customers Screen** ([lib/admin_panel/screens/admin_customers_screen.dart](file:///c:/Users/MARKOSE/OneDrive/Desktop/College/SEM-3/seat%20and%20set/lib/admin_panel/screens/admin_customers_screen.dart))
   - Header: "Customers" matching Figma mockup
   - Real-time search bar ("Search customers...") with instant name, phone number, and initials filtering
   - Customer cards matching Figma Admin 06 design:
     - Soft lavender circular avatar with purple uppercase initials (`RS`, `PM`, `AS`, `NK`, `VR`, etc.)
     - Customer name in bold typography
     - Phone number (`+91 98765 43210`, etc.)
     - Active rental status label (`12 active rentals`, `3 active rentals`, `1 active rental`, `2 active rentals`, `No active rentals`)
     - 3-dots popup menu (`...`) per customer (View Profile, Call Customer, Message, View Rentals)
   - Interactive Customer Profile modal bottom sheet with contact actions ("Call", "Message"), email, delivery address, membership details, and active rental breakdown
   - Customer Model & Mock Data: [lib/admin_panel/models/customer_item.dart](file:///c:/Users/MARKOSE/OneDrive/Desktop/College/SEM-3/seat%20and%20set/lib/admin_panel/models/customer_item.dart)
   - Bottom navigation bar with "Customers" tab active, fully interconnected with Dashboard, Inventory, and Orders

7. **Admin 07 – Reports Screen** ([lib/admin_panel/screens/admin_reports_screen.dart](file:///c:/Users/MARKOSE/OneDrive/Desktop/College/SEM-3/seat%20and%20set/lib/admin_panel/screens/admin_reports_screen.dart))
   - Header: "Reports" with interactive timeframe selector ("This Month", "This Week", "This Quarter", "This Year")
   - Metric 1: **Total Revenue** card (`₹1,24,800` with `+12%` green badge)
   - Metric 2: **Total Rentals** card (`86` with `+8%` green badge)
   - **Rentals Trend** Bar Chart:
     - Y-axis markers (`60`, `40`, `20`, `0`) with subtle horizontal grid lines
     - Rounded vertical bars with alternating primary purple (`#5D5FEF`) and soft lavender (`#B5B7FB`)
     - X-axis day markers (`01`, `05`, `10`, `15`, `20`, `25`, `30`)
     - Interactive tap selection showing tooltip with exact day and rental count
   - **Top Categories** Section:
     - Category cards with lavender icon badges (`#EEF0FE`) and icons for Sofas, Tables, Chairs, and Beds
     - Smooth horizontal progress bars in deep purple (`#5D5FEF`) over grey background tracks (`#F3F4FB`)
     - Volume counts: Sofas (32), Tables (24), Chairs (18), Beds (12)
   - Reports Model & Mock Data: [lib/admin_panel/models/reports_data.dart](file:///c:/Users/MARKOSE/OneDrive/Desktop/College/SEM-3/seat%20and%20set/lib/admin_panel/models/reports_data.dart)
   - Bottom navigation bar with "Reports" (tab index 4) active, interconnected with Dashboard, Inventory, Orders, and Customers

8. **Admin Shell & Performance Optimizations** ([lib/admin_panel/screens/admin_shell_screen.dart](file:///c:/Users/MARKOSE/OneDrive/Desktop/College/SEM-3/seat%20and%20set/lib/admin_panel/screens/admin_shell_screen.dart))
   - **State-Preserving IndexedStack**: Holds all 5 admin sections (Dashboard, Inventory, Orders, Customers, Reports) in memory without tearing down widgets on tab switch, instantly preserving scroll positions, filter chips, and search text.
   - **Render & Canvas Optimizations**:
     - `RepaintBoundary` wrappers on `FurnitureThumbnail`, `AdminLogo`, and the Reports bar chart.
     - Static `Paint` instance reuse in `_FurniturePainter` and `_AdminLogoPainter`, eliminating frame-by-frame GC allocations during scrolling.
     - Proper `shouldRepaint` checks on CustomPainters.
   - **Virtualization & Slivers**:
     - `AdminInventoryScreen` converted to `CustomScrollView` with lazy `SliverList.builder`, creating cards on-demand for fluid 60+ FPS scrolling.
   - **O(1) Search Query Normalization**:
     - `matchesQuery()` helpers on `CustomerItem` and `InventoryItem` preventing redundant allocations during text input.
   - **Resilient Firestore Architecture**:
     - `InventoryService` safely handles uninitialized or offline environments without crashing.

10. **UI/UX Animations & Tactile Micro-Interactions** ([lib/admin_panel/widgets/admin_animations.dart](file:///c:/Users/MARKOSE/OneDrive/Desktop/College/SEM-3/seat%20and%20set/lib/admin_panel/widgets/admin_animations.dart))
   - **Tactile Spring Physics (`BouncingScaleTap`)**: All interactive cards (KPI cards, delivery items, customers, inventory items), buttons, filter pills, and bottom navigation tabs subtly scale down to `0.92-0.98` with cubic spring physics and haptic vibration on tap.
   - **Live Pulsing Glow Badge (`PulsingGlowBadge`)**: Real-time breathing pulse animation on active statuses ("No delays today", new notification indicators).
   - **Animated Metric Counters (`AnimatedCounter`)**: Smooth count-up number interpolation on dashboard KPI metrics and deliveries.
   - **Staggered Entry Cascades (`StaggeredSlideFade`)**: Smooth 40ms-staggered slide-up and fade-in entrances for lists, cards, and activity feeds.
   - **Animated Shell Navigation**: Bottom navigation tabs feature morphing container pills, active scale pops, and color interpolation.

11. **Backend Services & Theme**
   - **Authentication & Firestore**: [lib/admin_panel/services/admin_auth_service.dart](file:///c:/Users/MARKOSE/OneDrive/Desktop/College/SEM-3/seat%20and%20set/lib/admin_panel/services/admin_auth_service.dart) (Firebase Auth + writes admin records to Firestore `admins/{uid}`)
   - **Theme & Colors**: [lib/admin_panel/theme/admin_colors.dart](file:///c:/Users/MARKOSE/OneDrive/Desktop/College/SEM-3/seat%20and%20set/lib/admin_panel/theme/admin_colors.dart) (Dark indigo gradients, glowing purple buttons)
   - **Reusable Widgets**: [lib/admin_panel/widgets/admin_text_field.dart](file:///c:/Users/MARKOSE/OneDrive/Desktop/College/SEM-3/seat%20and%20set/lib/admin_panel/widgets/admin_text_field.dart), [lib/admin_panel/widgets/admin_button.dart](file:///c:/Users/MARKOSE/OneDrive/Desktop/College/SEM-3/seat%20and%20set/lib/admin_panel/widgets/admin_button.dart), [lib/admin_panel/widgets/admin_logo.dart](file:///c:/Users/MARKOSE/OneDrive/Desktop/College/SEM-3/seat%20and%20set/lib/admin_panel/widgets/admin_logo.dart)

### How to Run
```powershell
flutter run -d emulator-5554
# or for Chrome
flutter run -d chrome
```
