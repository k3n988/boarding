import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../properties/views/property_detail_screen.dart';
import '../viewmodels/saved_viewmodel.dart';
import 'widgets/saved_list.dart';

class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          title: const Text(
            'Saved',
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w800,
              fontSize: 22,
              letterSpacing: -0.5,
            ),
          ),
          centerTitle: true,
          actions: [
            Consumer<SavedViewModel>(
              builder: (_, vm, __) => vm.isEmpty
                  ? const SizedBox.shrink()
                  : TextButton(
                      onPressed: () => _confirmClearAll(context, vm),
                      child: const Text(
                        'Clear all',
                        style: TextStyle(
                          color: Colors.black45,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48),
            child: Consumer<SavedViewModel>(
              builder: (_, vm, __) => TabBar(
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                labelColor: Colors.black87,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.black87,
                indicatorWeight: 2.5,
                labelPadding:
                    const EdgeInsets.symmetric(horizontal: 18),
                labelStyle: const TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 13),
                unselectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.w500, fontSize: 13),
                tabs: [
                  Tab(text: 'All (${vm.savedCount})'),
                  Tab(text: 'Boarding (${vm.boardingHouseItems.length})'),
                  Tab(text: 'Dorm (${vm.dormItems.length})'),
                  Tab(text: 'Apartment (${vm.apartmentItems.length})'),
                  Tab(text: 'Bedspace (${vm.bedspaceItems.length})'),
                ],
              ),
            ),
          ),
        ),
        body: Consumer<SavedViewModel>(
          builder: (context, vm, _) {
            // ── Unsave by id ──────────────────────────────────────────────
            void onUnsave(String id) => vm.unsaveById(id);

            // ── Navigate to PropertyDetailScreen ──────────────────────────
            void onTap(String id) {
              final property = vm.getById(id);
              if (property == null) return;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      PropertyDetailScreen(property: property),
                ),
              );
            }

            return TabBarView(
              children: [
                SavedList(items: vm.allItems,           onUnsave: onUnsave, onTap: onTap),
                SavedList(items: vm.boardingHouseItems, onUnsave: onUnsave, onTap: onTap),
                SavedList(items: vm.dormItems,          onUnsave: onUnsave, onTap: onTap),
                SavedList(items: vm.apartmentItems,     onUnsave: onUnsave, onTap: onTap),
                SavedList(items: vm.bedspaceItems,      onUnsave: onUnsave, onTap: onTap),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _confirmClearAll(
      BuildContext context, SavedViewModel vm) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text('Clear all saved?',
            style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text(
            'This will remove all properties from your saved list.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel',
                style: TextStyle(color: Colors.black45)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear all',
                style: TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (confirm == true) vm.clearAll();
  }
}