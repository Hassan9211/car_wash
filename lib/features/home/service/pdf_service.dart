import 'dart:io';
import 'package:car_wash/features/home/booking/model/booking_order_item.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfService {
  static Future<void> generateAndDownloadReceipt(BookingOrderItem order) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(40),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'levago',
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.green,
                      ),
                    ),
                    pw.Text(
                      'RECEIPT',
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.grey700,
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 10),
                pw.Divider(thickness: 1, color: PdfColors.grey300),
                pw.SizedBox(height: 30),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        _buildLabelValue('Order ID', order.id),
                        pw.SizedBox(height: 10),
                        _buildLabelValue('Date', _formatDate(order.paymentDate)),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        _buildLabelValue('Status', 'PAID'),
                        pw.SizedBox(height: 10),
                        _buildLabelValue('Amount', order.totalPayment),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 40),
                pw.Text(
                  'Service Details',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Divider(thickness: 1, color: PdfColors.grey300),
                pw.SizedBox(height: 10),
                _buildRowItem('Provider', order.serviceProviderName),
                _buildRowItem('Service Type', order.serviceType),
                _buildRowItem('Customer', order.customerName),
                _buildRowItem('Location', order.address),
                pw.SizedBox(height: 40),
                pw.Container(
                  padding: const pw.EdgeInsets.all(15),
                  decoration: const pw.BoxDecoration(
                    color: PdfColors.grey100,
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'Total Amount Paid',
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text(
                        order.totalPayment,
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.green900,
                        ),
                      ),
                    ],
                  ),
                ),
                pw.Spacer(),
                pw.Center(
                  child: pw.Text(
                    'Thank you for using levago!',
                    style: pw.TextStyle(
                      fontSize: 12,
                      color: PdfColors.grey500,
                      fontStyle: pw.FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    if (kIsWeb) {
      await Printing.sharePdf(
        bytes: await pdf.save(),
        filename: 'receipt_${order.id}.pdf',
      );
    } else {
      final bytes = await pdf.save();
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/receipt_${order.id}.pdf');
      await file.writeAsBytes(bytes);
      
      // Prompt user to open/share the file
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => bytes,
        name: 'receipt_${order.id}',
      );
    }
  }

  static pw.Widget _buildLabelValue(String label, String value) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          label.toUpperCase(),
          style: pw.TextStyle(fontSize: 10, color: PdfColors.grey500),
        ),
        pw.Text(
          value,
          style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
        ),
      ],
    );
  }

  static pw.Widget _buildRowItem(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 5),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: const pw.TextStyle(fontSize: 12)),
          pw.Text(value,
              style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
        ],
      ),
    );
  }

  static String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
