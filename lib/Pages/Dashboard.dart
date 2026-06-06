import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rustinnovations_adminpanel/Assets/Colors.dart';
import 'package:rustinnovations_adminpanel/Widgets/Sidebar.dart';
import 'package:rustinnovations_adminpanel/Widgets/Topbar.dart';
import 'package:rustinnovations_adminpanel/Widgets/myText.dart';
import 'package:rustinnovations_adminpanel/Widgets/Clickable.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../assets/Core/RandomId.dart';
import '../assets/Core/SupabaseCRUD/CRUD.dart';
import 'dart:html' as html;

import '../assets/Core/downloadQR.dart';


class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  bool _isAdding = false;
  final String BASE_URL = "https://rustpass.rustinnovations.com/employee.html?id=";

  /// Non-null when the user tapped Edit on a card — passes existing data into
  /// the form so it opens in edit mode instead of register mode.
  Map<String, dynamic>? _editingEmployee;

  late Future<List<Map<String, dynamic>>> _employeeFuture;

  @override
  void initState() {
    super.initState();
    _employeeFuture = Read('Employee');
  }

  void _refreshData() {
    setState(() {
      _employeeFuture = Read('Employee');
    });
  }

  void _onMenuItemTap(int index) {
    if (index == 1) {
      context.go('/articles');
    }
  }

  /// Toggles the form panel closed (register mode has no pre-filled data).
  void _toggleAdding() {
    setState(() {
      _isAdding = !_isAdding;
      if (!_isAdding) {
        _editingEmployee = null;
        _refreshData();
      }
    });
  }

  /// Opens the form pre-filled with [employee] data (edit mode).
  void _startEditing(Map<String, dynamic> employee) {
    setState(() {
      _editingEmployee = employee;
      _isAdding = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth >= 768 && screenWidth < 1200;

    return Scaffold(
      backgroundColor: MyColors.BACKGROUND_COLOR,
      body: Row(
        children: [
          Sidebar(
            selectedIndex: 0,
            onMenuItemTap: _onMenuItemTap,
            isMobile: isMobile,
            isTablet: isTablet,
          ),
          Expanded(
            child: Column(
              children: [
                Topbar(
                  title: "Employee Record",
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.all(isMobile ? 16 : 32),
                      child: _isAdding
                          ? _AddEmployeeForm(
                        isMobile: isMobile,
                        onCancel: _toggleAdding,
                        onSaved: _toggleAdding,
                        // null  → register mode
                        // map   → edit mode
                        editData: _editingEmployee,
                      )
                          : _buildEmployeeSection(isMobile),
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

  // ---------- EMPLOYEE LIST SECTION ----------

  Widget _buildEmployeeSection(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.topRight,
          child: _buildRegisterButton(
            text: "Register Employee",
            onPressed: _toggleAdding,
          ),
        ),
        const SizedBox(height: 24),
        FutureBuilder<List<Map<String, dynamic>>>(
          future: _employeeFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                  child: CircularProgressIndicator(color: Colors.white));
            } else if (snapshot.hasError) {
              return Center(
                child: paragraph(
                    text: "Error loading data: ${snapshot.error}",
                    fontsize: 14,
                    color: Colors.redAccent),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                  child: paragraph(text: "No employees found.", fontsize: 16));
            }

            final employees = snapshot.data!;
            return Column(
              children: employees
                  .map((emp) => Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: _buildEmployeeCard(isMobile, emp),
              ))
                  .toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildEmployeeCard(bool isMobile, Map<String, dynamic> employee) {
    final String avatarUrl   = employee['avatar_url'] ??
        'https://i.pravatar.cc/150?u=${employee['id']}';
    final String id          = employee['id'] ?? 'N/A';
    final String name        = employee['name'] ?? 'N/A';
    final String fName       = employee['f-name'] ?? 'N/A';
    final String role        = employee['role'] ?? 'N/A';
    final String location    = employee['location'] ?? 'N/A';
    final String joiningDate = employee['joining-date'] ?? 'N/A';
    final bool   isActive    = employee['status'] ?? true;
    final String cnic        = employee['CNIC']?.toString() ?? 'N/A';
    final String salary      = employee['salary']?.toString() ?? 'N/A';
    final String allowances  = employee['allowances']?.toString() ?? 'None';
    final String email       = employee['email']?.toString() ?? 'N/A';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1C23),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── Header: Avatar | Name+Role | Verified+ID ─────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Left: avatar
                  CircleAvatar(
                    radius: isMobile ? 38 : 50,
                    backgroundImage: NetworkImage(avatarUrl),
                    backgroundColor: const Color(0xFF2C2F3A),
                  ),
                  const SizedBox(width: 20),
                  // Centre: name + role
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        headline(text: name, fontsize: isMobile ? 16 : 20),
                        const SizedBox(height: 4),
                        paragraph(
                          text: role,
                          fontsize: 13,
                          color: const Color(0xFFD02657),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Right: verified badge + ID + copy
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Verified badge

                      SizedBox(height: 50,),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD02657).withOpacity(0.12),
                          border: Border.all(
                              color: const Color(0xFFD02657).withOpacity(0.35)),
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                  color: Color(0xFF4ADE80),
                                  shape: BoxShape.circle),
                            ),
                            const SizedBox(width: 6),
                            paragraph(
                              text: 'VERIFIED EMPLOYEE',
                              fontsize: 10,
                              color: const Color(0xFFFF8AB0),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Employee ID + copy button
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          headline(
                            text: id,
                            fontsize: isMobile ? 15 : 18,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 8),
                          Clickable(
                            onTap: () {
                              Clipboard.setData(ClipboardData(text: id));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Employee ID copied')),
                              );
                            },
                              child: Icon(Icons.copy, color: Colors.white, size: 13,)
                          )],
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 24),
              const Divider(color: Colors.white10, height: 1),
              const SizedBox(height: 20),

              // ── 3×3 info grid ─────────────────────────────────────────
              LayoutBuilder(builder: (context, constraints) {
                final w = constraints.maxWidth;
                final colW = (w - 32) / 3;
                return Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    SizedBox(width: isMobile ? w : colW,
                        child: _buildDetailItem('Father Name', fName)),
                    SizedBox(width: isMobile ? w : colW,
                        child: _buildDetailItem('Email', email)),
                    SizedBox(width: isMobile ? w : colW,
                        child: _buildDetailItem('Location', location)),
                    SizedBox(width: isMobile ? w : colW,
                        child: _buildDetailItem('Joining Date', joiningDate)),
                    SizedBox(
                      width: isMobile ? w : colW,
                      child: _buildDetailItem(
                        'Status',
                        isActive ? 'Active' : 'Inactive',
                        valueColor: isActive ? Colors.green : Colors.redAccent,
                      ),
                    ),
                    SizedBox(width: isMobile ? w : colW,
                        child: _buildDetailItem('CNIC', cnic)),
                    SizedBox(width: isMobile ? w : colW,
                        child: _buildDetailItem('Salary', salary)),
                    SizedBox(width: isMobile ? w : colW,
                        child: _buildDetailItem('Allowances', allowances)),
                  ],
                );
              }),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Image.network(
                      'https://api.qrserver.com/v1/create-qr-code/?size=120x120&data=${BASE_URL}$id',
                      width: 120,
                      height: 120,
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          headline(
                              text: "Employee QR Code",
                              fontsize: 14,
                              color: Colors.black87),
                          const SizedBox(height: 8),
                          paragraph(
                              text: "Scan to view employee details",
                              fontsize: 12,
                              color: Colors.black54),
                          const SizedBox(height: 12),
                          _buildPrimaryButton(
                              text: "Download QR Code", onPressed: () {
                            downloadQr(qrUrl: 'https://api.qrserver.com/v1/create-qr-code/?size=120x120&data=${BASE_URL}$id', id: id);
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // ---- Edit button (top-right corner of card) ----
          Positioned(
            top: 0,
            right: 0,
            child: Clickable(
              onTap: () => _startEditing(employee),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF2C2F3A),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white24),
                ),
                child: const Icon(Icons.edit, color: Colors.white70, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- SHARED WIDGETS ----------

  Widget _buildDetailItem(String label, String value,
      {Color? valueColor, bool hasCopy = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        paragraph(text: label, fontsize: 12, textAlign: TextAlign.start),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hasCopy) ...[
              Clickable(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: value.trim()));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Copied to clipboard")),
                  );
                },
                child: const Padding(
                  padding: EdgeInsets.all(4.0),
                  child: Icon(Icons.copy, size: 16, color: Colors.white70),
                ),
              ),
              const SizedBox(width: 4),
            ],
            headline(
              text: value,
              fontsize: 14,
              textAlign: TextAlign.start,
              color: valueColor ?? Colors.white,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRegisterButton(
      {required String text, required VoidCallback onPressed}) {
    return Clickable(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: MyColors.BUTTON_COLOR,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.add, size: 18, color: Colors.white),
            const SizedBox(width: 8),
            Text(text, style: TextStyle(fontSize: 14, color: Colors.white)),
          ],
        ),
      ),
    );
  }

  Widget _buildPrimaryButton(
      {required String text, required VoidCallback onPressed}) {
    return Clickable(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        decoration: BoxDecoration(
          color: MyColors.BUTTON_COLOR,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(text, style: TextStyle(fontSize: 14, color: Colors.white)),
      ),
    );
  }

}

