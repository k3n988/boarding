import 'saved_repository.dart';
import '../models/saved_item_model.dart';

class SavedRepositoryImpl implements SavedRepository {
  @override
  Future<List<SavedItemModel>> getSavedBoardingHouses() async {
    return [
      const SavedItemModel(
        title: "Green View Boarding",
        location: "Mandalagan, Bacolod",
        price: "3,500",
        originalPrice: "4,000",
        rating: "4.5",
        reviewCount: "120",
        // Stable image: Tropical house exterior with greenery (looks like Mandalagan area)
        imageUrl: "https://images.unsplash.com/photo-1605276374104-dee2a0ed3cd6?ixlib=rb-4.0.3&auto=format&fit=crop&w=600&q=80",
        tags: ["WiFi Included"],
      ),
      const SavedItemModel(
        title: "Olivia's Place",
        location: "Downtown Area",
        price: "4,200",
        originalPrice: "4,500",
        rating: "4.2",
        reviewCount: "85",
        // Stable image: Gated residential house (common in Bacolod subdivisions)
        imageUrl: "https://images.unsplash.com/photo-1564013799919-ab600027ffc6?ixlib=rb-4.0.3&auto=format&fit=crop&w=600&q=80",
        tags: ["Female Only"],
      ),
    ];
  }

  @override
  Future<List<SavedItemModel>> getSavedDorms() async {
    return [
      const SavedItemModel(
        title: "Cozy Student Dorm",
        location: "Near USLS",
        price: "1,200",
        originalPrice: "1,500",
        rating: "4.8",
        reviewCount: "340",
        // Stable image: Wooden bunk beds (Classic student dorm style)
        imageUrl: "https://images.unsplash.com/photo-1555854743-e3c2f6a5fc6b?ixlib=rb-4.0.3&auto=format&fit=crop&w=600&q=80",
        tags: ["Walking Distance"],
      ),
      const SavedItemModel(
        title: "University Hall",
        location: "Lacson St.",
        price: "2,000",
        originalPrice: "2,500",
        rating: "4.0",
        reviewCount: "210",
        // Stable image: Shared room with study desks
        imageUrl: "https://images.unsplash.com/photo-1595526114035-0d45ed16cfbf?ixlib=rb-4.0.3&auto=format&fit=crop&w=600&q=80",
        tags: ["Aircon"],
      ),
    ];
  }

  @override
  Future<List<SavedItemModel>> getSavedApartments() async {
    return [
      const SavedItemModel(
        title: "Sunny Studio Apt",
        location: "Quezon St.",
        price: "8,500",
        originalPrice: "9,000",
        rating: "4.9",
        reviewCount: "56",
        // Stable image: Clean studio apartment interior
        imageUrl: "https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?ixlib=rb-4.0.3&auto=format&fit=crop&w=600&q=80",
        tags: ["Fully Furnished"],
      ),
      const SavedItemModel(
        title: "The Urban Loft",
        location: "Ayala District",
        price: "12,000",
        originalPrice: "15,000",
        rating: "5.0",
        reviewCount: "23",
        // Stable image: Modern condo interior (similar to Ayala/Megaworld units)
        imageUrl: "https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?ixlib=rb-4.0.3&auto=format&fit=crop&w=600&q=80",
        tags: ["Pool Access"],
      ),
    ];
  }

  @override
  Future<List<SavedItemModel>> getSavedBedspaces() async {
    return [
      const SavedItemModel(
        title: "Budget Spacer",
        location: "Libertad Market",
        price: "800",
        originalPrice: "1,000",
        rating: "3.8",
        reviewCount: "50",
        // Stable image: Simple room with modest bed
        imageUrl: "https://images.unsplash.com/photo-1505691938895-1758d7feb511?ixlib=rb-4.0.3&auto=format&fit=crop&w=600&q=80",
        tags: ["Water Free"],
      ),
      const SavedItemModel(
        title: "Ladies Wing 2",
        location: "Taculing",
        price: "1,500",
        originalPrice: "1,800",
        rating: "4.6",
        reviewCount: "90",
        // Stable image: Clean, small bedroom space
        imageUrl: "https://images.unsplash.com/photo-1626026909476-80f0891f1ba4?ixlib=rb-4.0.3&auto=format&fit=crop&w=600&q=80",
        tags: ["Ladies Only"],
      ),
    ];
  }
}