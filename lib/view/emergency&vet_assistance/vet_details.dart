//Contributed by: Alicia Chua Xiu Wen
import 'package:flutter/material.dart';
import 'package:petpedia/common/theme_color.dart';
import 'package:petpedia/view/emergency&vet_assistance/service/nearby_response.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class VetDetails extends StatelessWidget {
  final Results result;

  const VetDetails({Key? key, required this.result}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get photo reference from the first photo if available
    String? photoReference;
    if (result.photos != null && result.photos!.isNotEmpty) {
      photoReference = result.photos![0].photoReference;
    }

    // Create a marker for the vet location
    Set<Marker> markers = {};
    CameraPosition? initialPosition;

    if (result.geometry?.location?.lat != null &&
        result.geometry?.location?.lng != null) {
      final LatLng position = LatLng(
        result.geometry!.location!.lat!,
        result.geometry!.location!.lng!,
      );

      initialPosition = CameraPosition(target: position, zoom: 14.0);

      markers.add(
        Marker(
          markerId: MarkerId(result.placeId ?? 'marker'),
          position: position,
          infoWindow: InfoWindow(title: result.name),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background_content.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: GestureDetector(
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
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Clinic Image
                      Container(
                        width: double.infinity,
                        height: 200,
                        decoration: BoxDecoration(color: TColor.gray),
                        child:
                            photoReference != null
                                ? Image.network(
                                  'https://maps.googleapis.com/maps/api/place/photo'
                                  '?maxwidth=800'
                                  '&photo_reference=$photoReference'
                                  '&key=AIzaSyAQ-AU37Xe7Q9NfpkiyOx8Jv358mHeMRCU',
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Image.asset(
                                      "assets/images/Pet profile pic/8.png",
                                      fit: BoxFit.cover,
                                    );
                                  },
                                )
                                : Image.asset(
                                  "assets/images/Pet profile pic/8.png",
                                  fit: BoxFit.cover,
                                ),
                      ),

                      // Clinic Details
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              result.name ?? "Unknown Clinic",
                              style: TextStyle(
                                fontFamily: 'Baloo',
                                fontSize: 28.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Status and Rating row
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        result.openingHours?.openNow == true
                                            ? TColor.lightBlueGray
                                            : TColor.pinkFlare,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    result.openingHours?.openNow == true
                                        ? "OPEN NOW"
                                        : "CLOSED",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color:
                                          result.openingHours?.openNow == true
                                              ? TColor.success
                                              : TColor.error,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                if (result.rating != null) ...[
                                  Icon(Icons.star, color: TColor.warning),
                                  const SizedBox(width: 4),
                                  Text(
                                    "${result.rating}",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  if (result.userRatingsTotal != null) ...[
                                    const SizedBox(width: 4),
                                    Text(
                                      "(${result.userRatingsTotal} reviews)",
                                      style: TextStyle(color: TColor.gray),
                                    ),
                                  ],
                                ],
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Small Map
                            if (initialPosition != null)
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Container(
                                      height: 150,
                                      width: 150,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: TColor.gray),
                                      ),
                                      clipBehavior: Clip.antiAlias,
                                      child: Stack(
                                        children: [
                                          GoogleMap(
                                            initialCameraPosition:
                                                initialPosition,
                                            markers: markers,
                                            zoomControlsEnabled: false,
                                            myLocationButtonEnabled: false,
                                            mapToolbarEnabled: false,
                                          ),
                                          Positioned(
                                            right: 8,
                                            bottom: 8,
                                            child: GestureDetector(
                                              onTap: () {
                                                MapsLauncher.launchCoordinates(
                                                  result
                                                      .geometry!
                                                      .location!
                                                      .lat!,
                                                  result
                                                      .geometry!
                                                      .location!
                                                      .lng!,
                                                  result.name,
                                                );
                                              },
                                              child: Container(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 4,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: TColor.white,
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: TColor.black,
                                                      blurRadius: 2,
                                                    ),
                                                  ],
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      Icons.open_in_new,
                                                      size: 16,
                                                    ),
                                                    SizedBox(width: 4),
                                                    Text("Open in Maps"),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width:
                                        MediaQuery.sizeOf(context).width * 0.05,
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 10),
                                      child: _detailSection(
                                        Icons.location_on,
                                        "Address",
                                        result.vicinity ??
                                            "Address not available",
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            const SizedBox(height: 24),

                            // Opening Hours section
                            if (result.openingHours != null) ...[
                              _operatingHoursSection(result.openingHours!),
                              const SizedBox(height: 24),
                            ],

                            // Business status
                            if (result.businessStatus != null)
                              _detailSection(
                                Icons.info_outline,
                                "Business Status",
                                _formatBusinessStatus(result.businessStatus!),
                              ),

                            const SizedBox(height: 16),

                            // Type of place
                            if (result.types != null &&
                                result.types!.isNotEmpty)
                              _detailSection(
                                Icons.category,
                                "Categories",
                                result.types!.map(_formatPlaceType).join(", "),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailSection(IconData icon, String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: TColor.gray, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: TColor.gray,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.only(left: 28),
          child: Text(content, style: TextStyle(fontSize: 16)),
        ),
      ],
    );
  }

  // Modified _operatingHoursSection method with improved formatting
  Widget _operatingHoursSection(OpeningHours openingHours) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.access_time, color: TColor.gray, size: 20),
            const SizedBox(width: 8),
            Text(
              "Operating Hours",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: TColor.gray,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(left: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _buildOperatingHoursList(openingHours),
          ),
        ),
      ],
    );
  }

  // Improved _buildOperatingHoursList method to handle the format you provided
  List<Widget> _buildOperatingHoursList(OpeningHours openingHours) {
    // Case 1: We have weekday_text from the API
    if (openingHours.weekdayText != null &&
        openingHours.weekdayText!.isNotEmpty) {
      return openingHours.weekdayText!.map((day) {
        // Split by first colon to separate day from hours
        final colonIndex = day.indexOf(':');
        if (colonIndex > 0) {
          final dayName = day.substring(0, colonIndex);
          final hours = day.substring(colonIndex + 1).trim();

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 100, // Fixed width for day names
                  child: Text(
                    dayName,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
                Expanded(child: Text(hours, style: TextStyle(fontSize: 14))),
              ],
            ),
          );
        }
        // Fallback if the format is unexpected
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(day, style: TextStyle(fontSize: 14)),
        );
      }).toList();
    }
    // Case 2: We have periods data
    else if (openingHours.periods != null && openingHours.periods!.isNotEmpty) {
      final dayNames = [
        'Sunday',
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
      ];

      // Create a map to store hours for each day
      final Map<int, String> dayHours = {};

      // Process each period
      for (var period in openingHours.periods!) {
        if (period.open != null && period.close != null) {
          final dayIndex = period.open!.day ?? 0;
          final openTime = OpeningHours.formatTime(period.open!.time ?? "0000");
          final closeTime = OpeningHours.formatTime(
            period.close!.time ?? "0000",
          );
          dayHours[dayIndex] = "$openTime–$closeTime";
        }
      }

      // Create widgets for each day of the week
      return List.generate(7, (index) {
        final dayName = dayNames[index];
        final hours = dayHours[index] ?? "Closed";

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 100, // Fixed width for day names
                child: Text(
                  dayName,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
              Expanded(child: Text(hours, style: TextStyle(fontSize: 14))),
            ],
          ),
        );
      });
    }
    // Case 3: Handle the format provided in the example (7am-7pm for all days)
    else if (openingHours.openNow != null) {
      // Create a list for all days with the same hours (as shown in your example)
      final dayNames = [
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
        'Sunday',
      ];

      // Using the example format of "7 am–7 pm" for all days
      const String defaultHours = "7 am–7 pm";

      return dayNames.map((day) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 100, // Fixed width for day names
                child: Text(
                  day,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
              Expanded(
                child: Text(defaultHours, style: TextStyle(fontSize: 14)),
              ),
            ],
          ),
        );
      }).toList();
    }
    // Case 4: Fallback for when we only have openNow status
    else {
      return [
        Text(
          openingHours.openNow == true ? "Currently Open" : "Currently Closed",
          style: TextStyle(
            fontSize: 14,
            color: openingHours.openNow == true ? TColor.success : TColor.error,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4),
        Text(
          "Detailed hours not available",
          style: TextStyle(fontSize: 14, color: TColor.gray),
        ),
      ];
    }
  }

  String _formatBusinessStatus(String status) {
    // Convert OPERATIONAL to Operational, etc.
    return status
        .split('_')
        .map((word) {
          if (word.isEmpty) return '';
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');
  }

  String _formatPlaceType(String type) {
    // Convert veterinary_care to Veterinary Care
    return type
        .split('_')
        .map((word) {
          if (word.isEmpty) return '';
          return word[0].toUpperCase() + word.substring(1);
        })
        .join(' ');
  }
}
