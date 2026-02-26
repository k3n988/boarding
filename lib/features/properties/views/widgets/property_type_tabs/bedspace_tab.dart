import 'package:flutter/material.dart';

class BedspaceScreen extends StatelessWidget {
  const BedspaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.black.withOpacity(0.6), Colors.transparent],
            ),
          ),
        ),
      ),
      extendBodyBehindAppBar: true, 
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- TOP HEADER & SEARCH CARD OVERLAP ---
            Stack(
              children: [
                // Background Image
                Container(
                  height: 280,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage("https://images.unsplash.com/photo-1505691938895-1758d7feb511?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80"),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // Title
                const Positioned(
                  top: 100,
                  left: 20,
                  child: Text(
                    "Bedspaces",
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: -0.5),
                  ),
                ),
                // Search Card
                Container(
                  margin: const EdgeInsets.only(top: 150, left: 16, right: 16, bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 5)),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildSearchField(Icons.search, "Find affordable bedspaces..."),
                      Divider(height: 1, color: Colors.grey[300]),
                      _buildSearchField(Icons.calendar_month_outlined, "Move-in date", trailingText: "Any"),
                      Divider(height: 1, color: Colors.grey[300]),
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0, top: 16.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[600],
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              elevation: 0,
                            ),
                            child: const Text("Search", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // --- WHY BOOK WITH KEN STAYS SECTION ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Why book with Ken Stays?",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  
                  // Benefit 1
                  _buildBenefitCard(
                    icon: Icons.verified_user,
                    title: "Verified & Safe Locations",
                    subtitle: "All our boarding houses are strictly vetted for your security.",
                    iconColor: Colors.green,
                  ),
                  const SizedBox(height: 12),
                  
                  // Benefit 2
                  _buildBenefitCard(
                    icon: Icons.savings,
                    title: "Student-Friendly Rates",
                    subtitle: "We offer the most competitive prices around Bacolod City.",
                    iconColor: Colors.blue,
                  ),
                  const SizedBox(height: 12),
                  
                  // Benefit 3
                  _buildBenefitCard(
                    icon: Icons.support_agent,
                    title: "24/7 Assistance",
                    subtitle: "Our support team is always ready to help you with your booking.",
                    iconColor: Colors.orange,
                  ),
                  
                  const SizedBox(height: 40), // Bottom padding
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- HELPER WIDGETS ---

  // Reusable search field row
  Widget _buildSearchField(IconData icon, String text, {String? trailingText}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600], size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 15, color: Colors.black87),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (trailingText != null)
            Text(
              trailingText,
              style: TextStyle(fontSize: 13, color: Colors.grey[500]),
            ),
        ],
      ),
    );
  }


  // Styling for the "Why book with Ken Stays" cards
  Widget _buildBenefitCard({required IconData icon, required String title, required String subtitle, required Color iconColor}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.pink.shade100, width: 1.5), 
        boxShadow: [
          BoxShadow(color: Colors.pink.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))
        ]
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 4),
                Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 13, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}