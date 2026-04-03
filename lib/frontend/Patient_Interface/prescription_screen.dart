import 'package:flutter/material.dart';
import 'user_selection_screen.dart';

class PrescriptionScreen extends StatelessWidget {
  const PrescriptionScreen({super.key}); // required

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),

      // 🔹 APP BAR
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF004976)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "CliniX AI",
          style: TextStyle(
            color: Color(0xFF00629B),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.grey),
            onPressed: () {},
          )
        ],
      ),

      // 🔹 BODY
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TITLE
            const Text(
              "Digital Prescription",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF004976),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              "Session ID: #CAI-99283-24",
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 20),

            // 🔹 PATIENT + HOSPITAL CARD
            _card(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Patient Details",
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontWeight: FontWeight.bold)),

                  const SizedBox(height: 6),
                  const Text(
                    "Alexander J. Sterling",
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 4),
                  const Text("Age: 32  |  Male  |  78kg"),

                  const SizedBox(height: 20),

                  const Text("Issued By",
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontWeight: FontWeight.bold)),

                  const SizedBox(height: 6),
                  const Text(
                    "St. Jude Medical Center",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF004976)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 🔹 AI RESULT
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFC2E8FF),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: const [
                  Row(
                    children: [
                      Icon(Icons.psychology, color: Color(0xFF004976)),
                      SizedBox(width: 8),
                      Text(
                        "AI Diagnostic Result",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF004976)),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Text(
                    "Acute Bacterial Sinusitis",
                    style:
                    TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text("Confidence: 92%"),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 🔹 MEDICATION LIST
            _card(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Suggested Medications",
                    style:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 12),

                  _medTile(
                    title: "Amoxicillin (500mg)",
                    desc: "Twice daily after meals for 7 days",
                    qty: "14 Capsules",
                  ),

                  _medTile(
                    title: "Guaifenesin (600mg)",
                    desc: "One tablet every 12 hours",
                    qty: "10 Tablets",
                  ),

                  _medTile(
                    title: "Saline Nasal Spray",
                    desc: "Use as needed",
                    qty: "1 Unit",
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 🔹 DISCLAIMER
            Row(
              children: const [
                Icon(Icons.info_outline, color: Colors.grey),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "This prescription is AI-assisted and follows hospital protocols.",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // 🔹 DOWNLOAD BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.download),
                label: const Text("Download PDF"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF004976),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),

      // 🔹 BOTTOM NAV (HOME ONLY)
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const UserSelectionScreen()),
                      (route) => false,
                );
              },
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.home, color: Color(0xFF004976)),
                  Text("Home"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 CARD WIDGET
  static Widget _card(Widget child) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }
}

// 🔹 MED TILE
class _medTile extends StatelessWidget {
  final String title;
  final String desc;
  final String qty;

  const _medTile({
    required this.title,
    required this.desc,
    required this.qty,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(desc, style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          Text(qty,
              style: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}