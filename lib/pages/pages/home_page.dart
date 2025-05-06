import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:derecho_en_perspectiva/pages/widgets/appBar.dart';
import 'package:flutter/material.dart';
import 'package:derecho_en_perspectiva/pages/widgets/appDrawer.dart';
import 'package:derecho_en_perspectiva/styles/colors.dart';
import 'package:derecho_en_perspectiva/pages/widgets/buildSectionItem.dart';
import 'package:derecho_en_perspectiva/data/data_source/device_info/device_height.dart';
import 'package:derecho_en_perspectiva/cubits/authCubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';

class homePage extends StatefulWidget {
  const homePage({super.key});

  @override
  State<homePage> createState() => _homePageState();
}

class _homePageState extends State<homePage> {
  int _currentArticleIndex = 0;
  late Timer _timer;
  late PageController
      _pageController; // Use PageController to control the PageView

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentArticleIndex);

    // Set a timer to change the article every 3 seconds
    _timer = Timer.periodic(Duration(seconds: 3), (timer) {
      setState(() {
        // Change the article index every 3 seconds and loop through 5 articles
        _currentArticleIndex = (_currentArticleIndex + 1) % 5;
        _pageController
            .jumpToPage(_currentArticleIndex); // Manually jump to the next page
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel(); // Cancel the timer when the widget is disposed
    _pageController.dispose(); // Dispose the PageController
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthCubit>().state;
    return Scaffold(
      backgroundColor: AppColors.darkBlack,
      extendBodyBehindAppBar:
          true, // Allows the body to extend behind the AppBar
      appBar: appBar(context),
      drawer: appDrawer(context),
      body: StreamBuilder<QuerySnapshot>(
          stream:
              FirebaseFirestore.instance.collection("articulos").snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final articles = snapshot.data!.docs;

            if (articles.isEmpty) {
              return const Center(
                child: Text('No articles found.'),
              );
            }
            return SingleChildScrollView(
                child: Column(
                  children: [
                    // Section with image background
                    top(context),
                  
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 20, horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Articulos Destacados',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 10.h),
                          // PageView to display highlighted articles
                          SizedBox(
                            height: 300, // Set a height for the article cards
                            width: deviceWidth(context) * 0.80,
                            child: PageView.builder(
                              controller:
                                  _pageController, // Use the controller for PageView
                              itemCount: articles
                                  .length, // Number of articles to display
                              itemBuilder: (context, index) {
                                final doc = articles[index];
                                final data = doc.data() as Map<String, dynamic>;
                                final title = data['title'] ?? 'Untitled';
                                final description = data['description'] ?? '';
                                final imageURL = data['imageURL'] ?? '';
                                return InkWell(
                                  onTap: () {
                                    context.push('/article/${doc.id}');
                                  },
                                  child: Container(
                                    margin: EdgeInsets.only(right: 20),
                                    decoration: BoxDecoration(
                                      color: AppColors.spaceCadet,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Column(
                                      children: [
                                        // Placeholder image for each article
                                        Container(
                                          height: 150,
                                          decoration: BoxDecoration(
                                            image: DecorationImage(
                                              image: AssetImage(
                                                  imageURL), // Placeholder image
                                              fit: BoxFit.cover,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(16),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(12.0),
                                          child: Text(
                                            title,
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12.0),
                                          child: ConstrainedBox(
                                            constraints: BoxConstraints(
                                              maxWidth:
                                                  200, // Set a maximum width for the description
                                            ),
                                            child: Text(
                                              description,
                                              style: TextStyle(
                                                color: Colors.white70,
                                                fontSize: 14,
                                              ),
                                              overflow: TextOverflow
                                                  .ellipsis, // Optional: Adds "..." when text overflows
                                              maxLines:
                                                  2, // Optional: Limits text to 2 lines (if you prefer)
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
          }),
    );
  }
}

Widget top(BuildContext context) {
  final h = deviceHeight(context);
  return SizedBox(
    width: double.infinity,
    height: h,
    child: Stack(
      children: [
        Image.asset(
          'assets/photos/law_backround.jpeg',
          fit: BoxFit.cover,
          width: double.infinity,
          height: h,
        ),
        // gradient fade
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  AppColors.darkBlack,
                ],
                stops: [0.90, 1.0],
              ),
            ),
          ),
        ),
        Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Bienvenid@s!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white70,
                letterSpacing: 1.5,
                fontFamily: 'Times New Roman',
              ),
            ),
            Text(
              'Derecho En Perspectiva',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Georgia',
                fontSize: 52,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
    ),
      ],
    ),
  );
}



