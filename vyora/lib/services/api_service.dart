import 'package:dio/dio.dart';

import '../models/visitor_model.dart';

// Paste your MockAPI.io base URL here (no trailing slash).
// While it still contains YOUR_ID the app runs on built-in demo data,
// so you can create passes and see a list without any server.
const String baseUrl = 'https://YOUR_ID.mockapi.io/api/v1';

bool get _useDemoData => baseUrl.contains('YOUR_ID');

/// Error with a message that is safe to show to the user.
class AppException implements Exception {
  AppException(this.message, {this.notFound = false});

  final String message;
  final bool notFound;

  @override
  String toString() => message;
}

class ApiService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  // Only used in demo mode.
  final List<Visitor> _demoVisitors = _sampleVisitors();
  int _nextDemoId = 1006;

  Future<List<Visitor>> getVisitors() async {
    if (_useDemoData) {
      await _fakeDelay();
      return List.of(_demoVisitors);
    }
    final data = await _send(() => _dio.get('/visitors'));
    if (data is! List)
      throw AppException('Unexpected response from the server.');
    return data
        .map((item) => Visitor.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<Visitor> getVisitor(String id) async {
    if (_useDemoData) {
      await _fakeDelay();
      return _demoVisitors.firstWhere(
        (v) => v.id == id,
        orElse: () => throw AppException('Visitor not found.', notFound: true),
      );
    }
    return _toVisitor(await _send(() => _dio.get('/visitors/$id')));
  }

  Future<Visitor> createVisitor(Visitor visitor) async {
    if (_useDemoData) {
      await _fakeDelay();
      final created = Visitor(
        id: 'VIS${_nextDemoId++}',
        name: visitor.name,
        mobile: visitor.mobile,
        email: visitor.email,
        visitorType: visitor.visitorType,
        project: visitor.project,
        purpose: visitor.purpose,
        status: visitor.status,
        createdAt: visitor.createdAt,
      );
      _demoVisitors.insert(0, created);
      return created;
    }
    return _toVisitor(
      await _send(() => _dio.post('/visitors', data: visitor.toJson())),
    );
  }

  Future<Visitor> updateVisitor(Visitor visitor) async {
    if (_useDemoData) {
      await _fakeDelay();
      final index = _demoVisitors.indexWhere((v) => v.id == visitor.id);
      if (index == -1) {
        throw AppException('Visitor not found.', notFound: true);
      }
      _demoVisitors[index] = visitor;
      return visitor;
    }
    return _toVisitor(
      await _send(
        () => _dio.put('/visitors/${visitor.id}', data: visitor.toJson()),
      ),
    );
  }

  Future<void> deleteVisitor(String id) async {
    if (_useDemoData) {
      await _fakeDelay();
      _demoVisitors.removeWhere((v) => v.id == id);
      return;
    }
    await _send(() => _dio.delete('/visitors/$id'));
  }

  Future<void> _fakeDelay() =>
      Future.delayed(const Duration(milliseconds: 300));

  Visitor _toVisitor(dynamic data) {
    if (data is! Map)
      throw AppException('Unexpected response from the server.');
    return Visitor.fromJson(Map<String, dynamic>.from(data));
  }

  Future<dynamic> _send(Future<Response> Function() request) async {
    try {
      final response = await request();
      return response.data;
    } on DioException catch (e) {
      throw _friendlyError(e);
    }
  }

  AppException _friendlyError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return AppException('The server took too long to respond.');
    }
    if (e.type == DioExceptionType.connectionError) {
      return AppException('No internet connection.');
    }
    final code = e.response?.statusCode;
    if (code == 404) return AppException('Visitor not found.', notFound: true);
    if (code != null && code >= 500) {
      return AppException('Server error ($code). Please try again.');
    }
    return AppException('Something went wrong. Please try again.');
  }
}

List<Visitor> _sampleVisitors() {
  final now = DateTime.now();
  return [
    Visitor(
      id: 'VIS1005',
      name: 'Dev Malhotra',
      mobile: '9090909090',
      email: 'dev@example.com',
      visitorType: VisitorType.vendor,
      project: 'Project C',
      purpose: 'Maintenance review',
      status: VisitorStatus.checkedIn,
      createdAt: now.subtract(const Duration(minutes: 30)),
      checkInTime: now.subtract(const Duration(minutes: 20)),
    ),
    Visitor(
      id: 'VIS1004',
      name: 'Nisha Shah',
      mobile: '9012345678',
      email: 'nisha@example.com',
      visitorType: VisitorType.other,
      project: 'Project A',
      purpose: 'Community meeting',
      createdAt: now.subtract(const Duration(hours: 1)),
    ),
    Visitor(
      id: 'VIS1003',
      name: 'Rohan Kapoor',
      mobile: '9988776655',
      visitorType: VisitorType.customer,
      project: 'Project C',
      purpose: 'Sales consultation',
      status: VisitorStatus.checkedOut,
      createdAt: now.subtract(const Duration(hours: 5)),
      checkInTime: now.subtract(const Duration(hours: 4)),
      checkOutTime: now.subtract(const Duration(hours: 3)),
    ),
    Visitor(
      id: 'VIS1002',
      name: 'Maya Fernandes',
      mobile: '9123456780',
      email: 'maya@example.com',
      visitorType: VisitorType.vendor,
      project: 'Project B',
      purpose: 'Material delivery',
      createdAt: now.subtract(const Duration(hours: 6)),
    ),
    Visitor(
      id: 'VIS1001',
      name: 'Aarav Mehta',
      mobile: '9876543210',
      email: 'aarav@example.com',
      visitorType: VisitorType.customer,
      project: 'Project A',
      purpose: 'Site walkthrough',
      status: VisitorStatus.checkedIn,
      createdAt: now.subtract(const Duration(hours: 7)),
      checkInTime: now.subtract(const Duration(hours: 6)),
    ),
  ];
}
