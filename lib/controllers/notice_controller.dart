import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../models/notice_model.dart';

class NoticeController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final RxList<NoticeModel> notices = <NoticeModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchNotices();
  }

  void fetchNotices() async {
    try {
      final QuerySnapshot snapshot =
          await _firestore.collection('notices').get();
      final List<NoticeModel> fetchedNotices =
          snapshot.docs.map((doc) {
            return NoticeModel.fromJson(doc.data() as Map<String, dynamic>);
          }).toList();
      notices.assignAll(fetchedNotices);
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch notices: $e');
    }
  }
}
