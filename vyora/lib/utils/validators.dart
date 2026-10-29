class Validators {
  static String? required(String? value, String field) {
    if (value == null || value.trim().isEmpty) return '$field is required';
    return null;
  }

  static String? mobile(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Mobile number is required';
    if (!RegExp(r'^\d{10}$').hasMatch(text)) return 'Enter exactly 10 digits';
    return null;
  }

  // Email is optional, so it is only checked when something is typed.
  static String? email(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return null;
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(text)) {
      return 'Enter a valid email address';
    }
    return null;
  }
}
