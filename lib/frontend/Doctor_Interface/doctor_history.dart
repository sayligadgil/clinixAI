import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'doctor_notifs.dart';

// REUSING THE COLORS FROM PREVIOUS SCREEN FOR CONSISTENCY
class CliniColor {
  static const primary = Color(0xFF004976);
  static const primaryContainer = Color(0xFF00629B);
  static const primaryFixed = Color(0xFFCEE5FF);
  static const onPrimaryFixed = Color(0xFF001D33);
  static const secondary = Color(0xFF006688);
  static const secondaryFixed = Color(0xFFC2E8FF);
  static const secondaryFixedDim = Color(0xFF75D1FF);
  static const surface = Color(0xFFF8F9FF);
  static const surfaceContainerLow = Color(0xFFF2F3F9);
  static const surfaceContainerHigh = Color(0xFFE6E8ED);
  static const surfaceContainerHighest = Color(0xFFE1E2E8);
  static const onSurface = Color(0xFF191C20);
  static const onSurfaceVariant = Color(0xFF414750);
  static const tertiaryFixed = Color(0xFFE0E0FF);
  static const onTertiaryFixed = Color(0xFF000767);
  static const errorContainer = Color(0xFFFFDAD6);
  static const onErrorContainer = Color(0xFF93000A);
}

// --- Data Models ---

class ConsultationResponse {
  final String id;
  final String patientName;
  final String category;
  final String date;
  final bool isAiPredicted;
  final String initials;

  ConsultationResponse({
    required this.id,
    required this.patientName,
    required this.category,
    required this.date,
    required this.isAiPredicted,
    required this.initials,
  });

  factory ConsultationResponse.fromJson(Map<String, dynamic> json) {
    String name = json['patient_name'] ?? 'Unknown';
    return ConsultationResponse(
      id: json['consultation_id'] ?? '#PX-0000',
      patientName: name,
      category: json['category'] ?? 'General',
      date: json['formatted_date'] ?? 'No Date',
      isAiPredicted: json['status'] == 'ai_generated', // logic based on your backend status
      initials: name.trim().split(' ').map((e) => e[0]).take(2).join().toUpperCase(),
    );
  }
}

class PatientHistoryScreen extends StatefulWidget {
  const PatientHistoryScreen({super.key});

  @override
  State<PatientHistoryScreen> createState() => _PatientHistoryScreenState();
}

class _PatientHistoryScreenState extends State<PatientHistoryScreen> {
  late Future<List<ConsultationResponse>> _historyFuture;
  List<ConsultationResponse> _allRecords = [];
  List<ConsultationResponse> _filteredRecords = [];
  final TextEditingController _searchController = TextEditingController();

  // Backend Config
  final String baseUrl = kIsWeb ? 'http://localhost:8000' : 'http://10.0.2.2:8000';
  String token = "YOUR_BEARER_TOKEN";
  String hospitalId = "HOSP_001";

  @override
  void initState() {
    super.initState();
    _historyFuture = Future.value([]);
    _loadTokenAndHistory();
  }

