import 'package:flutter/material.dart';
import '../providers/transaction.dart';
import './transaction_item.dart';

class TransactionList extends StatelessWidget {
  final List<Transaction> transactions;
  final Function deleteTx;
  final bool _isLoading;

  TransactionList(this.transactions, this.deleteTx, this._isLoading);

  @override
  Widget build(BuildContext context) {
    return (_isLoading)
        ? Center(
            child: CircularProgressIndicator(),
          )
        : transactions.isEmpty
            ? LayoutBuilder(builder: (ctx, constraints) {
                return Column(
                  children: <Widget>[
                    Text(
                      'No transactions added yet!',
                      style: Theme.of(context).textTheme.headline6,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                        height: constraints.maxHeight * 0.6,
                        child: Image.asset(
                          'assets/images/waiting.png',
                          fit: BoxFit.cover,
                        )),
                  ],
                );
              })
            : ListView.builder(
                itemBuilder: (ctx, index) {
                  return TransactionItem(
                      transaction: transactions[index], deleteTx: deleteTx);
                },
                itemCount: transactions.length,
              );
  }
}
