import 'package:flutter/foundation.dart';

import '../models/visitor_model.dart';
import '../services/api_service.dart';

class VisitorController extends ChangeNotifier {
  VisitorController(this._api);

  final ApiService _api;

  List<Visitor> _visitors = [];
  bool _isLoading = false;
  String? _errorMessage;

  String _searchText = '';
  VisitorStatus? _statusFilter;
  String? _projectFilter;

  // Visitors that have a check-in/out running, so a double tap does nothing.
  final Set<String> _busyIds = {};

  List<Visitor> get visitors => _visitors;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  VisitorStatus? get statusFilter => _statusFilter;
  String? get projectFilter => _projectFilter;

  bool get hasFilters =>
      _searchText.isNotEmpty || _statusFilter != null || _projectFilter != null;

  List<Visitor> get filteredVisitors {
    final query = _searchText.toLowerCase();
    return _visitors.where((v) {
      final matchesSearch =
          query.isEmpty ||
          v.name.toLowerCase().contains(query) ||
          v.mobile.contains(query);
      final matchesStatus = _statusFilter == null || v.status == _statusFilter;
      final matchesProject =
          _projectFilter == null || v.project == _projectFilter;
      return matchesSearch && matchesStatus && matchesProject;
    }).toList();
  }

  // Dashboard numbers. "Today" means today on this device.
  int get totalToday =>
      _visitors.where((v) => _isToday(v.createdAt)).length;

  int get checkedInCount =>
      _visitors.where((v) => v.status == VisitorStatus.checkedIn).length;

  int get checkedOutToday => _visitors
      .where(
        (v) =>
            v.status == VisitorStatus.checkedOut &&
            v.checkOutTime != null &&
            _isToday(v.checkOutTime!),
      )
      .length;

  bool isBusy(String id) => _busyIds.contains(id);

  Visitor? visitorById(String id) {
    for (final v in _visitors) {
      if (v.id == id) return v;
    }
    return null;
  }

  Future<void> loadVisitors({bool showLoader = true}) async {
    if (_isLoading) return;
    if (showLoader) {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
    }
    try {
      _visitors = await _api.getVisitors();
      _visitors.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      _errorMessage = null;
    } on AppException catch (e) {
      _errorMessage = e.message;
    }
    _isLoading = false;
    notifyListeners();
  }

  // The methods below throw an AppException when something goes wrong,
  // the screen that called them shows the message.

  Future<Visitor> addVisitor(Visitor visitor) async {
    final saved = await _api.createVisitor(visitor);
    _saveLocally(saved);
    return saved;
  }

  Future<void> updateVisitor(Visitor visitor) async {
    _saveLocally(await _api.updateVisitor(visitor));
  }

  Future<void> deleteVisitor(String id) async {
    await _api.deleteVisitor(id);
    _visitors = _visitors.where((v) => v.id != id).toList();
    notifyListeners();
  }

  /// Used by the scanner. Always asks the server so the status is up to date.
  Future<Visitor> findVisitor(String id) async {
    final visitor = await _api.getVisitor(id);
    _saveLocally(visitor);
    return visitor;
  }

  Future<void> checkIn(String id) => _changeStatus(id, VisitorStatus.checkedIn);

  Future<void> checkOut(String id) =>
      _changeStatus(id, VisitorStatus.checkedOut);

  Future<void> _changeStatus(String id, VisitorStatus newStatus) async {
    if (_busyIds.contains(id)) return;
    _busyIds.add(id);
    notifyListeners();

    try {
      // Check the server copy first, our list might be out of date.
      final latest = await _api.getVisitor(id);

      if (newStatus == VisitorStatus.checkedIn &&
          latest.status != VisitorStatus.registered) {
        _saveLocally(latest);
        throw AppException(
          latest.status == VisitorStatus.checkedIn
              ? 'Visitor is already checked in.'
              : 'This visit is already completed.',
        );
      }
      if (newStatus == VisitorStatus.checkedOut &&
          latest.status != VisitorStatus.checkedIn) {
        _saveLocally(latest);
        throw AppException(
          latest.status == VisitorStatus.registered
              ? 'Visitor has not checked in yet.'
              : 'Visitor is already checked out.',
        );
      }

      final now = DateTime.now();
      final updated = latest.copyWith(
        status: newStatus,
        checkInTime: newStatus == VisitorStatus.checkedIn ? now : null,
        checkOutTime: newStatus == VisitorStatus.checkedOut ? now : null,
      );
      _saveLocally(await _api.updateVisitor(updated));
    } finally {
      _busyIds.remove(id);
      notifyListeners();
    }
  }

  void setSearch(String text) {
    _searchText = text.trim();
    notifyListeners();
  }

  void setStatusFilter(VisitorStatus? status) {
    _statusFilter = status;
    notifyListeners();
  }

  void setProjectFilter(String? project) {
    _projectFilter = project;
    notifyListeners();
  }

  void clearFilters() {
    _searchText = '';
    _statusFilter = null;
    _projectFilter = null;
    notifyListeners();
  }

  void _saveLocally(Visitor visitor) {
    final index = _visitors.indexWhere((v) => v.id == visitor.id);
    if (index == -1) {
      _visitors = [visitor, ..._visitors];
    } else {
      _visitors[index] = visitor;
    }
    _visitors.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    notifyListeners();
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    final local = date.toLocal();
    return local.year == now.year &&
        local.month == now.month &&
        local.day == now.day;
  }
}
