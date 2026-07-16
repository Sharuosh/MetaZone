import 'dart:ui';
import 'package:flutter/material.dart';

import 'layer_tile.dart';
import 'layers_controller.dart';

class LayersPanel extends StatefulWidget {
  final VoidCallback onClose;

  const LayersPanel({
    super.key,
    required this.onClose,
  });

  @override
  State<LayersPanel> createState() => _LayersPanelState();
}

class _LayersPanelState extends State<LayersPanel> {
  final controller = LayersController();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 12,
      right: 12,
      bottom: -8,
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(34),
          topRight: Radius.circular(34),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 45,
            sigmaY: 45,
          ),
          child: Container(
            height: MediaQuery.of(context).size.height * .42,
            padding: const EdgeInsets.fromLTRB(
              18,
              12,
              18,
              18,
            ),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(34),
                topRight: Radius.circular(34),
              ),
              border: Border.all(
                color: Colors.white.withOpacity(.03),
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 60,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius:
                    BorderRadius.circular(20),
                  ),
                ),

                const SizedBox(height: 14),

                Row(
                  children: [
                    const Icon(
                      Icons.layers,
                      color: Color(0xff00D4FF),
                      size: 24,
                    ),

                    const SizedBox(width: 10),

                    const Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Layers",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight:
                              FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            "Choose what you want to see in AR",
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white
                            .withOpacity(.05),
                      ),
                      child: IconButton(
                        onPressed: widget.onClose,
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                SizedBox(
                  height: 230,
                  child: GridView.builder(
                    physics:
                    const BouncingScrollPhysics(),
                    itemCount:
                    controller.layers.length,
                    gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: .65,
                    ),
                    itemBuilder: (_, index) {
                      final layer =
                      controller.layers[index];

                      return LayerTile(
                        layer: layer,
                        onToggle: () {
                          setState(() {
                            controller.toggleLayer(
                              layer.id,
                            );
                          });
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}