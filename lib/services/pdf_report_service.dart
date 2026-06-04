import 'package:flutter/services.dart' show Uint8List, rootBundle;

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import 'package:intl/intl.dart';
import 'package:gym_lead_master/src/data/models/attendance_model.dart';

class PdfReportService {
  // Font cache
  static pw.Font? _regularFont;
  static pw.Font? _boldFont;

  /// Load fonts from assets
  static Future<void> _loadFonts() async {
    if (_regularFont != null) return;

    try {
      final regularData = await rootBundle.load(
        'assets/fonts/Roboto-Regular.ttf',
      );
      final boldData = await rootBundle.load('assets/fonts/Roboto-Bold.ttf');

      _regularFont = pw.Font.ttf(regularData);
      _boldFont = pw.Font.ttf(boldData);
    } catch (e) {
      print("Custom fonts not found, using default: $e");
      _regularFont = pw.Font.helvetica();
      _boldFont = pw.Font.helvetica();
    }
  }

  static Future<void> generateAttendanceReport({
    required String gymName,
    required String monthLabel,
    required List<MemberAttendanceModel> records,
    required int year,
    required int monthNum,
  }) async {
    // Load fonts
    await _loadFonts();

    // Create PDF with custom font theme
    final pdf = pw.Document(
      theme: pw.ThemeData.withFont(base: _regularFont!, bold: _boldFont!),
    );

    // Sort by name
    records.sort((a, b) => a.memberName.compareTo(b.memberName));

    DateTime now = DateTime.now();
    String generatedDate = DateFormat('dd MMM yyyy').format(now);
    String generatedTime = DateFormat('hh:mm a').format(now);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.only(bottom: 8),
            decoration: const pw.BoxDecoration(
              border: pw.Border(
                bottom: pw.BorderSide(color: PdfColors.blue, width: 2),
              ),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      gymName,
                      style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blue800,
                      ),
                    ),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      'Attendance Report - $monthLabel',
                      style: const pw.TextStyle(
                        fontSize: 13,
                        color: PdfColors.grey700,
                      ),
                    ),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      'Generated: $generatedDate',
                      style: const pw.TextStyle(fontSize: 9),
                    ),
                    pw.Text(
                      'Time: $generatedTime',
                      style: const pw.TextStyle(fontSize: 9),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
        footer: (pw.Context context) {
          return pw.Container(
            alignment: pw.Alignment.center,
            margin: const pw.EdgeInsets.only(top: 8),
            child: pw.Text(
              'Page ${context.pageNumber} of ${context.pagesCount}',
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey),
            ),
          );
        },
        build: (pw.Context context) {
          return [
            pw.SizedBox(height: 16),

            // Summary
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColors.blue50,
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                children: [
                  _buildPdfStat('Total Members', '${records.length}'),
                  pw.Container(width: 1, height: 30, color: PdfColors.blue200),
                  _buildPdfStat(
                    'Avg Attendance',
                    '${_calculateAvgPercentage(records, year, monthNum).toStringAsFixed(1)}%',
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 16),

            // Table
            pw.Table.fromTextArray(
              headers: [
                '#',
                'Member Name',
                'Email',
                'Present',
                'Absent',
                'Percentage',
              ],
              data: _buildTableData(records, year, monthNum),
              border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
              headerDecoration: const pw.BoxDecoration(
                color: PdfColors.blue800,
              ),
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
                fontSize: 9,
              ),
              cellStyle: const pw.TextStyle(fontSize: 9),
              cellAlignment: pw.Alignment.center,
              headerAlignment: pw.Alignment.center,
              columnWidths: {
                0: const pw.FlexColumnWidth(0.5),
                1: const pw.FlexColumnWidth(2.5),
                2: const pw.FlexColumnWidth(2.5),
                3: const pw.FlexColumnWidth(1),
                4: const pw.FlexColumnWidth(1),
                5: const pw.FlexColumnWidth(1.2),
              },
            ),

            pw.SizedBox(height: 20),
            pw.Divider(),
            pw.SizedBox(height: 4),
           
            pw.Text(
              'This is a system-generated report from Gym Lead Master.',
              style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey),
            ),
          ];
        },
      ),
    );

    
    try {
      // Generate PDF bytes in memory
      final List<int> pdfBytes = await pdf.save();

      // Create XFile from data (NO path_provider needed!)
      final xFile = XFile.fromData(
        Uint8List.fromList(pdfBytes),
        name: '${gymName.replaceAll(' ', '_')}_Attendance_$monthLabel.pdf',
        mimeType: 'application/pdf',
      );

      // Share (On Web: triggers browser download. On Mobile: share sheet)
      await Share.shareXFiles(
        [xFile],
        subject: 'Attendance Report - $monthLabel - $gymName',
        text: 'Attendance Report for $monthLabel from $gymName',
      );
    } catch (e) {
      print("PDF Share error: $e");
      rethrow;
    }
  }

  // Need to import dart:typed_data for Uint8List
  // Add at top: import 'dart:typed_data';

  static pw.Widget _buildPdfStat(String label, String value) {
    return pw.Column(
      children: [
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue800,
          ),
        ),
        pw.SizedBox(height: 2),
        pw.Text(
          label,
          style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
        ),
      ],
    );
  }

  static List<List<String>> _buildTableData(
    List<MemberAttendanceModel> records,
    int year,
    int monthNum,
  ) {
    return records.asMap().entries.map((entry) {
      int index = entry.key;
      var r = entry.value;
      int absent = r.totalAbsent(year, monthNum);
      double pct = r.attendancePercentage(year, monthNum);
      return [
        '${index + 1}',
        r.memberName,
        r.memberEmail,
        '${r.totalPresent}',
        '$absent',
        '${pct.toStringAsFixed(1)}%',
      ];
    }).toList();
  }

  static double _calculateAvgPercentage(
    List<MemberAttendanceModel> records,
    int year,
    int monthNum,
  ) {
    if (records.isEmpty) return 0.0;
    double total = 0;
    for (var r in records) {
      total += r.attendancePercentage(year, monthNum);
    }
    return total / records.length;
  }
}
