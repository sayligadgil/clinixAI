import 'package:flutter/material.dart';

class UserSelectionScreen extends StatelessWidget {
  const UserSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      body: SafeArea(
        child: Column(
          children: [
            // 🔹 Header
            Container(
              height: 80,
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.local_hospital, color: Color(0xFF00629B)),
                  const SizedBox(width: 8),
                  const Text(
                    "CliniX AI",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF00629B),
                    ),
                  ),
                ],
              ),
            ),

            // 🔹 Title
            const SizedBox(height: 20),
            const Text(
              "Welcome to the Future of Care",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xFF004976),
              ),
            ),

            const SizedBox(height: 10),
            const Text(
              "Please select your profile to begin your personalized clinical journey.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 40),

            // 🔹 Cards
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    // Patient Card
                    Expanded(
                      child: _buildCard(
                        context,
                        title: "Patient",
                        description:
                        "Input symptoms and get an AI prescription or book a doctor.",
                        icon: Icons.person_search,
                        color: Colors.blue,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Doctor Card
                    Expanded(
                      child: _buildCard(
                        context,
                        title: "Doctor",
                        description:
                        "Manage your dashboard, alerts, and patient history.",
                        icon: Icons.medical_services,
                        color: Colors.deepPurple,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 🔹 Footer
            const Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                "© 2024 CliniAI Health Systems",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildCard(
      BuildContext context, {
        required String title,
        required String description,
        required IconData icon,
        required Color color,
      }) {
    return InkWell(
      onTap: () {
        // TODO: Navigate
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              description,
              style: const TextStyle(color: Colors.grey),
            ),
            const Spacer(),
            Row(
              children: const [
                Text(
                  "Get Started",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 6),
                Icon(Icons.arrow_forward),
              ],
            )
          ],
        ),
      ),
    );
  }
}