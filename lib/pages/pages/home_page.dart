import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:derecho_en_perspectiva/pages/widgets/appDrawer.dart';
import 'package:derecho_en_perspectiva/styles/colors.dart';
import 'package:derecho_en_perspectiva/pages/widgets/buildSectionItem.dart';
import 'package:derecho_en_perspectiva/data_source/device_info/device_height.dart';
import 'package:derecho_en_perspectiva/cubits/authCubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

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
    final user = context.watch<AuthCubit>().state;
    return Scaffold(
      extendBodyBehindAppBar: true, // Allows the body to extend behind the AppBar
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0, // Remove shadow
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(Icons.account_circle),
            onPressed: () {
              if (user != null){
                context.push('/userPage');
              }
              else{
                context.push('/sign-up');
              }
            },
          ),
        ],
      ),
      drawer: appDrawer(context),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
                  .collection("articulos")
                  .snapshots(),
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
          return Container(
            color: Colors.white,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Section with image background
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
                            'Bienvenid@s!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white70,
                              letterSpacing: 1.5,
                            ),
                          ),
            
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
                          
                        ],
                      ),
                    ),
                  ),
                  Container(
                    height: deviceHeight(context)*0.75,
                    width: deviceWidth(context)*0.70,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                        // Header text inside transparent box
                        SizedBox(
                          height: 12,
                        ),
                      // Body text inside transparent box
                      SizedBox(height: 30),
                      Text(
                        'The latest issue of our magazine is now available. Explore our featured articles and in-depth analysis on important legal matters.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.spaceCadet,
                          fontWeight: FontWeight.w400,
                        ),
                        ),
                        SizedBox(height: 20),
                        // Law Specialization Sections
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center, // Center the row
                          children: [
                            // Adjusted Icon for Business Law with larger size
                            buildSectionItem('Business Law', Icons.business, AppColors.slateGray),
                            SizedBox(width: 50), // Increased spacing between icons
                            // Adjusted Icon for Criminal Law with larger size
                            buildSectionItem('Criminal Law', Icons.gavel, AppColors.slateGray),
                            SizedBox(width: 50), // Increased spacing between icons
                            // Adjusted Icon for Family Law with larger size
                            buildSectionItem('Family Law', Icons.family_restroom, AppColors.slateGray),
                          ],
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
                            'Contáctenos',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                                ],
                                
                              ),
                              
                    
                    ),
                  ),
                  Container(
                    width: deviceWidth(context)*0.85,
                    color: Colors.white, // Background color for the content below the image
                    height: deviceHeight(context),
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: 1, // Example count
                      itemBuilder: (context, index) {
                        return Container(
                          height: deviceHeight(context)*0.75,
                          margin: EdgeInsets.all(20),
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: AppColors.coffee,
                          ),
                          child: ListTile(
                            title: Text(
                              textAlign: TextAlign.center,
                              '¡Volumen mas reciente!',
                              style: TextStyle(
                                fontSize: 36,
                                color: Colors.white,
                              ),
                            ),
                            subtitle: Text(
                              textAlign: TextAlign.center,
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
                        SizedBox(
                          height: 300, // Set a height for the article cards
                          width: deviceWidth(context)*0.80,
                          child: PageView.builder(
                            controller: _pageController, // Use the controller for PageView
                            itemCount: articles.length, // Number of articles to display
                            itemBuilder: (context, index) {
                              final doc = articles[index];
                              final data = doc.data() as Map<String, dynamic>;
                              final title = data['title'] ?? 'Untitled';
                              final description = data['description'] ?? '';
                              final imageURL = data['imageURL'] ?? '';
                              return InkWell(
                                onTap: (){
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
                                            image: AssetImage(imageURL), // Placeholder image
                                            fit: BoxFit.cover,
                                          ),
                                          borderRadius: BorderRadius.circular(16),
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
                                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                        child: ConstrainedBox(
                                          constraints: BoxConstraints(
                                            maxWidth: 200,  // Set a maximum width for the description
                                          ),
                                          child: Text(
                                            description,
                                            style: TextStyle(
                                              color: Colors.white70,
                                              fontSize: 14,
                                            ),
                                            overflow: TextOverflow.ellipsis,  // Optional: Adds "..." when text overflows
                                            maxLines: 2,  // Optional: Limits text to 2 lines (if you prefer)
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
            ),
          );
        }
      ),
    );
  }
} 