// =============================================================
//  ADD / EDIT EMPLOYEE FORM
// =============================================================

class _AddEmployeeForm extends StatefulWidget {
  final bool isMobile;
  final VoidCallback onCancel;
  final VoidCallback onSaved;

  /// When non-null the form opens in **edit mode** pre-filled with this data.
  /// When null the form opens in **register mode**.
  final Map<String, dynamic>? editData;

  const _AddEmployeeForm({
    required this.isMobile,
    required this.onCancel,
    required this.onSaved,
    this.editData,
  });

  @override
  State<_AddEmployeeForm> createState() => _AddEmployeeFormState();
}

class _AddEmployeeFormState extends State<_AddEmployeeForm> {
  // ---- Controllers ----
  final _nameCtrl       = TextEditingController();
  final _fNameCtrl      = TextEditingController();
  final _emailCtrl      = TextEditingController();
  final _roleCtrl       = TextEditingController();
  final _cnicCtrl       = TextEditingController();
  final _salaryCtrl     = TextEditingController();
  final _allowancesCtrl = TextEditingController();

  // ---- State ----
  bool _statusActive = true;
  String _locationValue = 'Remote'; // Remote | On-site | Hybrid
  DateTime _joiningDate = DateTime.now();
  Uint8List? _imageBytes;
  String? _imageFileName;
  bool _isSaving = false;

