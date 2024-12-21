import 'package:derecho_en_perspectiva/pages/pages/home_page.dart';
import 'package:go_router/go_router.dart';

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
]);






// BlocProvider(
//   //   create: (context) => LoginCubit(),
//   //   child: const SignUpPage(),
//   // ),