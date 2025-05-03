import 'package:flutter/material.dart';
import 'package:petpedia/common/theme_color.dart';
import 'package:petpedia/common_widget/home_button.dart';
import 'package:petpedia/common_widget/page_title.dart';
import 'package:petpedia/database/database_handler.dart';
import 'package:petpedia/view/emergency&vet_assistance/firstaid_checklist.dart';
import 'package:petpedia/view/emergency&vet_assistance/vet_hospitals.dart';

class FurstaidView extends StatefulWidget {
  const FurstaidView({super.key});

  @override
  State<FurstaidView> createState() => _FurstaidViewState();
}

class _EmergencyItem extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback onTap;

  const _EmergencyItem({
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: TColor.white,
          borderRadius: BorderRadius.circular(5.0),
          border: Border.all(color: TColor.gray, width: 0.5),
        ),
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(10.0, 0.0, 10.0, 0.0),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontFamily: "Fredoka",
                      fontWeight: FontWeight.w300,
                      letterSpacing: 0.0,
                    ),
                  ),
                ),
              ),
              Icon(Icons.expand_more, color: TColor.black, size: 40.0),
            ],
          ),
        ),
      ),
    );
  }
}

class _FurstaidViewState extends State<FurstaidView> {
  final DatabaseHandler _databaseHandler = DatabaseHandler();
  List<Map<String, dynamic>> _emergencyTips = [];
  String _selectedCategory = 'All';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEmergencyTips();
  }

  Future<void> _loadEmergencyTips() async {
    try {
      final tips = await _databaseHandler.getAllEmergencyTips();
      setState(() {
        _emergencyTips = tips;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error loading emergency tips: $e');
    }
  }

  List<Map<String, dynamic>> get _filteredTips {
    if (_selectedCategory == 'All') {
      return _emergencyTips;
    } else {
      return _emergencyTips
          .where((tip) => tip['emergency_cat'] == _selectedCategory)
          .toList();
    }
  }

  void _showEmergencyDetails(Map<String, dynamic> tip) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: MediaQuery.of(context).size.height * 0.7,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      tip['emergency_title'],
                      style: const TextStyle(
                        fontFamily: "Fredoka",
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: TColor.gray,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "Category: ${tip['emergency_cat']}",
                  style: TextStyle(
                    fontFamily: "Fredoka",
                    fontWeight: FontWeight.w500,
                    color: TColor.black,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    tip['emergency_desc'],
                    style: const TextStyle(
                      fontFamily: "Fredoka",
                      fontWeight: FontWeight.w300,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get unique categories from emergency tips
    final List<String> categories = ['All'];
    if (_emergencyTips.isNotEmpty) {
      final emergencyCategories =
          _emergencyTips
              .map((tip) => tip['emergency_cat'] as String)
              .toSet()
              .toList();
      categories.addAll(emergencyCategories);
    }

    // Calculate bottom padding to account for home button
    final bottomPadding = MediaQuery.of(context).padding.bottom + 70;

    return Scaffold(
      extendBody: true,
      appBar: null,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background_content.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            // Header
            PageTitle(
              icon: 'assets/images/icon_furstaid.png',
              title: 'Furstaid',
              subtitle: 'Emergency & Vet Assistance',
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 50, 20, 0),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(
                        Icons.perm_contact_cal_rounded,
                        color: TColor.error,
                        size: 40,
                      ),
                    ],
                  ),
                  Expanded(
                    child: Stack(
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            SizedBox(width: double.infinity, height: 25),
                            Expanded(
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: TColor.white,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(30),
                                    topRight: Radius.circular(30),
                                  ),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    top: 20,
                                    left: 20,
                                    right: 20,
                                    bottom: bottomPadding,
                                  ),
                                  child: SingleChildScrollView(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.all(20),
                                          child: Wrap(
                                            spacing: 15,
                                            children: [
                                              GestureDetector(
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder:
                                                          (context) =>
                                                              VetHospitals(),
                                                    ),
                                                  );
                                                },
                                                child: Container(
                                                  width:
                                                      MediaQuery.sizeOf(
                                                        context,
                                                      ).width *
                                                      0.30,
                                                  height: 75,
                                                  decoration: BoxDecoration(
                                                    image: DecorationImage(
                                                      image:
                                                          Image.asset(
                                                            "assets/images/emergency_hospitals_button.png",
                                                          ).image,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          20,
                                                        ),
                                                  ),
                                                ),
                                              ),
                                              GestureDetector(
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder:
                                                          (context) =>
                                                              FirstaidChecklist(),
                                                    ),
                                                  );
                                                },
                                                child: Container(
                                                  width:
                                                      MediaQuery.sizeOf(
                                                        context,
                                                      ).width *
                                                      0.30,
                                                  height: 75,
                                                  decoration: BoxDecoration(
                                                    image: DecorationImage(
                                                      image:
                                                          Image.asset(
                                                            "assets/images/emergency_first-aid_checklist_button.png",
                                                          ).image,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          20,
                                                        ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 15,
                                          ),
                                          child: SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: Wrap(
                                              spacing: 10,
                                              children:
                                                  categories.map((category) {
                                                    return GestureDetector(
                                                      onTap: () {
                                                        setState(() {
                                                          _selectedCategory =
                                                              category;
                                                        });
                                                      },
                                                      child: Container(
                                                        padding:
                                                            EdgeInsets.symmetric(
                                                              horizontal: 12,
                                                              vertical: 5,
                                                            ),
                                                        decoration: BoxDecoration(
                                                          color:
                                                              _selectedCategory ==
                                                                      category
                                                                  ? TColor
                                                                      .orangePeel
                                                                      .withOpacity(
                                                                        0.2,
                                                                      )
                                                                  : TColor
                                                                      .white,
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                10.0,
                                                              ),
                                                          border: Border.all(
                                                            color:
                                                                _selectedCategory ==
                                                                        category
                                                                    ? TColor
                                                                        .orangePeel
                                                                    : TColor
                                                                        .gray,
                                                            width: 0.5,
                                                          ),
                                                        ),
                                                        alignment:
                                                            AlignmentDirectional(
                                                              0.0,
                                                              0.0,
                                                            ),
                                                        child: Text(
                                                          category,
                                                          style: TextStyle(
                                                            fontFamily:
                                                                'ComicNeue',
                                                            letterSpacing: 0.0,
                                                            fontWeight:
                                                                _selectedCategory ==
                                                                        category
                                                                    ? FontWeight
                                                                        .bold
                                                                    : FontWeight
                                                                        .normal,
                                                            color:
                                                                _selectedCategory ==
                                                                        category
                                                                    ? TColor
                                                                        .orangePeel
                                                                    : TColor
                                                                        .black,
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  }).toList(),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(top: 30),
                                          child:
                                              _isLoading
                                                  ? const Center(
                                                    child:
                                                        CircularProgressIndicator(),
                                                  )
                                                  : _filteredTips.isEmpty
                                                  ? const Center(
                                                    child: Text(
                                                      'No emergency tips found for this category',
                                                      style: TextStyle(
                                                        fontFamily: "Fredoka",
                                                        fontWeight:
                                                            FontWeight.w300,
                                                      ),
                                                    ),
                                                  )
                                                  : Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children:
                                                        _filteredTips.map((
                                                          tip,
                                                        ) {
                                                          return Padding(
                                                            padding:
                                                                const EdgeInsets.only(
                                                                  bottom: 10,
                                                                ),
                                                            child: _EmergencyItem(
                                                              title:
                                                                  tip['emergency_title'],
                                                              description:
                                                                  tip['emergency_desc'],
                                                              onTap:
                                                                  () =>
                                                                      _showEmergencyDetails(
                                                                        tip,
                                                                      ),
                                                            ),
                                                          );
                                                        }).toList(),
                                                  ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Home button at bottom
            const Positioned(bottom: 0, left: 0, right: 0, child: HomeButton()),
          ],
        ),
      ),
    );
  }
}