  /// The ID shown in the form header.
  /// Register mode: generated fresh on init, initials update as user types.
  /// Edit mode:     loaded from DB, only the initials part updates on name change.
  late String _generatedId;

  /// Existing avatar URL fetched from DB (edit mode only).
  String? _existingAvatarUrl;

  // ---- Convenience getter ----
  bool get _isEditMode => widget.editData != null;

  @override
  void initState() {
    super.initState();

    if (_isEditMode) {
      // ---- Edit mode: pre-fill everything from DB record ----
      final d = widget.editData!;

      _generatedId = d['id'] ?? '';
      _existingAvatarUrl = d['avatar_url'] as String?;

      _nameCtrl.text     = d['name'] ?? '';
      _fNameCtrl.text    = d['f-name'] ?? '';
      _emailCtrl.text    = d['email'] ?? '';
      _roleCtrl.text     = d['role'] ?? '';
      _cnicCtrl.text     = d['CNIC']?.toString() ?? '';
      _salaryCtrl.text = d['salary']?.toString() ?? '';
      _allowancesCtrl.text = d['allowances']?.toString() ?? '';
      _statusActive = d['status'] ?? true;
      _locationValue = d['location'] ?? 'Remote';

      final rawDate = d['joining-date'] as String?;
      if (rawDate != null) {
        _joiningDate = DateTime.tryParse(rawDate) ?? DateTime.now();
      }
    } else {
      // ---- Register mode: generate a fresh sequential RP-XXXX ID ----
      _generatedId = 'RP-0001'; // placeholder until async fetch completes
      _fetchNextId();
    }
  }

