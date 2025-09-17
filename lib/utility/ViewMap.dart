
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';




class SimpleMapPage extends StatefulWidget {
  final double latitude;
  final double longitude;
  final Function(double)? onDistanceCalculated; // 👈 callback


  const SimpleMapPage({super.key, required this.latitude,   required this.longitude,  this.onDistanceCalculated,});


  @override
  State<SimpleMapPage> createState() => _SimpleMapPageState();
}

class _SimpleMapPageState extends State<SimpleMapPage> {
  @override
  void initState() {
    super.initState();
    fetchAndHighlightPolygon(32, 565,5690,628485);
/*    fetchVillagePolygons();*/
  }
  String? token;
  var polygons = <Polygon>[];
  final mapController = MapController();
  LatLng mapCenter = const LatLng(20, 78); // default India center
  bool isLoading = true;

  Future<String?> getToken() async {
    final Uri url = Uri.parse(
        "https://mapservice.gov.in/gismapservice/tokens/generateToken");

    print("🔹 Requesting token from: $url");

    final response = await http.post(
      url,
      body: {
        "username": "mobile_usr",
        "password": "mobile_usr#43%",
        "client": "requestip",
        "f": "json",
      },
    );

    print("📡 Token request status: ${response.statusCode}");
    print("📡 Raw response: ${response.body}");

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);

      if (json["token"] != null) {
        print("✅ Token received: ${json["token"]}");
        print("⏰ Token expiry: ${json["expires"]}");
        return json["token"];
      } else {
        print("❌ Failed to get token, response: $json");
      }
    } else {
      print("❌ Error fetching token: ${response.statusCode} ${response.reasonPhrase}");
    }
    return null;
  }

  // make sure these exist in your state
  Set<Polygon> loadedPolygons = {};
  Set<Polyline> loadedPolylines = {};

