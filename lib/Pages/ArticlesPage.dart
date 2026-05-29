import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:rustinnovations_adminpanel/Assets/Colors.dart';
import 'package:rustinnovations_adminpanel/Widgets/Sidebar.dart';
import 'package:rustinnovations_adminpanel/Widgets/Topbar.dart';
import 'package:rustinnovations_adminpanel/Widgets/myText.dart';
import 'package:rustinnovations_adminpanel/Widgets/Clickable.dart';
import 'package:rustinnovations_adminpanel/Widgets/RichEditor.dart';
import 'package:go_router/go_router.dart';
import 'package:html_editor_enhanced/html_editor.dart';

class ArticlesPage extends StatefulWidget {
  const ArticlesPage({super.key});

  @override
  State<ArticlesPage> createState() => _ArticlesPageState();
}

class _ArticlesPageState extends State<ArticlesPage> {
  // ── View state ──────────────────────────────────────────────
  bool _isAdding = false;
  bool _isPosting = false;
  bool _isFetching = false;
  List<Map<String, dynamic>> _blogs = [];

  // ── Supabase ─────────────────────────────────────────────────
  final _supabase = Supabase.instance.client;
  static const _bucketName = 'Bob';

  // ── Form controllers ─────────────────────────────────────────
  final HtmlEditorController _controller = HtmlEditorController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _slugController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  final TextEditingController _altTextController = TextEditingController();
  final TextEditingController _keywordController = TextEditingController();

  // ── Form state ───────────────────────────────────────────────
  final List<String> _keywords = [];
  Uint8List? _imageBytes;
  String? _imageFileName;
  String? _imageMimeType;

  @override
  void initState() {
    super.initState();
    _fetchBlogs();
  }

  Future<void> _fetchBlogs() async {
    setState(() => _isFetching = true);
    try {
      final response = await _supabase
          .from('Blogs')
          .select('id, title, content, created_at, author, featured_image, keyword')
          .order('created_at', ascending: false);
      if (mounted) setState(() => _blogs = List<Map<String, dynamic>>.from(response));
    } catch (e) {
      _showSnack('Failed to load blogs.');
    } finally {
      if (mounted) setState(() => _isFetching = false);
    }
  }

  String _generateSlug(String title) {
    return title.toLowerCase().replaceAll(RegExp(r'[^a-z0-9\s-]'), '').trim().replaceAll(RegExp(r'\s+'), '-');
  }

  void _onMenuItemTap(int index) {
    if (index == 0) context.go('/dashboard');
  }

  void _toggleAdding() {
    setState(() {
      _isAdding = !_isAdding;
      if (!_isAdding) {
        _resetForm();
        _fetchBlogs();
      }
    });
  }

  void _resetForm() {
    _titleController.clear();
    _slugController.clear();
    _authorController.clear();
    _altTextController.clear();
    _keywordController.clear();
    _keywords.clear();
    _imageBytes = null;
  }

  void _addKeyword(String value) {
    final trimmed = value.trim();
    if (trimmed.isNotEmpty && !_keywords.contains(trimmed)) {
      setState(() {
        _keywords.add(trimmed);
        _keywordController.clear();
      });
    }
  }

