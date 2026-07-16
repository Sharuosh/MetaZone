import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

// ثيم MetaZone
import '../../../core/theme/theme.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _controller;

  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(30.0444, 31.2357), // Cairo
    zoom: 13.5,
  );

  final List<Map<String, dynamic>> _spots = [
    {
      "id": "spot1",
      "title": "Nebula Gate",
      "location": LatLng(30.043, 31.233),
    },
    {
      "id": "spot2",
      "title": "Tiny Robot",
      "location": LatLng(30.048, 31.240),
    },
    {
      "id": "spot3",
      "title": "Sky Lantern",
      "location": LatLng(30.040, 31.238),
    },
  ];

  Set<Marker> _buildMarkers() {
    return _spots.map((spot) {
      return Marker(
        markerId: MarkerId(spot["id"]),
        position: spot["location"],
        infoWindow: InfoWindow(title: spot["title"]),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueAzure,
        ),
      );
    }).toSet();
  }

  void _centerOn(LatLng pos) {
    _controller?.animateCamera(
      CameraUpdate.newLatLngZoom(pos, 15),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          "AR Map",
          style: GoogleFonts.orbitron(
            color: AppColors.primary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: Stack(
        children: [
          // ---------- Google Map ----------
          GoogleMap(
            initialCameraPosition: _initialPosition,
            onMapCreated: (c) => _controller = c,
            markers: _buildMarkers(),
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: false,
            compassEnabled: true,
          ),

          // ---------- Bottom Card ----------
          Positioned(
            bottom: 20,
            left: 12,
            right: 12,
            child: _buildBottomCard(),
          )
        ],
      ),
    );
  }

  Widget _buildBottomCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Nearby AR Spots",
            style: GoogleFonts.orbitron(
              color: AppColors.primary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          ..._spots.map((spot) {
            return GestureDetector(
              onTap: () => _centerOn(spot["location"]),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Icon(Icons.location_on, color: AppColors.primary),
                    const SizedBox(width: 10),
                    Text(
                      spot["title"],
                      style: TextStyle(color: AppColors.text),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: AppColors.textSoft,
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
