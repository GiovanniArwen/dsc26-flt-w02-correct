import 'package:flutter/material.dart';

import '../../../domain/models/stock_alert.dart';
import '../view_models/alerts_view_model.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key, required this.viewModel});

  final AlertsViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Branch alerts')),
      body: AnimatedBuilder(
        animation: viewModel,
        builder: (context, _) {
          if (viewModel.loading) {
            return const Center(
              key: Key('alerts-loading'),
              child: CircularProgressIndicator(),
            );
          }

          final alerts = viewModel.visibleAlerts;
          final count = alerts.length;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: TextField(
                  key: const Key('search-field'),
                  onChanged: viewModel.setQuery,
                  decoration: const InputDecoration(
                    hintText: 'Search medicines...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Wrap(
                  spacing: 4,
                  children: [
                    _filterChip(
                      label: 'Critical',
                      severity: Severity.critical,
                      keyName: 'filter-critical',
                    ),
                    _filterChip(
                      label: 'High',
                      severity: Severity.high,
                      keyName: 'filter-high',
                    ),
                    _filterChip(
                      label: 'Medium',
                      severity: Severity.medium,
                      keyName: 'filter-medium',
                    ),
                    _filterChip(
                      label: 'Low',
                      severity: Severity.low,
                      keyName: 'filter-low',
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '$count ${count == 1 ? 'alert' : 'alerts'}',
                    key: const Key('alerts-count'),
                  ),
                ),
              ),
              Expanded(
                child: alerts.isEmpty
                    ? const Center(
                        key: Key('alerts-empty'),
                        child: Text('No alerts found'),
                      )
                    : ListView.builder(
                        key: const Key('alerts-list'),
                        itemCount: alerts.length,
                        itemBuilder: (context, index) {
                          final alert = alerts[index];

                          return Card(
                            key: Key('alert-${alert.id}'),
                            margin: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            child: ListTile(
                              title: Text(alert.medicineNameEn),
                              subtitle: Text(
                                '${alert.medicineNameAr}\n'
                                'Branch: ${alert.branchCode} · '
                                '${alert.daysOfCover} days remaining',
                              ),
                              isThreeLine: true,
                              leading: CircleAvatar(
                                child: Text(
                                  alert.severity.name[0].toUpperCase(),
                                ),
                              ),
                              trailing: alert.acknowledged
                                  ? const Icon(
                                      Icons.check_circle,
                                      color: Colors.green,
                                    )
                                  : TextButton(
                                      key: Key('ack-${alert.id}'),
                                      onPressed: () {
                                        viewModel.acknowledge(alert.id);
                                      },
                                      child: const Text('Acknowledge'),
                                    ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _filterChip({
    required String label,
    required Severity severity,
    required String keyName,
  }) {
    return FilterChip(
      key: Key(keyName),
      label: Text(label),
      selected: viewModel.activeFilters.contains(severity),
      onSelected: (_) => viewModel.toggleFilter(severity),
    );
  }
}
