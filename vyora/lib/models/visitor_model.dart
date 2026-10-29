enum VisitorStatus {
  registered('Registered'),
  checkedIn('Checked In'),
  checkedOut('Checked Out');

  const VisitorStatus(this.label);
  final String label;
}

enum VisitorType {
  customer('Customer'),
  vendor('Vendor'),
  other('Other');

  const VisitorType(this.label);
  final String label;
}

const visitorProjects = ['Project A', 'Project B', 'Project C'];

class Visitor {
  const Visitor({
    this.id = '',
    required this.name,
    required this.mobile,
    this.email,
    required this.visitorType,
    required this.project,
    required this.purpose,
    this.status = VisitorStatus.registered,
    required this.createdAt,
    this.checkInTime,
    this.checkOutTime,
  });

  final String id;
  final String name;
  final String mobile;
  final String? email;
  final VisitorType visitorType;
  final String project;
  final String purpose;
  final VisitorStatus status;
  final DateTime createdAt;
  final DateTime? checkInTime;
  final DateTime? checkOutTime;

  factory Visitor.fromJson(Map<String, dynamic> json) {
    final email = json['email']?.toString() ?? '';
    return Visitor(
      id: json['id'].toString(),
      name: json['name']?.toString() ?? '',
      mobile: json['mobile']?.toString() ?? '',
      email: email.isEmpty ? null : email,
      visitorType: VisitorType.values.firstWhere(
        (t) => t.label == json['visitor_type'],
        orElse: () => VisitorType.other,
      ),
      project: json['project']?.toString() ?? '',
      purpose: json['purpose']?.toString() ?? '',
      status: VisitorStatus.values.firstWhere(
        (s) => s.label == json['status'],
        orElse: () => VisitorStatus.registered,
      ),
      createdAt: _parseDate(json['created_at']) ?? DateTime.now(),
      checkInTime: _parseDate(json['check_in_time']),
      checkOutTime: _parseDate(json['check_out_time']),
    );
  }

  // The id is not part of the body, the server creates it and we send it in the URL.
  // Dates go out as UTC and come back as local time.
  Map<String, dynamic> toJson() => {
    'name': name,
    'mobile': mobile,
    'email': email,
    'visitor_type': visitorType.label,
    'project': project,
    'purpose': purpose,
    'status': status.label,
    'created_at': createdAt.toUtc().toIso8601String(),
    'check_in_time': checkInTime?.toUtc().toIso8601String(),
    'check_out_time': checkOutTime?.toUtc().toIso8601String(),
  };

  Visitor copyWith({
    VisitorStatus? status,
    DateTime? checkInTime,
    DateTime? checkOutTime,
  }) {
    return Visitor(
      id: id,
      name: name,
      mobile: mobile,
      email: email,
      visitorType: visitorType,
      project: project,
      purpose: purpose,
      status: status ?? this.status,
      createdAt: createdAt,
      checkInTime: checkInTime ?? this.checkInTime,
      checkOutTime: checkOutTime ?? this.checkOutTime,
    );
  }
}

DateTime? _parseDate(dynamic value) {
  if (value == null) return null;
  return DateTime.tryParse(value.toString())?.toLocal();
}
