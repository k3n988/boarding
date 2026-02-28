import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import 'pin_location_screen.dart';
import '../../viewmodels/property_detail_viewmodel.dart';

// --- ADDED THIS WRAPPER TO PROVIDE THE VIEWMODEL ---
class PostingFormScreen extends StatelessWidget {
  const PostingFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PropertyDetailViewModel(),
      child: const PostingForm(),
    );
  }
}

class PostingForm extends StatefulWidget {
  const PostingForm({super.key});

  @override
  State<PostingForm> createState() => _PostingFormState();
}

class _PostingFormState extends State<PostingForm> {
  // ── Controllers ────────────────────────────────────────────────────────────
  final TextEditingController _titleController = TextEditingController();
  
  // ── Splitted Location Controllers ──
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _barangayController = TextEditingController();
  // Pre-filled with Bacolod details for convenience
  final TextEditingController _cityController = TextEditingController(text: 'Bacolod City');
  final TextEditingController _provinceController = TextEditingController(text: 'Negros Occidental');
  final TextEditingController _zipCodeController = TextEditingController();

  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _slotsController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _policiesController = TextEditingController();

  // ── State ──────────────────────────────────────────────────────────────────
  String selectedCategory = 'Boarding House';
  String selectedGender = 'All / Mixed';
  final List<String> selectedAmenities = [];
  bool _isLocationPinned = false;
  
  // ── Variables to store the actual map coordinates ──
  double? _latitude;
  double? _longitude;

  final ImagePicker _picker = ImagePicker();
  final List<File> _selectedImages = [];

  final List<String> categories = [
    'Boarding House',
    'Dormitory',
    'Apartment',
    'Bedspace',
  ];

  final List<String> genderOptions = [
    'All / Mixed',
    'Female Only',
    'Male Only',
  ];

  List<String> amenitiesList = [
    'Free WiFi',
    'Aircon',
    'Private Bath',
    'No Curfew',
    'Cooking Allowed',
    'CCTV',
    'Study Area',
    'Water Included',
    'Electricity Included',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _streetController.dispose();
    _barangayController.dispose();
    _cityController.dispose();
    _provinceController.dispose();
    _zipCodeController.dispose();
    _priceController.dispose();
    _slotsController.dispose();
    _descriptionController.dispose();
    _policiesController.dispose();
    super.dispose();
  }

  // ── Helper: Combine all address fields into one string ──
  String getFullAddress() {
    List<String> parts = [];
    
    if (_streetController.text.trim().isNotEmpty) {
      parts.add(_streetController.text.trim());
    }
    if (_barangayController.text.trim().isNotEmpty) {
      parts.add('Brgy. ${_barangayController.text.trim()}');
    }
    if (_cityController.text.trim().isNotEmpty) {
      parts.add(_cityController.text.trim());
    }
    if (_provinceController.text.trim().isNotEmpty) {
      parts.add(_provinceController.text.trim());
    }
    if (_zipCodeController.text.trim().isNotEmpty) {
      parts.add(_zipCodeController.text.trim());
    }
    
    return parts.join(', '); // Example output: blk 8 lot 16, Brgy. Mansilingan, Bacolod City, Negros Occidental, 6100
  }

