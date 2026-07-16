import 'package:flutter/material.dart';
import 'layer_model.dart';

class LayersController extends ChangeNotifier {
  final List<LayerModel> layers = [
    LayerModel(
      id: 'people',
      title: 'People',
      subtitle: 'Nearby users',
      icon: Icons.groups,
      color: const Color(0xff3B82F6),
    ),
    LayerModel(
      id: 'objects',
      title: 'Objects',
      subtitle: '3D objects',
      icon: Icons.view_in_ar,
      color: const Color(0xff22C55E),
    ),
    LayerModel(
      id: 'events',
      title: 'Events',
      subtitle: 'Live events',
      icon: Icons.event,
      color: const Color(0xffC026D3),
    ),
    LayerModel(
      id: 'ai',
      title: 'AI',
      subtitle: 'AI assistants',
      icon: Icons.smart_toy,
      color: const Color(0xff06B6D4),
    ),
    LayerModel(
      id: 'ghost',
      title: 'Ghost Echo',
      subtitle: 'Digital echoes',
      icon: Icons.blur_on,
      color: const Color(0xffEC4899),
    ),
    LayerModel(
      id: 'messages',
      title: 'Messages',
      subtitle: 'AR messages',
      icon: Icons.chat_bubble_outline,
      color: const Color(0xffF59E0B),
    ),
    LayerModel(
      id: 'portals',
      title: 'Portals',
      subtitle: 'AR portals',
      icon: Icons.public,
      color: const Color(0xff6366F1),
    ),
    LayerModel(
      id: 'market',
      title: 'Market',
      subtitle: 'Nearby offers',
      icon: Icons.shopping_bag_outlined,
      color: const Color(0xffFB923C),
    ),
  ];

  void toggleLayer(String id) {
    final layer = layers.firstWhere((e) => e.id == id);
    layer.enabled = !layer.enabled;
    notifyListeners();
  }

  bool isEnabled(String id) {
    return layers.firstWhere((e) => e.id == id).enabled;
  }
}