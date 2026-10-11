import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:meta_zone/core/theme/theme.dart';
import 'package:meta_zone/screens/home/domain/home_section_model.dart';
import 'package:meta_zone/screens/map/metazone_map_screen.dart';

/// One reusable profile for every place in MetaZone.
///
/// The current Home data is demo data. This screen intentionally renders only
/// fields that exist on [NearbyPlace] and does not invent phone numbers,
/// opening hours, addresses, or services.
class ZoneProfileScreen extends StatefulWidget {
  const ZoneProfileScreen({
    required this.place,
    required this.locationName,
    this.happenings = const <Happening>[],
    super.key,
  });

  final NearbyPlace place;
  final String locationName;
  final List<Happening> happenings;

  @override
  State<ZoneProfileScreen> createState() => _ZoneProfileScreenState();
}

class _ZoneProfileScreenState extends State<ZoneProfileScreen> {
  static const String _savedZonesKey = 'metazone_saved_zone_ids_v1';

  bool _isSaved = false;
  bool _savedStateLoaded = false;
  bool _saveBusy = false;

  List<Happening> get _relatedHappenings {
    final String placeName = _normalize(widget.place.name);
    return widget.happenings
        .where((item) => _normalize(item.placeName) == placeName)
        .toList(growable: false);
  }

  String get _placeLocationLabel {
    final String value = widget.locationName.trim();
    if (value.isEmpty || value.toLowerCase() == 'around you') {
      return 'Nearby';
    }
    return value;
  }

  @override
  void initState() {
    super.initState();
    _loadSavedState();
  }

  Future<void> _loadSavedState() async {
    try {
      final SharedPreferences preferences =
      await SharedPreferences.getInstance();
      final List<String> savedIds =
          preferences.getStringList(_savedZonesKey) ?? <String>[];

      if (!mounted) return;
      setState(() {
        _isSaved = savedIds.contains(widget.place.id);
        _savedStateLoaded = true;
      });
    } catch (error) {
      debugPrint('MetaZone saved-zone load failed: $error');
      if (!mounted) return;
      setState(() => _savedStateLoaded = true);
    }
  }

  Future<void> _toggleSaved() async {
    if (_saveBusy || !_savedStateLoaded) return;

    setState(() => _saveBusy = true);
    final bool nextSavedState = !_isSaved;

    try {
      final SharedPreferences preferences =
      await SharedPreferences.getInstance();
      final List<String> savedIds =
          preferences.getStringList(_savedZonesKey) ?? <String>[];

      if (nextSavedState) {
        if (!savedIds.contains(widget.place.id)) {
          savedIds.add(widget.place.id);
        }
      } else {
        savedIds.removeWhere((id) => id == widget.place.id);
      }

      final bool persisted = await preferences.setStringList(
        _savedZonesKey,
        savedIds,
      );

      if (!mounted) return;
      if (!persisted) {
        _showMessage('Could not update saved places. Try again.');
        return;
      }

      setState(() => _isSaved = nextSavedState);
      _showMessage(
        nextSavedState ? 'Saved to your places.' : 'Removed from saved places.',
      );
    } catch (error) {
      debugPrint('MetaZone saved-zone update failed: $error');
      if (mounted) {
        _showMessage('Could not update saved places. Try again.');
      }
    } finally {
      if (mounted) setState(() => _saveBusy = false);
    }
  }

