import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:rustinnovations_adminpanel/Pages/Dashboard.dart';
import 'package:rustinnovations_adminpanel/Pages/LoginPage.dart';
import 'package:rustinnovations_adminpanel/Pages/ArticlesPage.dart';
import 'package:rustinnovations_adminpanel/Pages/BlogDetailsPage.dart';

final supabase = Supabase.instance.client;

final GoRouter route = GoRouter(

  initialLocation: '/login',

  redirect: (context, state) {

    final session = supabase.auth.currentSession;

    final isLoggedIn = session != null;

    final isGoingToLogin =
        state.matchedLocation == '/login';

    /// USER NOT LOGGED IN
    if (!isLoggedIn && !isGoingToLogin) {
      return '/login';
    }

    /// USER LOGGED IN
    if (isLoggedIn && isGoingToLogin) {
      return '/dashboard';
    }

    return null;
  },

  routes: [

    GoRoute(
      path: '/login',
      builder: (context, state) =>
      const Loginpage(),
    ),

    GoRoute(
      path: '/dashboard',
      builder: (context, state) =>
      const Dashboard(),
    ),

    GoRoute(
      path: '/articles',
      builder: (context, state) =>
      const ArticlesPage(),
    ),

    GoRoute(
      path: '/blog-details',

      builder: (context, state) {

        final blog =
        state.extra as Map<String, dynamic>;

        return BlogDetailsPage(blog: blog);
      },
    ),
  ],
);