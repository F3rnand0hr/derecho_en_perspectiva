import 'package:derecho_en_perspectiva/pages/pages/articleListPage.dart';
import 'package:derecho_en_perspectiva/pages/pages/articlePage.dart';
import 'package:derecho_en_perspectiva/pages/pages/home_page.dart';
import 'package:go_router/go_router.dart';

import '../models/articles.dart';
import '../pages/pages/sign_up_page.dart';

final GoRouter router = GoRouter(routes:[
  GoRoute(name: 'home',
  path: "/",
    builder: (context,state) => homePage(),
  ),

  GoRoute(
    name: 'sign_up',
    path: '/sign-up',
    builder: (context, state) => SignUpPage(),
  ),

  GoRoute(
      name: 'articlesList',
      path: '/articles',
      builder: (context, state) => const ArticlesListPage(), // Route for the list of articles
    ),

  GoRoute(
      name: 'article',
      path: '/article',
      builder: (context, state) {
        final article = state.extra as Article; // Get the article passed via `state.extra`
        return ArticlePage(article: article); // Pass article to ArticlePage
      },
    ),
]);






// BlocProvider(
//   //   create: (context) => LoginCubit(),
//   //   child: const SignUpPage(),
//   // ),