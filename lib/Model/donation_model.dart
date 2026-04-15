import 'dart:convert';

DonationModel donationModelFromJson(String str) =>
    DonationModel.fromJson(json.decode(str));
String donationModelToJson(DonationModel data) => json.encode(data.toJson());

class DonationModel {
  final String title;
  final String status;
  final double amountInr;
  final double amountUsd;
  final String userId;
  final String userEmail;
  final DateTime createdAt;
  final PaypalResponse paypalResponse;
  DonationModel({
    required this.title,
    required this.status,
    required this.amountInr,
    required this.amountUsd,
    required this.userId,
    required this.userEmail,
    required this.createdAt,
    required this.paypalResponse,
  });
  factory DonationModel.fromJson(Map<String, dynamic> json) {
    return DonationModel(
      title: json['title'] ?? '',
      status: json['status'] ?? '',
      amountInr: (json['amount_inr'] ?? 0).toDouble(),
      amountUsd: (json['amount_usd'] ?? 0).toDouble(),
      userId: json['user_id'] ?? '',
      userEmail: json['user_email'] ?? '',
      createdAt: json['created_at'] is String
          ? DateTime.parse(json['created_at'])
          : json['created_at']?.toDate(),
      paypalResponse: PaypalResponse.fromJson(json['paypal_response'] ?? {}),
    );
  }
  Map<String, dynamic> toJson() => {
    'title': title,
    'status': status,
    'amount_inr': amountInr,
    'amount_usd': amountUsd,
    'user_id': userId,
    'user_email': userEmail,
    'created_at': createdAt.toIso8601String(),
    'paypal_response': paypalResponse.toJson(),
  };
}

/* -------------------------------------------------------------------------- */
/*                              PAYPAL RESPONSE                               */
/* -------------------------------------------------------------------------- */
class PaypalResponse {
  final String id;
  final String intent;
  final String state;
  final String cart;
  final DateTime? createTime;
  final DateTime? updateTime;
  final Payer payer;
  final List<Link> links;
  final List<dynamic> failedTransactions;
  PaypalResponse({
    required this.id,
    required this.intent,
    required this.state,
    required this.cart,
    required this.createTime,
    required this.updateTime,
    required this.payer,
    required this.links,
    required this.failedTransactions,
  });
  factory PaypalResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    return PaypalResponse(
      id: data['id'] ?? '',
      intent: data['intent'] ?? '',
      state: data['state'] ?? '',
      cart: data['cart'] ?? '',
      createTime: data['create_time'] == null
          ? null
          : DateTime.parse(data['create_time']),
      updateTime: data['update_time'] == null
          ? null
          : DateTime.parse(data['update_time']),
      payer: Payer.fromJson(data['payer'] ?? {}),
      links: (data['links'] as List? ?? [])
          .map((e) => Link.fromJson(e))
          .toList(),
      failedTransactions: data['failed_transactions'] ?? [],
    );
  }
  Map<String, dynamic> toJson() => {
    'id': id,
    'intent': intent,
    'state': state,
    'cart': cart,
    'create_time': createTime?.toIso8601String(),
    'update_time': updateTime?.toIso8601String(),
    'payer': payer.toJson(),
    'links': links.map((e) => e.toJson()).toList(),
    'failed_transactions': failedTransactions,
  };
}

/* -------------------------------------------------------------------------- */
/*                                   PAYER                                    */
/* -------------------------------------------------------------------------- */
class Payer {
  final String paymentMethod;
  final String status;
  final PayerInfo payerInfo;
  Payer({
    required this.paymentMethod,
    required this.status,
    required this.payerInfo,
  });
  factory Payer.fromJson(Map<String, dynamic> json) {
    return Payer(
      paymentMethod: json['payment_method'] ?? '',
      status: json['status'] ?? '',
      payerInfo: PayerInfo.fromJson(json['payer_info'] ?? {}),
    );
  }
  Map<String, dynamic> toJson() => {
    'payment_method': paymentMethod,
    'status': status,
    'payer_info': payerInfo.toJson(),
  };
}

/* -------------------------------------------------------------------------- */
/*                                PAYER INFO                                  */
/* -------------------------------------------------------------------------- */
class PayerInfo {
  final String payerId;
  final String firstName;
  final String lastName;
  final String email;
  final String countryCode;
  PayerInfo({
    required this.payerId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.countryCode,
  });
  factory PayerInfo.fromJson(Map<String, dynamic> json) {
    return PayerInfo(
      payerId: json['payer_id'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      email: json['email'] ?? '',
      countryCode: json['country_code'] ?? '',
    );
  }
  Map<String, dynamic> toJson() => {
    'payer_id': payerId,
    'first_name': firstName,
    'last_name': lastName,
    'email': email,
    'country_code': countryCode,
  };
}

/* -------------------------------------------------------------------------- */
/*                                   LINKS                                    */
/* -------------------------------------------------------------------------- */
class Link {
  final String rel;
  final String method;
  final String href;
  Link({required this.rel, required this.method, required this.href});
  factory Link.fromJson(Map<String, dynamic> json) {
    return Link(
      rel: json['rel'] ?? '',
      method: json['method'] ?? '',
      href: json['href'] ?? '',
    );
  }
  Map<String, dynamic> toJson() => {'rel': rel, 'method': method, 'href': href};
}
