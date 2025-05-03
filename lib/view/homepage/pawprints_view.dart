import 'package:flutter/material.dart';
import 'package:petpedia/common/theme_color.dart';
import 'package:petpedia/common_widget/home_button.dart';
import 'package:petpedia/common_widget/page_title.dart';

class PawprintsView extends StatefulWidget {
  const PawprintsView({super.key});

  @override
  State<PawprintsView> createState() => _PawprintsViewState();
}

class _PawprintsViewState extends State<PawprintsView> {
  int _rating = 0;
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _suggestionController = TextEditingController();
  final TextEditingController _bugReportController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    _suggestionController.dispose();
    _bugReportController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background_content.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            // Header
            const PageTitle(
              icon: 'assets/images/icon_pawprints.png',
              title: 'PawPrints',
              subtitle: 'Feedback',
            ),

            Positioned.fill(
              top: 100,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),

                    const Text(
                      'App Performance',
                      style: TextStyle(
                        fontFamily: "Baloo",
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _rating = index + 1;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Image.asset(
                              index < _rating
                                  ? 'assets/images/feedback_star_filled.png'
                                  : 'assets/images/feedback_star_notfilled.png',
                              width: 40,
                              height: 40,
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 20),

                    // Comment Section
                    const Text(
                      'Comment',
                      style: TextStyle(
                        fontFamily: "Baloo",
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: TColor.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: TColor.gray.withOpacity(0.2),
                            spreadRadius: 1,
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Icon container with alignment
                          Container(
                            padding: const EdgeInsets.only(left: 12, top: 16),
                            child: Image.asset(
                              'assets/images/feedback_comment.png',
                              width: 24,
                              height: 24,
                            ),
                          ),
                          // TextField container
                          Expanded(
                            child: TextField(
                              controller: _commentController,
                              style: TextStyle(
                                fontFamily: "ComicNeue",
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: TColor.black,
                              ),
                              maxLines: 4,
                              decoration: const InputDecoration(
                                hintText: 'Comments',
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.all(16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Suggestion Section
                    const Text(
                      'Suggestion',
                      style: TextStyle(
                        fontFamily: "Baloo",
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: TColor.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: TColor.gray.withOpacity(0.2),
                            spreadRadius: 1,
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Icon container with alignment
                          Container(
                            padding: const EdgeInsets.only(left: 12, top: 16),
                            child: Image.asset(
                              'assets/images/feedback_suggestion.png',
                              width: 24,
                              height: 24,
                            ),
                          ),
                          // TextField container
                          Expanded(
                            child: TextField(
                              controller: _suggestionController,
                              style: TextStyle(
                                fontFamily: "ComicNeue",
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: TColor.black,
                              ),
                              maxLines: 4,
                              decoration: const InputDecoration(
                                hintText: 'Feature Suggestions',
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.all(16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Bug Report Section
                    const Text(
                      'Bug Report (Optional)',
                      style: TextStyle(
                        fontFamily: "Baloo",
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: TColor.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: TColor.gray.withOpacity(0.2),
                            spreadRadius: 1,
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Icon container with alignment
                          Container(
                            padding: const EdgeInsets.only(left: 12, top: 16),
                            child: Image.asset(
                              'assets/images/feedback_bug.png',
                              width: 24,
                              height: 24,
                            ),
                          ),
                          // TextField container
                          Expanded(
                            child: TextField(
                              controller: _bugReportController,
                              style: TextStyle(
                                fontFamily: "ComicNeue",
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: TColor.black,
                              ),
                              maxLines: 4,
                              decoration: const InputDecoration(
                                hintText: 'Bug Report',
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.all(16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Email Section
                    const Text(
                      'Email (Optional)',
                      style: TextStyle(
                        fontFamily: "Baloo",
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: TColor.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: TColor.gray.withOpacity(0.2),
                            spreadRadius: 1,
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Icon container with alignment
                          Container(
                            padding: const EdgeInsets.only(left: 12),
                            child: Image.asset(
                              'assets/images/icon_email.png',
                              width: 24,
                              height: 24,
                            ),
                          ),
                          // TextField container
                          Expanded(
                            child: TextField(
                              controller: _emailController,
                              style: TextStyle(
                                fontFamily: "ComicNeue",
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: TColor.black,
                              ),
                              decoration: const InputDecoration(
                                hintText:
                                    'Leave your email if you need our response',
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.all(16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Feedback submitted!',
                                style: TextStyle(fontFamily: "Fredoka One"),
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 12,
                          ),
                          backgroundColor: TColor.orangePeel,
                          foregroundColor: TColor.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text(
                          'Submit Feedback',
                          style: TextStyle(
                            fontFamily: "Fredoka One",
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 80),
                  ],
                ),
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