/*  Future<void> fetchAndHighlightPolygon(String state, String district) async {
    print("📍 Fetching polygon for State: $state | District: $district");

    final token = await getToken();
    if (token == null) {
      print("❌ Token is null, cannot fetch data.");
      return;
    }
    print("✅ Token received: $token");

    final url =
        "https://mapservice.gov.in/gismapservice/rest/services/Transport/adminVillage/MapServer/1/query?"
        "f=json&where=1=1&outFields=*&returnGeometry=true&outSR=4326&token=$token";

    print("🌐 Sending request: $url");

    final response = await http.get(Uri.parse(url));
    print("📡 Response status: ${response.statusCode}");

    if (response.statusCode != 200) {
      print("❌ Failed to fetch data. Status: ${response.statusCode}");
      return;
    }

    final data = jsonDecode(response.body);
    print("📦 Response parsed successfully");

    if (data["features"] == null) {
      print("⚠️ No features found in response.");
      return;
    }

    List<Polygon> loadedPolygons = [];
    print("📊 Total features: ${data["features"].length}");

    for (var feature in data["features"]) {
      final attrs = feature["attributes"];
      final rings = feature["geometry"]["rings"];

      final stname = attrs["stname"]?.toString() ?? "";
      final dtname = attrs["dtname"]?.toString() ?? "";

      print("🔍 Checking feature -> State: $stname | District: $dtname");

      if (stname.toLowerCase() == state.toLowerCase() &&
          dtname.toLowerCase() == district.toLowerCase()) {
        print("✅ Match found for $state - $district with ${rings.length} rings");

        for (var ring in rings) {
          List<LatLng> points =
          ring.map<LatLng>((coord) => LatLng(coord[1], coord[0])).toList();

          print("🌀 Ring loaded with ${points.length} points");

          loadedPolygons.add(
            Polygon(
              points: points,
              color: Colors.red.withOpacity(0.4),
              borderColor: Colors.red,
              borderStrokeWidth: 3,
            ),
          );
        }
      }
    }

    if (loadedPolygons.isEmpty) {
      print("⚠️ No polygons matched for $state - $district");
    } else {
      print("✅ ${loadedPolygons.length} polygons loaded for $state - $district");
    }

    setState(() {
      polygons = loadedPolygons;
    });
    print("🎯 State updated with ${polygons.length} polygons.");
  }*/
  LatLngBounds getBoundsFromRings(List rings) {
    double? minLat, maxLat, minLng, maxLng;

    for (var ring in rings) {
      for (var coord in ring) {
        double lng = coord[0];
        double lat = coord[1];

        minLat = (minLat == null) ? lat : (lat < minLat ? lat : minLat);
        maxLat = (maxLat == null) ? lat : (lat > maxLat ? lat : maxLat);
        minLng = (minLng == null) ? lng : (lng < minLng ? lng : minLng);
        maxLng = (maxLng == null) ? lng : (lng > maxLng ? lng : maxLng);
      }
    }

    return LatLngBounds(
      LatLng(minLat!, minLng!), // southwest
      LatLng(maxLat!, maxLng!), // northeast
    );
  }

  Future<void> fetchAndHighlightPolygon(
      int state, int district, int subdistrict, int village) async {
    print("🔹 Starting fetchAndHighlightPolygon "
        "for state=$state, district=$district, subdistrict=$subdistrict, village=$village");

    final token = await getToken();
    if (token == null) {
      print("❌ No token available, aborting fetch.");
      return;
    }

    final url =
        "https://mapservice.gov.in/gismapservice/rest/services/Transport/adminVillage/MapServer/3/query?"
        "f=json&where=1=1&outFields=*&returnGeometry=true&outSR=4326&token=$token";

    print("🌐 Requesting polygons from: $url");

    final response = await http.get(Uri.parse(url));
    print("📡 HTTP status: ${response.statusCode}");

    if (response.statusCode != 200) {
      print("❌ Error: ${response.reasonPhrase}");
      print("📡 Response body: ${response.body}");
      return;
    }

    final data = jsonDecode(response.body);
    if (data["features"] == null) {
      print("⚠️ No 'features' found in response: $data");
      return;
    }

    print("📊 Total features: ${data["features"].length}");

    List<Polygon> loadedPolygons = [];
    int matchedCount = 0;

    for (var i = 0; i < data["features"].length; i++) {
      var feature = data["features"][i];
      final attrs = feature["attributes"];
      final rings = feature["geometry"]["rings"];

      // ✅ Normalize attribute keys once
      final normalizedAttrs = {
        for (var entry in attrs.entries) entry.key.toLowerCase(): entry.value
      };

      final stateAttr = normalizedAttrs["state_lgd"];
      final districtAttr = normalizedAttrs["dist_lgd"];
      final subdistrictAttr = normalizedAttrs["subdt_lgd"];
      final villageAttr = normalizedAttrs["vil_lgd"];

      print("all d-> $stateAttr,$districtAttr,$subdistrictAttr,$villageAttr");

      print("➡️ Processing feature #$i with attrs: $normalizedAttrs");

      // ✅ Match condition (like your style)
      if (stateAttr?.toString() == state.toString() && districtAttr?.toString() == district.toString()) {
        // If subdistrict is provided, check it
        if (stateAttr?.toString() == state.toString() &&
            districtAttr?.toString() == district.toString()) {
          // 🔹 Subdistrict check only if present in API response
          if (subdistrict != 0) {
            if (subdistrictAttr == null) {
              print("⚠️ API has no subdistrict field, skipping subdistrict filter.");
            } else if (subdistrictAttr.toString() != subdistrict.toString()) {
              print("❌ Subdistrict mismatch");
              continue;
            }
          }

          // 🔹 Village check only if present in API response
          if (village != 0) {
            if (villageAttr == null) {
              print("⚠️ API has no village field, skipping village filter.");
            } else if (villageAttr.toString() != village.toString()) {
              print("❌ Village mismatch");
              continue;
            }
          }

          matchedCount++;
          print("🎯 Match found → "
              "State=$stateAttr, Dist=$districtAttr, "
              "SubDist=$subdistrictAttr, Village=$villageAttr");

          // 🎨 Color logic
          bool isVillageMatch =
          (village != 0 && villageAttr?.toString() == village.toString());

          for (var r = 0; r < rings.length; r++) {
            final ring = rings[r];
            final points = ring.map<LatLng>((coord) => LatLng(coord[1], coord[0])).toList();





// ✅ User point
            LatLng userPoint = LatLng(widget.latitude, widget.longitude);
            LatLng randomPoint = LatLng(widget.latitude, widget.longitude);
            double minDistMeters = distanceToPolygonMeters(randomPoint, points);
            widget.onDistanceCalculated?.call(minDistMeters);
            print("📏 Nearest distance from random point to this boundary: ${minDistMeters.toStringAsFixed(2)} meters");


// ✅ Compute polygon center (roughly, average of all points in the ring)
            LatLng polyCenter = LatLng(
              points.map((p) => p.latitude).reduce((a, b) => a + b) / points.length,
              points.map((p) => p.longitude).reduce((a, b) => a + b) / points.length,
            );
// ✅ Draw red line
            loadedPolylines.add(
              Polyline(
                points: [userPoint, polyCenter],
                color: Colors.red,
                strokeWidth: 3,
              ),
            );


            // Polygon fill (transparent if you only want borders)
            loadedPolygons.add(
              Polygon(
                points: points,
                color: isVillageMatch
                    ? Colors.redAccent.withOpacity(0.15)
                    : Colors.blueAccent.withOpacity(0.05),
                borderColor: isVillageMatch ? Colors.redAccent : Colors.blueAccent,
                borderStrokeWidth: isVillageMatch ? 2.5 : 1.5,
                pattern: StrokePattern.dotted(), // optional dotted border if polygon supports it
              ),
            );

            // Polyline for neat dotted outline
            loadedPolylines.add(
              Polyline(
                points: points,
                strokeWidth: isVillageMatch ? 2.0 : 1.2,
                color: isVillageMatch ? Colors.redAccent : Colors.deepOrange,
                // smaller dash, smaller gap = neat dots
                pattern: StrokePattern.dashed(segments: const [2, 6]),
              ),
            );
          }



          // ✅ Zoom to bounds
          final bounds = getBoundsFromRings(rings);

          setState(() {
            polygons = loadedPolygons;
            mapCenter = bounds.center;
            isLoading = false;
          });
        }
      } else {
        print("❌ No match → ""State=$stateAttr, Dist=$districtAttr, SubDist=$subdistrictAttr, Village=$villageAttr");
      }
    }

    print("✅ Finished parsing. Found $matchedCount matching polygons.");

    setState(() {
      polygons = loadedPolygons;
    });

    print("🎉 State updated with $matchedCount highlighted polygons.");
  }



  double _deg2rad(double deg) => deg * (pi / 180);

  /// Haversine distance in METERS between two LatLng points.
  double haversineDistanceMeters(LatLng p1, LatLng p2) {
    const double R = 6371000.0; // Earth radius in meters
    final double dLat = _deg2rad(p2.latitude - p1.latitude);
    final double dLon = _deg2rad(p2.longitude - p1.longitude);

    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_deg2rad(p1.latitude)) *
            cos(_deg2rad(p2.latitude)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c; // meters
  }

  /// Distance from point p to segment [a,b] in meters (projects onto segment).
  double _pointToSegmentDistance(LatLng p, LatLng a, LatLng b) {
    // Work in radians for projection math
    final double pLat = _deg2rad(p.latitude);
    final double pLon = _deg2rad(p.longitude);
    final double aLat = _deg2rad(a.latitude);
    final double aLon = _deg2rad(a.longitude);
    final double bLat = _deg2rad(b.latitude);
    final double bLon = _deg2rad(b.longitude);

    final double dx = bLon - aLon;
    final double dy = bLat - aLat;

    // If a and b are the same point, return distance to a
    final double denom = dx * dx + dy * dy;
    if (denom == 0) {
      return haversineDistanceMeters(p, a);
    }

    // projection factor t
    final double t = ((pLon - aLon) * dx + (pLat - aLat) * dy) / denom;

    if (t <= 0.0) return haversineDistanceMeters(p, a);
    if (t >= 1.0) return haversineDistanceMeters(p, b);

    // projection point in radians
    final double projLat = aLat + t * dy;
    final double projLon = aLon + t * dx;

    final LatLng proj = LatLng(projLat * 180 / pi, projLon * 180 / pi);
    return haversineDistanceMeters(p, proj);
  }

  /// Minimum distance from a point to polygon boundary in METERS.
  double distanceToPolygonMeters(LatLng point, List<LatLng> polygon) {
    double minDistance = double.infinity;

    for (int i = 0; i < polygon.length; i++) {
      final LatLng p1 = polygon[i];
      final LatLng p2 = polygon[(i + 1) % polygon.length];
      final double dist = _pointToSegmentDistance(point, p1, p2);
      if (dist < minDistance) minDistance = dist;
    }

    return minDistance; // meters
  }
  List<LatLng> generateBufferPolygon(LatLng center, double radiusMeters) {
    const int segments = 64; // smoothness
    const double earthRadius = 6371000; // meters
    final List<LatLng> points = [];

    final lat = center.latitude * pi / 180.0;
    final lon = center.longitude * pi / 180.0;

    for (int i = 0; i < segments; i++) {
      final angle = (2 * pi / segments) * i;
      final dx = radiusMeters * cos(angle) / earthRadius;
      final dy = radiusMeters * sin(angle) / earthRadius;

      final newLat = lat + dy;
      final newLon = lon + dx / cos(lat);

      points.add(LatLng(newLat * 180 / pi, newLon * 180 / pi));
    }

    return points;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(), // Loader
      )
          :FlutterMap(
        mapController: mapController,
        options: MapOptions(
          initialCenter: mapCenter,
          initialZoom: 12,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://a.tile.openstreetmap.fr/osmfr/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.simplemap',
          ),

          // 🔹 API polygons
          PolygonLayer(polygons: polygons),

          // 🔹 Buffer circle around user (5 km)
          PolygonLayer(
            polygons: [
              Polygon(
                points: generateBufferPolygon(
                  LatLng(widget.latitude, widget.longitude),
                  5000, // radius in meters
                ),
                color: Colors.blueAccent.withOpacity(0.2),
                borderColor: Colors.blueAccent,
                borderStrokeWidth: 2,
              ),
            ],
          ),

          // 🔹 Red line from user → village center
          PolylineLayer(
            polylines: [
              Polyline(
                points: [
                  LatLng(widget.latitude, widget.longitude), // user location
                  mapCenter, // village center (your polygons' center)
                ],
                strokeWidth: 2,
                color: Colors.red,
              ),
            ],
          ),

          // 🔹 Optional markers for clarity
          MarkerLayer(
            markers: [
              Marker(
                point: LatLng(widget.latitude, widget.longitude),
                width: 40,
                height: 40,
                child: const Icon(Icons.location_on, color: Colors.red, size: 20),
              ),
              Marker(
                point: mapCenter,
                width: 40,
                height: 40,
                child: const Icon(Icons.location_on_outlined, color: Colors.red, size: 20),
              ),
            ],
          ),
        ],
      )

    );
  }
}
