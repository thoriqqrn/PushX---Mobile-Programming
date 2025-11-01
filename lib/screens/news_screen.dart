// lib/screens/news_screen.dart (Premium Edition with Fun Facts)

import 'package:flutter/material.dart';
import 'dart:math' as math;

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController(viewportFraction: 0.85);
  int _currentPage = 0;
  AnimationController? _iconController;

  // Daftar fun facts tentang push up
  final List<Map<String, dynamic>> funFacts = [
    {
      'title': 'FUNFACT PUSH UP\nHARI INI !!!',
      'fact': 'PUSH UP\nMEREDAKAN\n150 PERSEN\nMASALAH\nHIDUP ANDA',
      'icon': Icons.self_improvement_rounded,
      'gradient': [const Color(0xFF667eea), const Color(0xFF764ba2)],
    },
    {
      'title': 'TAHUKAH KAMU?',
      'fact': 'PUSH UP\nMELATIH\n3 KELOMPOK\nOTOT UTAMA\nSEKALIGUS',
      'icon': Icons.fitness_center_rounded,
      'gradient': [const Color(0xFFf093fb), const Color(0xFFf5576c)],
    },
    {
      'title': 'FAKTA MENARIK!',
      'fact': 'PUSH UP\nSELAMA\n5 MENIT\nMEMBAKAR\n30 KALORI',
      'icon': Icons.local_fire_department_rounded,
      'gradient': [const Color(0xFFfa709a), const Color(0xFFfee140)],
    },
    {
      'title': 'AMAZING FACT!',
      'fact': 'REKOR DUNIA\nPUSH UP\n1 JAM ADALAH\n3,877 KALI',
      'icon': Icons.emoji_events_rounded,
      'gradient': [const Color(0xFF4facfe), const Color(0xFF00f2fe)],
    },
    {
      'title': 'WAJIB TAHU!',
      'fact': 'PUSH UP\nMENINGKATKAN\nKESEHATAN\nJANTUNG 40%',
      'icon': Icons.favorite_rounded,
      'gradient': [const Color(0xFFff6b6b), const Color(0xFFffa502)],
    },
    {
      'title': 'SUPER BENEFIT!',
      'fact': 'PUSH UP\nMEMPERKUAT\nTULANG DAN\nPOSTUR TUBUH',
      'icon': Icons.accessibility_new_rounded,
      'gradient': [const Color(0xFF43e97b), const Color(0xFF38f9d7)],
    },
  ];

  @override
  void initState() {
    super.initState();
    _iconController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _iconController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'NEWS',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey,
                      letterSpacing: 2,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey[800]!, width: 1),
                    ),
                    child: Text(
                      '${_currentPage + 1}/${funFacts.length}',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Swipeable Cards
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: funFacts.length,
                itemBuilder: (context, index) {
                  return AnimatedBuilder(
                    animation: _pageController,
                    builder: (context, child) {
                      double value = 1.0;
                      if (_pageController.position.haveDimensions) {
                        value = _pageController.page! - index;
                        value = (1 - (value.abs() * 0.3)).clamp(0.0, 1.0);
                      }
                      return Center(
                        child: SizedBox(
                          height: Curves.easeInOut.transform(value) * 550,
                          child: child,
                        ),
                      );
                    },
                    child: _buildFunFactCard(funFacts[index]),
                  );
                },
              ),
            ),

            // Navigation Indicators
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Previous Button
                  _buildNavButton(
                    icon: Icons.chevron_left_rounded,
                    onTap: () {
                      if (_currentPage > 0) {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    enabled: _currentPage > 0,
                  ),

                  const SizedBox(width: 20),

                  // Dots Indicator
                  Row(
                    children: List.generate(
                      funFacts.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? Colors.white
                              : Colors.grey[800],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 20),

                  // Next Button
                  _buildNavButton(
                    icon: Icons.chevron_right_rounded,
                    onTap: () {
                      if (_currentPage < funFacts.length - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    enabled: _currentPage < funFacts.length - 1,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildFunFactCard(Map<String, dynamic> fact) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: fact['gradient'],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: fact['gradient'][0].withOpacity(0.4),
            blurRadius: 30,
            offset: const Offset(0, 15),
            spreadRadius: 5,
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: Colors.white.withOpacity(0.2), width: 2),
        ),
        child: Stack(
          children: [
            // Background pattern
            Positioned.fill(child: CustomPaint(painter: PatternPainter())),

            // Content
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Title
                    Text(
                      fact['title'],
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 1,
                        height: 1.2,
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Icon with animation
                    if (_iconController != null)
                      AnimatedBuilder(
                        animation: _iconController!,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: 1.0 + (_iconController!.value * 0.2),
                            child: Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 2,
                                ),
                              ),
                              child: Icon(
                                fact['icon'],
                                size: 60,
                                color: Colors.white,
                              ),
                            ),
                          );
                        },
                      ),

                    const SizedBox(height: 40),

                    // Main Fact Text
                    Text(
                      fact['fact'],
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 0.5,
                        height: 1.2,
                        shadows: [
                          Shadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool enabled,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: enabled ? Colors.white : Colors.grey[900],
          shape: BoxShape.circle,
          border: Border.all(
            color: enabled ? Colors.white : Colors.grey[800]!,
            width: 2,
          ),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.3),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ]
              : [],
        ),
        child: Icon(
          icon,
          color: enabled ? Colors.black : Colors.grey[700],
          size: 24,
        ),
      ),
    );
  }
}

// Custom painter untuk background pattern
class PatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Draw circles pattern
    for (int i = 0; i < 5; i++) {
      canvas.drawCircle(
        Offset(size.width * 0.2, size.height * (0.2 + i * 0.15)),
        20 + (i * 10),
        paint,
      );
      canvas.drawCircle(
        Offset(size.width * 0.8, size.height * (0.3 + i * 0.15)),
        15 + (i * 8),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
