import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

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

// ── Rently Brand Colors ───────────────────────────────────────────────────────
class _R {
  static const navy      = Color(0xFF1B2A6B);
  static const green     = Color(0xFF2EB85C);
  static const greenLight= Color(0xFFE8F8EE);
  static const textSub   = Color(0xFFADB5C7);
}

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

  static const String home             = '/home';
  static const String map              = '/map';
  static const String bookings         = '/bookings';
  static const String saved            = '/saved';
  static const String account          = '/account';
  static const String login            = '/login';
  static const String register         = '/register';
  static const String verification     = '/verification';
  static const String propertyDetail   = '/property/:id';
  static const String post             = '/post';
  static const String postingForm      = '/posting-form';
  static const String landlordDashboard= '/landlord-dashboard';
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
      case 0: context.go(AppRoutes.home);     break;
      case 1: context.go(AppRoutes.saved);    break;
      case 2: context.go(AppRoutes.post);     break;
      case 3: context.go(AppRoutes.bookings); break;
      case 4: context.go(AppRoutes.account);  break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentIdx = _currentIndex;

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: _R.navy.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, -3),
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
                  icon: currentIdx == 0
                      ? Icons.home_rounded
                      : Icons.home_outlined,
                  label: 'Home',
                  isSelected: currentIdx == 0,
                  onTap: () => _onItemTapped(context, 0),
                ),
                _NavItem(
                  icon: currentIdx == 1
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                  label: 'Saved',
                  isSelected: currentIdx == 1,
                  onTap: () => _onItemTapped(context, 1),
                ),
                // ── Centre FAB-style Post button ─────────────────
                _PostNavItem(
                  isSelected: currentIdx == 2,
                  onTap: () => _onItemTapped(context, 2),
                ),
                _NavItem(
                  icon: currentIdx == 3
                      ? Icons.calendar_month_rounded
                      : Icons.calendar_today_rounded,
                  label: 'Booking',
                  isSelected: currentIdx == 3,
                  onTap: () => _onItemTapped(context, 3),
                ),
                _NavItem(
                  icon: currentIdx == 4
                      ? Icons.person_rounded
                      : Icons.person_outline_rounded,
                  label: 'Account',
                  isSelected: currentIdx == 4,
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

// ── Regular Nav Item ──────────────────────────────────────────────────────────
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          // Green pill background when selected
          color: isSelected ? _R.greenLight : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected ? _R.green : _R.textSub,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight:
                    isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? _R.green : _R.textSub,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Centre Post Button (FAB style) ────────────────────────────────────────────
class _PostNavItem extends StatelessWidget {
  final bool isSelected;
  final VoidCallback onTap;

  const _PostNavItem({
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
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: isSelected
                  ? const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [_R.green, Color(0xFF1E9448)],
                    )
                  : const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [_R.navy, Color(0xFF243580)],
                    ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: (isSelected ? _R.green : _R.navy)
                      .withOpacity(0.35),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.add_rounded,
                color: Colors.white, size: 26),
          ),
          const SizedBox(height: 3),
          Text(
            'Post',
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight:
                  isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? _R.green : _R.textSub,
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
    if (isLoggedIn && isGoingToAuth)   return AppRoutes.home;
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
          builder: (context, state) {
            final property = state.extra as PropertyModel?;
            return BookingScreen(property: property);
          },
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
            SnackBar(
              content: Text(
                'Identity verification submitted successfully!',
                style: GoogleFonts.poppins(fontSize: 13),
              ),
              backgroundColor: _R.navy,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
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
          Icon(Icons.error_outline, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Page not found',
            style: GoogleFonts.poppins(
                color: Colors.grey, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            '${state.error}',
            style: GoogleFonts.poppins(
                color: Colors.grey[400], fontSize: 12),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => context.go(AppRoutes.home),
            style: ElevatedButton.styleFrom(
              backgroundColor: _R.green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(
                  horizontal: 24, vertical: 12),
            ),
            child: Text('Go Home',
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    ),
  ),
);