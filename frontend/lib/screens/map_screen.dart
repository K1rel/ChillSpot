import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            options: const MapOptions(
              initialCenter: LatLng(41.9981, 21.4254),
              initialZoom: 13.0,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                subdomains: ['a', 'b', 'c'],
              ),
            ],
          ),
          Positioned(
            top: 40,
            left: 20,
            right: 20,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDDA15E),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.search, color: Colors.black),
                        SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: "Search...",
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 50,
                  height: 50,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFDDA15E),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.add),
                    color: Colors.black,
                    onPressed: () {},
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            child: Container(
              width: 60,
              height: 60,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFDDA15E),
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back),
                color: Colors.black,
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
