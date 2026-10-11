import 'package:flutter/material.dart';

class AskScreen extends StatelessWidget {
  const AskScreen({super.key});

  @override
  Widget build(BuildContext context) => const _SenseCapabilityScaffold(
    title: 'Ask',
    icon: Icons.chat_bubble_rounded,
    accent: Color(0xFF53E0C0),
    description:
    'Ask MetaZone about the thing or scene you are looking at. The conversational UI will connect to the multimodal AI layer in the next implementation step.',
    integration: 'Multimodal AI + Camera context integration point',
  );
}

class _SenseCapabilityScaffold extends StatelessWidget {
  const _SenseCapabilityScaffold({
    required this.title,
    required this.icon,
    required this.accent,
    required this.description,
    required this.integration,
  });

  final String title;
  final IconData icon;
  final Color accent;
  final String description;
  final String integration;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: Text(title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: VisionCapabilityBody(
          title: title,
          icon: icon,
          accent: accent,
          description: description,
          integration: integration,
        ),
      ),
    );
  }
}

class VisionCapabilityBody extends StatelessWidget {
  const VisionCapabilityBody({
    super.key,
    required this.title,
    required this.icon,
    required this.accent,
    required this.description,
    required this.integration,
  });

  final String title;
  final IconData icon;
  final Color accent;
  final String description;
  final String integration;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: accent.withOpacity(.12),
            border: Border.all(color: accent.withOpacity(.45)),
          ),
          child: Icon(icon, color: accent, size: 30),
        ),
        const SizedBox(height: 18),
        Text(title, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 10),
        Text(description),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: accent.withOpacity(.35)),
          ),
          child: Row(
            children: [
              Icon(Icons.link_rounded, color: accent, size: 20),
              const SizedBox(width: 10),
              Expanded(child: Text(integration)),
            ],
          ),
        ),
      ],
    );
  }
}
