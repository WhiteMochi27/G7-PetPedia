import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:petpedia/common/theme_color.dart';
import 'package:petpedia/view/emergency&vet_assistance/service/nearby_response.dart';
import 'package:petpedia/view/emergency&vet_assistance/vet_details.dart';

class VetHospitals extends StatefulWidget {
  const VetHospitals({super.key});

  @override
  State<VetHospitals> createState() => _VetHospitalsState();
}

class _VetHospitalsState extends State<VetHospitals> {
  String apiKey = "AIzaSyAQ-AU37Xe7Q9NfpkiyOx8Jv358mHeMRCU";
  String radius = "10000"; //by default 10km, if nearby then 5km
  bool isLoading = false;
  String selectedFilter = "All"; // Track selected filter button
  String searchQuery = ""; // Track search query

  double? latitude;
  double? longitude;

  NearbyPlacesResponse nearbyPlacesResponse = NearbyPlacesResponse();
  List<Results> filteredResults = []; // Store filtered results

  @override
  void initState() {
    super.initState();
    // Use a slight delay to ensure the widget is fully mounted
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _getCurrentLocationAndFindVets();
      }
    });
  }

  // Apply filters and search to the results
  void _applyFiltersAndSearch() {
    if (nearbyPlacesResponse.results == null) {
      filteredResults = [];
      return;
    }

    // Start with all results
    List<Results> results = List.from(nearbyPlacesResponse.results!);

    // Apply search filter if search query exists
    if (searchQuery.isNotEmpty) {
      results =
          results
              .where(
                (result) =>
                    result.name?.toLowerCase().contains(
                      searchQuery.toLowerCase(),
                    ) ??
                    false,
              )
              .toList();
    }

    // Apply sorting if "Rating" filter is selected
    if (selectedFilter == "Rating") {
      results.sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));
    }

    setState(() {
      filteredResults = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background_content.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, 36, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    'assets/images/icon_back.png',
                    width: 30.0,
                    height: 30.0,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(30.0, 20.0, 0.0, 0.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Find Clinic',
                      style: TextStyle(
                        fontFamily: 'Baloo',
                        fontSize: 32.0,
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    FloatingActionButton(
                      onPressed: _getCurrentLocationAndFindVets,
                      tooltip: "Refresh nearby vets",
                      child: const Icon(Icons.refresh),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: SizedBox(
                  width: double.infinity,
                  child: TextField(
                    autofocus: false,
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                        _applyFiltersAndSearch();
                      });
                    },
                    decoration: InputDecoration(
                      isDense: true,
                      labelStyle: TextStyle(
                        fontFamily: "Fredoka",
                        letterSpacing: 0.0,
                      ),
                      hintText: 'Search for a vet clinic',
                      hintStyle: TextStyle(
                        fontFamily: 'ComicNeue',
                        fontSize: 14.0,
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.w300,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: TColor.gray, width: 0.5),
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: TColor.gray, width: 0.5),
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      fillColor: TColor.white,
                      prefixIcon: Icon(Icons.search, size: 28),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(10, 15, 10, 15),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterButton("All"),
                      SizedBox(width: 15),
                      _buildFilterButton("Nearby"),
                      SizedBox(width: 15),
                      _buildFilterButton("Rating"),
                    ],
                  ),
                ),
              ),
              Expanded(
                child:
                    (isLoading)
                        ? const Center(child: CircularProgressIndicator())
                        : (filteredResults.isEmpty)
                        ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.location_off,
                                size: 60,
                                color: TColor.gray,
                              ),
                              const SizedBox(height: 20),
                              Text(
                                "No veterinary clinics found nearby",
                                style: TextStyle(
                                  fontFamily: 'ComicNeue',
                                  fontSize: 18.0,
                                  color: TColor.gray,
                                ),
                              ),
                            ],
                          ),
                        )
                        : RefreshIndicator(
                          onRefresh: _getCurrentLocationAndFindVets,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(10),
                            physics:
                                const AlwaysScrollableScrollPhysics(), // Important for RefreshIndicator
                            itemCount: filteredResults.length,
                            itemBuilder: (context, index) {
                              Results result = filteredResults[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 15),
                                child: vetListItem(result),
                              );
                            },
                          ),
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Build filter button with active state
  Widget _buildFilterButton(String text) {
    bool isActive = selectedFilter == text;

    return GestureDetector(
      onTap: () {
        if (selectedFilter != text) {
          setState(() {
            selectedFilter = text;

            // Change radius if "Nearby" is selected
            if (text == "Nearby") {
              radius = "5000";
            } else {
              radius = "10000";
            }

            // If filter changed to "Nearby" with different radius, reload data
            if (text == "Nearby") {
              _getCurrentLocationAndFindVets();
            } else {
              // Otherwise just apply filter to existing data
              _applyFiltersAndSearch();
            }
          });
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: isActive ? TColor.lightBlueGray : TColor.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Text(
            text,
            style: TextStyle(
              fontFamily: "ComicNeue",
              fontSize: 18,
              color: isActive ? TColor.white : TColor.black,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _getCurrentLocationAndFindVets() async {
    // Cancel if widget is no longer mounted
    if (!mounted) return;

    setState(() {
      isLoading = true;
    });

    try {
      Position position = await _determinePosition();

      // Cancel if widget is no longer mounted after async operation
      if (!mounted) return;

      // Update the latitude and longitude variables
      latitude = position.latitude;
      longitude = position.longitude;

      // Get nearby vets
      await getNearbyVets();
    } catch (e) {
      // Cancel if widget is no longer mounted
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
    } finally {
      // Cancel if widget is no longer mounted
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> getNearbyVets() async {
    if (latitude == null || longitude == null) {
      throw Exception("Location not available");
    }

    var url = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/nearbysearch/json'
      '?location=${latitude.toString()},${longitude.toString()}'
      '&radius=$radius'
      '&type=veterinary_care'
      '&keyword=veterinary+hospital+clinic+pet'
      '&key=$apiKey',
    );

    var response = await http.get(url);

    // Cancel if widget is no longer mounted after network request
    if (!mounted) return;

    nearbyPlacesResponse = NearbyPlacesResponse.fromJson(
      jsonDecode(response.body),
    );

    // Only call setState if the widget is still mounted
    if (mounted) {
      _applyFiltersAndSearch(); // Apply filters to the fetched results
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      return Future.error('Location services are disabled');
    }

    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        return Future.error("Location permission denied");
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied');
    }

    Position position = await Geolocator.getCurrentPosition();

    return position;
  }

  Widget vetListItem(Results result) {
    // Get photo reference from the first photo if available
    String? photoReference;
    if (result.photos != null && result.photos!.isNotEmpty) {
      photoReference = result.photos![0].photoReference;
    }

    return GestureDetector(
      onTap: () {
        // Navigate to vet details page when user clicks on the item
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => VetDetails(result: result)),
        );
      },
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: TColor.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            // Fixed width container for the image with proper clipping
            SizedBox(
              width: 124,
              height: 124,
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  topLeft: Radius.circular(20),
                ),
                child:
                    photoReference != null
                        ? Image.network(
                          'https://maps.googleapis.com/maps/api/place/photo'
                          '?maxwidth=400'
                          '&photo_reference=$photoReference'
                          '&key=$apiKey',
                          width: 124,
                          height: 124,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            // Fallback to default image on error
                            return Image.asset(
                              "assets/images/Pet profile pic/8.png",
                              width: 124,
                              height: 124,
                              fit: BoxFit.cover,
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              width: 124,
                              height: 124,
                              color: TColor.gray,
                              child: Center(
                                child: CircularProgressIndicator(
                                  value:
                                      loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress
                                                  .cumulativeBytesLoaded /
                                              loadingProgress
                                                  .expectedTotalBytes!
                                          : null,
                                ),
                              ),
                            );
                          },
                        )
                        : Image.asset(
                          "assets/images/Pet profile pic/8.png",
                          width: 124,
                          height: 124,
                          fit: BoxFit.cover,
                        ),
              ),
            ),
            // Text content with proper constraints
            Expanded(
              child: Padding(
                padding: EdgeInsetsDirectional.fromSTEB(10.0, 5.0, 10.0, 5.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name with text overflow handling
                    Text(
                      result.name ?? "Unknown",
                      style: TextStyle(
                        fontFamily: 'ComicNeue',
                        fontSize: 18.0,
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 5),
                    // Address with proper overflow handling
                    if (result.vicinity != null)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.location_on, size: 16, color: TColor.gray),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              result.vicinity!,
                              style: TextStyle(color: TColor.gray),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 8),
                    // Ratings and open/closed indicators
                    Row(
                      children: [
                        if (result.rating != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: TColor.butteryWhite,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.star,
                                  color: TColor.warning,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  result.rating.toString(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color:
                                result.openingHours?.openNow == true
                                    ? TColor.lightBlueGray
                                    : TColor.pinkFlare,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            result.openingHours?.openNow == true
                                ? "Open"
                                : "Closed",
                            style: TextStyle(
                              color:
                                  result.openingHours?.openNow == true
                                      ? TColor.success
                                      : TColor.error,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
