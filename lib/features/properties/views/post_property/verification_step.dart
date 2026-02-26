import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart'; 
import 'dart:io';
import 'dart:ui' as ui;

// --- THEME CONSTANTS ---
const Color appGreen = Color(0xFF96D130);
const Color textDark = Color(0xFF1F1F1F);
const Color textGrey = Color(0xFF8C8C8C);

// --- HELPER FUNCTIONS FOR UPLOADS & SCHEDULING ---
class VerificationFunctions {
  static final ImagePicker _picker = ImagePicker();

  static Future<String?> handleCommunityUpload(BuildContext context) async {
    return await _handleGenericUpload(context, 'barangay_clearance', 'barangayClearanceUrl');
  }

  static Future<String?> handleOwnershipUpload(BuildContext context) async {
    return await _handleGenericUpload(context, 'ownership_proof', 'ownershipProofUrl');
  }

  static Future<String?> _handleGenericUpload(BuildContext context, String storageFolder, String fieldName) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please sign in first.')));
      return null;
    }

    try {
      final picked = await _picker.pickImage(source: ImageSource.gallery);
      if (picked == null) return null;

      final bytes = await picked.readAsBytes();
      final storageRef = FirebaseStorage.instance.ref().child(
          'host_verifications/${user.uid}/${storageFolder}_${DateTime.now().millisecondsSinceEpoch}.jpg');
      await storageRef.putData(bytes);
      final downloadUrl = await storageRef.getDownloadURL();

      await FirebaseFirestore.instance.collection('host_verifications').doc(user.uid).set({
        fieldName: downloadUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Document uploaded successfully.')));
      }
      return downloadUrl;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
      }
      return null;
    }
  }

  static Future<bool> handleRealityCheck(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    String? localType;
    DateTime? localDate;
    final noteController = TextEditingController();

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20, right: 20, top: 20,
            bottom: 20 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Reality Check', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  const Text('Choose how you want us to verify the property.', style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ChoiceChip(
                          label: const Text('Live'),
                          selected: localType == 'live',
                          selectedColor: Colors.black,
                          labelStyle: TextStyle(color: localType == 'live' ? Colors.white : Colors.black),
                          onSelected: (v) => setModalState(() => localType = 'live'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ChoiceChip(
                          label: const Text('Visit'),
                          selected: localType == 'visit',
                          selectedColor: Colors.black,
                          labelStyle: TextStyle(color: localType == 'visit' ? Colors.white : Colors.black),
                          onSelected: (v) => setModalState(() => localType = 'visit'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Preferred date'),
                    subtitle: Text(localDate != null
                        ? '${localDate!.year}-${localDate!.month.toString().padLeft(2, '0')}-${localDate!.day.toString().padLeft(2, '0')}'
                        : 'Choose a date'),
                    trailing: const Icon(Icons.calendar_today_rounded),
                    onTap: () async {
                      final now = DateTime.now();
                      final picked = await showDatePicker(
                        context: context, initialDate: now, firstDate: now, lastDate: now.add(const Duration(days: 365)),
                      );
                      if (picked != null) setModalState(() => localDate = picked);
                    },
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: noteController, maxLines: 2,
                    decoration: InputDecoration(
                      hintText: 'Any special instructions...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity, height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        if (localType == null || localDate == null) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please choose Live/Visit and a date.')));
                          return;
                        }
                        Navigator.pop(context, true);
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      child: const Text('Save schedule', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );

    if (result == true && localType != null && localDate != null) {
      await FirebaseFirestore.instance.collection('host_verifications').doc(user.uid).set({
        'realityCheck': {
          'type': localType,
          'date': Timestamp.fromDate(localDate!),
          'note': noteController.text.trim(),
        },
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reality check scheduled.')));
      }
      return true;
    }
    return false;
  }
}

// --- IDENTITY VERIFICATION PAGE VIEW FLOW ---
class IdentityVerificationFlow extends StatefulWidget {
  final VoidCallback onVerified;
  const IdentityVerificationFlow({super.key, required this.onVerified});

  @override
  State<IdentityVerificationFlow> createState() => _IdentityVerificationFlowState();
}

