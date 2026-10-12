import 'package:go_router/go_router.dart';

import 'pages/home_page.dart';
import 'pages/note_detail_page.dart';

final router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomePage()),
    GoRoute(
      path: '/note/:id',
      builder: (context, state) => NoteDetailPage(
        id: int.tryParse(state.pathParameters['id'] ?? '') ?? 0,
      ),
    ),
  ],
);
