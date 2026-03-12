import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/document_model.dart';
import 'services/records_api_service.dart';
import 'widgets/record_filter_chips.dart';
import 'widgets/visit_timeline_card.dart';
import 'widgets/upload_record_bottom_sheet.dart';

class RecordsScreen extends StatefulWidget {
  const RecordsScreen({super.key});

  @override
  State<RecordsScreen> createState() => _RecordsScreenState();
}

class _RecordsScreenState extends State<RecordsScreen> {
  RecordType _selectedFilter = RecordType.all;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  final RecordsApiService _apiService = RecordsApiService();
  late Future<List<VisitGroup>> _visitsFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _visitsFuture = _fetchVisits();
  }

  Future<List<VisitGroup>> _fetchVisits() async {
    final prefs = await SharedPreferences.getInstance();
    // Use health_id from session, or fallback to a dummy if testing directly
    final healthId = prefs.getString('health_id') ?? 'H-DEFAULT-123';
    return await _apiService.fetchVisitRecords(healthId);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    setState(() {
      _loadData();
    });
    await _visitsFuture;
  }

  void _showUploadSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: const UploadRecordBottomSheet(),
      ),
    ).then((result) {
      if (result == true && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Record uploaded and saved successfully!')),
        );
        _refresh(); // Reload the timeline to show new record
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medical Records'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refresh,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: 'Search records, doctors, diagnosis...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
          RecordFilterChips(
            selectedFilter: _selectedFilter,
            onFilterChanged: (newFilter) {
              setState(() {
                _selectedFilter = newFilter;
              });
            },
          ),
          Expanded(
            child: FutureBuilder<List<VisitGroup>>(
              future: _visitsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: Colors.red),
                        const SizedBox(height: 16),
                        Text('Error loading records:\n${snapshot.error}', textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _refresh,
                          child: const Text('Retry'),
                        )
                      ],
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      'No medical records found.',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  );
                }

                final visits = snapshot.data!;
                
                // Filter the visits based on selected document type AND search query
                final filteredVisits = visits.map((visit) {
                  // Filter documents within the visit
                  final matchingDocs = visit.documents.where((d) {
                    final matchesType = _selectedFilter == RecordType.all || d.type == _selectedFilter;
                    final matchesSearch = d.title.toLowerCase().contains(_searchQuery);
                    return matchesType && matchesSearch;
                  }).toList();

                  return VisitGroup(
                    visitId: visit.visitId,
                    visitDate: visit.visitDate,
                    diagnosis: visit.diagnosis,
                    doctorName: visit.doctorName,
                    documents: matchingDocs,
                  );
                }).where((visit) {
                  // Keep visit if it matches search (diagnosis/doctor) OR has matching documents
                  final matchesVisitSearch = visit.diagnosis.toLowerCase().contains(_searchQuery) ||
                                           visit.doctorName.toLowerCase().contains(_searchQuery);
                  
                  return visit.documents.isNotEmpty || matchesVisitSearch;
                }).toList();

                if (filteredVisits.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.search_off, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty 
                              ? 'No records found for this category.' 
                              : 'No matches found for "$_searchQuery"',
                          style: const TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: _refresh,
                  child: ListView.builder(
                    itemCount: filteredVisits.length,
                    itemBuilder: (context, index) {
                      return VisitTimelineCard(
                        visit: filteredVisits[index],
                        onRefresh: _refresh,
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 70), // Lift it above the bottom navigation bar
        child: FloatingActionButton.extended(
          onPressed: _showUploadSheet,
          icon: const Icon(Icons.add),
          label: const Text('Add Record'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
