
import 'package:flutter/foundation.dart';

import '../../../data/repositories/alert_repository.dart';
import '../../../domain/models/stock_alert.dart';

/// Turns the alerts from [AlertRepository] into what the alerts screen shows.
class AlertsViewModel extends ChangeNotifier {
  AlertsViewModel({required this._repository});

final AlertRepository _repository;


  List<StockAlert> _alerts = <StockAlert>[];
  bool _loading = false;

  final Set<Severity> _activeFilters = <Severity>{};
  String _query = '';

  /// True while load is in progress.
  bool get loading => _loading;

  /// Fetches the alerts from the repository.
  Future<void> load() async {
    if (_loading) return;

    _loading = true;
    notifyListeners();

    try {
      final alerts = await _repository.fetchAlerts();
      _alerts = List<StockAlert>.of(alerts);
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Unmodifiable; filtered by severity and search query, then sorted.
  List<StockAlert> get visibleAlerts {
    final results = _alerts.where((alert) {
      final matchesSeverity = _activeFilters.isEmpty ||
          _activeFilters.contains(alert.severity);

      final normalizedQuery = _query;
      final matchesQuery = normalizedQuery.isEmpty ||
          _normalizeArabic(alert.medicineNameEn).contains(normalizedQuery) ||
          _normalizeArabic(alert.medicineNameAr).contains(normalizedQuery);

      return matchesSeverity && matchesQuery;
    }).toList();

    results.sort(_compareAlerts);

    return List<StockAlert>.unmodifiable(results);
  }

  /// The severities currently shown. Empty means show all.
  Set<Severity> get activeFilters =>
      Set<Severity>.unmodifiable(_activeFilters);

  void toggleFilter(Severity severity) {
    if (_activeFilters.contains(severity)) {
      _activeFilters.remove(severity);
    } else {
      _activeFilters.add(severity);
    }

    notifyListeners();
  }

  void setQuery(String query) {
    final normalized = _normalizeArabic(query.trim());

    if (normalized == _query) return;

    _query = normalized;
    notifyListeners();
  }

  Future<void> acknowledge(String id) async {
    final index = _alerts.indexWhere((alert) => alert.id == id);

    if (index == -1 || _alerts[index].acknowledged) return;

    await _repository.acknowledge(id);

    _alerts[index] = _alerts[index].copyWith(acknowledged: true);
    notifyListeners();
  }

  /// Unacknowledged critical alerts among all loaded alerts.
  int get unacknowledgedCriticalCount => _alerts
      .where((alert) =>
          alert.severity == Severity.critical && !alert.acknowledged)
      .length;

  int _severityRank(Severity severity) {
    switch (severity) {
      case Severity.critical:
        return 0;
      case Severity.high:
        return 1;
      case Severity.medium:
        return 2;
      case Severity.low:
        return 3;
    }
  }

  int _compareAlerts(StockAlert a, StockAlert b) {
    // Unacknowledged alerts first.
    if (a.acknowledged != b.acknowledged) {
      return a.acknowledged ? 1 : -1;
    }

    // Then severity: critical, high, medium, low.
    final severityComparison =
        _severityRank(a.severity).compareTo(_severityRank(b.severity));

    if (severityComparison != 0) return severityComparison;

    // Then fewer days of cover first.
    final daysComparison = a.daysOfCover.compareTo(b.daysOfCover);

    if (daysComparison != 0) return daysComparison;

    // Finally, English name alphabetically, ignoring case.
    return a.medicineNameEn
        .toLowerCase()
        .compareTo(b.medicineNameEn.toLowerCase());
  }

  String _normalizeArabic(String value) {
    return value
        .toLowerCase()
        .replaceAll(RegExp('[أإآ]'), 'ا')
        .replaceAll('ة', 'ه')
        .replaceAll('ى', 'ي')
        .replaceAll('\u0640', '')
        .replaceAll(RegExp('[\u064B-\u0652]'), '');
  }
}