  /// Fetches all existing employee IDs from Supabase and derives the next
  /// sequential RP-XXXX id.
  Future<void> _fetchNextId() async {
    try {
      final supabase = Supabase.instance.client;
      final response = await supabase
          .from('Employee')
          .select('id')
          .like('id', 'RP-%');

      final List rows = response as List;
      int maxNum = 0;
      for (final row in rows) {
        final rawId = row['id'] as String? ?? '';
        if (rawId.startsWith('RP-')) {
          final numPart = int.tryParse(rawId.substring(3)) ?? 0;
          if (numPart > maxNum) maxNum = numPart;
        }
      }
      final nextNum = maxNum + 1;
      final nextId = 'RP-${nextNum.toString().padLeft(4, '0')}';
      if (mounted) setState(() => _generatedId = nextId);
    } catch (_) {
      // Keep the placeholder if fetch fails
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _fNameCtrl.dispose();
    _emailCtrl.dispose();
    _roleCtrl.dispose();
    _cnicCtrl.dispose();
    _salaryCtrl.dispose();
    _allowancesCtrl.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------------
  //  ID helpers
  // ------------------------------------------------------------------

  // _refreshId removed — ID is now a fixed sequential RP-XXXX number assigned
  // automatically and never changed after creation.

  // ------------------------------------------------------------------
  //  Storage helpers
  // ------------------------------------------------------------------

  /// Extracts the storage object path from a Supabase public URL so we can
  /// delete it. The URL looks like:
  ///   https://<ref>.supabase.co/storage/v1/object/public/Employee/avatars/...
  /// We want everything after `/Employee/`.
  String? _extractStoragePath(String url) {
    const marker = '/Employee/';
    final idx = url.indexOf(marker);
    if (idx == -1) return null;
    return url.substring(idx + marker.length);
  }

  // ------------------------------------------------------------------
  //  Image picker
  // ------------------------------------------------------------------

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked =
    await picker.pickImage(source: ImageSource.gallery, imageQuality: 90);
    if (picked == null) return;

    final bytes = await picked.readAsBytes();

    // 2 MB limit
    if (bytes.lengthInBytes > 2 * 1024 * 1024) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Image must be smaller than 2 MB."),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
      return;
    }

    setState(() {
      _imageBytes = bytes;
      _imageFileName = picked.name;
    });
  }