  // ── Image Picker ───────────────────────────────────────────────────────────
  Future<void> _pickImages() async {
    if (_selectedImages.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Max 5 photos allowed.')),
      );
      return;
    }
    final pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles.isEmpty) return;
    setState(() {
      for (final file in pickedFiles) {
        if (_selectedImages.length < 5) {
          _selectedImages.add(File(file.path));
        }
      }
    });
  }

  // ── Publish ────────────────────────────────────────────────────────────────
  Future<void> _handlePublish(PropertyDetailViewModel viewModel) async {
    if (_titleController.text.trim().isEmpty ||
        _priceController.text.trim().isEmpty ||
        _streetController.text.trim().isEmpty ||
        _cityController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Please fill in Property Name, Price, Street, and City.')),
      );
      return;
    }
    if (_selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least 1 photo.')),
      );
      return;
    }

    if (!_isLocationPinned) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please pin the location on the map to help students find it.')),
      );
      return;
    }

    try {
      // Pass the data cleanly to the ViewModel
      await viewModel.publishListing(
        title: _titleController.text.trim(),
        fullAddress: getFullAddress(),
        price: double.tryParse(_priceController.text.trim().replaceAll(',', '')) ?? 0.0,
        availableSlots: int.tryParse(_slotsController.text.trim()) ?? 0,
        category: selectedCategory,
        tenantPreference: selectedGender,
        amenities: selectedAmenities,
        isLocationPinned: _isLocationPinned,
        latitude: _latitude,
        longitude: _longitude,
        description: _descriptionController.text.trim(),
        policies: _policiesController.text.trim(),
        selectedImages: _selectedImages,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Listing published successfully!')),
      );

      // Reset form on success
      setState(() {
        _titleController.clear();
        _streetController.clear();
        _barangayController.clear();
        _cityController.text = 'Bacolod City';
        _provinceController.text = 'Negros Occidental';
        _zipCodeController.clear();
        _priceController.clear();
        _slotsController.clear();
        _descriptionController.clear();
        _policiesController.clear();
        _selectedImages.clear();
        selectedAmenities.clear();
        _isLocationPinned = false;
        _latitude = null;  
        _longitude = null; 
        selectedCategory = 'Boarding House';
        selectedGender = 'All / Mixed';
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to publish: $e')),
      );
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // ── Consume the ViewModel so UI updates during loading ──
    return Consumer<PropertyDetailViewModel>(
      builder: (context, viewModel, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Photo Picker ───────────────────────────────────────────────────
              GestureDetector(
                onTap: _pickImages,
                child: Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: _selectedImages.isEmpty
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.add_a_photo_outlined,
                                size: 40, color: Colors.grey),
                            const SizedBox(height: 8),
                            Text('Add Photos',
                                style: TextStyle(
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.bold)),
                            const Text(
                              '(Max 5 photos — first photo is your cover)',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 11),
                            ),
                          ],
                        )
                      : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.all(8),
                          itemCount: _selectedImages.length < 5
                              ? _selectedImages.length + 1
                              : 5,
                          itemBuilder: (context, index) {
                            if (index == _selectedImages.length &&
                                _selectedImages.length < 5) {
                              return GestureDetector(
                                onTap: _pickImages,
                                child: Container(
                                  width: 120,
                                  margin: const EdgeInsets.only(right: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: Colors.grey.shade400),
                                  ),
                                  child: const Icon(Icons.add,
                                      color: Colors.grey),
                                ),
                              );
                            }
                            return Stack(
                              children: [
                                Container(
                                  width: 120,
                                  margin: const EdgeInsets.only(right: 8),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    image: DecorationImage(
                                      image: FileImage(_selectedImages[index]),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  child: index == 0
                                      ? Align(
                                          alignment: Alignment.bottomCenter,
                                          child: Container(
                                            width: double.infinity,
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Colors.black
                                                  .withValues(alpha: 0.5),
                                              borderRadius:
                                                  const BorderRadius.only(
                                                bottomLeft: Radius.circular(12),
                                                bottomRight:
                                                    Radius.circular(12),
                                              ),
                                            ),
                                            child: const Text(
                                              'Cover',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        )
                                      : null,
                                ),
                                Positioned(
                                  top: 4,
                                  right: 12,
                                  child: GestureDetector(
                                    onTap: () => setState(
                                        () => _selectedImages.removeAt(index)),
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: Colors.black54,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.close,
                                          size: 16, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                ),
              ),

              const SizedBox(height: 24),

              // ── Property Name ──────────────────────────────────────────────────
              _buildLabel('Property Name *'),
              const SizedBox(height: 8),
              TextField(
                controller: _titleController,
                decoration: _inputDecoration('e.g. Ken\'s Safe Haven'),
              ),

              const SizedBox(height: 20),

              // ── SPLITTED LOCATION FIELDS ───────────────────────────────────────
              _buildLabel('Location Details *'),
              const SizedBox(height: 8),
              
              TextField(
                controller: _streetController,
                decoration: _inputDecoration('House No. / Lot / Blk / Street Name'),
              ),
              const SizedBox(height: 12),
              
              TextField(
                controller: _barangayController,
                decoration: _inputDecoration('Barangay (e.g. Mansilingan)'),
              ),
              const SizedBox(height: 12),
              
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _cityController,
                      decoration: _inputDecoration('City / Municipality'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _provinceController,
                      decoration: _inputDecoration('Province'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.45,
                child: TextField(
                  controller: _zipCodeController,
                  keyboardType: TextInputType.number,
                  decoration: _inputDecoration('ZIP Code'),
                ),
              ),
              const SizedBox(height: 16),

              GestureDetector(
                onTap: () async {
                  // Ensure they've at least typed a street and city
                  if (_streetController.text.trim().isEmpty || _cityController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter at least the Street and City before pinning!')),
                    );
                    return;
                  }

                  // ── Pinapasa ang combined text sa map screen ──
                  final fullAddress = getFullAddress();
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PinLocationScreen(
                        initialAddress: fullAddress, 
                      ),
                    ),
                  );

                  // ── Handle the returned LatLng object ──
                  if (result != null && result is LatLng) {
                    setState(() {
                      _isLocationPinned = true;
                      _latitude = result.latitude;
                      _longitude = result.longitude;
                    });
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: _isLocationPinned
                        ? Colors.blue.withValues(alpha: 0.05)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _isLocationPinned
                          ? Colors.blue
                          : Colors.grey.shade300,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _isLocationPinned
                            ? Icons.location_on
                            : Icons.add_location_alt_outlined,
                        color: _isLocationPinned
                            ? Colors.blue
                            : Colors.black54,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _isLocationPinned
                              ? 'Location Pinned Successfully!'
                              : 'Pin location on map (optional)',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: _isLocationPinned
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: _isLocationPinned
                                ? Colors.blue
                                : Colors.black87,
                          ),
                        ),
                      ),
                      if (_isLocationPinned)
                        const Icon(Icons.check_circle,
                            color: Colors.blue, size: 20)
                      else
                        const Icon(Icons.arrow_forward_ios,
                            size: 16, color: Colors.black54),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ── Category ───────────────────────────────────────────────────────
              _buildLabel('Category'),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: categories.map((cat) {
                  final isSelected = selectedCategory == cat;
                  return ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    selectedColor: Colors.black,
                    labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected
                            ? Colors.transparent
                            : Colors.grey.shade300,
                      ),
                    ),
                    onSelected: (_) =>
                        setState(() => selectedCategory = cat),
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),

              // ── Price & Slots ──────────────────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Price / Month *'),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _priceController,
                          keyboardType: TextInputType.number,
                          decoration: _inputDecoration('₱ 0'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Available Slots'),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _slotsController,
                          keyboardType: TextInputType.number,
                          decoration: _inputDecoration('e.g. 2'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ── Who can stay ───────────────────────────────────────────────────
              _buildLabel('Who can stay?'),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedGender,
                    isExpanded: true,
                    items: genderOptions
                        .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                        .toList(),
                    onChanged: (val) =>
                        setState(() => selectedGender = val!),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ── Property Description ───────────────────────────────────────────
              _buildLabel('Property Description'),
              const SizedBox(height: 8),
              TextField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: _inputDecoration(
                    'Tell us about your property. What makes it special?'),
              ),

              const SizedBox(height: 20),

              // ── Policies & Rules ───────────────────────────────────────────────
              _buildLabel('Policies & Rules'),
              const SizedBox(height: 8),
              TextField(
                controller: _policiesController,
                maxLines: 4,
                decoration: _inputDecoration(
                    'e.g. No smoking indoors, Visitors allowed until 10 PM'),
              ),

              const SizedBox(height: 20),

              // ── Amenities ──────────────────────────────────────────────────────
              _buildLabel('Amenities & Offers'),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ...amenitiesList.map((amenity) {
                    final isSelected = selectedAmenities.contains(amenity);
                    return InputChip(
                      label: Text(amenity),
                      selected: isSelected,
                      selectedColor: Colors.green[100],
                      checkmarkColor: Colors.green[800],
                      labelStyle: TextStyle(
                        color: isSelected
                            ? Colors.green[800]
                            : Colors.black87,
                        fontSize: 12,
                      ),
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(
                            color: isSelected
                                ? Colors.green
                                : Colors.grey.shade300),
                      ),
                      deleteIconColor: Colors.green[800],
                      onDeleted: isSelected
                          ? () => setState(() {
                                amenitiesList.remove(amenity);
                                selectedAmenities.remove(amenity);
                              })
                          : null,
                      onSelected: (selected) => setState(() {
                        if (selected) {
                          selectedAmenities.add(amenity);
                        } else {
                          selectedAmenities.remove(amenity);
                        }
                      }),
                    );
                  }),
                  ActionChip(
                    label: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add, size: 16, color: Colors.black54),
                        SizedBox(width: 4),
                        Text('Add',
                            style: TextStyle(
                                fontSize: 12, color: Colors.black54)),
                      ],
                    ),
                    backgroundColor: Colors.grey.shade100,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                    onPressed: _showAddAmenityDialog,
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // ── Publish Button ─────────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: viewModel.isLoading ? null : () => _handlePublish(viewModel),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    disabledBackgroundColor: Colors.grey,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: viewModel.isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          'Publish Listing',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        );
      }
    );
  }

  // ── Dialogs ────────────────────────────────────────────────────────────────

  void _showAddAmenityDialog() {
    final customController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Custom Amenity',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: customController,
          decoration: _inputDecoration('e.g. Gym Access'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
                const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              final newAmenity = customController.text.trim();
              if (newAmenity.isNotEmpty &&
                  !amenitiesList.contains(newAmenity)) {
                setState(() {
                  amenitiesList.add(newAmenity);
                  selectedAmenities.add(newAmenity);
                });
              }
              Navigator.pop(context);
            },
            child: const Text('Add',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ── Reusable Widgets ───────────────────────────────────────────────────────

  Widget _buildLabel(String text) =>
      Text(text, style: const TextStyle(fontWeight: FontWeight.w600));

  InputDecoration _inputDecoration(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black),
        ),
      );
}