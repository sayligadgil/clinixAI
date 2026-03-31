import 'package:flutter/material.dart';

class DoctorLoginScreen extends StatefulWidget {
  const DoctorLoginScreen({super.key});

  @override
  State<DoctorLoginScreen> createState() => _DoctorLoginScreenState();
}

class _DoctorLoginScreenState extends State<DoctorLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String doctorId = "";
  String password = "";
  bool hidePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // 🔹 HEADER (matches HTML)
              Container(
                height: 70,
                alignment: Alignment.center,
                child: const Text(
                  "CliniX AI",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF004976),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // 🔹 MAIN CONTAINER (IMPORTANT)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                    )
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 🔹 TITLE
                      const Text(
                        "Doctor Login",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF004976),
                        ),
                      ),

                      const SizedBox(height: 8),

                      const Text(
                        "Access your practitioner dashboard",
                        style: TextStyle(color: Colors.grey),
                      ),

                      const SizedBox(height: 30),

                      // 🔹 SECTION LABEL (like 01)
                      Row(
                        children: const [
                          CircleAvatar(
                            radius: 14,
                            backgroundColor: Color(0xFFE6E8ED),
                            child: Text("01", style: TextStyle(fontSize: 12)),
                          ),
                          SizedBox(width: 10),
                          Text(
                            "Credentials",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          )
                        ],
                      ),

                      const SizedBox(height: 20),

                      // 🔹 DOCTOR ID
                      const Text("Doctor ID",
                          style: TextStyle(fontWeight: FontWeight.w500)),
                      const SizedBox(height: 6),

                      TextFormField(
                        decoration: InputDecoration(
                          hintText: "Enter your ID",
                          filled: true,
                          fillColor: const Color(0xFFF2F3F9),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (v) => v!.isEmpty ? "Required" : null,
                        onSaved: (v) => doctorId = v!,
                      ),

                      const SizedBox(height: 20),

                      // 🔹 PASSWORD
                      const Text("Password",
                          style: TextStyle(fontWeight: FontWeight.w500)),
                      const SizedBox(height: 6),

                      TextFormField(
                        obscureText: hidePassword,
                        decoration: InputDecoration(
                          hintText: "••••••••",
                          filled: true,
                          fillColor: const Color(0xFFF2F3F9),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(hidePassword
                                ? Icons.visibility
                                : Icons.visibility_off),
                            onPressed: () {
                              setState(() {
                                hidePassword = !hidePassword;
                              });
                            },
                          ),
                        ),
                        validator: (v) => v!.isEmpty ? "Required" : null,
                        onSaved: (v) => password = v!,
                      ),

                      const SizedBox(height: 30),

                      // 🔹 BUTTON (gradient like HTML)
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: EdgeInsets.zero,
                          ),
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              _formKey.currentState!.save();
                              // TODO: navigate
                            }
                          },
                          child: Ink(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF004976),
                                  Color(0xFF00629B),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: const Center(
                              child: Text(
                                "Login",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // 🔹 FOOTER LINK
                      Center(
                        child: TextButton(
                          onPressed: () {},
                          child: const Text(
                            "Create Practitioner Account",
                            style: TextStyle(color: Color(0xFF004976)),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
