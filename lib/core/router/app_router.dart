import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

// --- AUTH VIEWS ---
import '../../features/auth/views/login_screen.dart';
import '../../features/auth/views/register_screen.dart';

// --- PROPERTIES VIEWS ---
import '../../features/properties/views/home_screen.dart';
import '../../features/properties/views/property_detail_screen.dart';
import '../../features/properties/data/models/property_model.dart';

// --- POST PROPERTY VIEWS ---
import '../../features/properties/views/post_property/post_screen.dart';
import '../../features/properties/views/post_property/posting_form.dart';
import '../../features/properties/views/post_property/verification_step.dart';

// --- OTHER FEATURE VIEWS ---
import '../../features/map/views/map_screen.dart';
import '../../features/bookings/views/booking_screen.dart';
import '../../features/saved/views/saved_screen.dart';
import '../../features/account/views/account_screen.dart';
import '../../features/landlord/views/landlord_dashboard_screen.dart';

// ── GoRouter Auth Refresh ─────────────────────────────────────────────────────

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription =
        stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

// ── Route Names ───────────────────────────────────────────────────────────────

class AppRoutes {
  AppRoutes._();

  static const String home = '/home';
  static const String map = '/map';
  static const String bookings = '/bookings';
  static const String saved = '/saved';
  static const String account = '/account';
  static const String login = '/login';
  static const String register = '/register';
  static const String verification = '/verification';

  // ✅ Uses /property/:id  — pass PropertyModel via extra
  static const String propertyDetail = '/property/:id';

  static const String post = '/post';
  static const String postingForm = '/posting-form';
  static const String landlordDashboard = '/landlord-dashboard';
}

// ── Bottom Nav Shell ──────────────────────────────────────────────────────────

class MainShell extends StatelessWidget {
  final Widget child;
  final GoRouterState state;

  const MainShell({super.key, required this.child, required this.state});

  int get _currentIndex {
    final path = state.uri.path;
    if (path.startsWith(AppRoutes.home) || path == '/') return 0;
    if (path.startsWith(AppRoutes.saved)) return 1;
    if (path.startsWith(AppRoutes.post) ||
        path.startsWith(AppRoutes.postingForm)) return 2;
    if (path.startsWith(AppRoutes.bookings)) return 3;
    if (path.startsWith(AppRoutes.account)) return 4;
    return 0;
  }

  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(AppRoutes.home);
      case 1:
        context.go(AppRoutes.saved);
      case 2:
        context.go(AppRoutes.post);
      case 3:
        context.go(AppRoutes.bookings);
      case 4:
        context.go(AppRoutes.account);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: Icons.home_rounded,
                  label: 'Home',
                  isSelected: _currentIndex == 0,
                  onTap: () => _onItemTapped(context, 0),
                ),
                _NavItem(
                  icon: Icons.bookmark_border_rounded,
                  label: 'Saved',
                  isSelected: _currentIndex == 1,
                  onTap: () => _onItemTapped(context, 1),
                ),
                _NavItem(
                  icon: Icons.add_circle,
                  label: 'Post',
                  isSelected: _currentIndex == 2,
                  onTap: () => _onItemTapped(context, 2),
                ),
                _NavItem(
                  icon: Icons.calendar_today_rounded,
                  label: 'Booking',
                  isSelected: _currentIndex == 3,
                  onTap: () => _onItemTapped(context, 3),
                ),
                _NavItem(
                  icon: Icons.person_outline_rounded,
                  label: 'Account',
                  isSelected: _currentIndex == 4,
                  onTap: () => _onItemTapped(context, 4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 26,
            color: isSelected ? Colors.black87 : Colors.grey[600],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected ? Colors.black87 : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Router Config ─────────────────────────────────────────────────────────────

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.home,
  debugLogDiagnostics: true,
  refreshListenable:
      GoRouterRefreshStream(FirebaseAuth.instance.authStateChanges()),
  redirect: (BuildContext context, GoRouterState state) {
    final bool isLoggedIn = FirebaseAuth.instance.currentUser != null;
    final bool isGoingToAuth =
        state.matchedLocation == AppRoutes.login ||
            state.matchedLocation == AppRoutes.register;

    if (!isLoggedIn && !isGoingToAuth) return AppRoutes.login;
    if (isLoggedIn && isGoingToAuth) return AppRoutes.home;
    return null;
  },
  routes: [
    // ── MAIN APP (With Bottom Nav Bar) ──────────────────────────────────────
    ShellRoute(
      builder: (context, state, child) =>
          MainShell(state: state, child: child),
      routes: [
        GoRoute(
          path: AppRoutes.home,
          name: 'home',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: AppRoutes.map,
          name: 'map',
          builder: (context, state) => const MapScreen(),
        ),
        GoRoute(
          path: AppRoutes.bookings,
          name: 'bookings',
          builder: (context, state) => const BookingScreen(),
        ),
        GoRoute(
          path: AppRoutes.saved,
          name: 'saved',
          builder: (context, state) => const SavedScreen(),
        ),
        GoRoute(
          path: AppRoutes.account,
          name: 'account',
          builder: (context, state) => const AccountScreen(),
        ),
        GoRoute(
          path: AppRoutes.post,
          name: 'post',
          builder: (context, state) => const PostScreen(),
        ),

        // ✅ FIXED: PostingFormScreen wraps PostingForm with its ChangeNotifierProvider
        GoRoute(
          path: AppRoutes.postingForm,
          name: 'postingForm',
          builder: (context, state) => const PostingFormScreen(),
        ),
      ],
    ),

    // ── FULL SCREEN ROUTES (No Bottom Nav) ──────────────────────────────────
    GoRoute(
      path: AppRoutes.login,
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: AppRoutes.register,
      name: 'register',
      builder: (context, state) => const RegisterScreen(),
    ),

    // ✅ PropertyModel is passed via state.extra
    GoRoute(
      path: AppRoutes.propertyDetail,
      name: 'propertyDetail',
      builder: (context, state) {
        final property = state.extra as PropertyModel;
        return PropertyDetailScreen(property: property);
      },
    ),

    GoRoute(
      path: AppRoutes.landlordDashboard,
      name: 'landlordDashboard',
      builder: (context, state) => const LandlordDashboardScreen(),
    ),

    GoRoute(
      path: AppRoutes.verification,
      name: 'verification',
      builder: (context, state) => IdentityVerificationFlow(
        onVerified: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go(AppRoutes.account);
          }
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Identity verification submitted successfully!'),
            ),
          );
        },
      ),
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'Page not found: ${state.error}',
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.go(AppRoutes.home),
            child: const Text('Go Home'),
          ),
        ],
      ),
    ),
  ),
);