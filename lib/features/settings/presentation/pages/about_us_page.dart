import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart'; 

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  final String _igLogoUrl = "https://img.lovepik.com/png/20231104/instagram-black-and-white-icon-red-facebook-instagram-logo_494361_wh860.png";
  final String _ghLogoUrl = "https://github.githubassets.com/assets/GitHub-Mark-ea2971cee799.png";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tentang Kami"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // --- BAGIAN 1: INFO APLIKASI ---
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blueAccent.withOpacity(0.1),
                border: Border.all(color: Colors.blueAccent, width: 2),
              ),
              child: const Icon(Icons.menu_book_rounded, size: 60, color: Colors.blueAccent),
            ),
            const SizedBox(height: 16),
            const Text(
              "MangaRead",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Text(
              "Versi 1.0.0",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            const Text(
              "MangaRead adalah aplikasi baca komik open source yang dibuat untuk memenuhi tugas kuliah. Aplikasi ini menyediakan ribuan manga, manhwa, dan manhua terupdate setiap harinya dengan pengalaman membaca yang nyaman.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, height: 1.5),
            ),
            
            const SizedBox(height: 40),
            const Divider(),
            const SizedBox(height: 24),

            // --- BAGIAN 2: TIM PENGEMBANG ---
            const Text(
              "Meet Our Team",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            // List Anggota Tim
            Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.center,
              children: [
                // ANGGOTA 1 (Ketua)
                _buildTeamMember(
                  context,
                  name: "Rahmat Sigma",
                  role: "Team Lead & Fullstack",
                  imageAsset: "assets/images/rahmat.jpg", 
                  instagramLink: "https://www.instagram.com/rahmat_sigma/", // Ganti dengan link asli
                  githubLink: "https://github.com/rahmatsigma",
                ),

                // ANGGOTA 2
                _buildTeamMember(
                  context,
                  name: "Anggota Dua",
                  role: "Frontend Developer",
                  imageAsset: "assets/images/anggota2.jpg",
                  instagramLink: "https://instagram.com",
                  githubLink: "https://github.com",
                ),

                // ANGGOTA 3
                _buildTeamMember(
                  context,
                  name: "Anggota Tiga",
                  role: "Backend Engineer",
                  imageAsset: "assets/images/anggota3.jpg", 
                  instagramLink: "https://instagram.com",
                  githubLink: "https://github.com",
                ),

                // ANGGOTA 4
                _buildTeamMember(
                  context,
                  name: "Anggota Empat",
                  role: "UI/UX Designer",
                  imageAsset: "assets/images/anggota4.jpg",
                  instagramLink: "https://instagram.com",
                  githubLink: "https://github.com", 
                ),

                // ANGGOTA 5
                _buildTeamMember(
                  context,
                  name: "Anggota Lima",
                  role: "Mobile Developer",
                  imageAsset: "assets/images/anggota5.jpg",
                  instagramLink: "https://instagram.com",
                  githubLink: "https://github.com", 
                ),

                // ANGGOTA 6
                _buildTeamMember(
                  context,
                  name: "Anggota Enam",
                  role: "Quality Assurance",
                  imageAsset: "assets/images/anggota6.jpg",
                  instagramLink: "https://instagram.com",
                  githubLink: "https://github.com", 
                ),

                // ANGGOTA 7
                _buildTeamMember(
                  context,
                  name: "Anggota Tujuh",
                  role: "Project Manager",
                  imageAsset: "assets/images/anggota7.jpg", 
                  instagramLink: "https://instagram.com",
                  githubLink: "https://github.com",
                ),
              ],
            ),

            const SizedBox(height: 40),
            const Text(
              "© 2024 Kelompok 3. All Rights Reserved.",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamMember(BuildContext context, {
    required String name,
    required String role,
    required String imageAsset,
    // Parameter Link Sosmed
    String? instagramLink, 
    String? githubLink,
  }) {
    return Container(
      width: 160, // Lebar kartu sedikit dibesarkan
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 35,
            backgroundColor: Colors.grey[200],
            backgroundImage: AssetImage(imageAsset),
            onBackgroundImageError: (_, __) {},
            child: const Icon(Icons.person, color: Colors.grey),
          ),
          const SizedBox(height: 12),
          Text(
            name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            role,
            style: const TextStyle(color: Colors.blueAccent, fontSize: 11),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
          
          // --- BAGIAN IKON SOSMED ---
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (instagramLink != null) 
                _buildSocialIcon(context, _igLogoUrl, instagramLink),
              
              if (instagramLink != null && githubLink != null)
                const SizedBox(width: 12), // Jarak antar ikon

              if (githubLink != null) 
                _buildSocialIcon(context, _ghLogoUrl, githubLink),
            ],
          )
        ],
      ),
    );
  }

  // Helper untuk membuat ikon sosmed yang bisa diklik
  Widget _buildSocialIcon(BuildContext context, String iconUrl, String linkUrl) {
    return InkWell(
      onTap: () async {
        final Uri url = Uri.parse(linkUrl);
        // Logic buka browser (external application)
        if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
           if (context.mounted) {
             ScaffoldMessenger.of(context).showSnackBar(
               SnackBar(content: Text('Tidak bisa membuka link: $linkUrl')),
             );
           }
        }
      },
      borderRadius: BorderRadius.circular(50),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        // Tampilkan Gambar Logo dari URL
        child: Image.network(
          iconUrl,
          width: 20,
          height: 20,
          errorBuilder: (context, error, stackTrace) => const Icon(Icons.link, size: 20),
        ),
      ),
    );
  }
}