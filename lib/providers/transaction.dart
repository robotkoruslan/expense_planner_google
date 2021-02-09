import 'package:flutter/foundation.dart';

class Transaction with ChangeNotifier {
  final String id;
  final String title;
  final dynamic amount;
  final DateTime date;
  Transaction(
      {@required this.id,
      @required this.title,
      @required this.amount,
      @required this.date});
}