  Future<void> _loadTokenAndHistory() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      token = prefs.getString('token') ?? "YOUR_BEARER_TOKEN";
      hospitalId = prefs.getString('hospital_id') ?? "HOSP_001";
      _historyFuture = _fetchHistory();
    });
  }

  Future<List<ConsultationResponse>> _fetchHistory() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/doctor/consultations?hospital_id=$hospitalId&status=completed'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        _allRecords = data.map((json) => ConsultationResponse.fromJson(json)).toList();
        _filteredRecords = List.from(_allRecords);
        return _allRecords;
      } else {
        throw Exception('Failed to fetch records');
      }
    } catch (e) {
      throw Exception('Connection Error: $e');
    }
  }

  void _filterSearch(String query) {
    setState(() {
      _filteredRecords = _allRecords
          .where((record) =>
      record.patientName.toLowerCase().contains(query.toLowerCase()) ||
          record.id.toLowerCase().contains(query.toLowerCase()) ||
          record.category.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CliniColor.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            pinned: true,
            backgroundColor: Colors.white.withOpacity(0.8),
            elevation: 0,
            centerTitle: false,
            title: Row(
              children: [
                const CircleAvatar(
                  radius: 18,
                  backgroundImage: NetworkImage('https://lh3.googleusercontent.com/aida-public/...'),
                ),
                const SizedBox(width: 12),
                const Text('CliniX AI',
                  style: TextStyle(color: CliniColor.primaryContainer, fontWeight: FontWeight.w900, letterSpacing: -1),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined, color: CliniColor.primary),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AlertDashboard())),
              ),
              const SizedBox(width: 8),
            ],
          ),

          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 24),
                const Text('Patient Records',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: CliniColor.primary, letterSpacing: -0.5),
                ),
                const SizedBox(height: 24),

                TextField(
                  controller: _searchController,
                  onChanged: _filterSearch,
                  decoration: InputDecoration(
                    hintText: 'Search by name, ID or disease...',
                    hintStyle: TextStyle(color: CliniColor.onSurfaceVariant.withOpacity(0.6)),
                    prefixIcon: const Icon(Icons.search, color: CliniColor.onSurfaceVariant),
                    filled: true,
                    fillColor: CliniColor.surfaceContainerLow,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(vertical: 20),
                  ),
                ),
                const SizedBox(height: 16),

                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildFilterChip('All Records', isActive: true),
                      _buildFilterChip('AI-Predicted'),
                      _buildFilterChip('Doctor-Attended'),
                      _buildFilterChip('Urgent'),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Database Driven List
                FutureBuilder<List<ConsultationResponse>>(
                  future: _historyFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()));
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error loading history: ${snapshot.error}'));
                    } else if (!snapshot.hasData || _allRecords.isEmpty) {
                      return const Center(child: Text('No records found in database.'));
                    }

                    return Column(
                      children: _filteredRecords.map((record) {
                        return RecordEntry(
                          initials: record.initials,
                          name: record.patientName,
                          id: record.id,
                          category: record.category,
                          date: record.date,
                          isAiPredicted: record.isAiPredicted,
                          // Dynamic colors based on category or prediction
                          avatarColor: record.isAiPredicted ? CliniColor.primaryFixed : CliniColor.surfaceContainerHigh,
                          textColor: record.isAiPredicted ? CliniColor.onPrimaryFixed : CliniColor.onSurfaceVariant,
                        );
                      }).toList(),
                    );
                  },
                ),

                const SizedBox(height: 24),
                const AiInsightCard(),
                const SizedBox(height: 100),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, {bool isActive = false}) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? CliniColor.primary : CliniColor.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Text(label,
          style: TextStyle(color: isActive ? Colors.white : CliniColor.onSurfaceVariant, fontSize: 13, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}

// --- Components (Preserving UI logic) ---

class RecordEntry extends StatefulWidget {
  final String initials, name, id, category, date;
  final bool isAiPredicted;
  final Color avatarColor, textColor;

  const RecordEntry({
    super.key, required this.initials, required this.name, required this.id,
    required this.category, required this.date, required this.isAiPredicted,
    required this.avatarColor, required this.textColor,
  });

  @override
  State<RecordEntry> createState() => _RecordEntryState();
}

class _RecordEntryState extends State<RecordEntry> {
  bool _isReviewed = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _isReviewed ? Colors.green.withOpacity(0.03) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: _isReviewed ? Border.all(color: Colors.green.withOpacity(0.3), width: 1.5) : null,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Checkbox(
            value: _isReviewed,
            activeColor: Colors.green,
            onChanged: (bool? val) {
              setState(() {
                _isReviewed = val ?? false;
              });
              if (_isReviewed) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('✅ Patient record ${widget.id} marked as fully reviewed & completed.'),
                    backgroundColor: Colors.green,
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
          ),
          const SizedBox(width: 8),
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(color: widget.avatarColor, borderRadius: BorderRadius.circular(12)),
            alignment: Alignment.center,
            child: Text(widget.initials, style: TextStyle(color: widget.textColor, fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, decoration: _isReviewed ? TextDecoration.lineThrough : null)),
                Text(widget.id, style: const TextStyle(color: CliniColor.onSurfaceVariant, fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: widget.isAiPredicted ? CliniColor.secondaryFixed.withOpacity(0.3) : CliniColor.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(20),
                  border: widget.isAiPredicted ? Border.all(color: CliniColor.secondary.withOpacity(0.1)) : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(widget.isAiPredicted ? Icons.psychology : Icons.medical_services_outlined, size: 14,
                        color: widget.isAiPredicted ? CliniColor.secondary : CliniColor.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(widget.isAiPredicted ? 'AI-Predicted' : 'Doctor-Attended',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: widget.isAiPredicted ? CliniColor.secondary : CliniColor.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(widget.date, style: const TextStyle(fontSize: 11, color: CliniColor.onSurfaceVariant)),
            ],
          ),
        ],
      ),
    );
  }
}

class AiInsightCard extends StatelessWidget {
  const AiInsightCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [CliniColor.secondaryFixed, CliniColor.surface], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: CliniColor.secondary.withOpacity(0.1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.auto_awesome, color: CliniColor.secondary),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Weekly Database Insight', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                SizedBox(height: 4),
                Text("We've noticed a 15% increase in Cardiology scans this month. CliniAI has pre-sorted these records for your review.",
                  style: TextStyle(fontSize: 13, color: CliniColor.onSurfaceVariant, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}