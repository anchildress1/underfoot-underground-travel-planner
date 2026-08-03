import '../models/models.dart';
import '../services/api_service.dart';

class SearchRepository {
  final ApiService _apiService;

  SearchRepository({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  Future<SearchResponse> search(
    String query, {
    String? userLocation,
    bool force = false,
  }) async {
    return _apiService.search(
      query,
      userLocation: userLocation,
      force: force,
    );
  }

  Future<bool> checkHealth() async {
    return _apiService.checkHealth();
  }

  void dispose() {
    _apiService.dispose();
  }
}
