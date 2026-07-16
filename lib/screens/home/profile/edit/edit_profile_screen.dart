// File: lib/screens/home/profile/edit/edit_profile_screen.dart
// MetaZone — Edit Profile (Professional, AR-ready)

import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../services/user_service.dart';
import 'package:firebase_storage/firebase_storage.dart';

Timer? _usernameDebounce;

class EditProfileScreen extends StatefulWidget {
  final String displayName;
  final String username;
  final String bio;
  final Map<String, String> socialLinks;
  final File? avatarFile;
  final File? coverFile;
  final String? country;
  final String? language;
  final DateTime? birthDate;

  const EditProfileScreen({
    super.key,
    required this.displayName,
    required this.username,
    required this.bio,
    required this.socialLinks,
    this.avatarFile,
    this.coverFile,
    this.country,
    this.language,
    this.birthDate,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _userService = UserService();
  bool _saving = false;
  bool _checkingUsername = false;
  bool _usernameValid = true;
  String? _usernameError;

  late TextEditingController _nameCtl;
  late TextEditingController _usernameCtl;
  late TextEditingController _bioCtl;
  late Map<String, TextEditingController> _socialCtrls;

  File? _avatarFile;
  File? _coverFile;
  final ImagePicker _picker = ImagePicker();

  // extra profile fields
  String? _country;
  String? _language;
  DateTime? _birthDate;

  // small config
  static const int bioMax = 180;

  // sample lists (you can replace with real data)
  final List<String> _countries = [
    "Egypt",
    "United States",
    "United Kingdom",
    "United Arab Emirates",
    "Other"
  ];
  final List<String> _languages = [
    "English",
    "Arabic",
    "Spanish",
    "French",
    "Other"
  ];

  @override
  void initState() {
    super.initState();
    _nameCtl = TextEditingController(text: widget.displayName);
    _usernameCtl = TextEditingController(text: widget.username);
    _bioCtl = TextEditingController(text: widget.bio);
    _avatarFile = widget.avatarFile;
    _coverFile = widget.coverFile;
    _country = widget.country ?? _countries.first;
    _language = widget.language ?? _languages.first;
    _birthDate = widget.birthDate;

    _socialCtrls = {
      for (final e in widget.socialLinks.entries)
        e.key: TextEditingController(text: e.value)
    };
    // ensure at least one default social field
    if (_socialCtrls.isEmpty) {
      _socialCtrls["Website"] = TextEditingController();
    }
  }

  @override
  void dispose() {
    _nameCtl.dispose();
    _usernameCtl.dispose();
    _bioCtl.dispose();
    for (final c in _socialCtrls.values) {
      c.dispose();
    }
    _usernameDebounce?.cancel();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source, {required bool forCover}) async {
    try {
      final picked = await _picker.pickImage(source: source, imageQuality: 80);
      if (picked == null) return;
      setState(() {
        if (forCover) {
          _coverFile = File(picked.path);
        } else {
          _avatarFile = File(picked.path);
        }
      });
    } catch (_) {}
  }
  Future<String?> _uploadFile(File file, String path) async {
    final ref = FirebaseStorage.instance
        .ref()
        .child("$path/${_auth.currentUser!.uid}-${DateTime.now().millisecondsSinceEpoch}.jpg");

    await ref.putFile(file);
    return await ref.getDownloadURL();
  }

  void _showImageChooser({required bool forCover}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt, color: AppColors.primary),
              title: Text("Take photo", style: AppTextStyles.body()),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera, forCover: forCover);
              },
            ),
            ListTile(
              leading: Icon(Icons.photo, color: AppColors.primary),
              title: Text("Choose from gallery", style: AppTextStyles.body()),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery, forCover: forCover);
              },
            ),
            if (forCover && _coverFile != null)
              ListTile(
                leading: Icon(Icons.delete, color: AppColors.danger),
                title: Text("Remove cover", style: AppTextStyles.body()),
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _coverFile = null);
                },
              ),
            if (!forCover && _avatarFile != null)
              ListTile(
                leading: Icon(Icons.delete, color: AppColors.danger),
                title: Text("Remove avatar", style: AppTextStyles.body()),
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _avatarFile = null);
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _addSocialField() {
    // create a new labeled field with unique key name
    var idx = 1;
    String key = "Link";
    while (_socialCtrls.containsKey("$key $idx")) idx++;
    final label = "$key $idx";
    setState(() {
      _socialCtrls[label] = TextEditingController();
    });
  }

  void _removeSocialField(String key) {
    setState(() {
      _socialCtrls[key]?.dispose();
      _socialCtrls.remove(key);
      if (_socialCtrls.isEmpty) {
        _socialCtrls["Website"] = TextEditingController();
      }
    });
  }

  String? _validateUsername(String? v) {

    if (v == null || v.trim().isEmpty) return "Username required";

    final t = v.trim();

    final reg = RegExp(r'^[a-zA-Z0-9_\.]{3,20}$');

    if (!reg.hasMatch(t)) {
      return "3–20 chars. letters, numbers, _ . only";
    }

    return null; // <-- IMPORTANT sync return
  }

  Future<void> _onUsernameChanged(String v) async {
    if (v.trim().isEmpty) {
      setState(() {
        _checkingUsername = false;
        _usernameValid = false;
        _usernameError = "Username required";
      });
      return;
    }

    final t = v.trim().toLowerCase();

    final reg = RegExp(r'^[a-z0-9_\.]{3,20}$');

    if (!reg.hasMatch(t)) {
      setState(() {
        _usernameError = "3–20 letters/numbers/_ only";
        _checkingUsername = false;
        _usernameValid = false;
      });
      return;
    }

    if (t == widget.username.toLowerCase()) {
      setState(() {
        _checkingUsername = false;
        _usernameValid = true;
      });
      return;
    }

    final doc = await _firestore.collection("usernames").doc(t).get();

    setState(() {
      _checkingUsername = false;
      _usernameValid = !doc.exists;
      _usernameError = doc.exists ? "Username already taken" : null;
    });
  }


  void _selectBirthDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(now.year - 20),
      firstDate: DateTime(1900),
      lastDate: now,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.dark(
            background: AppColors.surface,
            primary: AppColors.primary,
            onPrimary: Colors.black,
            onBackground: AppColors.textLight,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _birthDate = picked);
    }
  }

  Future<bool> _isUsernameAvailable(String username) async {
    final clean = username.trim().toLowerCase();

    final doc = await _firestore
        .collection("usernames")
        .doc(clean)
        .get();

    return !doc.exists;
  }


  void _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_checkingUsername || !_usernameValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please choose a valid username")),
      );
      return;
    }

    setState(() => _saving = true);

    final uid = _auth.currentUser!.uid;

    final error = await _userService.fullUpdateProfile(
      uid: uid,

      displayName: _nameCtl.text.trim(),
      username: _usernameCtl.text.trim(),
      bio: _bioCtl.text.trim(),

      country: _country,
      language: _language,
      birthDate: _birthDate,

      socialLinks: {
        for (final k in _socialCtrls.keys)
          k: _socialCtrls[k]!.text.trim(),
      },

      isPrivate: false, // لو عندك privacy toggle غيرها لاحقًا

      newAvatar: _avatarFile,
      newCover: _coverFile,
    );

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated successfully")),
      );
      await _userService.checkAndGrantAchievements(uid);
      await _userService.updateProfileCompletion(uid);

      Navigator.pop(context, true);
    }

    setState(() => _saving = false);
  }




  // small helper for preview chip
  Widget _previewChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      margin: const EdgeInsets.only(right: 8, bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: AppTextStyles.caption(size: 12)),
          const SizedBox(width: 8),
          Text(value, style: AppTextStyles.title(size: 12)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [

      Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 1,
        title: Text("Edit Profile", style: AppTextStyles.heading()),
        actions: [
          TextButton(
            onPressed: _save,
            child: Text("Save", style: AppTextStyles.title()),
          ),
        ],
      ),
      body: Form(
          key: _formKey,
          child: ListView(
              padding: const EdgeInsets.all(16),
              children: [

              // cover preview
              GestureDetector(
              onTap: () => _showImageChooser(forCover: true),
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          image: _coverFile != null
              ? DecorationImage(image: FileImage(_coverFile!), fit: BoxFit.cover)
              : null,
          border: Border.all(color: AppColors.border),
        ),
        child: _coverFile == null
            ? Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.photo_size_select_actual_rounded, size: 36, color: AppColors.primary),
              const SizedBox(height: 6),
              Text("Add cover photo", style: AppTextStyles.caption()),
            ],
          ),
        )
            : Align(
          alignment: Alignment.topRight,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: Colors.black26,
              child: Icon(Icons.edit, color: AppColors.text),
            ),
          ),
        ),
      ),
    ),
    const SizedBox(height: 12),

    // avatar & basic info
    Row(
    children: [
    GestureDetector(
    onTap: () => _showImageChooser(forCover: false),
    child: CircleAvatar(
    radius: 44,
    backgroundColor: AppColors.card,
    backgroundImage: _avatarFile != null ? FileImage(_avatarFile!) : null,
    child: _avatarFile == null
    ? Text(
    _nameCtl.text.isNotEmpty ? _nameCtl.text[0].toUpperCase() : "?",
    style: AppTextStyles.heading(size: 28),
    )
        : null,
    ),
    ),
    const SizedBox(width: 12),
    Expanded(
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    // Display name
    TextFormField(
    controller: _nameCtl,
    style: AppTextStyles.title(),
    decoration: InputDecoration(
    hintText: "Display name",
    filled: true,
    fillColor: AppColors.card,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
    ),
    validator: (v) => (v == null || v.trim().isEmpty) ? "Display name required" : null,
    ),
    const SizedBox(height: 8),
// username
      TextFormField(
        controller: _usernameCtl,
        style: AppTextStyles.body(),
        decoration: InputDecoration(
          hintText: "Username",
          prefixText: "@",
          errorText: _usernameError,
          filled: true,
          fillColor: AppColors.card,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),

          // 👇 ده المؤشر المتحرك الصحيح
          suffixIcon: AnimatedSwitcher(
            duration: Duration(milliseconds: 250),
            child: _checkingUsername
                ? Padding(
              padding: EdgeInsets.all(10),
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              ),
            )
                : _usernameError != null
                ? Icon(Icons.error_rounded,
                color: AppColors.danger, key: ValueKey("err"))
                : Icon(Icons.check_circle_rounded,
                color: Colors.greenAccent, key: ValueKey("ok")),
          ),
        ),

        // 👇 هنا الديباونس اللي عملناه
        onChanged: (v) {
          if (_usernameDebounce?.isActive ?? false) {
            _usernameDebounce!.cancel();
          }
          _usernameDebounce =
              Timer(const Duration(milliseconds: 600), () {
                _onUsernameChanged(v);
              });
        },

        validator: _validateUsername,
      ),

    if (_checkingUsername)
    Padding(
    padding: const EdgeInsets.only(top: 4),
    child: Text("Checking availability...",
    style: AppTextStyles.caption(size: 12)),
    )
    else if (_usernameError != null)
    Padding(
    padding: const EdgeInsets.only(top: 4),
    child: Text(_usernameError!,
    style: AppTextStyles.caption(size: 12).copyWith(color: AppColors.danger)),
    )
    else
    Padding(
    padding: const EdgeInsets.only(top: 4),
    child: Text("Great username 😉",
    style: AppTextStyles.caption(size: 12).copyWith(color: Colors.greenAccent)),
    ),


    ],
    ),
    ),
    ],
    ),

    const SizedBox(height: 12),

    // bio with counter
    TextFormField(
    controller: _bioCtl,
    maxLength: bioMax,
    minLines: 3,
    maxLines: 6,
    style: AppTextStyles.body(),
    decoration: InputDecoration(
    hintText: "Tell the world what you build in AR...",
    filled: true,
    fillColor: AppColors.card,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
    counterText: "",
    ),
    ),
    Align(
    alignment: Alignment.centerRight,
    child: Text("${_bioCtl.text.length}/$bioMax", style: AppTextStyles.caption(size: 12)),
    ),
    const SizedBox(height: 10),

    // metadata row: birth / country / language
    Row(
    children: [
    Expanded(
    child: GestureDetector(
    onTap: _selectBirthDate,
    child: Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(10)),
    child: Row(
    children: [
    Icon(Icons.cake, color: AppColors.primary, size: 18),
    const SizedBox(width: 8),
    Expanded(
    child: Text(
    _birthDate == null ? "Birth date" : "${_birthDate!.day}/${_birthDate!.month}/${_birthDate!.year}",
    style: AppTextStyles.body(),
    ),
    ),
    Icon(Icons.edit, size: 16, color: AppColors.textSoft),
    ],
    ),
    ),
    ),
    ),
    const SizedBox(width: 8),
    Expanded(
    child: DropdownButtonFormField<String>(
    value: _country,
    items: _countries.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
    onChanged: (v) => setState(() => _country = v),
    decoration: InputDecoration(
    filled: true,
    fillColor: AppColors.card,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
    ),
    ),
    ),
    const SizedBox(width: 8),
    Expanded(
    child: DropdownButtonFormField<String>(
    value: _language,
    items: _languages.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
    onChanged: (v) => setState(() => _language = v),
    decoration: InputDecoration(
    filled: true,
    fillColor: AppColors.card,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
    ),
    ),
    ),
    ],
    ),

    const SizedBox(height: 16),

    // Social links header + add button
    Row(
    children: [
    Text("Social links", style: AppTextStyles.title(size: 14)),
    const Spacer(),
    OutlinedButton.icon(
    onPressed: _addSocialField,
    icon: Icon(Icons.add, color: AppColors.primary),
    label: Text("Add", style: AppTextStyles.caption()),
    ),
    ],
    ),
    const SizedBox(height: 8),

    // social fields list
    Column(
    children: _socialCtrls.entries.map((e) {
    final key = e.key;
    final ctl = e.value;
    return Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(10)),
    child: Row(
    children: [
    Expanded(
    child: TextFormField(
    controller: ctl,
    style: AppTextStyles.body(),
    decoration: InputDecoration(
    hintText: key,
    border: InputBorder.none,
    ),
    ),
    ),
    const SizedBox(width: 8),
    IconButton(
    onPressed: () => _removeSocialField(key),
    icon: Icon(Icons.delete_outline, color: AppColors.danger),
    ),
    ],
    ),
    );
    }).toList(),
    ),

    const SizedBox(height: 16),

    // preview chips (quick look)
    Text("Preview", style: AppTextStyles.title(size: 14)),
    const SizedBox(height: 8),
    Wrap(
    children: [
    if (_country != null) _previewChip("Country", _country!),
    if (_language != null) _previewChip("Language", _language!),
    if (_birthDate != null) _previewChip("Birth", "${_birthDate!.day}/${_birthDate!.month}/${_birthDate!.year}"),
    _previewChip("Username", "@${_usernameCtl.text.trim()}"),
    ],
    ),

    const SizedBox(height: 22),

    // action buttons
    Row(
    children: [
    Expanded(
    child: OutlinedButton(
    onPressed: () => Navigator.pop(context),
    style: OutlinedButton.styleFrom(
    side: BorderSide(color: AppColors.border),
    ),
    child: Text("Cancel", style: AppTextStyles.title()),
    ),
    ),
    const SizedBox(width: 12),
    Expanded(
    child: ElevatedButton(
    onPressed: _save,
    style: ElevatedButton.styleFrom(
    backgroundColor: AppColors.primary,
    foregroundColor: Colors.black,
    ),
    child: Text("Save changes", style: AppTextStyles.title()),
    ),
    ),
    ],
    ),
    const SizedBox(height: 18),
    ],
    ),
    ),
    ),

    // 🔥 overlay loading
    if (_saving)
    Container(
    color: Colors.black54,
    child: const Center(
    child: CircularProgressIndicator(),
    ),
    ),
    ]);
    }
}
