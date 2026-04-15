import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import '../Model/donation_model.dart';

class DonationReceiptPage extends StatelessWidget {
  final DonationModel donation;
  const DonationReceiptPage({super.key, required this.donation});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFC),
      appBar: AppBar(
        title: const Text(
          'Transaction Detail',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded),
            onPressed: _shareReceipt,
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        child: Column(
          children: [
            // 1. SUCCESS ANIMATION AREA
            const Icon(
              Icons.check_circle_rounded,
              color: Colors.green,
              size: 70,
            ),
            const SizedBox(height: 12),
            const Text(
              "Donation Successful",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Thank you for your generous contribution!",
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
            const SizedBox(height: 30),
            // 2. THE TICKET CARD
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Main Amount Header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.05),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(30),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          donation.title?.toUpperCase() ?? "GENERAL HELP",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                            fontSize: 11,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "₹${donation.amountInr?.toStringAsFixed(0)}",
                          style: const TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.w900,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          "≈ \$${donation.amountUsd?.toStringAsFixed(2)} USD",
                          style: const TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Receipt Body
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        _buildReceiptRow(
                          "Status",
                          donation.status!.toUpperCase(),
                          isStatus: true,
                        ),
                        _buildReceiptRow(
                          "Date",
                          donation.createdAt.toString().split(' ')[0],
                        ),
                        _buildReceiptRow(
                          "Transaction ID",
                          "TXN-${donation.paypalResponse?.payer?.payerInfo?.payerId?.substring(0, 8) ?? "7892341"}",
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 15),
                          child: Divider(thickness: 1, height: 1),
                        ),
                        _buildReceiptRow(
                          "Method",
                          donation.paypalResponse?.payer?.paymentMethod
                                  ?.toUpperCase() ??
                              "PAYPAL",
                        ),
                        _buildReceiptRow(
                          "Payer Name",
                          "${donation.paypalResponse?.payer?.payerInfo?.firstName ?? "Kind "} ${donation.paypalResponse?.payer?.payerInfo?.lastName ?? "Soul"} ",
                        ),
                        _buildReceiptRow(
                          "Payer Email",
                          donation.paypalResponse?.payer?.payerInfo?.email ??
                              "N/A",
                        ),
                      ],
                    ),
                  ),
                  _buildDottedBottom(),
                ],
              ),
            ),
            const SizedBox(height: 40),
            // 3. ACTION BUTTONS
            _buildDownloadButton(context),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value, {bool isStatus = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isStatus ? Colors.green : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDottedBottom() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: const Center(
        child: Column(
          children: [
            Text(
              "SECURELY PROCESSED",
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
                color: Colors.black26,
              ),
            ),
            SizedBox(height: 4),
            Icon(Icons.qr_code_2_rounded, color: Colors.black12, size: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildDownloadButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton.icon(
        onPressed: () {
          HapticFeedback.mediumImpact();
          _generateAndDownloadPdf(context);
        },
        icon: const Icon(Icons.file_download_outlined),
        label: const Text(
          "Download PDF Receipt",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
        ),
      ),
    );
  }

  Future<void> _generateAndDownloadPdf(BuildContext context) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                "OFFICIAL DONATION RECEIPT",
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Divider(),
              pw.SizedBox(height: 20),
              pw.Text("Cause: ${donation.title}"),
              pw.Text("Amount: INR ${donation.amountInr}"),
              pw.Text("Date: ${donation.createdAt}"),
              pw.Text(
                "Payer: ${donation.paypalResponse?.payer?.payerInfo?.firstName} ${donation.paypalResponse?.payer?.payerInfo?.lastName}",
              ),
              pw.Text(
                "Email: ${donation.paypalResponse?.payer?.payerInfo?.email}",
              ),
              pw.SizedBox(height: 40),
              pw.Text(
                "Thank you for your kindness!",
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ],
          );
        },
      ),
    );
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Donation_Receipt_${donation.title}.pdf',
    );
  }

  Future<void> _shareReceipt() async {
    HapticFeedback.mediumImpact();
    try {
      // 1. Generate the PDF bytes (reusing your existing PDF logic)
      final pdf = pw.Document();
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) => pw.Center(
            child: pw.Text(
              "Donation Receipt: ${donation.title}\nAmount: ₹${donation.amountInr}",
            ),
          ),
        ),
      );
      // 2. Save to temporary storage
      final output = await getTemporaryDirectory();
      final file = File("${output.path}/Receipt_${donation.title}.pdf");
      await file.writeAsBytes(await pdf.save());
      // 3. Share the file
      final result = await Share.shareXFiles([
        XFile(file.path),
      ], text: 'Check out my donation receipt for ${donation.title}! ❤️');

      if (result.status == ShareResultStatus.success) {
        debugPrint('Thank you for sharing!');
      }
    } catch (e) {
      debugPrint("Share error: $e");
    }
  }
}
