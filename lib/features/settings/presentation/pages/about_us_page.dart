import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  final String _igLogoUrl =
      "https://img.lovepik.com/png/20231104/instagram-black-and-white-icon-red-facebook-instagram-logo_494361_wh860.png";
  final String _ghLogoUrl =
      "https://github.githubassets.com/assets/GitHub-Mark-ea2971cee799.png";

  final List<Map<String, String>> _teamMembers = const [
    {
      "name": "Riski Rahmattillah P",
      "role": "Team Lead & Fullstack",
      "image": "assets/images/rahmat.jpg",
      "ig": "https://www.instagram.com/rrahmat_prt?utm_source=ig_web_button_share_sheet&igsh=ZDNlZDc0MzIxNw==",
      "gh": "https://github.com/rahmatsigma",
    },
    {
      "name": "Anggota Dua",
      "role": "Frontend Developer",
      "image": "assets/images/anggota2.jpg",
      "ig": "https://instagram.com",
      "gh": "https://github.com",
    },
    {
      "name": "Anggota Tiga",
      "role": "Backend Engineer",
      "image": "assets/images/anggota3.jpg",
      "ig": "https://instagram.com",
      "gh": "https://github.com",
    },
    {
      "name": "Anggota Empat",
      "role": "UI/UX Designer",
      "image": "assets/images/anggota4.jpg",
      "ig": "https://instagram.com",
      "gh": "https://github.com",
    },
    {
      "name": "Anggota Lima",
      "role": "Mobile Developer",
      "image": "assets/images/anggota5.jpg",
      "ig": "https://instagram.com",
      "gh": "https://github.com",
    },
    {
      "name": "Anggota Enam",
      "role": "Quality Assurance",
      "image": "assets/images/anggota6.jpg",
      "ig": "https://instagram.com",
      "gh": "https://github.com",
    },
    {
      "name": "Anggota Tujuh",
      "role": "Project Manager",
      "image": "assets/images/anggota7.jpg",
      "ig": "https://instagram.com",
      "gh": "https://github.com",
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Deteksi lebar layar
    final double screenWidth = MediaQuery.of(context).size.width;

    // Logic Kolom: HP=2, Tablet=3, Desktop=5
    int crossAxisCount = 2;
    if (screenWidth > 600) crossAxisCount = 3;
    if (screenWidth > 900) crossAxisCount = 5;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Tentang Kami"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => context.pop(),
        ),
      ),
      // Gunakan CustomScrollView biar Header dan Grid nyatu scrollnya
      body: CustomScrollView(
        slivers: [
          // --- 1. HEADER (Info Aplikasi) ---
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 10),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.blueAccent.withOpacity(0.1),
                      border: Border.all(color: Colors.blueAccent, width: 2),
                    ),
                    child: const Icon(
                      Icons.menu_book_rounded,
                      size: 50,
                      color: Colors.blueAccent,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "MangaRead",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    "Versi 1.0.0",
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Selamat datang di dunia manga dan komik digital tanpa batas! Aplikasi kami adalah sebuah platform yang didedikasikan untuk para pecinta manga, manhua, dan manhwa di seluruh dunia. Dibuat dari hasrat mendalam terhadap seni penceritaan visual, kami bertujuan untuk memberikan pengalaman membaca yang paling nyaman, imersif, dan kaya akan fitur langsung di genggaman Anda.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Row(
                    children: [
                      Expanded(child: Divider()),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          "Meet Our Team",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(child: Divider()),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // --- 2. GRID TIM (Gaya Manga Card) ---
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                childAspectRatio: 0.7, // Rasio Poster (Tinggi > Lebar)
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              delegate: SliverChildBuilderDelegate((context, index) {
                final member = _teamMembers[index];
                return _buildTeamCard(context, member);
              }, childCount: _teamMembers.length),
            ),
          ),

          // --- 3. FOOTER ---
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Center(
                child: Text(
                  "© 2024 Kelompok 3. All Rights Reserved.",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget Kartu Anggota (Mirip Manga Card)
  Widget _buildTeamCard(BuildContext context, Map<String, String> member) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 1. FOTO (Background Full)
            Image.asset(
              member['image']!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: Colors.grey[800],
                child: const Icon(
                  Icons.person,
                  size: 50,
                  color: Colors.white54,
                ),
              ),
            ),

            // 2. GRADIENT (Bayangan Hitam di Bawah)
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 120, // Tinggi area gelap
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.9), // Hitam pekat
                    ],
                    stops: const [0.0, 0.7],
                  ),
                ),
              ),
            ),

            // 3. INFO & SOSMED (Overlay di atas Gradient)
            Positioned(
              bottom: 10,
              left: 8,
              right: 8,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // NAMA
                  Text(
                    member['name']!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      shadows: [Shadow(blurRadius: 2, color: Colors.black)],
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // ROLE
                  Text(
                    member['role']!,
                    style: const TextStyle(
                      color: Colors.blueAccent,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 8),

                  // TOMBOL SOSMED
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (member['ig'] != null)
                        _buildSocialIcon(context, _igLogoUrl, member['ig']!),

                      const SizedBox(width: 12),

                      if (member['gh'] != null)
                        _buildSocialIcon(context, _ghLogoUrl, member['gh']!),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialIcon(
    BuildContext context,
    String iconUrl,
    String linkUrl,
  ) {
    return InkWell(
      onTap: () async {
        final Uri url = Uri.parse(linkUrl);
        if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Tidak bisa membuka link: $linkUrl')),
            );
          }
        }
      },
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15), // Latar transparan
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white30, width: 1),
        ),
        child: Image.network(
          iconUrl,
          width: 16,
          height: 16,
          errorBuilder: (_, __, ___) =>
              const Icon(Icons.link, size: 16, color: Colors.white),
        ),
      ),
    );
  }
}
