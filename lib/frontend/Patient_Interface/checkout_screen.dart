import 'package:flutter/material.dart';
import 'prescription_screen.dart';
import 'package:clinixai/backend/app/models/consultation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:clinixai/core/api_client.dart';
import 'package:dio/dio.dart';
import 'dart:math' as math;

class CheckoutScreen extends StatefulWidget {
  final ConsultationData consultation;

  const CheckoutScreen({super.key, required this.consultation});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  bool _isLoading = false;

  Future<void> _payAndGenerate() async {
    final consultationId = widget.consultation.consultationId;
    if (consultationId == null || consultationId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Error: Missing consultation reference. Please re-run intake."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("User is not signed in.");
      }

      final idToken = await user.getIdToken();
      final patientUid = user.uid;

      // 1. Verify Payment & Generate Prescription (Backend will run ML model)
      final verifyResponse = await dioClient.post(
        '/patient/payment/verify',
        data: {
          'patient_uid': patientUid,
          'consultation_id': consultationId,
          'razorpay_order_id': 'order_mock_${consultationId.substring(0, math.min(8, consultationId.length))}',
          'razorpay_payment_id': 'pay_mock_${DateTime.now().millisecondsSinceEpoch}',
          'razorpay_signature': 'mock_signature_approved',
        },
        options: Options(headers: {'Authorization': 'Bearer $idToken'}),
      );

      if (verifyResponse.statusCode != 200 || verifyResponse.data == null) {
        throw Exception("Failed to verify payment with backend.");
      }

      final rxId = verifyResponse.data['prescription_id'];
      if (rxId == null) {
        throw Exception("No prescription ID returned from backend.");
      }

      // 2. Fetch the newly generated prescription details containing the medications
      final rxResponse = await dioClient.get(
        '/patient/prescription/$rxId',
        options: Options(headers: {'Authorization': 'Bearer $idToken'}),
      );

      if (rxResponse.statusCode != 200 || rxResponse.data == null) {
        throw Exception("Failed to fetch prescription medications from backend.");
      }

      final rxData = rxResponse.data;
      final List<dynamic> medsJson = rxData['medications'] ?? [];
      final parsedMedications = medsJson.map((m) => Medication.fromJson(Map<String, dynamic>.from(m))).toList();

      final generatedConsultation = ConsultationData(
        sessionId: rxData['session_id'] ?? widget.consultation.sessionId,
        patientName: rxData['patient_name'] ?? widget.consultation.patientName,
        hospitalName: rxData['hospital_name'] ?? widget.consultation.hospitalName,
        diagnosis: rxData['diagnosis'] ?? widget.consultation.diagnosis,
        confidence: (rxData['confidence_score'] ?? widget.consultation.confidence).toDouble(),
        medications: parsedMedications,
        consultationId: consultationId,
        doctorName: rxData['issuing_doctor'] ?? widget.consultation.doctorName,
        prescriptionId: rxId, // Pass real prescription ID for PDF download
      );

      if (!mounted) return;

      // Navigate to the digital prescription screen with fully populated medications!
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PrescriptionScreen(consultation: generatedConsultation),
        ),
      );
    } catch (e) {
      debugPrint("❌ Payment/Prescription Generation Error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Prescription Generation Failed: ${e.toString()}"),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
        // Fallback navigation using existing consultation data
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PrescriptionScreen(consultation: widget.consultation),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
  int _selectedPayment = 0; // 0 = card, 1 = wallet, 2 = netbanking

  final _cardController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();

  @override
  void dispose() {
    _cardController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.85),
        elevation: 1,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Icon(Icons.arrow_back, color: Color(0xFF004976)),
            ),
            const SizedBox(width: 12),
            const Text(
              'CliniX AI',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: Color(0xFF00629B),
                fontSize: 18,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: Color(0xFFCEE5FF),
              child: Icon(Icons.person, size: 18, color: Color(0xFF004976)),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Complete Your Request',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: Color(0xFF004976),
                letterSpacing: -0.8,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Secure payment for your personalized AI-driven medical insights.',
              style: TextStyle(color: Color(0xFF414750), fontSize: 14),
            ),
            const SizedBox(height: 24),

            GestureDetector(
              onTap: () => setState(() => _selectedPayment = 0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _selectedPayment == 0
                        ? const Color(0xFF004976).withOpacity(0.4)
                        : Colors.transparent,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFCEE5FF),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.credit_card,
                              color: Color(0xFF004976), size: 22),
                        ),
                        if (_selectedPayment == 0)
                          const Icon(Icons.check_circle,
                              color: Color(0xFF004976), size: 22),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Credit / Debit Card',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    const Text(
                      'Visa, Mastercard, Amex supported',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    if (_selectedPayment == 0) ...[
                      const SizedBox(height: 20),
                      _fieldLabel('Card Number'),
                      const SizedBox(height: 6),
                      _textInput(
                        controller: _cardController,
                        hint: '**** **** **** 4242',
                        type: TextInputType.number,
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _fieldLabel('Expiry'),
                                const SizedBox(height: 6),
                                _textInput(
                                  controller: _expiryController,
                                  hint: 'MM/YY',
                                  type: TextInputType.datetime,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _fieldLabel('CVV'),
                                const SizedBox(height: 6),
                                _textInput(
                                  controller: _cvvController,
                                  hint: '***',
                                  type: TextInputType.number,
                                  obscure: true,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            _paymentOptionTile(
              index: 1,
              icon: Icons.account_balance_wallet_outlined,
              title: 'Digital Wallets',
              subtitle: 'Apple Pay, Google Pay, PayPal',
            ),
            const SizedBox(height: 12),
            _paymentOptionTile(
              index: 2,
              icon: Icons.account_balance_outlined,
              title: 'Net Banking',
              subtitle: 'All major healthcare-partnered banks',
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFC2E8FF).withOpacity(0.35),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.lock_outlined, color: Color(0xFF005370), size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'HIPAA Compliant Processing',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: Color(0xFF005370),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Your payment and medical data are encrypted with bank-grade 256-bit AES security protocol.',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF005370),
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFF2F3F9),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Order Summary',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.description_outlined,
                            color: Color(0xFF004976), size: 22),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'AI Prescription Service',
                              style: TextStyle(
                                  fontWeight: FontWeight.w700, fontSize: 14),
                            ),
                            Text(
                              'Standard Consultation Analysis',
                              style: TextStyle(
                                  fontSize: 11, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      const Text(
                        '₹49.00',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF004976),
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _summaryRow('Service Fee', '₹2.50'),
                  const SizedBox(height: 10),
                  _summaryRow('Clinical Verification', 'Included'),
                  const SizedBox(height: 16),
                  const Divider(color: Color(0xFFC0C7D1), thickness: 0.5),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        'Total Amount',
                        style: TextStyle(
                            fontWeight: FontWeight.w800, fontSize: 16),
                      ),
                      Text(
                        '₹51.50',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 24,
                          color: Color(0xFF004976),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFC0C7D1).withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.auto_awesome,
                            color: Color(0xFF006688), size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'AI INSIGHT',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF006688),
                                  letterSpacing: 1,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Patients using AI-verification reduce medication conflict risks by 34% on average.',
                                style: TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF414750),
                                    height: 1.5),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _payAndGenerate,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF004976),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999)),
                        elevation: 4,
                        shadowColor: const Color(0xFF004976).withOpacity(0.3),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.verified_user, size: 20),
                                SizedBox(width: 10),
                                Text(
                                  'Pay and Generate',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w800, fontSize: 16),
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Center(
                    child: Text(
                      'INSTANT ACCESS TO DIGITAL RECORDS UPON PAYMENT',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 12)],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _navItem(
                  icon: Icons.home_outlined,
                  label: 'Home',
                  onTap: () => Navigator.popUntil(
                      context, (route) => route.isFirst),
                ),
                _navItem(
                  icon: Icons.settings_outlined,
                  label: 'Settings',
                  onTap: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _paymentOptionTile({
    required int index,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final selected = _selectedPayment == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedPayment = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF2F3F9),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? const Color(0xFF004976).withOpacity(0.4)
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: const Color(0xFF004976), size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 14)),
                  Text(subtitle,
                      style:
                      const TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
            ),
            Icon(
              selected ? Icons.check_circle : Icons.chevron_right,
              color: selected ? const Color(0xFF004976) : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _fieldLabel(String text) => Text(
    text.toUpperCase(),
    style: const TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w700,
      color: Color(0xFF414750),
      letterSpacing: 1,
    ),
  );

  Widget _textInput({
    required TextEditingController controller,
    required String hint,
    required TextInputType type,
    bool obscure = false,
  }) =>
      TextField(
        controller: controller,
        keyboardType: type,
        obscureText: obscure,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
          filled: true,
          fillColor: const Color(0xFFF2F3F9),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        ),
      );

  Widget _summaryRow(String label, String value) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(label,
          style: const TextStyle(fontSize: 13, color: Colors.grey)),
      Text(value,
          style: const TextStyle(fontSize: 13, color: Colors.grey)),
    ],
  );

  Widget _navItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) =>
      GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: const Color(0xFF004976), size: 24),
            const SizedBox(height: 4),
            Text(label,
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF004976))),
          ],
        ),
      );
}