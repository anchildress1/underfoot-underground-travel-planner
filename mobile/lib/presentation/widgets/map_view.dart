import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/colors.dart';
import '../../data/models/models.dart';
import '../blocs/chat/chat.dart';

class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> with TickerProviderStateMixin {
  final MapController _mapController = MapController();
  static const _defaultCenter = LatLng(37.2760, -82.0957); // Grundy, VA
  static const _defaultZoom = 13.0;

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  void _animateToPlace(Place place) {
    if (place.latitude != null && place.longitude != null) {
      final dest = LatLng(place.latitude!, place.longitude!);
      _mapController.move(dest, 15.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    // CartoDB Dark Matter base
    const darkMapUrl = 'https://cartodb-basemaps-{s}.global.ssl.fastly.net/dark_all/{z}/{x}/{y}.png';

    return BlocConsumer<ChatBloc, ChatState>(
      listenWhen: (prev, curr) => prev.selectedPlace != curr.selectedPlace,
      listener: (context, state) {
        if (state.selectedPlace != null) {
          _animateToPlace(state.selectedPlace!);
        }
      },
      builder: (context, state) {
        final places = state.allPlaces;
        
        LatLng center = _defaultCenter;
        if (places.isNotEmpty) {
          final firstWithCoords = places.firstWhere(
            (p) => p.latitude != null && p.longitude != null,
            orElse: () => places.first,
          );
          if (firstWithCoords.latitude != null &&
              firstWithCoords.longitude != null) {
            center = LatLng(
              firstWithCoords.latitude!,
              firstWithCoords.longitude!,
            );
          }
        }

        return FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: center,
            initialZoom: _defaultZoom,
            minZoom: 3,
            maxZoom: 18,
            backgroundColor: AppColors.background,
          ),
          children: [
            // Dark Gray Map Customization
            // Using ColorFiltered to shift the black tiles to dark gray/tinted
            ColorFiltered(
              colorFilter: const ColorFilter.matrix(<double>[
                // R  G  B  A  Const
                0.8, 0, 0, 0, 20, // Lighten red channel slightly
                0, 0.8, 0, 0, 20, // Lighten green
                0, 0, 0.9, 0, 30, // Lighten blue more for cool tint
                0, 0, 0, 1, 0,    // Alpha
              ]),
              child: TileLayer(
                urlTemplate: darkMapUrl,
                userAgentPackageName: 'com.underfoot.travel',
                subdomains: const ['a', 'b', 'c'],
              ),
            ),
            MarkerLayer(
              markers: _buildMarkers(places, state.selectedPlace),
            ),
            RichAttributionWidget(
              attributions: [
                TextSourceAttribution(
                  'OpenStreetMap contributors',
                  onTap: () => launchUrl(Uri.parse('https://openstreetmap.org/copyright')),
                ),
                TextSourceAttribution(
                  'CartoDB',
                  onTap: () => launchUrl(Uri.parse('https://carto.com/attributions')),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  List<Marker> _buildMarkers(List<Place> places, Place? selectedPlace) {
    return places.asMap().entries.map((entry) {
      final index = entry.key;
      final place = entry.value;
      final isSelected = place == selectedPlace;

      if (place.latitude == null || place.longitude == null) {
        return null;
      }

      return Marker(
        point: LatLng(place.latitude!, place.longitude!),
        width: 60,
        height: 70,
        child: GestureDetector(
          onTap: () {
             context.read<ChatBloc>().add(ChatPlaceSelected(index));
          },
          child: _CustomMarker(
            isSelected: isSelected,
            label: (index + 1).toString(),
          ),
        ),
      );
    }).whereType<Marker>().toList();
  }
}

class _CustomMarker extends StatelessWidget {
  final bool isSelected;
  final String label;

  const _CustomMarker({required this.isSelected, required this.label});

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? AppColors.magenta : AppColors.electricViolet;
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.darkSurface,
            shape: BoxShape.circle,
            border: Border.all(
              color: color,
              width: isSelected ? 3 : 2,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.6),
                blurRadius: isSelected ? 12 : 6,
                spreadRadius: isSelected ? 2 : 0,
              ),
            ],
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
                shadows: [
                  Shadow(
                    color: color,
                    blurRadius: 8,
                  ),
                ],
              ),
            ),
          ),
        ),
        Container(
          width: 2,
          height: 12,
          color: color,
        ).animate().fadeIn().scaleY(alignment: Alignment.topCenter),
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ).animate(onPlay: (c) => c.repeat(reverse: true))
         .scale(begin: const Offset(0.5, 0.5), end: const Offset(1.2, 1.2), duration: 1.seconds),
      ],
    );
  }
}
