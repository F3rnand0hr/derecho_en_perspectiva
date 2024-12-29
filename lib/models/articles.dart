class Article {
  final String title;
  final String description;
  final String imageUrl;
  final String content; // Store the full content of the article

  Article({
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.content,
  });
}

// Create a list of articles
List<Article> articles = [
  Article(
    title: 'Business Law',
    description: 'This article discusses the latest trends in Business Law.',
    imageUrl: 'assets/business_law.jpg',
    content: '''Business law is the body of law that governs business and commercial transactions...
                (continue the content here)...
                This is the first page of the article...
                This is the second page...''',
  ),
  Article(
    title: 'Criminal Law',
    description: 'An in-depth analysis of the criminal law system.',
    imageUrl: 'assets/criminal_law.jpg',
    content: '''Criminal law involves the prosecution of individuals who have been accused of committing crimes...
                (continue the content here)...
                Page 1 of the article...
                Page 2...''',
  ),
  // Add more articles...
];
