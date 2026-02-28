import 'dart:io'; // Import ito para magamit ang File
import 'package:flutter/material.dart';

class ProfileAvatar extends StatelessWidget {
  final String? imageUrl;   // Para sa picture na galing sa internet/database
  final File? imageFile;    // BAGO: Para sa picture na bagong pili mula sa gallery
  final double radius;
  final VoidCallback? onEditTap;

  const ProfileAvatar({
    super.key, 
    this.imageUrl,
    this.imageFile, // Idinagdag dito
    this.radius = 40.0,
    this.onEditTap,
  });

  @override
  Widget build(BuildContext context) {
    // Function para malaman kung anong ImageProvider ang gagamitin
    ImageProvider? getBackgroundImage() {
      if (imageFile != null) {
        return FileImage(imageFile!); // Uunahin i-display ang bagong pili na picture
      } else if (imageUrl != null && imageUrl!.isNotEmpty) {
        return NetworkImage(imageUrl!); // Kung walang bagong pili, yung galing sa internet
      }
      return null;
    }

    return GestureDetector(
      onTap: onEditTap,
      child: Stack(
        children: [
          CircleAvatar(
            radius: radius,
            backgroundColor: Colors.grey.shade300,
            backgroundImage: getBackgroundImage(), // Ginamit natin yung function sa taas
            child: (imageFile == null && (imageUrl == null || imageUrl!.isEmpty))
                ? Icon(Icons.person, size: radius, color: Colors.grey.shade600) 
                : null,
          ),
          // Only show the edit icon if an onEditTap function is provided
          if (onEditTap != null)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black, // Changed this from Theme.of(context).primaryColor
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 14,
                ),
              ),
            ),
        ],
      ),
    );
  }
}