import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

// ── ViewModels ──────────────────────────────────────────────
import '../viewmodels/account_viewmodel.dart';
import '../../auth/viewmodels/auth_viewmodel.dart';

// ── Widgets ─────────────────────────────────────────────────
import 'widgets/account_list_tile.dart';
import 'widgets/profile_avatar.dart';

// ─── Rently Brand Colors ─────────────────────────────────────
class _R {
  static const navy       = Color(0xFF1B2A6B);
  static const green      = Color(0xFF2EB85C);
  static const greenDark  = Color(0xFF1E9448);
  static const greenLight = Color(0xFFE8F8EE);
  static const gold       = Color(0xFFE8A020);
  static const bg         = Color(0xFFF7F9FC);
  static const divider    = Color(0xFFE8EDF2);
  static const textMain   = Color(0xFF0D1B3E);
  static const textSub    = Color(0xFF6B7A99);
}

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AccountViewModel>().loadProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _R.bg,
      body: Consumer<AccountViewModel>(
        builder: (context, viewModel, _) {
          final String displayFirstName = viewModel.firstName.isNotEmpty
              ? viewModel.firstName
              : 'User';

          return Column(
            children: [
              // ─── Header ──────────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(
                    top: 60, left: 20, right: 20, bottom: 30),
                decoration: const BoxDecoration(
                  // Navy → Green gradient matching Rently logo
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [_R.navy, _R.green],
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft:  Radius.circular(28),
                    bottomRight: Radius.circular(28),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // ─── Left: Avatar & Text ───
                    Expanded(
                      child: Row(
                        children: [
                          Opacity(
                            opacity: viewModel.isLoading ? 0.5 : 1.0,
                            child: ProfileAvatar(
                              imageUrl: viewModel.photoUrl,
                              radius: 28,
                              onEditTap: () =>
                                  viewModel.uploadProfilePicture(),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Welcome, $displayFirstName",
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  viewModel.email,
                                  style: GoogleFonts.poppins(
                                    color: Colors.white.withOpacity(0.75),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // ─── Right: VIP Badge ───
                    _VipBadge(tier: viewModel.vipTier),
                  ],
                ),
              ),

              // ─── Scrollable Body ──────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 20),
                  child: Column(
                    children: [
                      if (viewModel.isLoading) ...[
                        LinearProgressIndicator(
                          color: _R.green,
                          backgroundColor: _R.greenLight,
                        ),
                        const SizedBox(height: 16),
                      ],
                      _RewardsCard(viewModel: viewModel),
                      const SizedBox(height: 16),
                      _MyAccountCard(),
                      const SizedBox(height: 16),
                      _SettingsCard(viewModel: viewModel),
                      const SizedBox(height: 30),
                      Text(
                        "Version ${viewModel.appVersion}",
                        style: GoogleFonts.poppins(
                            color: _R.textSub, fontSize: 13),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ─── VIP Badge ───────────────────────────────────────────────
class _VipBadge extends StatelessWidget {
  final String tier;
  const _VipBadge({required this.tier});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      decoration: BoxDecoration(
        // Gold tone for badge body — matches logo's keyhole accent
        color: const Color(0xFFE8A020).withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFE8A020).withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipPath(
            clipper: _VipSlantClipper(),
            child: Container(
              color: Colors.white.withOpacity(0.15),
              padding:
                  const EdgeInsets.only(left: 8, right: 16),
              alignment: Alignment.center,
              child: Row(
                children: [
                  const Icon(Icons.star_rounded,
                      color: _R.gold, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    "VIP",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 2, right: 10),
            child: Text(
              tier,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VipSlantClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(size.width, 0);
    path.lineTo(size.width - 10, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// ─── Section card helper ──────────────────────────────────────
Widget _sectionCard({required String title, required List<Widget> children}) {
  return Container(
    width: double.infinity,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF1B2A6B).withOpacity(0.05),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
          child: Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF6B7A99),
              letterSpacing: 0.3,
            ),
          ),
        ),
        ...children,
        const SizedBox(height: 10),
      ],
    ),
  );
}

// ─── Rewards Card ─────────────────────────────────────────────
class _RewardsCard extends StatelessWidget {
  final AccountViewModel viewModel;
  const _RewardsCard({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return _sectionCard(
      title: 'Reward and savings',
      children: [
        const AccountListTile(
          icon: Icons.confirmation_num_outlined,
          title: "Coupons",
          trailingText: "",
        ),
        Divider(height: 1, indent: 60, endIndent: 20,
            color: const Color(0xFFE8EDF2)),
        AccountListTile(
          icon: Icons.savings_outlined,
          title: "Cashback Rewards",
          trailingText: viewModel.cashbackAmount,
        ),
      ],
    );
  }
}

// ─── My Account Card ──────────────────────────────────────────
class _MyAccountCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _sectionCard(
      title: 'My account',
      children: [
        const AccountListTile(icon: Icons.person_outline, title: "Profile"),
        Divider(height: 1, indent: 60, endIndent: 20,
            color: const Color(0xFFE8EDF2)),
        const AccountListTile(
          icon: Icons.chat_bubble_outline,
          title: "Property messages",
        ),
        Divider(height: 1, indent: 60, endIndent: 20,
            color: const Color(0xFFE8EDF2)),
        const AccountListTile(
            icon: Icons.favorite_border, title: "Saved"),
        Divider(height: 1, indent: 60, endIndent: 20,
            color: const Color(0xFFE8EDF2)),
        const AccountListTile(
          icon: Icons.credit_card,
          title: "My saved cards",
        ),
      ],
    );
  }
}

// ─── Settings Card ────────────────────────────────────────────
class _SettingsCard extends StatelessWidget {
  final AccountViewModel viewModel;
  const _SettingsCard({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return _sectionCard(
      title: 'Settings',
      children: [
        AccountListTile(
          icon: Icons.language,
          title: "Language",
          trailingText: viewModel.language,
        ),
        Divider(height: 1, indent: 60, endIndent: 20,
            color: const Color(0xFFE8EDF2)),
        AccountListTile(
          icon: Icons.price_change_outlined,
          title: "Price display",
          trailingText: viewModel.priceDisplay,
        ),
        Divider(height: 1, indent: 60, endIndent: 20,
            color: const Color(0xFFE8EDF2)),
        AccountListTile(
          icon: Icons.logout,
          title: "Sign out",
          isDestructive: true,
          onTap: () async {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Logging out...',
                    style: GoogleFonts.poppins(fontSize: 13)),
                backgroundColor: const Color(0xFF1B2A6B),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                margin:
                    const EdgeInsets.fromLTRB(16, 0, 16, 16),
                duration: const Duration(seconds: 1),
              ),
            );
            await context.read<AuthViewModel>().logout();
          },
        ),
      ],
    );
  }
}