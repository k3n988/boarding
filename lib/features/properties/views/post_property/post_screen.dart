import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'verification_step.dart';
import '../../viewmodels/requirement_viewmodel.dart';

// --- ADDED THIS WIDGET TO PROVIDE THE VIEWMODEL ---
class PostScreen extends StatelessWidget {
  const PostScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // This injects the ViewModel into the widget tree so the Consumer can find it!
    return ChangeNotifierProvider(
      create: (_) => RequirementViewModel(),
      child: const PostScreenView(),
    );
  }
}

// --- RENAMED YOUR ORIGINAL SCREEN TO PostScreenView ---
class PostScreenView extends StatefulWidget {
  const PostScreenView({super.key});

  @override
  State<PostScreenView> createState() => _PostScreenViewState();
}

class _PostScreenViewState extends State<PostScreenView> {
  
  Future<void> _handleSubmit(RequirementViewModel viewModel) async {
    // Optional: Check if all requirements are met before submitting
    // if (!viewModel.canSubmit) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(content: Text('Please complete all requirements first.')),
    //   );
    //   return;
    // }

    try {
      await viewModel.submitApplication();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Application submitted successfully!')),
        );
        context.push('/posting-form');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error submitting application: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // The Consumer will now successfully find the Provider we created above
    return Consumer<RequirementViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            title: const Text(
              'Verification',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Safety First Banner
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFCFCFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.shield_outlined, color: Colors.blueAccent, size: 28),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Safety First',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'To prevent scams, we require all hosts to submit proof of ownership and identity.',
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 14,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                const Text(
                  'Required Documents',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 16),

                // --- 1. IDENTITY CARD ---
                _buildRequirementCard(
                  icon: Icons.person_pin_circle_outlined,
                  title: '1. Identity',
                  subtitle: 'Upload a valid Government ID',
                  isCompleted: viewModel.isIdentityVerified,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => IdentityVerificationFlow(
                          onVerified: () {
                            Navigator.pop(context);
                            viewModel.setIdentityVerified(); // Update State
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Identity verified successfully!')),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),

                // --- 2. COMMUNITY STANDING CARD ---
                _buildRequirementCard(
                  icon: Icons.domain,
                  title: '2. Community Standing',
                  subtitle: 'Recent Barangay Clearance',
                  isCompleted: viewModel.communityDocUrl != null,
                  onTap: () async {
                    String? url = await VerificationFunctions.handleCommunityUpload(context);
                    if (url != null) {
                      viewModel.setCommunityDocUrl(url);
                    }
                  },
                ),

                // --- 3. OWNERSHIP CARD ---
                _buildRequirementCard(
                  icon: Icons.receipt_long_outlined,
                  title: '3. Ownership/Control',
                  subtitle: 'Recent Utility Bill (Electric/Water)',
                  isCompleted: viewModel.ownershipDocUrl != null,
                  onTap: () async {
                    String? url = await VerificationFunctions.handleOwnershipUpload(context);
                    if (url != null) {
                      viewModel.setOwnershipDocUrl(url);
                    }
                  },
                ),

                // --- 4. REALITY CHECK CARD ---
                _buildRequirementCard(
                  icon: Icons.videocam_outlined,
                  title: '4. Reality Check',
                  subtitle: 'Schedule a Live Video Call or Site Visit',
                  isCompleted: viewModel.isRealityCheckScheduled,
                  onTap: () async {
                    bool success = await VerificationFunctions.handleRealityCheck(context);
                    if (success == true) {
                      viewModel.setRealityCheckScheduled();
                    }
                  },
                ),

                const SizedBox(height: 32),

                // Submit Application Button
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: viewModel.isLoading 
                        ? null 
                        : () => _handleSubmit(viewModel),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey.shade400,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: viewModel.isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Submit Application',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      }
    );
  }

  Widget _buildRequirementCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isCompleted,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isCompleted ? Colors.green.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCompleted ? Colors.green.shade400 : Colors.grey.shade300,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  isCompleted ? Icons.check_circle : icon, 
                  color: isCompleted ? Colors.green : Colors.black87, 
                  size: 24,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 13,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  isCompleted ? Icons.check : Icons.chevron_right, 
                  color: isCompleted ? Colors.green : Colors.blueAccent, 
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}