import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/expense_model.dart';
import '../models/category_model.dart';

class PdfService {
  static Future<void> generateAndShareReport({
    required String title,
    required List<ExpenseModel> expenses,
    required List<CategoryModel> categories,
    required double totalIncome,
    required double totalSpent,
    required double netBalance,
  }) async {
    final pdf = pw.Document();

    // Sort expenses by date desc
    final sortedExpenses = [...expenses]
      ..sort((a, b) => b.date.compareTo(a.date));

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          _buildHeader(title),
          pw.SizedBox(height: 20),
          _buildSummary(totalIncome, totalSpent, netBalance),
          pw.SizedBox(height: 30),
          _buildTransactionTable(sortedExpenses, categories),
          pw.SizedBox(height: 20),
          _buildFooter(),
        ],
      ),
    );

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'Expense_Report_${title.replaceAll(' ', '_')}.pdf',
    );
  }

  static pw.Widget _buildHeader(String title) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'Expense Tracker',
              style: pw.TextStyle(
                fontSize: 24,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blue900,
              ),
            ),
            pw.Text(
              DateFormat('yyyy-MM-dd').format(DateTime.now()),
              style: const pw.TextStyle(color: PdfColors.grey700),
            ),
          ],
        ),
        pw.SizedBox(height: 10),
        pw.Text(
          'Financial Report',
          style: pw.TextStyle(fontSize: 18, color: PdfColors.grey800),
        ),
        pw.Text(
          title,
          style: pw.TextStyle(fontSize: 14, color: PdfColors.grey600),
        ),
        pw.Divider(thickness: 2, color: PdfColors.blue900),
      ],
    );
  }

  static pw.Widget _buildSummary(double income, double spent, double net) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem('Income', income, PdfColors.green800),
          _buildSummaryItem('Expense', spent, PdfColors.red800),
          _buildSummaryItem(
            'Net Balance',
            net,
            net >= 0 ? PdfColors.green900 : PdfColors.red900,
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildSummaryItem(
    String label,
    double amount,
    PdfColor color,
  ) {
    return pw.Column(
      children: [
        pw.Text(
          label,
          style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
        ),
        pw.SizedBox(height: 5),
        pw.Text(
          'ETB ${amount.toStringAsFixed(2)}',
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildTransactionTable(
    List<ExpenseModel> expenses,
    List<CategoryModel> categories,
  ) {
    final headers = ['Date', 'Category', 'Note', 'Amount'];

    final data = expenses.map((e) {
      final category = categories.firstWhere(
        (c) => c.id == e.categoryId,
        orElse: () => CategoryModel(id: '', name: 'Unknown', iconCode: 0),
      );
      return [
        DateFormat('MMM dd').format(e.date),
        category.name,
        e.note.isEmpty ? '-' : e.note,
        '${e.type == TransactionType.income ? '+' : '-'}ETB ${e.amount.toStringAsFixed(2)}',
      ];
    }).toList();

    return pw.TableHelper.fromTextArray(
      headers: headers,
      data: data,
      border: null,
      headerStyle: pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.white,
      ),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.blue900),
      cellHeight: 30,
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerLeft,
        2: pw.Alignment.centerLeft,
        3: pw.Alignment.centerRight,
      },
      cellStyle: const pw.TextStyle(fontSize: 10),
      rowDecoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.5),
        ),
      ),
    );
  }

  static pw.Widget _buildFooter() {
    return pw.Column(
      children: [
        pw.Divider(thickness: 1, color: PdfColors.grey300),
        pw.SizedBox(height: 10),
        pw.Text(
          'Generated by Expense Tracker Offline App',
          style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
        ),
      ],
    );
  }
}
