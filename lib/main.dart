import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:google_fonts/google_fonts.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HealthHomePage(),
    );
  }
}

class HealthHomePage extends StatelessWidget {
  const HealthHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tiêu đề và thời tiết
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Theo dõi",
                      style: GoogleFonts.nunito(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF3C3C66),
                      )),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Color(0xFFBBDEFB),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.cloud_outlined, size: 18),
                        SizedBox(width: 4),
                        Text('26°C'),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Tim + nhịp tim + 2 nút
              Container(
                height: 120,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFD6D6), Color(0xFFB3E5FC)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Stack(
                  children: [
                    Row(
                      children: [
                        // Tim đập
                        SizedBox(
                          width: 80,
                          height: 80,
                          child:
                              Lottie.asset('assets/animations/heart-beat.json'),
                        ),
                        const SizedBox(width: 12),
                        // Nhịp tim
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Text(
                              'Nhịp tim',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 14),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '78 bpm',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),

                    // Nút Lịch sử
                    Positioned(
                      right: 0,
                      top: 0,
                      child: TextButton.icon(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                        ),
                        icon: const Icon(Icons.history, size: 18),
                        label: const Text("Lịch sử",
                            style: TextStyle(fontSize: 14)),
                      ),
                    ),

                    // Nút Đo ngay
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.red.shade400,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text('Đo ngay'),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              Text("Nhật ký sức khỏe",
                  style: GoogleFonts.nunito(
                      fontSize: 20, fontWeight: FontWeight.bold)),

              const SizedBox(height: 16),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.0,
                  children: [
                    _buildHealthCard(
                      title: 'Huyết áp',
                      value: '100/76',
                      unit: 'mmHg',
                      asset: 'assets/images/blood_pressure.png',
                      bgColor: const Color(0xFFEFF4FB),
                    ),
                    _buildHealthCard(
                      title: 'Đường huyết',
                      value: '4,4',
                      unit: 'mmol/L',
                      asset: 'assets/images/glucose.png',
                      bgColor: const Color(0xFFEFF4FB),
                    ),
                    _buildHealthCard(
                      title: 'BMI',
                      value: '--',
                      unit: 'KG',
                      asset: 'assets/images/bmi.png',
                      bgColor: const Color(0xFFEFF4FB),
                    ),
                    _buildHealthCard(
                      title: 'Uống nước',
                      value: '0',
                      unit: '/2000ml',
                      asset: 'assets/images/water.png',
                      bgColor: const Color(0xFFEFF4FB),
                    ),
                    _buildHealthCard(
                      title: 'Bác sĩ AI',
                      value: '',
                      unit: '',
                      asset: 'assets/images/doctor_ai.png',
                      bgColor: const Color(0xFFEFF4FB),
                    ),
                    _buildHealthCard(
                      title: 'Máy quét thực phẩm',
                      value: '',
                      unit: '',
                      asset: 'assets/images/scanner.png',
                      bgColor: const Color(0xFFEFF4FB),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget xây dựng các ô nhật ký sức khỏe
  Widget _buildHealthCard({
    required String title,
    required String value,
    required String unit,
    required String asset,
    required Color bgColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            asset,
            height: 72,
            alignment: Alignment.centerLeft,
            fit: BoxFit.contain,
          ),
          const Spacer(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                unit,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF666666),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Color(0xFF3C3C66),
            ),
          ),
        ],
      ),
    );
  }
}