  Future<void> _openDirections() async {
    // Keep map exploration inside MetaZone. The map uses the Zone's own
    // coordinates when they are available; it never launches Google Maps.
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => MetaZoneMapScreen(
          place: widget.place,
          places: <NearbyPlace>[widget.place],
          locationName: _placeLocationLabel,
        ),
      ),
    );
  }

  Future<void> _shareZone() async {
    final NearbyPlace place = widget.place;
    final StringBuffer details = StringBuffer()
      ..writeln(place.name)
      ..writeln('${place.category} · $_placeLocationLabel');

    final String? address = place.address?.trim();
    if (address != null && address.isNotEmpty) {
      details.writeln(address);
    }
    final String? phone = place.phone?.trim();
    if (phone != null && phone.isNotEmpty) details.writeln('Phone: $phone');
    final String? website = place.websiteUrl?.trim();
    if (website != null && website.isNotEmpty) details.writeln(website);
    details
      ..writeln('MetaZone Zone ID: ${place.id}')
      ..write('Discovered with MetaZone');

    try {
      await Share.share(
        details.toString(),
        subject: 'Discover ${place.name} on MetaZone',
      );
    } catch (error) {
      debugPrint('MetaZone zone share failed: $error');
      if (mounted) _showMessage('Could not share this place right now.');
    }
  }

  Uri _webUri(String value) {
    final String normalized = value.trim();
    final Uri? parsed = Uri.tryParse(normalized);
    if (parsed != null && parsed.hasScheme) return parsed;
    return Uri.parse('https://$normalized');
  }

  Future<void> _openContactUri(Uri uri) async {
    try {
      final bool opened = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!opened && mounted) _showMessage('Could not open this contact link.');
    } catch (error) {
      debugPrint('MetaZone contact action failed: $error');
      if (mounted) _showMessage('Could not open this contact link.');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  static String _normalize(String value) =>
      value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

  @override
  Widget build(BuildContext context) {
    final NearbyPlace place = widget.place;
    final List<Happening> relatedHappenings = _relatedHappenings;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 270,
            pinned: true,
            elevation: 0,
            backgroundColor: AppColors.background,
            surfaceTintColor: Colors.transparent,
            leading: Padding(
              padding: const EdgeInsets.all(5),
              child: _HeroIconButton(
                icon: Icons.arrow_back_rounded,
                tooltip: 'Back',
                onTap: () => Navigator.maybePop(context),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 7),
                child: _HeroIconButton(
                  icon: Icons.ios_share_rounded,
                  tooltip: 'Share place',
                  onTap: _shareZone,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: _HeroIconButton(
                  icon: _isSaved
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                  tooltip: _isSaved ? 'Remove saved place' : 'Save place',
                  onTap: _savedStateLoaded && !_saveBusy
                      ? _toggleSaved
                      : null,
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: _buildHeroImage(place),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 20, 18, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildIdentity(place),
                  const SizedBox(height: 17),
                  _buildReputationRow(place),
                  const SizedBox(height: 20),
                  _buildPrimaryActions(),
                  const SizedBox(height: 28),
                  _SectionHeading(
                    title: 'Zone overview',
                    subtitle: 'The essentials, in one place',
                  ),
                  const SizedBox(height: 12),
                  _buildOverview(place),
                  const SizedBox(height: 24),
                  _SectionHeading(
                    title: 'About this Zone',
                    subtitle: 'Description, services and hours supplied for this place',
                  ),
                  const SizedBox(height: 12),
                  _buildPracticalDetails(place),
                  const SizedBox(height: 24),
                  _SectionHeading(
                    title: 'Contact & social',
                    subtitle: 'Official contact channels saved in MetaZone',
                  ),
                  const SizedBox(height: 12),
                  _buildContactSection(place),
                  const SizedBox(height: 26),
                  _SectionHeading(
                    title: 'Your place actions',
                    subtitle: 'Useful actions for exploring this location',
                  ),
                  const SizedBox(height: 12),
                  _buildActionRows(),
                  const SizedBox(height: 26),
                  _SectionHeading(
                    title: 'Around this Zone',
                    subtitle: 'Events and updates connected to this place',
                  ),
                  const SizedBox(height: 12),
                  if (relatedHappenings.isEmpty)
                    _buildEmptyActivity()
                  else
                    ...relatedHappenings.map(
                          (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _RelatedHappeningTile(item: item),
                      ),
                    ),
                  const SizedBox(height: 22),
                  _buildDataNote(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroImage(NearbyPlace place) {
    final List<String> imageUrls = <String>{
      place.imageUrl,
      ...place.galleryImageUrls,
    }.where((String value) => value.trim().isNotEmpty).toList();

    return Stack(
      fit: StackFit.expand,
      children: [
        PageView.builder(
          itemCount: imageUrls.isEmpty ? 1 : imageUrls.length,
          itemBuilder: (context, index) {
            final String imageUrl = imageUrls.isEmpty ? '' : imageUrls[index];
            if (imageUrl.isEmpty) {
              return const ColoredBox(
                color: Color(0xFF11182A),
                child: Center(
                  child: Icon(Icons.place_rounded, size: 62, color: Color(0xFF9D7BFF)),
                ),
              );
            }
            return Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const ColoredBox(
                color: Color(0xFF11182A),
                child: Center(
                  child: Icon(
                    Icons.place_rounded,
                    size: 62,
                    color: Color(0xFF9D7BFF),
                  ),
                ),
              ),
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return const ColoredBox(
                  color: Color(0xFF11182A),
                  child: Center(child: CircularProgressIndicator.adaptive()),
                );
              },
            );
          },
        ),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[
                Color(0x64000000),
                Color(0x00000000),
                Color(0x10000000),
                Color(0xF0000000),
              ],
              stops: <double>[0, 0.34, 0.58, 1],
            ),
          ),
        ),
        Positioned(
          left: 18,
          right: 18,
          bottom: 18,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 11,
                vertical: 7,
              ),
              decoration: BoxDecoration(
                color: const Color(0xB40A1020),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.16),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.layers_rounded,
                    size: 14,
                    color: Color(0xFFC4AEFF),
                  ),
                  SizedBox(width: 6),
                  Text(
                    'METAZONE PLACE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIdentity(NearbyPlace place) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _MetaBadge(
              label: place.category,
              icon: _categoryIcon(place.category),
              color: const Color(0xFFBFA8FF),
            ),
            _MetaBadge(
              label: place.isVerified ? 'Verified Zone' : place.zoneStatus,
              icon: place.isVerified ? Icons.verified_rounded : Icons.layers_rounded,
              color: const Color(0xFF62DCCF),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          place.name,
          style: TextStyle(
            color: AppColors.text,
            fontSize: 29,
            height: 1.08,
            letterSpacing: -0.85,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(
              Icons.location_on_outlined,
              size: 15,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                _placeLocationLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 9,
                vertical: 5,
              ),
              decoration: BoxDecoration(
                color: place.openingStatusVerified
                    ? (place.isOpen ? const Color(0x192FD4A0) : const Color(0x19FF7979))
                    : const Color(0x19FFC86B),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Text(
                place.openingStatusVerified
                    ? (place.isOpen ? 'Open' : 'Closed')
                    : 'Hours unknown',
                style: TextStyle(
                  color: place.openingStatusVerified
                      ? (place.isOpen ? const Color(0xFF6BE2B2) : const Color(0xFFFF9A9A))
                      : const Color(0xFFFFC86B),
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildReputationRow(NearbyPlace place) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.065)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _MetricItem(
              icon: place.ratingVerified ? Icons.star_rounded : Icons.verified_user_outlined,
              iconColor: place.ratingVerified
                  ? const Color(0xFFFFC86B)
                  : const Color(0xFFBFA8FF),
              value: place.ratingVerified && place.reviewCount > 0
                  ? place.rating.toStringAsFixed(1)
                  : (place.isVerified ? 'Verified' : 'New Zone'),
              label: place.ratingVerified && place.reviewCount > 0
                  ? '${_formatCount(place.reviewCount)} reviews'
                  : 'Profile status',
            ),
          ),
          _VerticalDivider(),
          Expanded(
            child: _MetricItem(
              icon: Icons.near_me_rounded,
              iconColor: const Color(0xFFBFA8FF),
              value: place.distance,
              label: 'Distance',
            ),
          ),
          _VerticalDivider(),
          Expanded(
            child: _MetricItem(
              icon: Icons.access_time_rounded,
              iconColor: place.openingStatusVerified
                  ? (place.isOpen ? const Color(0xFF62DDB0) : const Color(0xFFFF9696))
                  : const Color(0xFFFFC86B),
              value: place.openingStatusVerified
                  ? (place.isOpen ? 'Open' : 'Closed')
                  : 'Unknown',
              label: 'Opening hours',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryActions() {
    return Row(
      children: [
        Expanded(
          flex: 6,
          child: SizedBox(
            height: 52,
            child: FilledButton.icon(
              onPressed: _openDirections,
              icon: const Icon(Icons.directions_rounded, size: 20),
              label: const Text(
                'Directions',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 5,
          child: SizedBox(
            height: 52,
            child: OutlinedButton.icon(
              onPressed: _savedStateLoaded && !_saveBusy
                  ? _toggleSaved
                  : null,
              icon: Icon(
                _isSaved
                    ? Icons.bookmark_added_rounded
                    : Icons.bookmark_add_outlined,
                size: 19,
              ),
              label: Text(
                _isSaved ? 'Saved' : 'Save place',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.text,
                side: BorderSide(
                  color: AppColors.primary.withValues(alpha: 0.60),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOverview(NearbyPlace place) {
    final String zoneDescription = _zoneDescription(place.zoneStatus);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.065)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 43,
                height: 43,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.public_rounded,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'A place with a digital layer',
                      style: TextStyle(
                        color: AppColors.text,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      zoneDescription,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Divider(color: Colors.white.withValues(alpha: 0.08), height: 1),
          const SizedBox(height: 13),
          _InfoLine(
            icon: _categoryIcon(place.category),
            title: 'Category',
            value: place.category,
          ),
          const SizedBox(height: 12),
          _InfoLine(
            icon: Icons.layers_outlined,
            title: 'Zone type',
            value: place.zoneStatus,
          ),
          const SizedBox(height: 12),
          _InfoLine(
            icon: Icons.location_on_outlined,
            title: 'Area',
            value: _placeLocationLabel,
          ),
        ],
      ),
    );
  }

  Widget _buildPracticalDetails(NearbyPlace place) {
    final String? description = place.description?.trim();
    final String? hours = place.openingHours?.trim();
    final List<String> services = place.services
        .map((String value) => value.trim())
        .where((String value) => value.isNotEmpty)
        .toList(growable: false);

    if ((description == null || description.isEmpty) &&
        (hours == null || hours.isEmpty) &&
        services.isEmpty) {
      return _InfoPanel(
        icon: Icons.info_outline_rounded,
        title: 'Details are being completed',
        body: 'This Zone has not added a verified description, service list or opening hours yet.',
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.065)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (description != null && description.isNotEmpty) ...<Widget>[
            Text(
              description,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.55),
            ),
            if ((hours != null && hours.isNotEmpty) || services.isNotEmpty)
              const SizedBox(height: 15),
          ],
          if (hours != null && hours.isNotEmpty) ...<Widget>[
            _InfoLine(
              icon: Icons.schedule_rounded,
              title: 'Opening hours',
              value: hours,
            ),
            if (services.isNotEmpty) const SizedBox(height: 14),
          ],
          if (services.isNotEmpty) ...<Widget>[
            Text(
              'Services',
              style: TextStyle(color: AppColors.text, fontSize: 12, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 9),
            Wrap(
              spacing: 7,
              runSpacing: 7,
              children: services.map((String service) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.11),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.20)),
                  ),
                  child: Text(
                    service,
                    style: TextStyle(color: AppColors.text, fontSize: 10.5, fontWeight: FontWeight.w600),
                  ),
                );
              }).toList(growable: false),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildContactSection(NearbyPlace place) {
    final List<Widget> rows = <Widget>[];
    final String? phone = place.phone?.trim();
    final String? email = place.email?.trim();
    final String? website = place.websiteUrl?.trim();
    final String? whatsapp = place.whatsAppNumber?.trim();
    final String? address = place.address?.trim();

    if (phone != null && phone.isNotEmpty) {
      rows.add(_ContactAction(
        icon: Icons.call_rounded,
        title: 'Phone',
        value: phone,
        onTap: () => _openContactUri(Uri(scheme: 'tel', path: phone)),
      ));
    }
    if (whatsapp != null && whatsapp.isNotEmpty) {
      final String digits = whatsapp.replaceAll(RegExp(r'[^0-9]'), '');
      if (digits.isNotEmpty) {
        rows.add(_ContactAction(
          icon: Icons.chat_rounded,
          title: 'WhatsApp',
          value: whatsapp,
          onTap: () => _openContactUri(Uri.https('wa.me', '/$digits')),
        ));
      }
    }
    if (email != null && email.isNotEmpty) {
      rows.add(_ContactAction(
        icon: Icons.mail_outline_rounded,
        title: 'Email',
        value: email,
        onTap: () => _openContactUri(Uri(scheme: 'mailto', path: email)),
      ));
    }
    if (website != null && website.isNotEmpty) {
      rows.add(_ContactAction(
        icon: Icons.language_rounded,
        title: 'Website',
        value: website,
        onTap: () => _openContactUri(_webUri(website)),
      ));
    }
    if (address != null && address.isNotEmpty) {
      rows.add(_ContactAction(
        icon: Icons.location_on_outlined,
        title: 'Address',
        value: address,
        onTap: _openDirections,
      ));
    }

    final List<MapEntry<String, String>> socials = place.socialLinks.entries
        .where((MapEntry<String, String> entry) => entry.value.trim().isNotEmpty)
        .toList(growable: false);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.065)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (rows.isEmpty && socials.isEmpty)
            const _InfoPanel(
              icon: Icons.contact_page_outlined,
              title: 'No contact details yet',
              body: 'This Zone has not published phone, email, website or social accounts.',
            )
          else ...<Widget>[
            ...rows,
            if (socials.isNotEmpty) ...<Widget>[
              if (rows.isNotEmpty) const SizedBox(height: 7),
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 8, 4, 9),
                child: Text(
                  'Social channels',
                  style: TextStyle(color: AppColors.text, fontSize: 12, fontWeight: FontWeight.w800),
                ),
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: socials.map((MapEntry<String, String> entry) {
                  final String network = entry.key;
                  return ActionChip(
                    avatar: Icon(_socialIcon(network), size: 15, color: AppColors.primary),
                    label: Text(network),
                    onPressed: () => _openContactUri(_webUri(entry.value)),
                    backgroundColor: AppColors.background,
                    side: BorderSide(color: Colors.white.withValues(alpha: 0.09)),
                    labelStyle: TextStyle(color: AppColors.text, fontSize: 10.5, fontWeight: FontWeight.w700),
                  );
                }).toList(growable: false),
              ),
            ],
          ],
        ],
      ),
    );
  }

  static IconData _socialIcon(String network) {
    final String key = network.toLowerCase();
    if (key.contains('instagram')) return Icons.camera_alt_outlined;
    if (key.contains('facebook')) return Icons.facebook_rounded;
    if (key.contains('tiktok')) return Icons.music_video_rounded;
    if (key.contains('youtube')) return Icons.smart_display_rounded;
    if (key.contains('linkedin')) return Icons.work_outline_rounded;
    if (key.contains('whatsapp')) return Icons.chat_rounded;
    if (key.contains('telegram')) return Icons.send_rounded;
    return Icons.link_rounded;
  }

  Widget _buildActionRows() {
    return Column(
      children: [
        _ActionTile(
          icon: Icons.directions_outlined,
          title: 'Get directions',
          subtitle: 'Open the interactive map inside MetaZone',
          onTap: _openDirections,
        ),
        const SizedBox(height: 9),
        _ActionTile(
          icon: Icons.ios_share_rounded,
          title: 'Share this Zone',
          subtitle: 'Send the place to someone',
          onTap: _shareZone,
        ),
        const SizedBox(height: 9),
        _ActionTile(
          icon: _isSaved ? Icons.bookmark_added_rounded : Icons.bookmark_add_outlined,
          title: _isSaved ? 'Saved to your places' : 'Save for later',
          subtitle: 'Keep this place in your personal list',
          onTap: _savedStateLoaded && !_saveBusy ? _toggleSaved : null,
        ),
      ],
    );
  }

  Widget _buildEmptyActivity() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.065)),
      ),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.13),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.dynamic_feed_rounded,
              color: AppColors.primary,
              size: 23,
            ),
          ),
          const SizedBox(height: 11),
          Text(
            'No updates here yet',
            style: TextStyle(
              color: AppColors.text,
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Events, offers, and place updates will appear here when available.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11.5,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataNote() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.info_outline_rounded,
          size: 16,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'This is a MetaZone Zone profile. Contact details, ratings, opening hours '
                'and the exact map pin appear only when those fields are provided and verified. '
                'Map tiles are supplied separately from the Zone directory.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 10.5,
              height: 1.45,
            ),
          ),
        ),
      ],
    );
  }

  static String _zoneDescription(String zoneStatus) {
    final String status = zoneStatus.toLowerCase();
    if (status.contains('smart')) {
      return 'This place is marked as a Smart Zone in the current MetaZone data.';
    }
    if (status.contains('active')) {
      return 'This place is marked as an Active Zone in the current MetaZone data.';
    }
    if (status.contains('basic')) {
      return 'This place currently has a Basic Zone profile in MetaZone.';
    }
    return 'This profile brings the place information and useful actions together.';
  }

  static IconData _categoryIcon(String category) {
    final String value = category.toLowerCase();
    if (value.contains('restaurant') ||
        value.contains('food') ||
        value.contains('egyptian') ||
        value.contains('dining') ||
        value.contains('مطعم')) {
      return Icons.restaurant_rounded;
    }
    if (value.contains('cafe') || value.contains('coffee') || value.contains('كافيه')) {
      return Icons.coffee_rounded;
    }
    if (value.contains('hospital') ||
        value.contains('clinic') ||
        value.contains('health')) {
      return Icons.health_and_safety_rounded;
    }
    if (value.contains('school') ||
        value.contains('university') ||
        value.contains('education')) {
      return Icons.school_rounded;
    }
    if (value.contains('hotel')) return Icons.hotel_rounded;
    if (value.contains('shop') || value.contains('mall')) {
      return Icons.shopping_bag_rounded;
    }
    return Icons.place_rounded;
  }

  static String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    }
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }
}

