import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:rustinnovations_adminpanel/Assets/Colors.dart';
import 'package:rustinnovations_adminpanel/Widgets/Sidebar.dart';
import 'package:rustinnovations_adminpanel/Widgets/Topbar.dart';
import 'package:rustinnovations_adminpanel/Widgets/myText.dart';
import 'package:rustinnovations_adminpanel/Widgets/Clickable.dart';
import 'package:go_router/go_router.dart';

class BlogDetailsPage extends StatefulWidget {
  final Map<String, dynamic> blog;
  const BlogDetailsPage({super.key, required this.blog});

  @override
  State<BlogDetailsPage> createState() => _BlogDetailsPageState();
}

class _BlogDetailsPageState extends State<BlogDetailsPage> {
  void _onMenuItemTap(int index) {
    if (index == 0) context.go('/dashboard');
    if (index == 1) context.go('/articles');
  }

  String _formatDate(String? isoDate) {
    if (isoDate == null) return '—';
    try {
      final dt = DateTime.parse(isoDate).toLocal();
      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return isoDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth >= 768 && screenWidth < 1200;

    final title = widget.blog['title'] ?? 'Untitled';
    final content = widget.blog['content'] as String? ?? '';
    final author = widget.blog['author'] ?? 'Unknown';
    final date = _formatDate(widget.blog['created_at']);
    final imageUrl = widget.blog['featured_image'];
    final keywords = widget.blog['keyword'] as List<dynamic>? ?? [];

    // Wrap content with inline CSS so the dark theme applies inside the renderer
    final styledContent = '''
      <style>
        body, p, li, td, span {
          color: #D0D0D0;
          font-size: 16px;
          line-height: 1.85;
        }
        h1 { color: #FFFFFF; font-size: 26px; font-weight: 700; margin: 24px 0 12px; }
        h2 { color: #FFFFFF; font-size: 22px; font-weight: 700; margin: 20px 0 10px; }
        h3 { color: #FFFFFF; font-size: 18px; font-weight: 600; margin: 18px 0 8px; }
        h4 { color: #FFFFFF; font-size: 16px; font-weight: 600; }
        strong, b { color: #FFFFFF; font-weight: 700; }
        em, i { color: #BDBDBD; font-style: italic; }
        a { color: #D02657; text-decoration: underline; }
        blockquote {
          border-left: 4px solid #a30000;
          padding: 8px 20px;
          margin: 20px 0;
          color: #BDBDBD;
          font-style: italic;
        }
        ul, ol { padding-left: 20px; margin-bottom: 16px; }
        li { margin-bottom: 6px; }
        code {
          background: #2C2F3A;
          color: #E0E0E0;
          font-family: monospace;
          padding: 2px 6px;
          border-radius: 4px;
        }
        pre {
          background: #2C2F3A;
          color: #E0E0E0;
          font-family: monospace;
          padding: 16px;
          border-radius: 8px;
          margin-bottom: 16px;
          overflow-x: auto;
        }
        hr { border-color: rgba(255,255,255,0.1); margin: 24px 0; }
        img { max-width: 100%; border-radius: 8px; }
      </style>
      $content
    ''';

    return Scaffold(
      backgroundColor: MyColors.BACKGROUND_COLOR,
      body: Row(
        children: [
          Sidebar(
            selectedIndex: 1,
            onMenuItemTap: _onMenuItemTap,
            isMobile: isMobile,
            isTablet: isTablet,
          ),
          Expanded(
            child: Column(
              children: [
                Topbar(onProfileTap: () {}, title: "View Article"),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(isMobile ? 16 : 32),
                    child: Center(
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 1000),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildBackButton(),
                            const SizedBox(height: 32),

                            // Title
                            headline(
                              text: title,
                              fontsize: isMobile ? 28 : 42,
                              textAlign: TextAlign.start,
                            ),
                            const SizedBox(height: 20),

                            // Metadata Row
                            Row(
                              children: [
                                _buildMetaTag(Icons.person, "By $author", MyColors.PRIMARY_COLOR),
                                const SizedBox(width: 12),
                                _buildMetaTag(Icons.calendar_today, date, Colors.white10),
                              ],
                            ),

                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 32),
                              child: Divider(color: Colors.white10),
                            ),

                            // Featured Image
                            if (imageUrl != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 40.0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image.network(
                                    imageUrl,
                                    width: double.infinity,
                                    height: isMobile ? 250 : 500,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                                  ),
                                ),
                              ),

                            // ── HTML content rendered natively ──
                            HtmlWidget(
                              styledContent,
                              textStyle: const TextStyle(
                                color: Color(0xFFD0D0D0),
                                fontSize: 16,
                                height: 1.85,
                              ),
                              onErrorBuilder: (context, element, error) =>
                                  Text('Error: $error', style: const TextStyle(color: Colors.red)),
                            ),

                            // Tags / Keywords
                            if (keywords.isNotEmpty) ...[
                              const SizedBox(height: 40),
                              paragraph(text: "Tags:", fontsize: 14, color: Colors.white38),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: keywords.map((kw) => Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    kw.toString(),
                                    style: const TextStyle(color: Colors.white60, fontSize: 13),
                                  ),
                                )).toList(),
                              ),
                            ],
                            const SizedBox(height: 100),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaTag(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white70),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildBackButton() {
    return Clickable(
      onTap: () => context.pop(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.arrow_back_ios, size: 14, color: Colors.white70),
            const SizedBox(width: 8),
            paragraph(text: "Return to Articles", fontsize: 14),
          ],
        ),
      ),
    );
  }
}