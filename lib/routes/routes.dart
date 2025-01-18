import 'package:derecho_en_perspectiva/pages/pages/articleListPage.dart';
import 'package:derecho_en_perspectiva/pages/pages/articlePage.dart';
import 'package:derecho_en_perspectiva/pages/pages/home_page.dart';
import 'package:derecho_en_perspectiva/pages/pages/logInPage.dart';
import 'package:derecho_en_perspectiva/pages/pages/userPage.dart';
import 'package:go_router/go_router.dart';

import '../pages/pages/signUpPage.dart';

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
      builder: (context, state) => const ArticleListPage(),
    ),


    GoRoute(
      name: 'article',
      path: '/article/:articleId', // Accepts an articleId as a parameter
      builder: (context, state) {
        final articleId = state.pathParameters['articleId']!;
        return ArticlePage(articleId: articleId);
      },
  ),

    GoRoute(
      name: 'logInPage',
      path: '/logInPage',
      builder: (context, state) => LoginPage(),
    ),

    GoRoute(
      name: 'userPage',
      path: '/userPage',
      builder: (context, state) => UserPage(),
    )
]);





