class ClassScheduleModel {
  final String id;
  final Map<String, List<TimeSlot>> weeklySchedule;

  ClassScheduleModel({required this.id, required this.weeklySchedule});

  factory ClassScheduleModel.fromJson(String id, Map<String, dynamic> json) {
    Map<String, List<TimeSlot>> schedule = {};

    // Parse each day of the week
    json.forEach((day, timeSlots) {
      if (timeSlots is Map<String, dynamic>) {
        List<TimeSlot> daySlots = [];

        // Extract time slots and corresponding course details
        timeSlots.forEach((key, value) {
          if (key.startsWith('course_')) {
            // Skip course keys, they are handled with time slots
            return;
          }

          if (value is String) {
            // Find the corresponding course key (e.g., course_0 for 0)
            String courseKey = 'course_$key';
            String courseName = timeSlots[courseKey] ?? '';

            daySlots.add(
              TimeSlot(
                timeRange: value,
                subject: courseName,
                teacher: '', // Add teacher if available in the structure
                room: '', // Add room if available in the structure
                code: courseName,
              ),
            );
          }
        });

        schedule[day] = daySlots;
      }
    });

    return ClassScheduleModel(id: id, weeklySchedule: schedule);
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> result = {};

    weeklySchedule.forEach((day, timeSlots) {
      Map<String, dynamic> dayData = {};
      for (TimeSlot slot in timeSlots) {
        dayData[slot.timeRange] = slot.toJson();
      }
      result[day] = dayData;
    });

    return result;
  }

  // Get classes for today
  List<TimeSlot> getTodaysClasses() {
    String today = _getCurrentDayName();
    return weeklySchedule[today] ?? [];
  }

  // Get classes for tomorrow
  List<TimeSlot> getTomorrowsClasses() {
    String tomorrow = _getTomorrowDayName();
    return weeklySchedule[tomorrow] ?? [];
  }

  String _getCurrentDayName() {
    List<String> weekdays = [
      'Sunday',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
    ];
    return weekdays[DateTime.now().weekday % 7];
  }

  String _getTomorrowDayName() {
    List<String> weekdays = [
      'Sunday',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
    ];
    return weekdays[(DateTime.now().weekday + 1) % 7];
  }
}

class TimeSlot {
  final String timeRange;
  final String subject;
  final String teacher;
  final String room;
  final String code;

  TimeSlot({
    required this.timeRange,
    required this.subject,
    required this.teacher,
    required this.room,
    required this.code,
  });

  factory TimeSlot.fromJson(String timeRange, Map<String, dynamic> json) {
    return TimeSlot(
      timeRange: timeRange,
      subject: json['subject'] ?? '',
      teacher: json['teacher'] ?? '',
      room: json['room'] ?? '',
      code: json['code'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'subject': subject, 'teacher': teacher, 'room': room, 'code': code};
  }

  // Parse start and end time from time range (e.g., "8:00-8:50")
  DateTime? getStartTime() {
    try {
      String startTimeStr;
      if (timeRange.contains('-')) {
        startTimeStr = timeRange.split('-')[0];
      } else {
        startTimeStr = timeRange; // It's a single time
      }
      List<String> timeParts = startTimeStr.split(':');
      int hour = int.parse(timeParts[0]);
      int minute = int.parse(timeParts[1]);

      DateTime now = DateTime.now();
      return DateTime(now.year, now.month, now.day, hour, minute);
    } catch (e) {
      // Consider logging this error
      return null;
    }
  }

  DateTime? getEndTime() {
    try {
      if (timeRange.contains('-')) {
        String endTimeStr = timeRange.split('-')[1];
        List<String> timeParts = endTimeStr.split(':');
        int hour = int.parse(timeParts[0]);
        int minute = int.parse(timeParts[1]);

        DateTime now = DateTime.now();
        return DateTime(now.year, now.month, now.day, hour, minute);
      } else {
        // No end time specified, calculate as start_time + 1 hour (default duration)
        DateTime? startTime = getStartTime();
        if (startTime != null) {
          return startTime.add(
            const Duration(hours: 1),
          ); // Default 1 hour duration
        }
        return null;
      }
    } catch (e) {
      // Consider logging this error
      return null;
    }
  }

  bool isCurrentClass() {
    DateTime now = DateTime.now();
    DateTime? start = getStartTime();
    DateTime? end = getEndTime();

    if (start != null && end != null) {
      return now.isAfter(start) && now.isBefore(end);
    }
    return false;
  }

  bool isUpcoming() {
    DateTime now = DateTime.now();
    DateTime? start = getStartTime();

    if (start != null) {
      return start.isAfter(now);
    }
    return false;
  }
}
