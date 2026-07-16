import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/theme.dart';
import 'saved_spot_model.dart';
import 'saved_spots_service.dart';
import '../../ar/spot_details/ar_spot_details_screen.dart';

class SavedSpotsScreen extends StatelessWidget {
  final String uid;
  SavedSpotsScreen({super.key, required this.uid});

  final _service = SavedSpotsService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text("Saved AR Spots",
            style: GoogleFonts.poppins(
                color: AppColors.primary,
                fontWeight: FontWeight.w600)),
      ),
      body: StreamBuilder<List<SavedSpot>>(
        stream: _service.streamSaved(uid),
        builder: (context, snap) {
          if (!snap.hasData) {
            return Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          final list = snap.data!;
          if (list.isEmpty) {
            return _emptyState(context);
          }

          return ListView.builder(
            padding: const EdgeInsets.all(14),
            itemCount: list.length,
            itemBuilder: (_, i) => _card(context, list[i]),
          );
        },
      ),
    );
  }

  Widget _emptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bookmark_border, size: 70, color: AppColors.textSoft),
          const SizedBox(height: 14),
          Text("No saved AR spots yet",
              style: GoogleFonts.poppins(color: AppColors.textSoft)),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: Text("Explore", style: TextStyle(color: Colors.black)),
          )
        ],
      ),
    );
  }

  Widget _card(BuildContext ctx, SavedSpot s) {
    return GestureDetector(
      onTap: () => Navigator.push(
          ctx,
          MaterialPageRoute(
              builder: (_) => ARSpotDetailsScreen(spotId: s.id))),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            _cover(s),
            Expanded(child: _info(s)),
            _actions(ctx, s),
          ],
        ),
      ),
    );
  }

  Widget _cover(SavedSpot s) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        s.coverUrl ?? "https://picsum.photos/200",
        width: 110,
        height: 80,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _info(SavedSpot s) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(s.title,
              style: GoogleFonts.inter(
                  color: AppColors.text,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text("by ${s.creatorName}",
              style: TextStyle(color: AppColors.textSoft)),
          const SizedBox(height: 6),
          if (s.featured)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primarySoft.withOpacity(.35),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text("Featured",
                  style: TextStyle(
                      color: AppColors.primary, fontSize: 12)),
            ),
        ],
      ),
    );
  }

  Widget _actions(BuildContext ctx, SavedSpot s) {
    return IconButton(
        onPressed: () async {
          await _service.toggleSave(uid, s);
        },
        icon: Icon(Icons.bookmark_remove,
            color: AppColors.primary));
  }
}
