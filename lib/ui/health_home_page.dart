import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../screen.dart';

class HealthHomePage extends StatefulWidget {
  const HealthHomePage({super.key});

  @override
  State<HealthHomePage> createState() => _HealthHomePageState();
}

class _HealthHomePageState extends State<HealthHomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<HeartRateManager>().loadLatestHeartRate();
      await context.read<HeartRateManager>().loadHistoryWithAutoRange();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final manager = Provider.of<HeartRateManager>(context);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await context.read<HeartRateManager>().loadLatestHeartRate();
            await context.read<HeartRateManager>().loadHistoryWithAutoRange();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tiêu đề + menu người dùng
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Theo dõi",
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      Consumer<AuthManager>(
                        builder: (context, authManager, _) {
                          final displayName =
                              authManager.userName ?? 'Người dùng';
                          final photoUrl = authManager.photoURL;

                          return PopupMenuButton<int>(
                            offset: const Offset(0, 48),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            color: theme.colorScheme.surface,
                            elevation: 4,
                            onSelected: (value) async {
                              if (value == 1) {
                                await Provider.of<AuthManager>(context,
                                        listen: false)
                                    .signOut();
                                Navigator.pushReplacementNamed(
                                    context, '/login');
                              } else if (value == 2) {
                                Provider.of<ThemeManager>(context,
                                        listen: false)
                                    .toggleTheme();
                              }
                            },
                            itemBuilder: (context) => [
                              PopupMenuItem<int>(
                                value: 2,
                                child: Row(
                                  children: [
                                    Icon(
                                      isDark
                                          ? Icons.light_mode
                                          : Icons.dark_mode,
                                      color: theme.colorScheme.secondary,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      isDark ? 'Chế độ sáng' : 'Chế độ tối',
                                      style:
                                          theme.textTheme.bodyMedium?.copyWith(
                                        color: theme.colorScheme.primary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const PopupMenuDivider(),
                              PopupMenuItem<int>(
                                value: 1,
                                child: Row(
                                  children: [
                                    Icon(Icons.logout,
                                        color: theme.colorScheme.primary),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Đăng xuất',
                                      style:
                                          theme.textTheme.bodyMedium?.copyWith(
                                        color: theme.colorScheme.primary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 18,
                                  backgroundImage: photoUrl != null
                                      ? NetworkImage(photoUrl)
                                      : null,
                                  backgroundColor: Colors.grey[300],
                                  child: photoUrl == null
                                      ? const Icon(Icons.person, size: 18)
                                      : null,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  displayName,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                                const Icon(Icons.arrow_drop_down),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Card Nhịp tim
                  Container(
                    height: 120,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? [
                                theme.colorScheme.primary.withOpacity(0.4),
                                theme.colorScheme.secondary.withOpacity(0.4)
                              ]
                            : [
                                const Color(0xFFB3E5FC),
                                const Color(0xFF81D4FA)
                              ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Stack(
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              width: 80,
                              height: 80,
                              child: Lottie.asset(
                                  'assets/animations/heart-beat.json'),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Nhịp tim',
                                  style: theme.textTheme.bodySmall
                                      ?.copyWith(color: Colors.white70),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  manager.isLoading
                                      ? "Đang tải..."
                                      : (manager.latestHeartRate != null
                                          ? "${manager.latestHeartRate} bpm"
                                          : "Chưa có"),
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: TextButton.icon(
                            onPressed: () {
                              Navigator.pushNamed(context, '/heartRateHistory');
                            },
                            style: TextButton.styleFrom(
                                foregroundColor: Colors.white),
                            icon: const Icon(Icons.history, size: 18),
                            label: const Text("Lịch sử",
                                style: TextStyle(fontSize: 14)),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/heartRateCamera');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: theme.colorScheme.primary,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),
                            ),
                            child: const Text('Đo ngay'),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  Text(
                    "Nhật ký sức khỏe",
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),

                  const SizedBox(height: 16),
                  GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.0,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildHealthCard(context, 'Huyết áp',
                          'assets/images/blood_pressure.png', () {
                        Navigator.pushNamed(context, '/bloodPressure');
                      }),
                      _buildHealthCard(context, 'Đường huyết',
                          'assets/images/glucose.png', () {}),
                      _buildHealthCard(
                          context, 'BMI', 'assets/images/bmi.png', () {}),
                      _buildHealthCard(
                          context, 'Uống nước', 'assets/images/water.png', () {
                        Navigator.pushNamed(context, '/water');
                      }),
                      _buildHealthCard(context, 'Bác sĩ AI',
                          'assets/images/doctor_ai.png', () {}),
                      _buildHealthCard(context, 'Máy quét thực phẩm',
                          'assets/images/scanner.png', () {}),
                      _buildHealthCard(
                          context, 'Bộ đếm bước', 'assets/images/steps.png',
                          () {
                        Navigator.pushNamed(context, '/step');
                      }),
                      _buildHealthCard(
                          context, 'Giấc ngủ', 'assets/images/sleep.png', () {
                        Navigator.pushNamed(context, '/sleep');
                      }),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHealthCard(
      BuildContext context, String title, String asset, VoidCallback onTap) {
    final theme = Theme.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: theme.brightness == Brightness.light
              ? [
                  const BoxShadow(
                      color: Color(0x11000000),
                      blurRadius: 4,
                      offset: Offset(2, 2))
                ]
              : [],
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(asset, height: 64, fit: BoxFit.contain),
            const Spacer(),
            Text(
              title,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
