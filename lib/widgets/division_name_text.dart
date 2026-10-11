import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/division_service.dart';

class DivisionNameText extends StatefulWidget {
  final String? divisionId;
  final String? prefix;
  final TextStyle? style;
  final DivisionNameLoader? divisionNameLoader;

  const DivisionNameText({
    super.key,
    required this.divisionId,
    this.prefix,
    this.style,
    this.divisionNameLoader,
  });

  @override
  State<DivisionNameText> createState() => _DivisionNameTextState();
}

class _DivisionNameTextState extends State<DivisionNameText> {
  late Future<String?> _divisionName;

  @override
  void initState() {
    super.initState();
    _loadDivisionName();
  }

  @override
  void didUpdateWidget(covariant DivisionNameText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.divisionId != widget.divisionId ||
        oldWidget.divisionNameLoader != widget.divisionNameLoader) {
      _loadDivisionName();
    }
  }

  void _loadDivisionName() {
    final divisionId = widget.divisionId?.trim();
    if (divisionId == null || divisionId.isEmpty) {
      _divisionName = Future.value(null);
      return;
    }

    _divisionName = (widget.divisionNameLoader ?? DivisionService())
        .getDivisionName(divisionId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _divisionName,
      builder: (context, snapshot) {
        final String divisionName;
        if (widget.divisionId?.trim().isNotEmpty != true) {
          divisionName = 'Divisi belum ditentukan';
        } else if (snapshot.hasError) {
          divisionName = _errorMessage(snapshot.error);
        } else if (snapshot.connectionState != ConnectionState.done) {
          divisionName = 'Memuat divisi...';
        } else {
          divisionName = snapshot.data ?? 'Divisi tidak ditemukan';
        }

        final prefix = widget.prefix;
        final label = prefix == null || prefix.isEmpty
            ? divisionName
            : '$prefix • $divisionName';

        return Text(
          label,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: widget.style,
        );
      },
    );
  }

  String _errorMessage(Object? error) {
    if (error is FirebaseException) {
      if (error.code == 'permission-denied') {
        return 'Akses Firestore untuk divisi ditolak';
      }
      return 'Gagal memuat divisi (${error.code})';
    }
    return 'Gagal memuat divisi';
  }
}
