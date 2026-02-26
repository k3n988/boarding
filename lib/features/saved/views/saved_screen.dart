import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels/saved_viewmodel.dart';
import 'widgets/saved_list.dart';

class SavedScreen extends StatefulWidget {
  const SavedScreen({super.key});

  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SavedViewModel>().loadSaved();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            "Saved",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          bottom: const TabBar(
            isScrollable: true,
            labelColor: Colors.blueAccent,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.blueAccent,
            indicatorWeight: 3,
            labelPadding: EdgeInsets.symmetric(horizontal: 16),
            labelStyle: TextStyle(fontWeight: FontWeight.w600),
            tabs: [
              Tab(text: "Boarding House"),
              Tab(text: "Dorm"),
              Tab(text: "Apartment"),
              Tab(text: "Bedspace"),
            ],
          ),
        ),
        body: Consumer<SavedViewModel>(
          builder: (context, viewModel, _) {
            if (viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            return TabBarView(
              children: [
                SavedList(items: viewModel.boardingHouseItems),
                SavedList(items: viewModel.dormItems),
                SavedList(items: viewModel.apartmentItems),
                SavedList(items: viewModel.bedspaceItems),
              ],
            );
          },
        ),
      ),
    );
  }
}
