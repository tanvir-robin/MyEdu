import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../models/class_schedule_model.dart';

class ClassScheduleController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final Rx<ClassScheduleModel?> classSchedule = Rx<ClassScheduleModel?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchClassSchedule();
  }

  Future<void> fetchClassSchedule() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Fetch from routines/6th document
      DocumentSnapshot doc =
          await _firestore.collection('routines').doc('6th').get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data() as Map<String, dynamic>;
        classSchedule.value = ClassScheduleModel.fromJson(doc.id, data);
      } else {
        errorMessage.value = 'No class schedule found';
      }
    } catch (e) {
      errorMessage.value = 'Failed to fetch class schedule: $e';
      Get.snackbar('Error', 'Failed to fetch class schedule: $e');
    } finally {
      isLoading.value = false;
    }
  }

  List<TimeSlot> getTodaysClasses() {
    return classSchedule.value?.getTodaysClasses() ?? [];
  }

  List<TimeSlot> getTomorrowsClasses() {
    return classSchedule.value?.getTomorrowsClasses() ?? [];
  }

  String getCurrentDayName() {
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

  String getTomorrowDayName() {
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

  void refresh() {
    fetchClassSchedule();
  }
}
