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
        imageUrl: "https://images.unsplash.com/photo-1598928506311-c55ded91a20c?ixlib=rb-4.0.3&auto=format&fit=crop&w=600&q=80",
        tags: ["WiFi Included"],
      ),
      const SavedItemModel(
        title: "Olivia's Place",
        location: "Downtown Area",
        price: "4,200",
        originalPrice: "4,500",
        rating: "4.2",
        reviewCount: "85",
        imageUrl: "https://images.unsplash.com/photo-1522771753014-df7060331667?ixlib=rb-4.0.3&auto=format&fit=crop&w=600&q=80",
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
        imageUrl: "https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?ixlib=rb-4.0.3&auto=format&fit=crop&w=600&q=80",
        tags: ["Fully Furnished"],
      ),
      const SavedItemModel(
        title: "The Urban Loft",
        location: "Ayala District",
        price: "12,000",
        originalPrice: "15,000",
        rating: "5.0",
        reviewCount: "23",
        imageUrl: "https://images.unsplash.com/photo-1502005229766-939cb4a5ea02?ixlib=rb-4.0.3&auto=format&fit=crop&w=600&q=80",
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
        imageUrl: "https://images.unsplash.com/photo-1626026909476-80f0891f1ba4?ixlib=rb-4.0.3&auto=format&fit=crop&w=600&q=80",
        tags: ["Water Free"],
      ),
      const SavedItemModel(
        title: "Ladies Wing 2",
        location: "Taculing",
        price: "1,500",
        originalPrice: "1,800",
        rating: "4.6",
        reviewCount: "90",
        imageUrl: "https://images.unsplash.com/photo-1505691938895-1758d7feb511?ixlib=rb-4.0.3&auto=format&fit=crop&w=600&q=80",
        tags: ["Ladies Only"],
      ),
    ];
  }
}
