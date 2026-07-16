// File: lib/screens/marketplace/seller/upload_item.dart
// MetaZone — Seller Upload AR Item (Premium Creator Flow)

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/theme.dart';

class UploadARItemScreen extends StatefulWidget {
  const UploadARItemScreen({super.key});

  @override
  State<UploadARItemScreen> createState() => _UploadARItemScreenState();
}

class _UploadARItemScreenState extends State<UploadARItemScreen> {
  final _formKey = GlobalKey<FormState>();

  // STEP CONTROL
  int _step = 0;

  // FORM DATA
  String _title = "";
  String _description = "";
  String _category = "Portal";
  double _price = 10;
  bool _allowCommercialUse = false;
  bool _allowModifications = true;

  File? _mainImage;
  File? _modelFile; // .glb / .usdz

  final picker = ImagePicker();

  Future<void> _pickImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _mainImage = File(picked.path));
  }

  Future<void> _pickModel() async {
    final picked = await picker.pickMedia();
    if (picked != null) setState(() => _modelFile = File(picked.path));
  }

  void _next() {
    if (_step < 3) {
      setState(() => _step++);
    } else {
      _submit();
    }
  }

  void _prev() {
    if (_step > 0) setState(() => _step--);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_mainImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please upload a cover image")),
      );
      return;
    }
    if (_modelFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please upload AR model (.glb/.usdz)")),
      );
      return;
    }

    _formKey.currentState!.save();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Item uploaded successfully! (demo)")),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text("Upload AR Item", style: AppTextStyles.heading()),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _stepsHeader(),
              Expanded(child: _buildStepContent()),
              _footerButtons(),
            ],
          ),
        ),
      ),
    );
  }

  // ------------------------------
  // STEP HEADER INDICATOR
  // ------------------------------
  Widget _stepsHeader() {
    const labels = ["Info", "Media", "AR Model", "License"];
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: List.generate(labels.length, (i) {
          final active = _step >= i;
          return Expanded(
            child: Column(
              children: [
                Container(
                  height: 10,
                  decoration: BoxDecoration(
                    color: active ? AppColors.primary : AppColors.surfaceSoft,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 6),
                Text(labels[i],
                    textAlign: TextAlign.center,
                    style: AppTextStyles.caption(
                        color: active ? AppColors.primary : AppColors.textSoft)),
              ],
            ),
          );
        }),
      ),
    );
  }

  // ------------------------------
  // STEP CONTENT
  // ------------------------------
  Widget _buildStepContent() {
    switch (_step) {
      case 0:
        return _stepInfo();
      case 1:
        return _stepMedia();
      case 2:
        return _stepModel();
      case 3:
        return _stepLicense();
      default:
        return const SizedBox();
    }
  }

  // ------------------------------
  // STEP 1 — BASIC INFO
  // ------------------------------
  Widget _stepInfo() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text("Basic Information", style: AppTextStyles.title()),
        const SizedBox(height: 16),
        TextFormField(
          decoration: const InputDecoration(labelText: "Item Title"),
          validator: (v) => v!.isEmpty ? "Required" : null,
          onSaved: (v) => _title = v!,
        ),
        const SizedBox(height: 12),
        TextFormField(
          maxLines: 4,
          decoration: const InputDecoration(labelText: "Description"),
          validator: (v) => v!.isEmpty ? "Required" : null,
          onSaved: (v) => _description = v!,
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField(
          decoration: const InputDecoration(labelText: "Category"),
          items: const [
            DropdownMenuItem(value: "Portal", child: Text("Portal")),
            DropdownMenuItem(value: "3D Object", child: Text("3D Object")),
            DropdownMenuItem(value: "Effect", child: Text("AR Effect")),
            DropdownMenuItem(value: "Aura", child: Text("Hologram Aura")),
          ],
          value: _category,
          onChanged: (v) => setState(() => _category = v.toString()),
        ),
        const SizedBox(height: 16),
        Slider(
          value: _price,
          min: 0,
          max: 200,
          divisions: 40,
          label: "\$${_price.toStringAsFixed(0)}",
          onChanged: (v) => setState(() => _price = v),
        ),
        Center(
            child: Text("Price: \$${_price.toStringAsFixed(0)}",
                style: AppTextStyles.body())),
      ],
    );
  }

  // ------------------------------
  // STEP 2 — MEDIA (IMAGES)
  // ------------------------------
  Widget _stepMedia() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text("Upload Cover Image", style: AppTextStyles.title()),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            height: 180,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
              image: _mainImage != null
                  ? DecorationImage(image: FileImage(_mainImage!), fit: BoxFit.cover)
                  : null,
            ),
            child: _mainImage == null
                ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add_photo_alternate,
                      size: 42, color: AppColors.primary),
                  const SizedBox(height: 8),
                  Text("Tap to upload image",
                      style: AppTextStyles.caption()),
                ],
              ),
            )
                : null,
          ),
        ),
      ],
    );
  }

  // ------------------------------
  // STEP 3 — AR MODEL (.glb / .usdz)
  // ------------------------------
  Widget _stepModel() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text("Upload AR Model", style: AppTextStyles.title()),
        const SizedBox(height: 14),
        GestureDetector(
          onTap: _pickModel,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                Icon(Icons.view_in_ar,
                    size: 46,
                    color: _modelFile == null
                        ? AppColors.textSoft
                        : AppColors.primary),
                const SizedBox(height: 10),
                Text(
                  _modelFile == null
                      ? "Tap to upload .glb / .usdz"
                      : "Model selected: ${_modelFile!.path.split('/').last}",
                  style: AppTextStyles.caption(),
                )
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Text(
            "Tip: Use optimized 3D models (under 10MB) for best AR performance.",
            style: AppTextStyles.caption(),
          ),
        )
      ],
    );
  }

  // ------------------------------
  // STEP 4 — LICENSE & RIGHTS
  // ------------------------------
  Widget _stepLicense() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text("Usage License", style: AppTextStyles.title()),
        const SizedBox(height: 14),
        SwitchListTile(
          value: _allowCommercialUse,
          onChanged: (v) => setState(() => _allowCommercialUse = v),
          title: const Text("Allow commercial use"),
        ),
        SwitchListTile(
          value: _allowModifications,
          onChanged: (v) => setState(() => _allowModifications = v),
          title: const Text("Allow modifications"),
        ),
        const SizedBox(height: 16),
        Text(
          "These settings affect how buyers can use your AR asset in MetaZone.",
          style: AppTextStyles.caption(),
        ),
      ],
    );
  }

  // ------------------------------
  // FOOTER BUTTONS
  // ------------------------------
  Widget _footerButtons() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          if (_step > 0)
            Expanded(
                child: OutlinedButton(
                    onPressed: _prev, child: const Text("Back"))),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: _next,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: Text(_step == 3 ? "Upload" : "Next"),
            ),
          ),
        ],
      ),
    );
  }
}
