import 'package:go_router/go_router.dart';
import 'package:rustinnovations_adminpanel/Pages/Dashboard.dart';
import 'package:rustinnovations_adminpanel/Pages/LoginPage.dart';
import 'package:rustinnovations_adminpanel/Pages/ArticlesPage.dart';
import 'package:rustinnovations_adminpanel/Pages/BlogDetailsPage.dart';

final route = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(path: '/login', builder: (context, state) => const Loginpage()),
    GoRoute(path: '/dashboard', builder: (context, state) => const Dashboard()),
    GoRoute(path: '/articles', builder: (context, state) => const ArticlesPage()),
    GoRoute(
      path: '/blog-details',
      builder: (context, state) {
        final blog = state.extra as Map<String, dynamic>;
        return BlogDetailsPage(blog: blog);
      },
    ),
  ],
);
