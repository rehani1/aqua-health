import 'package:health/health.dart';

class HealthService {
  final Health _health = Health();

  Future<bool> requestPermissions() async {
    final types = [
      HealthDataType.STEPS,
      HealthDataType.SLEEP_ASLEEP,
      HealthDataType.SLEEP_AWAKE,
    ];

    final permissions = [
      HealthDataAccess.READ,
      HealthDataAccess.READ,
      HealthDataAccess.READ,
    ];

    return await _health.requestAuthorization(
      types,
      permissions: permissions,
    );
  }

  Future<int> getTodaySteps() async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);

    final steps = await _health.getTotalStepsInInterval(start, now);

    return steps ?? 0;
  }

  Future<double> getSleepHoursLast24Hours() async {
    final now = DateTime.now();
    final start = now.subtract(const Duration(days: 1));

    final data = await _health.getHealthDataFromTypes(
      startTime: start,
      endTime: now,
      types: [
        HealthDataType.SLEEP_ASLEEP,
      ],
    );

    double total = 0;

    for (final point in data) {
      final duration = point.dateTo.difference(point.dateFrom);
      total += duration.inMinutes / 60.0;
    }

    return total;
  }
}