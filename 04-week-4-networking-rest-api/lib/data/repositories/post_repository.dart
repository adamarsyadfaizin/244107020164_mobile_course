import 'package:dio/dio.dart';

import '../models/post.dart';

class PostRepository {
  PostRepository(this._dio);
  final Dio _dio;

  Future<List<Post>> fetchPosts() async {
    final response = await _dio.get<List>('/posts');
    return _parsePosts(response.data);
  }

  Future<List<Post>> fetchPostsPage({required int page, int limit = 10}) async {
    final response = await _dio.get<List>(
      '/posts',
      queryParameters: {'_page': page, '_limit': limit},
    );
    return _parsePosts(response.data);
  }

  Future<Post> fetchPost(int id) async {
    final response = await _dio.get<Map<String, dynamic>>('/posts/$id');
    return Post.fromJson(response.data ?? const {});
  }

  List<Post> _parsePosts(List<dynamic>? data) => (data ?? const [])
      .whereType<Map<String, dynamic>>()
      .map(Post.fromJson)
      .toList();
}
