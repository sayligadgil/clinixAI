import 'package:flutter/material.dart';

class CarePathScreen extends StatelessWidget {
  const CarePathScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),

      // 🔷 AppBar
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.8),
        elevation: 1,
        title: const Text(
          "CliniX AI",
          style: TextStyle(
            color: Color(0xFF00629B),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: const [
          Icon(Icons.notifications, color: Colors.grey),
          SizedBox(width: 10),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // 🔷 Header
            const Text(
              "Analysis complete.\nHow would you like to proceed?",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF004976),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Choose a care path based on urgency.",
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 30),

            // 🔷 Option 1 — AI Prescription
            _optionCard(
              context,
              icon: Icons.psychology,
              title: "Generate AI Prescription",
              description:
              "AI-based analysis for common conditions.",
              color: const Color(0xFFC2E8FF),
              buttonText: "₹499",
              onTap: () {
                // TODO: Payment screen
              },
            ),

            const SizedBox(height: 20),

            // 🔷 Option 2 — Appointment
            _optionCard(
              context,
              icon: Icons.calendar_month,
              title: "Book Appointment",
              description:
              "Schedule with a doctor for detailed care.",
              color: const Color(0xFFF2F3F9),
              buttonText: "Nearest Hospital",
              onTap: () {
                // TODO: Appointment screen
              },
            ),

            const SizedBox(height: 30),

            // 🔷 Info Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Quick Tip",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF004976),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "AI suggests 78% match for seasonal allergies. AI prescription can provide quick relief.",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // 🔷 Bottom Navigation
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        selectedItemColor: const Color(0xFF004976),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: "Schedule"),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: "History"),
          BottomNavigationBarItem(icon: Icon(Icons.psychology), label: "AI Log"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
        ],
      ),
    );
  }

  Widget _optionCard(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String description,
        required Color color,
        required String buttonText,
        required VoidCallback onTap,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 40, color: const Color(0xFF004976)),
            const SizedBox(height: 15),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(description),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  buttonText,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const Icon(Icons.arrow_forward),
              ],
            )
          ],
        ),
      ),
    );
  }
}