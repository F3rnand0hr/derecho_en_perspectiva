import 'dart:async';
import 'package:derecho_en_perspectiva/models/articles.dart';
import 'package:flutter/material.dart';
import 'package:derecho_en_perspectiva/pages/widgets/appDrawer.dart';
import 'package:derecho_en_perspectiva/styles/colors.dart';
import 'package:derecho_en_perspectiva/pages/widgets/buildSectionItem.dart';
import 'package:derecho_en_perspectiva/data_source/device_info/device_height.dart';

class homePage extends StatefulWidget {
  const homePage({super.key});

  @override
  State<homePage> createState() => _homePageState();
}

class _homePageState extends State<homePage> {
  int _currentArticleIndex = 0;
  late Timer _timer;
  late PageController _pageController; // Use PageController to control the PageView

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentArticleIndex);

    // Set a timer to change the article every 3 seconds
    _timer = Timer.periodic(Duration(seconds: 3), (timer) {
      setState(() {
        // Change the article index every 3 seconds and loop through 5 articles
        _currentArticleIndex = (_currentArticleIndex + 1) % 5;
        _pageController.jumpToPage(_currentArticleIndex); // Manually jump to the next page
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
    return Scaffold(
      extendBodyBehindAppBar: true, // Allows the body to extend behind the AppBar
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0, // Remove shadow
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(Icons.account_circle, color: Colors.white),
            onPressed: () {
              // Navigate to the Sign Up page
            },
          ),
        ],
      ),
      drawer: appDrawer(context),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Section with image background, limited to a specific height for the latest volume
            Container(
              width: double.infinity,
              height: deviceHeight(context), // Adjust this height to control the size of the image section
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/law_backround.jpeg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Derecho En Perspectiva',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                    ),
                    SizedBox(height: 30),
                    Text(
                      'The latest issue of our magazine is now available. Explore our featured articles and in-depth analysis on important legal matters.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(height: 40),
                    // Call to Action: Go to the latest volume
                    ElevatedButton(
                      onPressed: () {
                        // Navigate to the latest volume page
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.caputMortuum,
                        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        'Contact Us',
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Additional page content (ListView, etc.) with a different background color
            Container(
              color: AppColors.tan, // Background color for the content below the image
              child: ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: 1, // Example count
                itemBuilder: (context, index) {
                  return Container(
                    height: 500,
                    margin: EdgeInsets.all(20),
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: AppColors.spaceCadet,
                    ),
                    child: ListTile(
                      title: Text(
                        '¡Volumen mas reciente!',
                        style: TextStyle(
                          fontSize: 36,
                          color: Colors.white,
                        ),
                      ),
                      subtitle: Text(
                        'Description for item $index',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      onTap: () {
                        // Item tap logic here
                      },
                    ),
                  );
                },
              ),
            ),

            
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Articulos Destacados',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 16),
                  // PageView to display highlighted articles
                  Container(
                    height: 300, // Set a height for the article cards
                    child: PageView.builder(
                      controller: _pageController, // Use the controller for PageView
                      itemCount: articles.length, // Number of articles to display
                      itemBuilder: (context, index) {
                        final article = articles[index];
                        return Container(
                          margin: EdgeInsets.only(right: 20),
                          width: 250,
                          decoration: BoxDecoration(
                            color: AppColors.slateGray,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              // Placeholder image for each article
                              Container(
                                height: 150,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage(article.imageUrl), // Placeholder image
                                    fit: BoxFit.cover,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Text(
                                  article.title,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                child: Text(
                                  article.description,
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
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
      ),
    );
  }
} 