class _IdentityVerificationFlowState extends State<IdentityVerificationFlow> {
  final PageController _controller = PageController();
  String? _idUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: PageView(
        controller: _controller,
        physics: const NeverScrollableScrollPhysics(), 
        children: [
          // Screen 0: Intro Hub
          _KYCIntro(
            onIDTap: () => _controller.jumpToPage(1),
            onSelfieTap: () => _controller.jumpToPage(2),
          ),
          
          // Screen 1: ID Upload
          _IDUpload(
            onComplete: (url) {
              _idUrl = url;
              _controller.jumpToPage(2);
            },
            onBack: () => _controller.jumpToPage(0),
          ),

          // Screen 2: Selfie Intro
          _SelfieIntroScreen(
            onOpenCamera: () => _controller.jumpToPage(3),
            onBack: () => _controller.jumpToPage(0),
          ),

          // Screen 3: Custom In-App Camera
          _CustomSelfieCamera(
            idUrl: _idUrl,
            onVerified: widget.onVerified,
            onBack: () => _controller.jumpToPage(2), 
          )
        ],
      ),
    );
  }
}

// ==========================================
// SCREEN 0: KYC INTRO
// ==========================================
class _KYCIntro extends StatelessWidget {
  final VoidCallback onIDTap;
  final VoidCallback onSelfieTap;
  
  const _KYCIntro({required this.onIDTap, required this.onSelfieTap});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // Back Button to return to post_screen.dart
          Padding(
            padding: const EdgeInsets.only(left: 8.0, top: 10.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: textDark),
                onPressed: () => Navigator.of(context).pop(), 
              ),
            ),
          ),
          
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 120,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const Icon(Icons.lock_rounded, size: 80, color: appGreen),
                        Positioned(
                          right: 0,
                          top: 10,
                          child: Container(
                            decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                            child: const Icon(Icons.verified_user_rounded, size: 40, color: appGreen),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Text("Verify KYC", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textDark)),
                  const SizedBox(height: 12),
                  const Text(
                    "Please submit the following documents to\nverify your identity.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: textGrey, height: 1.5),
                  ),
                  const SizedBox(height: 40),
                  
                  GestureDetector(
                    onTap: onIDTap,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE)))),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(color: const Color(0xFFF6F6F6), borderRadius: BorderRadius.circular(8)),
                            child: const Icon(Icons.badge_outlined, color: textDark),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text("Take a photo of your valid ID card", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textDark)),
                                SizedBox(height: 4),
                                Text("Your ID will be used to verify your identity\nand keep your account secure.", style: TextStyle(fontSize: 12, color: textGrey)),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right, color: textGrey),
                        ],
                      ),
                    ),
                  ),

                  GestureDetector(
                    onTap: onSelfieTap,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE)))),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(color: const Color(0xFFF6F6F6), borderRadius: BorderRadius.circular(8)),
                            child: const Icon(Icons.face_retouching_natural, color: textDark),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text("Take a selfie of yourself", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textDark)),
                                SizedBox(height: 4),
                                Text("To compare the photo on your ID", style: TextStyle(fontSize: 12, color: textGrey)),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right, color: textGrey),
                        ],
                      ),
                    ),
                  ),
                  
                  const Spacer(),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      "What is this for?",
                      style: TextStyle(color: textGrey, decoration: TextDecoration.underline, fontSize: 12),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// SCREEN 1: ID UPLOAD
// ==========================================
class _IDUpload extends StatefulWidget {
  final Function(String) onComplete;
  final VoidCallback onBack;
  
  const _IDUpload({required this.onComplete, required this.onBack});

  @override
  State<_IDUpload> createState() => _IDUploadState();
}

class _IDUploadState extends State<_IDUpload> {
  File? _image;
  bool _isUploading = false;

  Future<void> _pickImage() async {
    final res = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (res != null) {
      setState(() { _image = File(res.path); });
    }
  }

