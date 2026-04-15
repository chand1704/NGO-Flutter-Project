class DonationItem {
  final String title;
  final String amount;
  DonationItem({required this.title, required this.amount});
  factory DonationItem.fromMap(Map<String, dynamic> map) {
    return DonationItem(title: map['title'] ?? '', amount: map['amount'] ?? '');
  }
}
