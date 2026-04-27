import 'package:cloud_firestore/cloud_firestore.dart';

class ReportService {
  const ReportService._();

  static Future<void> submitQuestionReport({
    required String questionId,
    required String type,
    required String examType,
    required String examSession,
  }) async {
    await FirebaseFirestore.instance.collection('report').add({
      'questionId': questionId,
      'type': type,
      'examType': examType,
      'examSession': examSession,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