  // ------------------------------------------------------------------
  //  Date picker
  // ------------------------------------------------------------------

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _joiningDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF6C63FF),
            surface: Color(0xFF1A1C23),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _joiningDate = picked);
    }
  }

  // ------------------------------------------------------------------
  //  Validation
  // ------------------------------------------------------------------

  String? _validate() {
    if (_nameCtrl.text.trim().isEmpty) return "Name is required.";
    if (_fNameCtrl.text.trim().isEmpty) return "Father Name is required.";
    if (_emailCtrl.text.trim().isEmpty) return "Email is required.";
    if (_roleCtrl.text.trim().isEmpty) return "Role is required.";
    if (_cnicCtrl.text.trim().isEmpty) return "CNIC is required.";
    if (_salaryCtrl.text.trim().isEmpty) return "Salary is required.";
    if (int.tryParse(_salaryCtrl.text.trim()) == null) {
      return "Salary must be a valid number.";
    }
    if (_allowancesCtrl.text.trim().isNotEmpty &&
        int.tryParse(_allowancesCtrl.text.trim()) == null) {
      return "Allowances must be a valid number.";
    }
    return null;
  }

  // ------------------------------------------------------------------
  //  Save / Update
  // ------------------------------------------------------------------

  Future<void> _save() async {
    final error = _validate();
    if (error != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
      return;
    }

    setState(() => _isSaving = true);

    try {
      final supabase = Supabase.instance.client;
      String? imageUrl;

      if (_imageBytes != null && _imageFileName != null) {
        // ---- Edit mode: delete the old image first ----
        if (_isEditMode && _existingAvatarUrl != null) {
          final oldPath = _extractStoragePath(_existingAvatarUrl!);
          if (oldPath != null) {
            await supabase.storage.from('Employee').remove([oldPath]);
          }
        }

        // ---- Upload the new image ----
        final cleanFileName = _imageFileName!.replaceAll(' ', '_');
        final filePath =
            "avatars/${_generatedId}_${DateTime.now().millisecondsSinceEpoch}_$cleanFileName";

        await supabase.storage.from('Employee').uploadBinary(
          filePath,
          _imageBytes!,
          fileOptions: const FileOptions(upsert: false),
        );

        imageUrl = supabase.storage.from('Employee').getPublicUrl(filePath);
        if (kDebugMode) {
          print(imageUrl);
        }
      }

      final formattedDate =
          "${_joiningDate.year}-${_joiningDate.month.toString().padLeft(2, '0')}-${_joiningDate.day.toString().padLeft(2, '0')}";

      if (_isEditMode) {
        // ----------------------------------------------------------------
        //  UPDATE existing record
        //  Do NOT include 'id' or 'created_at' — they must not change.
        // ----------------------------------------------------------------
        final Map<String, dynamic> record = {
          // 'id' intentionally omitted — the ID must never change after creation.
          'name':     _nameCtrl.text.trim(),
          'f-name':   _fNameCtrl.text.trim(),
          'email':    _emailCtrl.text.trim(),
          'role':     _roleCtrl.text.trim(),
          'location': _locationValue,
          'CNIC': _cnicCtrl.text.trim(),
          'salary': int.parse(_salaryCtrl.text.trim()),
          'allowances': _allowancesCtrl.text.trim().isNotEmpty
              ? int.parse(_allowancesCtrl.text.trim())
              : 0,
          'joining-date': formattedDate,
          'status': _statusActive,
          // Only update avatar_url when a new image was picked; otherwise keep
          // the old URL untouched (don't overwrite with null).
          if (imageUrl != null) 'avatar_url': imageUrl,
        };

        // Use the original DB id to identify the row, in case initials changed.
        final originalId = widget.editData!['id'] as String;
        await Update('Employee', record, id: originalId);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Employee updated successfully!"),
              backgroundColor: Colors.green,
            ),
          );
          widget.onSaved();
        }
      } else {
        // ----------------------------------------------------------------
        //  INSERT new record
        // ----------------------------------------------------------------
        final Map<String, dynamic> record = {
          'id':       _generatedId,
          'name':     _nameCtrl.text.trim(),
          'f-name':   _fNameCtrl.text.trim(),
          'email':    _emailCtrl.text.trim(),
          'role':     _roleCtrl.text.trim(),
          'location': _locationValue,
          'CNIC': _cnicCtrl.text.trim(),
          'salary': int.parse(_salaryCtrl.text.trim()),
          'allowances': _allowancesCtrl.text.trim().isNotEmpty
              ? int.parse(_allowancesCtrl.text.trim())
              : 0,
          'joining-date': formattedDate,
          'status': _statusActive,
          'created_at': DateTime.now().toUtc().toIso8601String(),
          if (imageUrl != null) 'avatar_url': imageUrl,
        };

        await Insert('Employee', record);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Employee registered successfully!"),
              backgroundColor: Colors.green,
            ),
          );
          widget.onSaved();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: $e"),
            backgroundColor: Colors.redAccent,
          ),
        );
        if (kDebugMode) {
          print(e);
        }
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // ==========================================================
  //  BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildBackButton(),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1C23),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---- Avatar + ID header row ----
              Row(
                children: [
                  // Avatar preview
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: const Color(0xFF2C2F3A),
                    backgroundImage: _imageBytes != null
                        ? MemoryImage(_imageBytes!) as ImageProvider
                        : (_existingAvatarUrl != null
                        ? NetworkImage(_existingAvatarUrl!)
                        : null),
                    child: (_imageBytes == null && _existingAvatarUrl == null)
                        ? const Icon(Icons.person,
                        size: 40, color: Colors.white38)
                        : null,
                  ),
                  const SizedBox(width: 16),
                  _buildSecondaryButton(
                    text: _isEditMode ? "Change Image" : "Upload New Image",
                    onPressed: _pickImage,
                  ),
                  const Spacer(),
                  // Dynamic Employee ID display
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      paragraph(
                          text: _isEditMode
                              ? "Employee ID"
                              : "New Employee ID",
                          fontsize: 12),
                      headline(
                        text: _generatedId,
                        fontsize: widget.isMobile ? 16 : 20,
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // ---- Form fields ----
              Wrap(
                spacing: 24,
                runSpacing: 24,
                children: [
                  _buildInputField(
                    "Name",
                    "John Smith",
                    controller: _nameCtrl,
                    icon: Icons.person,
                    width: widget.isMobile ? null : 350,
                  ),
                  _buildInputField(
                    "F-Name",
                    "John David",
                    controller: _fNameCtrl,
                    icon: Icons.person,
                    width: widget.isMobile ? null : 350,
                  ),
                  _buildInputField(
                    "Email",
                    "john@example.com",
                    controller: _emailCtrl,
                    icon: Icons.email_outlined,
                    width: widget.isMobile ? null : 350,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  _buildInputField(
                    "Role",
                    "e.g. Founder, CEO",
                    controller: _roleCtrl,
                    icon: Icons.work_outline,
                    width: widget.isMobile ? null : 350,
                  ),
                  _buildLocationDropdown(width: widget.isMobile ? null : 350),
                  _buildInputField(
                    "CNIC",
                    "35202-XXXXXXX-X",
                    controller: _cnicCtrl,
                    icon: Icons.badge_outlined,
                    width: widget.isMobile ? null : 350,
                    keyboardType: TextInputType.number,
                  ),
                  _buildInputField(
                    "Salary",
                    "e.g. 50000",
                    controller: _salaryCtrl,
                    icon: Icons.attach_money,
                    width: widget.isMobile ? null : 350,
                    keyboardType: TextInputType.number,
                  ),
                  _buildInputField(
                    "Allowances (optional)",
                    "e.g. 5000",
                    controller: _allowancesCtrl,
                    icon: Icons.card_giftcard_outlined,
                    width: widget.isMobile ? null : 350,
                    keyboardType: TextInputType.number,
                  ),
                  _buildDatePickerField(width: widget.isMobile ? null : 350),
                  _buildStatusDropdown(width: widget.isMobile ? null : 350),
                ],
              ),

              const SizedBox(height: 40),

              // ---- Action buttons ----
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Clickable(
                    onTap: widget.onCancel,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Text("Cancel", style: TextStyle(fontSize: 14, color:  Colors.grey.shade300)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  _buildSaveButton(),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================================
  //  FORM WIDGETS
  // ==========================================================

  Widget _buildInputField(
      String label,
      String hint, {
        required TextEditingController controller,
        IconData? icon,
        double? width,
        TextInputType? keyboardType,
      }) {
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          paragraph(text: label, fontsize: 14, textAlign: TextAlign.start),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.white24),
              prefixIcon: icon != null
                  ? Icon(icon, color: Colors.white38, size: 20)
                  : null,
              fillColor: const Color(0xFF2C2F3A),
              filled: true,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none),
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePickerField({double? width}) {
    final formatted =
        "${_joiningDate.year}-${_joiningDate.month.toString().padLeft(2, '0')}-${_joiningDate.day.toString().padLeft(2, '0')}";

    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          paragraph(
              text: "Joining Date", fontsize: 14, textAlign: TextAlign.start),
          const SizedBox(height: 8),
          Clickable(
            onTap: _pickDate,
            child: Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFF2C2F3A),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today,
                      color: Colors.white38, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      formatted,
                      style:
                      const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                  const Icon(Icons.arrow_drop_down, color: Colors.white54),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusDropdown({double? width}) {
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          paragraph(text: "Status", fontsize: 14, textAlign: TextAlign.start),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF2C2F3A),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<bool>(
                value: _statusActive,
                dropdownColor: const Color(0xFF2C2F3A),
                icon:
                const Icon(Icons.arrow_drop_down, color: Colors.white70),
                isExpanded: true,
                items: [
                  DropdownMenuItem(
                    value: true,
                    child: Row(
                      children: [
                        Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle)),
                        const SizedBox(width: 8),
                        paragraph(
                            text: "Active", fontsize: 14, color: Colors.white),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: false,
                    child: Row(
                      children: [
                        Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                                color: Colors.redAccent,
                                shape: BoxShape.circle)),
                        const SizedBox(width: 8),
                        paragraph(
                            text: "Inactive",
                            fontsize: 14,
                            color: Colors.white),
                      ],
                    ),
                  ),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _statusActive = val);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationDropdown({double? width}) {
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          paragraph(
              text: "Location", fontsize: 14, textAlign: TextAlign.start),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF2C2F3A),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _locationValue,
                dropdownColor: const Color(0xFF2C2F3A),
                icon:
                const Icon(Icons.arrow_drop_down, color: Colors.white70),
                isExpanded: true,
                items: const [
                  DropdownMenuItem(
                    value: 'Remote',
                    child: Text('Remote',
                        style: TextStyle(color: Colors.white, fontSize: 14)),
                  ),
                  DropdownMenuItem(
                    value: 'On-site',
                    child: Text('On-site',
                        style: TextStyle(color: Colors.white, fontSize: 14)),
                  ),
                  DropdownMenuItem(
                    value: 'Hybrid',
                    child: Text('Hybrid',
                        style: TextStyle(color: Colors.white, fontSize: 14)),
                  ),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _locationValue = val);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return Clickable(
      onTap: () => _isSaving ? () {} : _save(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
        decoration: BoxDecoration(
          color: _isSaving
              ? MyColors.BUTTON_COLOR.withOpacity(0.6)
              : MyColors.BUTTON_COLOR,
          borderRadius: BorderRadius.circular(8),
        ),
        child: _isSaving
            ? const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.white,
          ),
        )
            : Text(
             _isEditMode ? "Save Changes" : "Register Employee",
            style: TextStyle(fontSize: 14, color: Colors.white)),
      ),
    );
  }

  Widget _buildSecondaryButton(
      {required String text, required VoidCallback onPressed}) {
    return Clickable(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF2C2F3A),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(text, style: TextStyle(fontSize: 14, color: Colors.white)),
      ),
    );
  }

  Widget _buildBackButton() {
    return Clickable(
      onTap: widget.onCancel,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.arrow_back_ios, size: 14, color: Colors.white70),
          const SizedBox(width: 4),
          Text("Back", style: TextStyle(fontSize:  16, color: Colors.white)),
        ],
      ),
    );
  }
}