  void _removeKeyword(String keyword) => setState(() => _keywords.remove(keyword));

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    if (bytes.lengthInBytes > 200 * 1024) { _showSnack('Image too large (>200KB)'); return; }
    setState(() {
      _imageBytes = bytes;
      _imageFileName = picked.name;
      _imageMimeType = 'image/${picked.name.split('.').last}';
    });
  }

  Future<void> _postBlog() async {
    final title = _titleController.text.trim();
    final slug = _slugController.text.trim();
    final author = _authorController.text.trim();
    final rawContent = await _controller.getText();

    if (title.isEmpty || slug.isEmpty || author.isEmpty || _imageBytes == null) {
      _showSnack('All fields are required.');
      return;
    }

    setState(() => _isPosting = true);
    try {
      final imagePath = 'bob/$slug-${DateTime.now().millisecondsSinceEpoch}.${_imageFileName!.split('.').last}';
      await _supabase.storage.from(_bucketName).uploadBinary(imagePath, _imageBytes!, fileOptions: FileOptions(contentType: _imageMimeType));
      final imageUrl = _supabase.storage.from(_bucketName).getPublicUrl(imagePath);

      await _supabase.from('Blogs').insert({
        'featured_image': imageUrl,
        'title': title,
        'slug': slug,
        'created_at': DateTime.now().toIso8601String(),
        'content': rawContent,
        'image_alt': _altTextController.text.trim(),
        'author': author,
        'keyword': _keywords,
      });

      _showSnack('Blog published!', success: true);
      _toggleAdding();
    } catch (e) {
      _showSnack('Upload failed: $e');
    } finally {
      setState(() => _isPosting = false);
    }
  }

  void _showSnack(String message, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: success ? Colors.green : Colors.red));
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    return Scaffold(
      backgroundColor: MyColors.BACKGROUND_COLOR,
      body: Row(
        children: [
          Sidebar(selectedIndex: 1, onMenuItemTap: _onMenuItemTap, isMobile: isMobile, isTablet: screenWidth < 1200),
          Expanded(
            child: Column(
              children: [
                Topbar(onProfileTap: () {}, title: "Articles Record"),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.all(isMobile ? 16 : 32),
                      child: _isAdding ? _buildAddArticleForm(isMobile) : _buildArticleSection(isMobile),
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

  Widget _buildArticleSection(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            headline(text: "All Blogs", fontsize: 22, textAlign: TextAlign.start),
            _buildRegisterButton(text: "Register New Blog", onPressed: _toggleAdding),
          ],
        ),
        const SizedBox(height: 24),
        if (_isFetching) const Center(child: CircularProgressIndicator())
        else ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _blogs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) => _buildBlogCard(_blogs[index], isMobile),
        ),
      ],
    );
  }

  Widget _buildBlogCard(Map<String, dynamic> blog, bool isMobile) {
    return Clickable(
      onTap: () => context.push('/blog-details', extra: blog),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: const Color(0xFF1A1C23), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white10)),
        child: Row(
          children: [
            if (blog['featured_image'] != null)
              ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(blog['featured_image'], width: 120, height: 80, fit: BoxFit.cover)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  headline(text: blog['title'] ?? 'No Title', fontsize: 16, textAlign: TextAlign.start),
                  const SizedBox(height: 4),
                  paragraph(text: "By ${blog['author']} • ${blog['created_at'].toString().substring(0, 10)}", fontsize: 12),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.white24),
          ],
        ),
      ),
    );
  }

  Widget _buildAddArticleForm(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildBackButton(),
        const SizedBox(height: 24),
        _buildImageUploader(),
        const SizedBox(height: 24),
        _buildInputField("Title", "Enter Blog Title", controller: _titleController, onChanged: (v) => _slugController.text = _generateSlug(v)),
        const SizedBox(height: 24),
        _buildInputField("Slug", "URL address", controller: _slugController),
        const SizedBox(height: 24),
        _buildEditor(),
        const SizedBox(height: 24),
        _buildInputField("Author", "Writer Name", controller: _authorController),
        const SizedBox(height: 24),
        _buildKeywordsInputField(),
        const SizedBox(height: 32),
        Align(alignment: Alignment.centerRight, child: _isPosting ? const CircularProgressIndicator() : _buildPrimaryButton(text: "Post Blog", onPressed: _postBlog)),
      ],
    );
  }

  Widget _buildImageUploader() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        width: double.infinity,
        height: 160,
        decoration: BoxDecoration(color: const Color(0xFF1A1C23), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white10)),
        child: _imageBytes != null ? Image.memory(_imageBytes!, fit: BoxFit.cover) : const Icon(Icons.cloud_upload_outlined, size: 40, color: Colors.white24),
      ),
    );
  }

  Widget _buildInputField(String label, String hint, {required TextEditingController controller, Function(String)? onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        paragraph(text: label, fontsize: 14, textAlign: TextAlign.start),
        const SizedBox(height: 8),
        TextField(controller: controller, onChanged: onChanged, style: const TextStyle(color: Colors.white), decoration: InputDecoration(hintText: hint, hintStyle: const TextStyle(color: Colors.white24), fillColor: const Color(0xFF2C2F3A), filled: true, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none))),
      ],
    );
  }

  Widget _buildKeywordsInputField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        paragraph(text: "Keywords (Press Enter)", fontsize: 14, textAlign: TextAlign.start),
        const SizedBox(height: 8),
        TextField(controller: _keywordController, onSubmitted: _addKeyword, style: const TextStyle(color: Colors.white), decoration: InputDecoration(hintText: "Add tag...", hintStyle: const TextStyle(color: Colors.white24), fillColor: const Color(0xFF2C2F3A), filled: true, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none))),
        const SizedBox(height: 8),
        Wrap(spacing: 8, children: _keywords.map((k) => Chip(label: Text(k, style: const TextStyle(fontSize: 10)), onDeleted: () => _removeKeyword(k))).toList()),
      ],
    );
  }

  Widget _buildRegisterButton({required String text, required VoidCallback onPressed}) {
    return Clickable(onTap: onPressed, child: Container(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12), decoration: BoxDecoration(color: MyColors.BUTTON_COLOR, borderRadius: BorderRadius.circular(8)), child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))));
  }

  Widget _buildPrimaryButton({required String text, required VoidCallback onPressed}) {
    return Clickable(onTap: onPressed, child: Container(padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16), decoration: BoxDecoration(color: MyColors.BUTTON_COLOR, borderRadius: BorderRadius.circular(8)), child: headline(text: text, fontsize: 14)));
  }

  Widget _buildEditor() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [paragraph(text: "Content", fontsize: 14, textAlign: TextAlign.start), const SizedBox(height: 8), RichEditor(controller: _controller, height: 400)]);

  Widget _buildBackButton() => Clickable(onTap: _toggleAdding, child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.arrow_back_ios, size: 14, color: Colors.white70), const SizedBox(width: 4), paragraph(text: "Back to List", fontsize: 16)]));
}
