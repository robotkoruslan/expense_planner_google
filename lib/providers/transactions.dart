import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import './transaction.dart';
import '../models/http_exception.dart';

class Transactions with ChangeNotifier {
  List<Transaction> userTransactions = [];

  final String authToken;
  final String userId;

  Transactions(this.authToken, this.userId, this.userTransactions);

  Future<void> fetchAndSetTransactions() async {
    final url =
        'https://expense-6e6c7-default-rtdb.firebaseio.com/transactions.json?auth=$authToken&orderBy="creatorId"&equalTo="$userId"';
    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData == null) {
        return;
      }
      final List<Transaction> loadedTransactions = [];
      extractedData.forEach((transId, transData) {
        loadedTransactions.add(Transaction(
          id: transId,
          title: transData['title'],
          amount: transData['amount'],
          date: DateTime.fromMillisecondsSinceEpoch(
            transData['date'],
          ),
        ));
      });
      userTransactions = loadedTransactions;
      notifyListeners();
    } catch (error) {
      throw (error);
    }
  }

  Future<void> addNewTransaction(
      String title, double amount, DateTime date) async {
    final url =
        'https://expense-6e6c7-default-rtdb.firebaseio.com/transactions.json?auth=$authToken';
    try {
      final response = await http.post(
        url,
        body: json.encode({
          'title': title,
          'amount': amount,
          'date': date.millisecondsSinceEpoch,
          'creatorId': userId,
        }),
      );
      final newTransaction = Transaction(
        title: title,
        amount: amount,
        date: date,
        id: json.decode(response.body)['name'],
      );
      userTransactions.add(newTransaction);
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> deleteTransaction(String id) async {
    final url =
        'https://expense-6e6c7-default-rtdb.firebaseio.com/transactions/$id.json?auth=$authToken';
    final existingTransactionIndex =
        userTransactions.indexWhere((trans) => trans.id == id);
    var existingTransaction = userTransactions[existingTransactionIndex];
    userTransactions.removeAt(existingTransactionIndex);
    notifyListeners();
    final response = await http.delete(url);

    if (response.statusCode >= 400) {
      userTransactions.insert(existingTransactionIndex, existingTransaction);
      notifyListeners();
      throw HttpException('Could not delete transaction.');
    }
    existingTransaction = null;
  }
}
