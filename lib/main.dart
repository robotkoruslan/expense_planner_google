import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './providers/auth.dart';

import './screens/splash_screen.dart';
import './providers/transactions.dart';
import './screens/transaction_overview_screen.dart';
import './screens/auth_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider.value(
            value: Auth(),
          ),
          ChangeNotifierProxyProvider<Auth, Transactions>(
            update: (ctx, auth, previousTransactions) => Transactions(
                auth.token,
                auth.userId,
                previousTransactions == null
                    ? []
                    : previousTransactions.userTransactions),
          )
        ],
        child: Consumer<Auth>(
          builder: (ctx, auth, _) => MaterialApp(
            title: 'Personal Expenses',
            theme: ThemeData(
                primarySwatch: Colors.green,
                errorColor: Colors.red,
                accentColor: Colors.green,
                fontFamily: 'Quicksand',
                textTheme: ThemeData.light().textTheme.copyWith(
                      headline6: TextStyle(
                        fontFamily: 'OpenSans',
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                      button: TextStyle(color: Colors.white),
                    ),
                appBarTheme: AppBarTheme(
                  color: Colors.green,
                  textTheme: ThemeData.light().textTheme.copyWith(
                        headline6: TextStyle(
                            fontFamily: 'OpenSans',
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                )),
            home: auth.isAuth
                ? TransactionsOverviewScreen()
                : FutureBuilder(
                    future: auth.tryAutoLogin(),
                    builder: (ctx, authResultSnapshot) =>
                        authResultSnapshot.connectionState ==
                                ConnectionState.waiting
                            ? SplashScreen()
                            : AuthScreen(),
                  ),
          ),
        ));
  }
}
