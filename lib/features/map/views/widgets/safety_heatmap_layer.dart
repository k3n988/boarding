import 'package:flutter/material.dart';

/// SafetyHeatmapLayer
/// Currently a no-op widget — reserved for future safety heatmap overlay.
/// When implemented, this will render a color-coded heatmap on the GoogleMap
/// using the google_maps_flutter heatmap tiles or a custom tile provider.
class SafetyHeatmapLayer extends StatelessWidget {
  final bool isVisible;

  const SafetyHeatmapLayer({super.key, this.isVisible = false});

  @override
  Widget build(BuildContext context) {
    // Returns empty — actual heatmap tiles are added directly to GoogleMap widget
    return const SizedBox.shrink();
  }
}