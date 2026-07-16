// File: lib/screens/ar/portal_editor/panels/teleport_panel.dart
// MetaZone — Teleport Panel (FULL INTEGRATION VERSION)

import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';
import '../models/portal_config.dart';

class TeleportPanel extends StatefulWidget {
  final PortalConfig config;
  final Function(PortalConfig newConfig) onChanged;

  const TeleportPanel({
    super.key,
    required this.config,
    required this.onChanged,
  });

  @override
  State<TeleportPanel> createState() => _TeleportPanelState();
}

class _TeleportPanelState extends State<TeleportPanel> {
  // =============================
  // INTERNAL STATE RESTORED
  // =============================
  List<String> _destinations = [
    "City Rooftop - Night",
    "Underground Arcade",
    "Ocean Dome",
    "Desert Temple",
    "User Zone: Ahmed"
  ];

  String? _selectedDestination;

  String _mode = "instant";
  double _arrivalDelay = 0.6;
  bool _relativeToUser = true;

  bool _useParticles = true;
  double _particleAmount = 0.6;

  bool _useSound = true;
  double _volume = 0.7;

  bool _requirePermission = false;
  bool _allowGuests = true;
  bool _recordEntry = false;

  @override
  void initState() {
    super.initState();

    // Load from config if exists
    _selectedDestination = widget.config.teleportDestination != "none"
        ? widget.config.teleportDestination
        : _destinations.first;

    final saved = widget.config.presets["teleport"];
    if (saved is Map) {
      _mode = saved["mode"] ?? _mode;
      _arrivalDelay = (saved["delay"] ?? _arrivalDelay).toDouble();
      _relativeToUser = saved["relative"] ?? _relativeToUser;
      _useParticles = saved["particles"] ?? _useParticles;
      _particleAmount = (saved["particleAmount"] ?? _particleAmount).toDouble();
      _useSound = saved["sound"] ?? _useSound;
      _volume = (saved["volume"] ?? _volume).toDouble();
      _requirePermission = saved["requirePermission"] ?? _requirePermission;
      _allowGuests = saved["allowGuests"] ?? _allowGuests;
      _recordEntry = saved["recordEntry"] ?? _recordEntry;
    }
  }

  // ======================================================
  // EMIT CHANGES → update PortalConfig in parent
  // ======================================================
  void _emit() {
    final newConfig = widget.config.copyWith(
      teleportDestination: _selectedDestination,
      presets: {
        ...widget.config.presets,
        "teleport": {
          "mode": _mode,
          "delay": _arrivalDelay,
          "relative": _relativeToUser,
          "particles": _useParticles,
          "particleAmount": _particleAmount,
          "sound": _useSound,
          "volume": _volume,
          "requirePermission": _requirePermission,
          "allowGuests": _allowGuests,
          "recordEntry": _recordEntry,
        }
      },
    );

    widget.onChanged(newConfig);
  }

  // ======================================================
  // UI
  // ======================================================
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Teleport & Destination", style: AppTextStyles.title(size: 18)),
          const SizedBox(height: 12),

          _label("Destination"),
          _destinationDropdown(),

          const SizedBox(height: 14),
          _label("Teleport Mode"),
          _modes(),

          const SizedBox(height: 14),
          _label("Arrival Delay (s)"),
          Slider(
            value: _arrivalDelay,
            min: 0,
            max: 3,
            divisions: 30,
            onChanged: (v) {
              setState(() => _arrivalDelay = v);
              _emit();
            },
            activeColor: AppColors.primary,
          ),
          Text(
            "${_arrivalDelay.toStringAsFixed(2)} s",
            style: AppTextStyles.caption(),
          ),

          const SizedBox(height: 18),
          _label("Spawn Position"),
          Row(
            children: [
              _chipButton("Relative to User", _relativeToUser, () {
                setState(() => _relativeToUser = true);
                _emit();
              }),
              const SizedBox(width: 8),
              _chipButton("Absolute (World)", !_relativeToUser, () {
                setState(() => _relativeToUser = false);
                _emit();
              }),
            ],
          ),

          const SizedBox(height: 18),
          Divider(color: AppColors.border.withOpacity(.6)),
          const SizedBox(height: 10),

          // -----------------------
          // ARRIVAL FX
          // -----------------------
          Text("Arrival Effects", style: AppTextStyles.title(size: 16)),
          const SizedBox(height: 10),

          _toggleRow("Particles", _useParticles, (v) {
            setState(() => _useParticles = v);
            _emit();
          }),

          if (_useParticles)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text("Particle Amount", style: AppTextStyles.caption()),
                Slider(
                  value: _particleAmount,
                  min: 0,
                  max: 1,
                  onChanged: (v) {
                    setState(() => _particleAmount = v);
                    _emit();
                  },
                  activeColor: AppColors.primary,
                ),
              ],
            ),

          const SizedBox(height: 12),
          _toggleRow("Arrival Sound", _useSound, (v) {
            setState(() => _useSound = v);
            _emit();
          }),

          if (_useSound)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text("Volume", style: AppTextStyles.caption()),
                Slider(
                  value: _volume,
                  min: 0,
                  max: 1,
                  onChanged: (v) {
                    setState(() => _volume = v);
                    _emit();
                  },
                  activeColor: AppColors.primary,
                ),
              ],
            ),

          const SizedBox(height: 18),
          Divider(color: AppColors.border.withOpacity(.6)),
          const SizedBox(height: 12),

          Text("Access & Behavior", style: AppTextStyles.title(size: 16)),
          const SizedBox(height: 10),

          _toggleRow("Require Permission", _requirePermission, (v) {
            setState(() => _requirePermission = v);
            _emit();
          }),

          _toggleRow("Allow Guest Access", _allowGuests, (v) {
            setState(() => _allowGuests = v);
            _emit();
          }),

          _toggleRow("Record Entry (Analytics)", _recordEntry, (v) {
            setState(() => _recordEntry = v);
            _emit();
          }),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ======================================================
  // UI COMPONENTS
  // ======================================================

  Widget _label(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(t, style: AppTextStyles.caption()),
  );

  Widget _destinationDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border.withOpacity(.5)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedDestination,
          items: _destinations
              .map((d) => DropdownMenuItem(
            value: d,
            child: Text(d, style: AppTextStyles.body()),
          ))
              .toList(),
          onChanged: (v) {
            setState(() => _selectedDestination = v);
            _emit();
          },
          isExpanded: true,
          dropdownColor: AppColors.card,
        ),
      ),
    );
  }

  Widget _modes() {
    return Row(
      children: [
        _modeChip("Instant", _mode == "instant", () {
          setState(() => _mode = "instant");
          _emit();
        }),
        const SizedBox(width: 8),
        _modeChip("Walkthrough", _mode == "walkthrough", () {
          setState(() => _mode = "walkthrough");
          _emit();
        }),
        const SizedBox(width: 8),
        _modeChip("Fade", _mode == "fade", () {
          setState(() => _mode = "fade");
          _emit();
        }),
      ],
    );
  }

  Widget _modeChip(String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : AppColors.surface.withOpacity(.4),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: AppTextStyles.caption().copyWith(
            color: active ? Colors.black : Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _chipButton(String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: active
              ? AppColors.neonGradient.colors.first
              : AppColors.surface.withOpacity(.4),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: AppTextStyles.caption().copyWith(
            color: active ? Colors.black : Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _toggleRow(String label, bool value, Function(bool) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(label, style: AppTextStyles.body())),
          Switch(
            value: value,
            activeColor: AppColors.primary,
            onChanged: (v) => onChanged(v),
          ),
        ],
      ),
    );
  }
}
