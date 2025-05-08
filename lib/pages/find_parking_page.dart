import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import '../models/carpark.dart';
import '../services/carpark_service.dart';
import '../services/location_service.dart';
import '../widgets/carpark_info_card.dart';
import 'dart:convert';

class FindParkingPage extends StatelessWidget {
  const FindParkingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MapScreen();
  }
}

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final LocationService _locationService = LocationService();
  final CarparkService _carparkService = CarparkService();
  final MapController _mapController = MapController();

  LatLng? _currentPosition;
  List<Carpark> _nearbyCarparks = [];
  Carpark? _selectedCarpark;
  List<LatLng>? _routePoints;
  bool _isLoading = true;
  bool _isError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    setState(() {
      _isLoading = true;
      _isError = false;
    });

    try {
      Position position = await _locationService.determinePosition();
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _isLoading = false;
      });

      _fetchNearbyCarparks();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isError = true;
        _errorMessage = e.toString();
      });
    }
  }

  // Fonction asynchrone pour récupérer les parkings à proximité
  Future<void> _fetchNearbyCarparks() async {
    if (_currentPosition == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      String url =
          'http://127.0.0.1:8000/api/nearby-carparks/?lat=${_currentPosition!.latitude}&lng=${_currentPosition!.longitude}';
      var response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        setState(() {
          _nearbyCarparks = parseCarparks(response.body);
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load nearby car parks');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isError = true;
        _errorMessage = 'Failed to load nearby car parks: $e';
      });
    }
  }

  // Exemple de fonction pour parser le JSON en objets Carpark
  List<Carpark> parseCarparks(String responseBody) {
  final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();
  return parsed.map<Carpark>((json) => Carpark.fromJson(json)).toList();
}

  Future<void> _getRouteToCarpark(Carpark carpark) async {
    if (_currentPosition == null) return;

    setState(() {
      _routePoints = null;
    });

    try {
      List<LatLng> route = await _carparkService.getRoute(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        carpark.latitude,
        carpark.longitude,
      );

      setState(() {
        _routePoints = route;
      });
    } catch (e) {
      setState(() {
        _routePoints = [
          _currentPosition!,
          LatLng(carpark.latitude, carpark.longitude),
        ];
      });
    }
  }

  void _selectCarpark(Carpark carpark) {
    setState(() {
      _selectedCarpark = carpark;
    });

    if (_currentPosition != null) {
      LatLng centerPoint = LatLng(
        (_currentPosition!.latitude + carpark.latitude) / 2,
        (_currentPosition!.longitude + carpark.longitude) / 2,
      );

      _mapController.move(centerPoint, 13.0);
      _getRouteToCarpark(carpark);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading && _currentPosition == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Parkings disponibles")),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Récupération de votre position...'),
            ],
          ),
        ),
      );
    }

    if (_isError) {
      return Scaffold(
        appBar: AppBar(title: const Text("Parkings disponibles")),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Erreur: $_errorMessage'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _getUserLocation,
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Parkings disponibles'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchNearbyCarparks,
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentPosition ?? LatLng(35.7, -0.6),
              maxZoom: 18.0,
              initialZoom: 13.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c'],
              ),
              if (_currentPosition != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      width: 40.0,
                      height: 40.0,
                      point: _currentPosition!,
                      child: const Icon(
                        Icons.my_location,
                        color: Colors.blue,
                        size: 30,
                      ),
                    ),
                  ],
                ),
              MarkerLayer(
                markers: _nearbyCarparks.map((carpark) {
                  return Marker(
                    width: 40.0,
                    height: 40.0,
                    point: LatLng(carpark.latitude, carpark.longitude),
                    child: GestureDetector(
                      onTap: () {
                        _selectCarpark(carpark);
                      },
                      child: Icon(
                        Icons.local_parking,
                        color: _selectedCarpark == carpark
                            ? Colors.green
                            : Colors.red,
                        size: 30,
                      ),
                    ),
                  );
                }).toList(),
              ),
              if (_routePoints != null)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _routePoints!,
                      strokeWidth: 4.0,
                      color: Colors.blue,
                    ),
                  ],
                ),
            ],
          ),
          DraggableScrollableSheet(
            initialChildSize: 0.3,
            minChildSize: 0.1,
            maxChildSize: 0.7,
            builder: (BuildContext context, ScrollController scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey[900] : Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 8, bottom: 16),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isDarkMode ? Colors.grey[700] : Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Parkings à proximité (${_nearbyCarparks.length})',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.white : Colors.black,
                            ),
                          ),
                          if (_isLoading)
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: _nearbyCarparks.isEmpty
                          ? Center(
                              child: Text(
                                'Aucun parking trouvé à proximité',
                                style: TextStyle(
                                  color: isDarkMode ? Colors.white : Colors.black,
                                ),
                              ),
                            )
                          : ListView.builder(
                              controller: scrollController,
                              itemCount: _nearbyCarparks.length,
                              itemBuilder: (context, index) {
                                final carpark = _nearbyCarparks[index];
                                return CarparkInfoCard(
                                  carpark: carpark,
                                  isSelected: _selectedCarpark == carpark,
                                  isDarkMode: isDarkMode,
                                  onTap: () {
                                    _selectCarpark(carpark);
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_currentPosition != null) {
            _mapController.move(_currentPosition!, 15.0);
          }
        },
        child: const Icon(Icons.gps_fixed),
      ),
    );
  }
}
