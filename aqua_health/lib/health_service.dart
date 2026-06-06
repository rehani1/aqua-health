import 'package:flutter/foundation.dart';
import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';

class HealthService {
  final Health _health = Health();
  Future<void>? _configureFuture;

  static const List<HealthDataType> _readTypes = <HealthDataType>[
    HealthDataType.STEPS,
    HealthDataType.SLEEP_ASLEEP,
    HealthDataType.SLEEP_DEEP,
    HealthDataType.SLEEP_LIGHT,
    HealthDataType.SLEEP_REM,
    HealthDataType.SLEEP_UNKNOWN,
    HealthDataType.SLEEP_SESSION,
  ];

  static const List<HealthDataType> _sleepStageTypes = <HealthDataType>[
    HealthDataType.SLEEP_ASLEEP,
    HealthDataType.SLEEP_DEEP,
    HealthDataType.SLEEP_LIGHT,
    HealthDataType.SLEEP_REM,
    HealthDataType.SLEEP_UNKNOWN,
  ];

  Future<void> _ensureConfigured() {
    return _configureFuture ??= _health.configure();
  }

  Future<bool> requestPermissions() async {
    try {
      await _ensureConfigured();

      if (defaultTargetPlatform == TargetPlatform.android) {
        final status = await _health.getHealthConnectSdkStatus();
        if (status != HealthConnectSdkStatus.sdkAvailable) {
          return false;
        }

        await Permission.activityRecognition.request();
      }

      final types = _availableTypes(_readTypes);
      final permissions = List<HealthDataAccess>.filled(
        types.length,
        HealthDataAccess.READ,
      );

      final hasPermissions = await _health.hasPermissions(
        types,
        permissions: permissions,
      );

      if (hasPermissions == true) {
        return true;
      }

      return await _health.requestAuthorization(
        types,
        permissions: permissions,
      );
    } catch (_) {
      return false;
    }
  }

  Future<int> getTodaySteps() async {
    try {
      await _ensureConfigured();

      final now = DateTime.now();
      final start = DateTime(now.year, now.month, now.day);
      final steps = await _health.getTotalStepsInInterval(start, now);

      return steps ?? 0;
    } catch (_) {
      return 0;
    }
  }

  Future<double> getSleepHoursLast24Hours() async {
    try {
      await _ensureConfigured();
    } catch (_) {
      return 0;
    }

    final now = DateTime.now();
    final start = now.subtract(const Duration(days: 1));

    final stageHours = await _getSleepHoursForTypes(
      _sleepStageTypes,
      start,
      now,
    );
    if (stageHours > 0) return stageHours;

    return _getSleepHoursForTypes(
      <HealthDataType>[HealthDataType.SLEEP_SESSION],
      start,
      now,
    );
  }

  List<HealthDataType> _availableTypes(List<HealthDataType> types) {
    return types
        .where((HealthDataType type) => _health.isDataTypeAvailable(type))
        .toList(growable: false);
  }

  Future<double> _getSleepHoursForTypes(
    List<HealthDataType> requestedTypes,
    DateTime start,
    DateTime end,
  ) async {
    final types = _availableTypes(requestedTypes);
    if (types.isEmpty) return 0;

    try {
      final data = await _health.getHealthDataFromTypes(
        startTime: start,
        endTime: end,
        types: types,
      );

      return _mergedHoursFromDataPoints(
        _health.removeDuplicates(data),
        start,
        end,
      );
    } catch (_) {
      return 0;
    }
  }

  double _mergedHoursFromDataPoints(
    List<HealthDataPoint> points,
    DateTime start,
    DateTime end,
  ) {
    final ranges = <_DateRange>[];

    for (final point in points) {
      final rangeStart = point.dateFrom.isBefore(start)
          ? start
          : point.dateFrom;
      final rangeEnd = point.dateTo.isAfter(end) ? end : point.dateTo;

      if (rangeEnd.isAfter(rangeStart)) {
        ranges.add(_DateRange(rangeStart, rangeEnd));
      }
    }

    if (ranges.isEmpty) return 0;

    ranges.sort((a, b) => a.start.compareTo(b.start));

    var mergedStart = ranges.first.start;
    var mergedEnd = ranges.first.end;
    var totalMinutes = 0;

    for (final range in ranges.skip(1)) {
      if (range.start.isAfter(mergedEnd)) {
        totalMinutes += mergedEnd.difference(mergedStart).inMinutes;
        mergedStart = range.start;
        mergedEnd = range.end;
      } else if (range.end.isAfter(mergedEnd)) {
        mergedEnd = range.end;
      }
    }

    totalMinutes += mergedEnd.difference(mergedStart).inMinutes;
    return totalMinutes / 60.0;
  }
}

class _DateRange {
  const _DateRange(this.start, this.end);

  final DateTime start;
  final DateTime end;
}
