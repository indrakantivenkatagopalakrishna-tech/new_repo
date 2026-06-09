import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

class ApiService {
  static const String _defaultBaseUrl = "http://localhost:3000";
  String _baseUrl = _defaultBaseUrl;
  String? _token;

  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String get baseUrl => _baseUrl;
  bool get isAuthenticated => _token != null;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _baseUrl = prefs.getString('api_base_url') ?? _defaultBaseUrl;
    _token = prefs.getString('auth_token');
  }

  Future<void> setBaseUrl(String url) async {
    _baseUrl = url;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('api_base_url', url);
  }

  Map<String, String> _getHeaders() {
    final headers = {
      'Content-Type': 'application/json',
    };
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  Future<bool> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/admin/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _token = data['token'];
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', _token!);
        await prefs.setString('admin_user', jsonEncode(data['admin']));
        return true;
      }
      return false;
    } catch (e) {
      print("Login error: $e");
      return false;
    }
  }

  Future<void> logout() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('admin_user');
  }

  Future<DashboardStats?> fetchDashboardStats() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/admin/dashboard'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        return DashboardStats.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      print("Fetch dashboard stats error: $e");
      return null;
    }
  }

  Future<List<Booking>> fetchBookings({String? query, String? date}) async {
    try {
      String url = '$_baseUrl/admin/bookings?';
      if (date != null && date.isNotEmpty) {
        url += 'date=$date&';
      }
      if (query != null && query.isNotEmpty) {
        url += 'query=${Uri.encodeComponent(query)}&';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Booking.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print("Fetch bookings error: $e");
      return [];
    }
  }

  Future<List<Slot>> fetchSlots({String? date}) async {
    try {
      String url = '$_baseUrl/admin/slots';
      if (date != null && date.isNotEmpty) {
        url += '?date=$date';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Slot.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print("Fetch slots error: $e");
      return [];
    }
  }

  Future<Slot?> createSlot(String date, String startTime, String endTime, int maxBookings) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/admin/slots'),
        headers: _getHeaders(),
        body: jsonEncode({
          'date': date,
          'start_time': startTime,
          'end_time': endTime,
          'max_bookings': maxBookings,
        }),
      );

      if (response.statusCode == 201) {
        return Slot.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      print("Create slot error: $e");
      return null;
    }
  }

  Future<Slot?> updateSlot(int id, int maxBookings, bool isAvailable) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/admin/slots/$id'),
        headers: _getHeaders(),
        body: jsonEncode({
          'max_bookings': maxBookings,
          'is_available': isAvailable,
        }),
      );

      if (response.statusCode == 200) {
        return Slot.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      print("Update slot error: $e");
      return null;
    }
  }

  Future<bool> deleteSlot(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/admin/slots/$id'),
        headers: _getHeaders(),
      );

      return response.statusCode == 200;
    } catch (e) {
      print("Delete slot error: $e");
      return false;
    }
  }
}