class _ContactAction extends StatelessWidget {
  const _ContactAction({
    required this.icon,
    required this.title,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
      leading: Container(
        width: 39,
        height: 39,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppColors.primary, size: 18),
      ),
      title: Text(title, style: TextStyle(color: AppColors.textSecondary, fontSize: 10.5)),
      subtitle: Text(
        value,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: AppColors.text, fontSize: 12, fontWeight: FontWeight.w700),
      ),
      trailing: Icon(Icons.open_in_new_rounded, color: AppColors.textSecondary, size: 16),
      onTap: onTap,
    );
  }
}

class _InfoPanel extends StatelessWidget {
  const _InfoPanel({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withValues(alpha: 0.055)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(title, style: TextStyle(color: AppColors.text, fontSize: 12, fontWeight: FontWeight.w800)),
                const SizedBox(height: 5),
                Text(body, style: TextStyle(color: AppColors.textSecondary, fontSize: 11, height: 1.45)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroIconButton extends StatelessWidget {
  const _HeroIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.black.withValues(alpha: 0.35),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: 42,
            height: 42,
            child: Icon(icon, color: Colors.white, size: 20),
          ),
        ),
      ),
    );
  }
}

class _MetaBadge extends StatelessWidget {
  const _MetaBadge({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.24)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricItem extends StatelessWidget {
  const _MetricItem({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 15, color: iconColor),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.text,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 9,
          ),
        ),
      ],
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 38,
      margin: const EdgeInsets.symmetric(horizontal: 9),
      color: Colors.white.withValues(alpha: 0.09),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: AppColors.text,
            fontSize: 18,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.35,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11.5,
          ),
        ),
      ],
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11.5,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.text,
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.065)),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(icon, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: AppColors.text,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 10.5,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RelatedHappeningTile extends StatelessWidget {
  const _RelatedHappeningTile({required this.item});

  final Happening item;

  @override
  Widget build(BuildContext context) {
    final Color kindColor = switch (item.type) {
      HappeningType.event => const Color(0xFFBFA8FF),
      HappeningType.offer => const Color(0xFFFFC779),
      HappeningType.activity => const Color(0xFF67D8D0),
    };

    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: Colors.white.withValues(alpha: 0.065)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 72,
              height: 72,
              child: Image.network(
                item.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => ColoredBox(
                  color: kindColor.withValues(alpha: 0.12),
                  child: Icon(Icons.event_rounded, color: kindColor),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                  decoration: BoxDecoration(
                    color: kindColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Text(
                    item.type.name.toUpperCase(),
                    style: TextStyle(
                      color: kindColor,
                      fontSize: 8,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.text,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (item.meta != null && item.meta!.trim().isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    item.meta!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 10.5,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
