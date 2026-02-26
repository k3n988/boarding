import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ── ViewModels ──────────────────────────────────────────────
import '../viewmodels/account_viewmodel.dart';
import '../../auth/viewmodels/auth_viewmodel.dart'; 

// ── Widgets ─────────────────────────────────────────────────
import 'widgets/account_list_tile.dart';
import 'widgets/profile_avatar.dart'; // Added the import for your Avatar

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
      backgroundColor: const Color(0xFFF0F2F5),
      body: Consumer<AccountViewModel>(
        builder: (context, viewModel, _) {
          // Optional: We removed the full-screen loading indicator here 
          // so the user can still see their screen while the image uploads.
          
          // Uses the real first name from your UserModel
          final String displayFirstName = viewModel.firstName.isNotEmpty 
              ? viewModel.firstName 
              : 'User';

          return Column(
            children: [
              // ─── Header matching your screenshot + Avatar ─────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(top: 60, left: 20, right: 20, bottom: 30),
                decoration: const BoxDecoration(
                  color: Color(0xFF8C5338), // The brown color
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // ─── Left Side: Avatar & Text ───
                    Expanded(
                      child: Row(
                        children: [
                          // Added Opacity to give visual feedback when uploading
                          Opacity(
                            opacity: viewModel.isLoading ? 0.5 : 1.0,
                            child: ProfileAvatar(
                              // Uses the URL straight from Firebase via ViewModel
                              imageUrl: viewModel.photoUrl, 
                              radius: 26,
                              // Calls the upload function directly from the ViewModel
                              onEditTap: () => viewModel.uploadProfilePicture(), 
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Welcome, $displayFirstName",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis, // Prevents overflow if name is long
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  viewModel.email,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
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
                    // ─── Right Side: Custom Slanted VIP Badge ───
                    _VipBadge(tier: viewModel.vipTier),
                  ],
                ),
              ),
              
              // ─── Scrollable Body ──────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  child: Column(
                    children: [
                      // Show a tiny progress bar if uploading
                      if (viewModel.isLoading) ...[
                         const LinearProgressIndicator(),
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
                        style: const TextStyle(color: Colors.grey),
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

// ─── Custom Widget for the Slanted VIP Badge ────────────────────
class _VipBadge extends StatelessWidget {
  final String tier;
  const _VipBadge({required this.tier});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 28,
      decoration: BoxDecoration(
        color: const Color(0xFFD39369), // Bronze color
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Black section with the slant
          ClipPath(
            clipper: _VipSlantClipper(),
            child: Container(
              color: const Color(0xFF2C2E3E), // Dark blue/black color
              padding: const EdgeInsets.only(left: 8, right: 16),
              alignment: Alignment.center,
              child: const Row(
                children: [
                  Icon(Icons.star, color: Colors.white, size: 14),
                  SizedBox(width: 4),
                  Text(
                    "VIP",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Tier text
          Padding(
            padding: const EdgeInsets.only(left: 2, right: 10),
            child: Text(
              tier,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Clipper to create the slanted edge on the VIP badge
class _VipSlantClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(size.width, 0); // Top right
    path.lineTo(size.width - 10, size.height); // Bottom right (shifted left for slant)
    path.lineTo(0, size.height); // Bottom left
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

// ─── Cards Below ───────────────────────────────

class _RewardsCard extends StatelessWidget {
  final AccountViewModel viewModel;

  const _RewardsCard({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: Text(
              "Reward and savings",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          const AccountListTile(
            icon: Icons.confirmation_num_outlined,
            title: "Coupons",
            trailingText: "",
          ),
          const Divider(height: 1, indent: 60, endIndent: 20),
          AccountListTile(
            icon: Icons.savings_outlined,
            title: "Cashback Rewards",
            trailingText: viewModel.cashbackAmount,
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

class _MyAccountCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: Text(
              "My account",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          const AccountListTile(icon: Icons.person_outline, title: "Profile"),
          const AccountListTile(
            icon: Icons.chat_bubble_outline,
            title: "Property messages",
          ),
          const AccountListTile(icon: Icons.favorite_border, title: "Saved"),
          const AccountListTile(
            icon: Icons.credit_card,
            title: "My saved cards",
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final AccountViewModel viewModel;

  const _SettingsCard({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: Text(
              "Settings",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          AccountListTile(
            icon: Icons.language,
            title: "Language",
            trailingText: viewModel.language,
          ),
          AccountListTile(
            icon: Icons.price_change_outlined,
            title: "Price display",
            trailingText: viewModel.priceDisplay,
          ),
          
          // ─── Sign Out Button ─────────────────────────────────
          AccountListTile(
            icon: Icons.logout,
            title: "Sign out",
            isDestructive: true,
            onTap: () async {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Logging out...'),
                  duration: Duration(seconds: 1),
                ),
              );
              
              await context.read<AuthViewModel>().logout();
            },
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}