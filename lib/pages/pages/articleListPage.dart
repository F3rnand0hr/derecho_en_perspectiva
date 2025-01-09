import 'package:flutter/material.dart';
import 'package:derecho_en_perspectiva/models/articles.dart'; // Import articles model
import 'package:go_router/go_router.dart'; // For navigation to article page
import 'articlePage.dart'; // Import ArticlePage

class ArticlesListPage extends StatelessWidget {
  const ArticlesListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Articles'),
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: GridView.builder(
        padding: EdgeInsets.all(16), // Add padding to the grid
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // 2 items per row
          crossAxisSpacing: 16, // Horizontal spacing between items
          mainAxisSpacing: 16, // Vertical spacing between items
          childAspectRatio: 0.8, // Aspect ratio of each item (adjust as needed)
        ),
        itemCount: articles.length, // Number of articles
        itemBuilder: (context, index) {
          final article = articles[index]; // Get the current article

          return GestureDetector(
            onTap: () {
              // Navigate to the article page when tapped
              context.push(
                '/article',
                extra: article, // Pass the article to ArticlePage
              );
            },
            child: Card(
              elevation: 5, // Add shadow to the card
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12), // Rounded corners
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Article Image
                  ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                    child: Image.asset(
                      article.imageUrl,
                      height: 150, // Fixed height for the image
                      width: double.infinity, // Make the image full width
                      fit: BoxFit.cover, // Ensure the image covers the area
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Article Title
                        Text(
                          article.title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        // Article Description
                        Text(
                          article.description,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
