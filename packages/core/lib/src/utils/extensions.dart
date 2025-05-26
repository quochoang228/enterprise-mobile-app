/// Common utilities and helper functions

/// String utilities
extension StringExtensions on String {
  bool get isValidEmail {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(this);
  }

  String get capitalizeFirst {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}

/// DateTime utilities
extension DateTimeExtensions on DateTime {
  String get toIso8601String => toUtc().toIso8601String();

  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }
}

/// List utilities
extension ListExtensions<T> on List<T> {
  List<T> get removeDuplicates => toSet().toList();

  T? get firstOrNull => isEmpty ? null : first;

  T? get lastOrNull => isEmpty ? null : last;
}
