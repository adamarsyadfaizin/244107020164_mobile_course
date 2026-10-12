import 'package:go_router/go_router.dart';

import 'data/models/post.dart';
import 'pages/paged_post_page.dart';
import 'pages/post_detail_page.dart';

final router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const PagedPostPage()),
    GoRoute(
      path: '/post/:id',
      builder: (context, state) => PostDetailPage(
        id: int.tryParse(state.pathParameters['id'] ?? '') ?? 0,
        initialPost: state.extra as Post?,
      ),
    ),
  ],
);
