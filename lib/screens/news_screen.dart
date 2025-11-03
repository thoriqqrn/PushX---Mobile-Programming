import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../utils/app_colors.dart';

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

  // Daftar fun facts yang LEBIH BANYAK (minimal 30+ untuk rotasi sebulan)
  final List<Map<String, dynamic>> allFunFacts = [
    // Week 1
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
    
    // Week 2
    {
      'title': 'DID YOU KNOW?',
      'fact': 'PUSH UP\nMEMBANTU\nMENGURANGI\nSTRESS & ANXIETY',
      'icon': Icons.mood_rounded,
      'gradient': [const Color(0xFFa8edea), const Color(0xFFfed6e3)],
    },
    {
      'title': 'FUN FACT!',
      'fact': 'OTOT DADA\nMULAI TERBENTUK\nSETELAH 2 MINGGU',
      'icon': Icons.timer_rounded,
      'gradient': [const Color(0xFFffecd2), const Color(0xFFfcb69f)],
    },
    {
      'title': 'INCREDIBLE!',
      'fact': 'PUSH UP\nMENINGKATKAN\nMETABOLISME\n25 PERSEN',
      'icon': Icons.bolt_rounded,
      'gradient': [const Color(0xFFff9a9e), const Color(0xFFfecfef)],
    },
    {
      'title': 'KESEHATAN!',
      'fact': 'PUSH UP\nMENGURANGI\nRISIKO\nOSTEOPOROSIS',
      'icon': Icons.healing_rounded,
      'gradient': [const Color(0xFFfbc2eb), const Color(0xFFa6c1ee)],
    },
    {
      'title': 'MOTIVASI!',
      'fact': 'KONSISTENSI\n3 BULAN\nCUKUP UNTUK\nPERUBAHAN BESAR',
      'icon': Icons.trending_up_rounded,
      'gradient': [const Color(0xFFfdcbf1), const Color(0xFFe6dee9)],
    },
    {
      'title': 'SCIENCE!',
      'fact': 'PUSH UP\nMERILIS\nENDORPHIN\nHORMON BAHAGIA',
      'icon': Icons.psychology_rounded,
      'gradient': [const Color(0xFFa1c4fd), const Color(0xFFc2e9fb)],
    },

    // Week 3
    {
      'title': 'POWER UP!',
      'fact': 'DIAMOND\nPUSH UP\nPALING EFEKTIF\nUNTUK TRICEPS',
      'icon': Icons.star_rounded,
      'gradient': [const Color(0xFFd299c2), const Color(0xFFfef9d7)],
    },
    {
      'title': 'BOOST!',
      'fact': 'PUSH UP\nMEMPERCEPAT\nALIRAN DARAH\n30 PERSEN',
      'icon': Icons.water_drop_rounded,
      'gradient': [const Color(0xFFfad0c4), const Color(0xFFffd1ff)],
    },
    {
      'title': 'STRONG!',
      'fact': 'PLYOMETRIC\nPUSH UP\nTINGKATKAN\nPOWER LEDAKAN',
      'icon': Icons.flashlight_on_rounded,
      'gradient': [const Color(0xFFffeaa7), const Color(0xFFfdcb6e)],
    },
    {
      'title': 'ENERGY!',
      'fact': 'PUSH UP PAGI\nMENINGKATKAN\nENERGI HARIAN\n50 PERSEN',
      'icon': Icons.wb_sunny_rounded,
      'gradient': [const Color(0xFFf6d365), const Color(0xFFfda085)],
    },
    {
      'title': 'RECOVERY!',
      'fact': 'ISTIRAHAT\n48 JAM\nPENTING UNTUK\nPERTUMBUHAN OTOT',
      'icon': Icons.bed_rounded,
      'gradient': [const Color(0xFFd7d2cc), const Color(0xFF304352)],
    },
    {
      'title': 'BALANCE!',
      'fact': 'PUSH UP\nMELATIH\nKESTABILAN\nCORE MUSCLES',
      'icon': Icons.balance_rounded,
      'gradient': [const Color(0xFFe0c3fc), const Color(0xFF8ec5fc)],
    },

    // Week 4
    {
      'title': 'TECHNIQUE!',
      'fact': 'WIDE PUSH UP\nFOKUS PADA\nOTOT DADA\nBAGIAN LUAR',
      'icon': Icons.open_in_full_rounded,
      'gradient': [const Color(0xFFf093fb), const Color(0xFFf5576c)],
    },
    {
      'title': 'PROGRESS!',
      'fact': 'TAMBAH 1\nPUSH UP\nTIAP HARI\n= 365 SETAHUN',
      'icon': Icons.calendar_today_rounded,
      'gradient': [const Color(0xFF4facfe), const Color(0xFF00f2fe)],
    },
    {
      'title': 'MINDSET!',
      'fact': 'MENTAL\nSAMA PENTING\nDENGAN FISIK\nDALAM TRAINING',
      'icon': Icons.lightbulb_rounded,
      'gradient': [const Color(0xFF43e97b), const Color(0xFF38f9d7)],
    },
    {
      'title': 'NUTRITION!',
      'fact': 'PROTEIN\n20-30 GRAM\nPER MEAL\nOPTIMAL UNTUK\nOTOT',
      'icon': Icons.restaurant_rounded,
      'gradient': [const Color(0xFFfa709a), const Color(0xFFfee140)],
    },
    {
      'title': 'HYDRATION!',
      'fact': 'MINUM AIR\n2-3 LITER\nPER HARI\nMAKSIMALKAN\nPERFORMANCE',
      'icon': Icons.local_drink_rounded,
      'gradient': [const Color(0xFF667eea), const Color(0xFF764ba2)],
    },
    {
      'title': 'CONSISTENCY!',
      'fact': 'LATIHAN RUTIN\n3-4 KALI\nSEMINGGU\nKUNCI KESUKSESAN',
      'icon': Icons.verified_rounded,
      'gradient': [const Color(0xFFff6b6b), const Color(0xFFffa502)],
    },

    // Bonus Facts
    {
      'title': 'LEGENDARY!',
      'fact': 'JACK LALANNE\nDI USIA 70\nMASIH BISA\n1,000 PUSH UP',
      'icon': Icons.elderly_rounded,
      'gradient': [const Color(0xFFfbc2eb), const Color(0xFFa6c1ee)],
    },
    {
      'title': 'MILITARY!',
      'fact': 'STANDAR US ARMY\nMINIMAL 42\nPUSH UP\nDALAM 2 MENIT',
      'icon': Icons.shield_rounded,
      'gradient': [const Color(0xFFa8edea), const Color(0xFFfed6e3)],
    },
    {
      'title': 'WORLD CLASS!',
      'fact': 'ATLET OLYMPIC\nBISA 200+\nPUSH UP\nTANPA HENTI',
      'icon': Icons.workspace_premium_rounded,
      'gradient': [const Color(0xFFffecd2), const Color(0xFFfcb69f)],
    },
    {
      'title': 'TRANSFORMATION!',
      'fact': '100 PUSH UP\nSETIAP HARI\n= BODY GOALS\nDALAM 6 BULAN',
      'icon': Icons.auto_awesome_rounded,
      'gradient': [const Color(0xFFd299c2), const Color(0xFFfef9d7)],
    },
  ];

  // Fungsi untuk get daily fun facts (6 facts per hari)
  List<Map<String, dynamic>> getDailyFunFacts() {
    final today = DateTime.now();
    final dayOfYear = today.difference(DateTime(today.year, 1, 1)).inDays;
    
    // Shuffle based on day of year
    final shuffledFacts = List<Map<String, dynamic>>.from(allFunFacts);
    final seed = dayOfYear;
    final random = math.Random(seed);
    
    shuffledFacts.shuffle(random);
    
    // Return first 6 facts
    return shuffledFacts.take(6).toList();
  }

  late List<Map<String, dynamic>> funFacts;

  @override
  void initState() {
    super.initState();
    
    // Load daily fun facts
    funFacts = getDailyFunFacts();
    
    _iconController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  // ... rest of the code sama

  @override
  void dispose() {
    _pageController.dispose();
    _iconController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'NEWS',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.secondaryText(context),
                      letterSpacing: 2,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground(context),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.cardBorder(context),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '${_currentPage + 1}/${funFacts.length}',
                      style: TextStyle(
                        color: AppColors.secondaryText(context),
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
                    context,
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
                              ? AppColors.primaryText(context)
                              : AppColors.cardBorder(context),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 20),

                  // Next Button
                  _buildNavButton(
                    context,
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
            Positioned.fill(
              child: CustomPaint(
                painter: PatternPainter(
                  isDark: AppColors.isDark(context),
                ),
              ),
            ),

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

  Widget _buildNavButton(
    BuildContext context, {
    required IconData icon,
    required VoidCallback onTap,
    required bool enabled,
  }) {
    final isDark = AppColors.isDark(context);
    
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: enabled 
              ? (isDark ? Colors.white : Colors.black)
              : AppColors.cardBackground(context),
          shape: BoxShape.circle,
          border: Border.all(
            color: enabled 
                ? (isDark ? Colors.white : Colors.black)
                : AppColors.cardBorder(context),
            width: 2,
          ),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: isDark
                        ? Colors.white.withOpacity(0.3)
                        : Colors.black.withOpacity(0.2),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ]
              : [],
        ),
        child: Icon(
          icon,
          color: enabled 
              ? (isDark ? Colors.black : Colors.white)
              : AppColors.tertiaryText(context),
          size: 24,
        ),
      ),
    );
  }
}

// Custom painter untuk background pattern
class PatternPainter extends CustomPainter {
  final bool isDark;

  PatternPainter({required this.isDark});

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
  bool shouldRepaint(covariant PatternPainter oldDelegate) {
    return oldDelegate.isDark != isDark;
  }
}