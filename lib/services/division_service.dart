import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../core/constants/app_constants.dart';

abstract interface class DivisionNameLoader {
  Future<String?> getDivisionName(String divisionId);
}

class DivisionService implements DivisionNameLoader {
  final FirebaseFirestore _firestore;

  DivisionService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<String?> getDivisionName(String divisionId) async {
    final cleanDivisionId = divisionId.trim();
    if (cleanDivisionId.isEmpty) {
      return null;
    }

    try {
      final snapshot = await _firestore
          .collection(AppConstants.divisionsCollection)
          .doc(cleanDivisionId)
          .get();

      if (!snapshot.exists) {
        return null;
      }

      final name = snapshot.data()?['nama'];
      if (name is! String || name.trim().isEmpty) {
        throw const FormatException(
          'Dokumen divisi tidak memiliki field nama yang valid.',
        );
      }

      return name.trim();
    } on FirebaseException catch (error) {
      debugPrint(
        '[OrgaFlow DivisionService ERROR] ${error.code} - ${error.message}',
      );
      rethrow;
    }
  }
}
