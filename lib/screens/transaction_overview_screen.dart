import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transactions.dart';
import '../providers/transaction.dart';
import '../providers/auth.dart';
import '../widgets/transaction_list.dart';
import '../widgets/new_transaction.dart';
import '../widgets/chart.dart';

class TransactionsOverviewScreen extends StatefulWidget {
  @override
  _TransactionsOverviewScreen createState() => _TransactionsOverviewScreen();
}

class _TransactionsOverviewScreen extends State<TransactionsOverviewScreen> {
  var _isInit = true;
  var _isLoading = false;
  bool _showChart = false;
  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      Provider.of<Transactions>(context).fetchAndSetTransactions().then((_) {
        setState(() {
          _isLoading = false;
        });
      });
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  void _startAddNewTransaction(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      builder: (_) {
        return GestureDetector(
          onTap: () {},
          child: NewTransaction(
              Provider.of<Transactions>(context).addNewTransaction),
          behavior: HitTestBehavior.opaque,
        );
      },
    );
  }

  List<Widget> _buildLandscapeContent(
    MediaQueryData mediaQuery,
    AppBar appBar,
    Widget txListWidget,
  ) {
    return [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text('Show Chart', style: Theme.of(context).textTheme.headline6),
          Switch.adaptive(
            activeColor: Theme.of(context).accentColor,
            value: _showChart,
            onChanged: (val) {
              setState(() {
                _showChart = val;
              });
            },
          ),
        ],
      ),
      _showChart
          ? Container(
              height: (mediaQuery.size.height -
                      appBar.preferredSize.height -
                      mediaQuery.padding.top) *
                  0.7,
              child: Chart(_recentTransactions),
            )
          : txListWidget,
    ];
  }

  List<Widget> _buildPortraitContent(
    MediaQueryData mediaQuery,
    AppBar appBar,
    Widget txListWidget,
  ) {
    return [
      Container(
        height: (mediaQuery.size.height -
                appBar.preferredSize.height -
                mediaQuery.padding.top) *
            0.3,
        child: Chart(_recentTransactions),
      ),
      txListWidget
    ];
  }

  Future<void> _refreshTransactions(BuildContext context) async {
    await Provider.of<Transactions>(context, listen: false)
        .fetchAndSetTransactions()
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
    });
  }

  List<Transaction> get _recentTransactions {
    return Provider.of<Transactions>(context).userTransactions.where((tx) {
      return tx.date.isAfter(
        DateTime.now().subtract(
          Duration(days: 7),
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    final isLandscape = mediaQuery.orientation == Orientation.landscape;

    final PreferredSizeWidget appBar = AppBar(
      title: Text(
        'Personal Expenses',
      ),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.add),
          onPressed: () => _startAddNewTransaction(context),
        ),
        IconButton(
          icon: Icon(Icons.exit_to_app),
          onPressed: () {
            Provider.of<Auth>(context, listen: false).logout();
          },
        ),
      ],
    );
    final txListWidget = Container(
      height: (mediaQuery.size.height -
              appBar.preferredSize.height -
              mediaQuery.padding.top) *
          0.7,
      child: (TransactionList(
          Provider.of<Transactions>(context).userTransactions,
          Provider.of<Transactions>(context).deleteTransaction,
          _isLoading)),
    );
    final pageBody = SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (isLandscape)
              ..._buildLandscapeContent(
                mediaQuery,
                appBar,
                txListWidget,
              ),
            if (!isLandscape)
              ..._buildPortraitContent(
                mediaQuery,
                appBar,
                txListWidget,
              ),
          ],
        ),
      ),
    );
    return Scaffold(
      appBar: appBar,
      body: RefreshIndicator(
          onRefresh: () => _refreshTransactions(context),
          child: Padding(
            padding: EdgeInsets.all(2),
            child: pageBody,
          )),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _startAddNewTransaction(context),
      ),
    );
  }
}
