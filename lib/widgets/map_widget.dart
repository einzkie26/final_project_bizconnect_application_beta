import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter/foundation.dart';
import 'offline_map_widget.dart';

class MapWidget extends StatefulWidget {
  final double? latitude;
  final double? longitude;
  final Function(LatLng)? onLocationSelected;
  final bool interactive;

  const MapWidget({
    super.key,
    this.latitude,
    this.longitude,
    this.onLocationSelected,
    this.interactive = true,
  });

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  late MapController _mapController;
  LatLng? _selectedLocation;
  int _currentTileSource = 0;
  bool _useOfflineMode = false;
  int _errorCount = 0;
  
  List<Map<String, dynamic>> get _tileSources {
    if (defaultTargetPlatform == TargetPlatform.windows) {
      return [
        {
          'name': 'Bing Maps',
          'url': 'https://ecn.t0.tiles.virtualearth.net/tiles/r{quadkey}?g=1',
          'subdomains': <String>[],
        },
        {
          'name': 'ESRI World',
          'url': 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer/tile/{z}/{y}/{x}',
          'subdomains': <String>[],
        },
      ];
    }
    return [
      {
        'name': 'OpenStreetMap',
        'url': 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
        'subdomains': <String>[],
      },
    ];
  }

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    if (widget.latitude != null && widget.longitude != null) {
      _selectedLocation = LatLng(widget.latitude!, widget.longitude!);
    }
  }

  @override
  void didUpdateWidget(MapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.latitude != oldWidget.latitude || widget.longitude != oldWidget.longitude) {
      if (widget.latitude != null && widget.longitude != null) {
        _selectedLocation = LatLng(widget.latitude!, widget.longitude!);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _mapController.move(_selectedLocation!, 13.0);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_useOfflineMode) {
      return OfflineMapWidget(
        latitude: widget.latitude,
        longitude: widget.longitude,
        onLocationSelected: widget.onLocationSelected,
      );
    }

    return Container(
      height: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: FlutterMap(
          key: ValueKey('map_${widget.latitude}_${widget.longitude}_$_currentTileSource'),
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _selectedLocation ?? const LatLng(7.0731, 125.6128), // Davao City default
            initialZoom: 13.0,
            interactionOptions: InteractionOptions(
              flags: widget.interactive 
                ? InteractiveFlag.all 
                : InteractiveFlag.none,
            ),
            onTap: widget.interactive ? _onMapTap : null,
          ),
          children: [
            Stack(
              children: [
                TileLayer(
                  urlTemplate: _tileSources[_currentTileSource]['url'],
                  subdomains: _tileSources[_currentTileSource]['subdomains'],
                  userAgentPackageName: 'com.bizconnect.app',
                  maxZoom: 18,
                  errorTileCallback: (tile, error, stackTrace) {
                    _handleTileError();
                  },
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.refresh),
                          onPressed: _switchTileSource,
                          tooltip: 'Switch Map Source',
                        ),
                        IconButton(
                          icon: const Icon(Icons.offline_pin),
                          onPressed: () => setState(() => _useOfflineMode = true),
                          tooltip: 'Use Offline Mode',
                        ),
                        Text(
                          _tileSources[_currentTileSource]['name'],
                          style: const TextStyle(fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (_selectedLocation != null)
              MarkerLayer(
                markers: [
                  Marker(
                    point: _selectedLocation!,
                    width: 40,
                    height: 40,
                    child: const Icon(
                      Icons.location_pin,
                      color: Colors.red,
                      size: 40,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  void _onMapTap(TapPosition tapPosition, LatLng point) {
    if (widget.onLocationSelected != null) {
      setState(() {
        _selectedLocation = point;
      });
      widget.onLocationSelected!(point);
    }
  }

  void _handleTileError() {
    _errorCount++;
    if (_errorCount >= 10) {
      setState(() {
        _useOfflineMode = true;
      });
    } else {
      _switchTileSource();
    }
  }

  void _switchTileSource() {
    setState(() {
      _currentTileSource = (_currentTileSource + 1) % _tileSources.length;
    });
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }
}