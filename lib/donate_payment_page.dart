import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_paypal_payment/flutter_paypal_payment.dart';
import 'package:ngo_project/Home_Page.dart';
import 'package:ngo_project/Model/Donation_Item.dart';
import 'package:ngo_project/service/donation_service.dart';

class DonatePaymentPage extends StatefulWidget {
  final DonationItem item;

  const DonatePaymentPage({super.key, required this.item});

  @override
  State<DonatePaymentPage> createState() => _DonatePaymentPageState();
}

class _DonatePaymentPageState extends State<DonatePaymentPage> {
  late double currentAmount;
  late TextEditingController amountController;

  final DonationService _donationService = DonationService();

  /// INR → USD conversion
  final double inrToUsdRate = 83.0;

  @override
  void initState() {
    super.initState();
    currentAmount =
        double.tryParse(widget.item.amount.replaceAll(RegExp(r'[^0-9]'), '')) ??
        500;

    amountController = TextEditingController(
      text: currentAmount.toStringAsFixed(0),
    );
  }

  // void _increaseAmount() {
  //   setState(() {
  //     currentAmount += 100;
  //     amountController.text = currentAmount.toStringAsFixed(0);
  //   });
  // }

  void _updateAmount(double value) {
    setState(() {
      currentAmount = value;
      amountController.text = currentAmount.toStringAsFixed(0);
    });
  }

  // void _decreaseAmount() {
  //   if (currentAmount > 500) {
  //     setState(() {
  //       currentAmount -= 100;
  //       amountController.text = currentAmount.toStringAsFixed(0);
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final double usdAmount = currentAmount / inrToUsdRate;
    final String usdAmountStr = usdAmount.toStringAsFixed(2);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "Support Our Cause",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.green,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          // crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.volunteer_activism, size: 80, color: Colors.green),
            const SizedBox(height: 16),
            Text(
              widget.item.title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            const Text(
              "Every contribution helps us reach our goal.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 30),

            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    "Enter Donation Amount",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.blueGrey,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _roundIconButton(Icons.remove, () {
                        if (currentAmount > 500)
                          _updateAmount(currentAmount - 100);
                      }),
                      const SizedBox(width: 20),
                      SizedBox(
                        width: 120,
                        child: TextField(
                          controller: amountController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                          decoration: const InputDecoration(
                            prefixText: "₹",
                            border: InputBorder.none,
                          ),
                          onChanged: (value) =>
                              currentAmount = double.tryParse(value) ?? 0,
                        ),
                      ),
                      const SizedBox(width: 20),
                      _roundIconButton(
                        Icons.add,
                        () => _updateAmount(currentAmount + 100),
                      ),
                    ],
                  ),
                  const SizedBox(width: 20),
                  Wrap(
                    spacing: 10,
                    children: [500, 1000, 2000, 5000].map((amt) {
                      return ChoiceChip(
                        label: Text("₹$amt"),
                        selected: currentAmount == amt.toDouble(),
                        onSelected: (selected) => _updateAmount(amt.toDouble()),
                        selectedColor: Colors.green.withValues(alpha: 0.2),
                        labelStyle: TextStyle(
                          color: currentAmount == amt
                              ? Colors.green
                              : Colors.black,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
            Text(
              "Approx. \$${usdAmountStr} USD",
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 30),

            const SizedBox(height: 30),
            Text(
              "You will pay approximately \$${usdAmountStr} USD",
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PaypalCheckoutView(
                      sandboxMode: true,
                      clientId:
                          "AfNqDrrMIjJ63CgwNRxfMMTFO5dzHjgx0cJpT0s8Dd6u-cEDUsCei02z6h3IvBMZj5VUIznxQKhWIdUI",
                      secretKey:
                          "ELQQOSBUlmGggDxHyL_EYNaOs_couBwAXYiodnYYUwTauvG0qZZMLoaWnvDu0HPS1DnQtEj9z7tkEYw_",
                      transactions: [
                        {
                          "amount": {
                            "total": usdAmountStr,
                            "currency": "USD",
                            "details": {
                              "subtotal": usdAmountStr,
                              "shipping": "0",
                              "shipping_discount": 0,
                            },
                          },
                          "description": "Donation for ${widget.item.title}",
                          "item_list": {
                            "items": [
                              {
                                "name": widget.item.title,
                                "quantity": 1,
                                "price": usdAmountStr,
                                "currency": "USD",
                              },
                            ],
                          },
                        },
                      ],
                      note: "Thank you for your donation",
                      onSuccess: (Map params) async {
                        log("PAYMENT SUCCESS: $params");

                        await _donationService.saveDonation(
                          title: widget.item.title,
                          amountInr: currentAmount,
                          amountUsd: usdAmount,
                          paypalResponse: params,
                        );

                        if (!mounted) return;

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Donation Successful ❤️"),
                          ),
                        );

                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => HomePage()),
                          (route) => false,
                        );
                      },
                      onError: (error) {
                        log("PAYMENT ERROR: $error");
                        Navigator.pop(context);
                      },
                      onCancel: () {
                        log("PAYMENT CANCELLED");
                        Navigator.pop(context);
                      },
                    ),
                  ),
                );
              },
              child: const Text("Proceed to Pay"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _roundIconButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Icon(icon, color: Colors.green),
      ),
    );
  }
}