  Future<void> _uploadAndContinue() async {
    if (_image == null) return;
    setState(() => _isUploading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      final uid = user?.uid ?? 'test_user_${DateTime.now().millisecondsSinceEpoch}';
      final ref = FirebaseStorage.instance.ref().child('ids/$uid.jpg');
      
      final UploadTask uploadTask = ref.putFile(_image!);
      final TaskSnapshot snapshot = await uploadTask;
      final url = await snapshot.ref.getDownloadURL();
      
      widget.onComplete(url);
    } catch (e) {
      if (mounted) {
        setState(() => _isUploading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Upload failed: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8.0, top: 10.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: textDark),
                onPressed: widget.onBack,
              ),
            ),
          ),
          
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 0.0),
              child: Column(
                children: [
                  const Text("Upload ID card", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textDark)),
                  const SizedBox(height: 12),
                  const Text(
                    "Verify your identity with a government\nissued ID.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: textGrey, height: 1.5),
                  ),
                  const SizedBox(height: 40),
                  
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Upload", style: TextStyle(fontSize: 12, color: textGrey)),
                  ),
                  const SizedBox(height: 8),

                  GestureDetector(
                    onTap: _pickImage,
                    child: CustomPaint(
                      painter: DashedRectPainter(color: Colors.grey.shade400, strokeWidth: 1.5, gap: 5.0),
                      child: Container(
                        height: 180,
                        width: double.infinity,
                        color: const Color(0xFFFAFAFA),
                        child: _image == null
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.cloud_upload_outlined, size: 32, color: textDark),
                                  SizedBox(height: 12),
                                  Text("Upload file", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textDark)),
                                  SizedBox(height: 4),
                                  Text("Supported file: JPG, PNG Max size: 5MB", style: TextStyle(fontSize: 12, color: textGrey)),
                                ],
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(_image!, fit: BoxFit.cover),
                              ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),

                  _isUploading 
                    ? const CircularProgressIndicator(color: appGreen)
                    : SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _image != null ? _uploadAndContinue : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _image != null ? appGreen : const Color(0xFFE0E0E0),
                            disabledBackgroundColor: const Color(0xFFE0E0E0),
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: Text(
                            "Continue", 
                            style: TextStyle(
                              fontSize: 16, 
                              fontWeight: FontWeight.w600, 
                              color: _image != null ? Colors.white : Colors.grey.shade600
                            ),
                          ),
                        ),
                      ),
                  
                  const Spacer(),
                  TextButton(
                    onPressed: () {},
                    child: const Text("Help?", style: TextStyle(color: textGrey, fontSize: 12)),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// SCREEN 2: SELFIE INTRO
// ==========================================
class _SelfieIntroScreen extends StatelessWidget {
  final VoidCallback onOpenCamera;
  final VoidCallback onBack;

  const _SelfieIntroScreen({required this.onOpenCamera, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8.0, top: 10.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: textDark),
                onPressed: onBack,
              ),
            ),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 0.0),
              child: Column(
                children: [
                  const Text("Selfie Verification", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textDark)),
                  const SizedBox(height: 12),
                  const Text(
                    "Verify your identity by taking a photo\nthat matches your ID provided.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: textGrey, height: 1.5),
                  ),
                  
                  const Spacer(),
                  
                  Center(
                    child: SizedBox(
                      height: 300,
                      width: 280,
                      child: CustomPaint(
                        painter: ScannerBracketsPainter(),
                        child: Padding(
                          padding: const EdgeInsets.all(30.0),
                          child: Icon(Icons.face_retouching_natural, size: 180, color: appGreen.withOpacity(0.5)),
                        ),
                      ),
                    ),
                  ),
                  
                  const Spacer(),
                  
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: onOpenCamera, 
                      style: ElevatedButton.styleFrom(
                        backgroundColor: appGreen,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text("Open camera", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  const Text(
                    "Your data is fully encrypted and used only for\nverification. We assure you that it is secured\nsafely.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11, color: textGrey, height: 1.5),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// SCREEN 3: CUSTOM IN-APP CAMERA
// ==========================================
class _CustomSelfieCamera extends StatefulWidget {
  final String? idUrl;
  final VoidCallback onVerified;
  final VoidCallback onBack;

  const _CustomSelfieCamera({this.idUrl, required this.onVerified, required this.onBack});

  @override
  State<_CustomSelfieCamera> createState() => _CustomSelfieCameraState();
}

class _CustomSelfieCameraState extends State<_CustomSelfieCamera> {
  CameraController? _camera;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cams = await availableCameras();
      final frontCam = cams.firstWhere((c) => c.lensDirection == CameraLensDirection.front, orElse: () => cams.first);
      _camera = CameraController(frontCam, ResolutionPreset.high, enableAudio: false);
      await _camera!.initialize();
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint("Camera init failed: $e");
    }
  }

  @override
  void dispose() { 
    _camera?.dispose(); 
    super.dispose(); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
               padding: const EdgeInsets.only(left: 8.0, top: 10.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                  onPressed: widget.onBack,
                ),
              ),
            ),
            
            const SizedBox(height: 10),
            const Text("Selfie Verification", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(
                "Make sure your face is clearly visible and well-lit. Look straight at the camera.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.white70, height: 1.5),
              ),
            ),
            const SizedBox(height: 40),
            
            Expanded(
              child: Center(
                child: _camera == null || !_camera!.value.isInitialized
                    ? const CircularProgressIndicator(color: appGreen)
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: SizedBox(
                          width: 280,
                          height: 380,
                          child: AspectRatio(
                            aspectRatio: _camera!.value.aspectRatio,
                            child: CameraPreview(_camera!),
                          ),
                        ),
                      ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            Padding(
              padding: const EdgeInsets.only(bottom: 40.0),
              child: _isProcessing 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : GestureDetector(
                      onTap: () async {
                        setState(() => _isProcessing = true);
                        try {
                          final user = FirebaseAuth.instance.currentUser;
                          final uid = user?.uid ?? 'test_user_${DateTime.now().millisecondsSinceEpoch}';
                          
                          final pic = await _camera!.takePicture();
                          final ref = FirebaseStorage.instance.ref().child('selfies/$uid.jpg');
                          
                          final UploadTask uploadTask = ref.putFile(File(pic.path));
                          final TaskSnapshot snapshot = await uploadTask;
                          final selfieUrl = await snapshot.ref.getDownloadURL();

                          await FirebaseFirestore.instance.collection('host_verifications').doc(uid).set({
                            'idImageUrl': widget.idUrl,
                            'selfieImageUrl': selfieUrl,
                            'kycCompletedAt': FieldValue.serverTimestamp(),
                          }, SetOptions(merge: true));

                          widget.onVerified();
                        } catch (e) {
                          if(mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
                            setState(() => _isProcessing = false);
                          }
                        }
                      },
                      child: Container(
                        height: 70, width: 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                        ),
                        child: Center(
                          child: Container(
                            height: 54, width: 54,
                            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- UTILITY: SCANNER BRACKETS PAINTER ---
class ScannerBracketsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1F1F1F) 
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const double length = 45.0; 
    const double radius = 30.0; 

    canvas.drawPath(
      Path()
        ..moveTo(0, length + radius)
        ..lineTo(0, radius)
        ..arcToPoint(const Offset(radius, 0), radius: const Radius.circular(radius))
        ..lineTo(length + radius, 0),
      paint,
    );

    canvas.drawPath(
      Path()
        ..moveTo(size.width - (length + radius), 0)
        ..lineTo(size.width - radius, 0)
        ..arcToPoint(Offset(size.width, radius), radius: const Radius.circular(radius))
        ..lineTo(size.width, length + radius),
      paint,
    );

    canvas.drawPath(
      Path()
        ..moveTo(0, size.height - (length + radius))
        ..lineTo(0, size.height - radius)
        ..arcToPoint(Offset(radius, size.height), radius: const Radius.circular(radius), clockwise: false)
        ..lineTo(length + radius, size.height),
      paint,
    );

    canvas.drawPath(
      Path()
        ..moveTo(size.width, size.height - (length + radius))
        ..lineTo(size.width, size.height - radius)
        ..arcToPoint(Offset(size.width - radius, size.height), radius: const Radius.circular(radius), clockwise: false)
        ..lineTo(size.width - (length + radius), size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// --- UTILITY: DASHED BORDER PAINTER ---
class DashedRectPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;

  DashedRectPainter({required this.color, this.strokeWidth = 1.0, this.gap = 5.0});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final Path path = Path()
      ..addRRect(RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, size.width, size.height), const Radius.circular(8)));

    final Path dashedPath = _createDashedPath(path, gap);
    canvas.drawPath(dashedPath, paint);
  }

  Path _createDashedPath(Path source, double gap) {
    final Path dashedPath = Path();
    for (final ui.PathMetric metric in source.computeMetrics()) {
      double distance = 0.0;
      bool draw = true;
      while (distance < metric.length) {
        final double len = draw ? gap * 1.5 : gap;
        if (draw) {
          dashedPath.addPath(metric.extractPath(distance, distance + len), Offset.zero);
        }
        distance += len;
        draw = !draw;
      }
    }
    return dashedPath;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}