import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'adaptive_button.dart';

class NewTransaction extends StatefulWidget {
  final Function addTx;

  NewTransaction(this.addTx);

  @override
  _NewTransactionState createState() => _NewTransactionState();
}

class _NewTransactionState extends State<NewTransaction> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  var _isLoading = false;

  void _submitData() {
    if (_amountController.text.isEmpty) {
      return;
    }
    final enteredTitle = _titleController.text;
    final enteredAmount = double.parse(_amountController.text);

    setState(() {
      _isLoading = true;
    });
    if (enteredTitle.isEmpty || enteredAmount <= 0) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    widget
        .addTx(
      enteredTitle,
      enteredAmount,
      _selectedDate,
    )
        .catchError((error) {
      return showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('An Error occurred!'),
          content: Text('Someting was wrong'),
          actions: <Widget>[
            TextButton(
              child: Text('Okey'),
              onPressed: () {
                Navigator.of(ctx).pop();
              },
            )
          ],
        ),
      );
    }).then((_) {
      setState(() {
        _isLoading = true;
      });
      Navigator.of(context).pop();
    });
  }

  void _presentDatePicker() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2021),
      lastDate: DateTime.now(),
    ).then((pickedDate) {
      if (pickedDate == null) {
        return;
      }
      setState(() {
        _selectedDate = pickedDate;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Center(
            child: CircularProgressIndicator(),
          )
        : SingleChildScrollView(
            child: Card(
              elevation: 5,
              child: Container(
                padding: EdgeInsets.only(
                  top: 10,
                  right: 10,
                  left: 10,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 10,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    TextField(
                      decoration: InputDecoration(labelText: 'Title'),
                      controller: _titleController,
                      onSubmitted: (_) => _submitData(),
                    ),
                    TextField(
                      decoration: InputDecoration(labelText: 'Amount'),
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      onSubmitted: (_) => _submitData(),
                    ),
                    Container(
                      height: 70,
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              _selectedDate == null
                                  ? 'No Date Chosen!'
                                  : 'Trasaction Date: ${DateFormat.yMd().format(_selectedDate)}',
                            ),
                          ),
                          AdaptiveTextButton('Choose Date', _presentDatePicker)
                        ],
                      ),
                    ),
                    ElevatedButton(
                      child: Text('Add Transaction'),
                      onPressed: _submitData,
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}
