import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:frontend/global.dart';
import 'package:frontend/page/error-page.dart';
import 'package:frontend/page/loading-page.dart';
import 'package:frontend/page/login-page.dart';
import 'package:frontend/page/root-page.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tz;

void main() => runApp(App());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Workbench",
      home: buildBody(context),
    );
  }
  
  Widget buildBody(BuildContext context) {
    return FutureBuilder(
        future: plugin.initialize(const InitializationSettings(
            linux: LinuxInitializationSettings(
                defaultActionName: "Workbench Notification",
            )
        )),

        builder: (_, snapshot) {
          if (snapshot.hasError) {
            print(snapshot.stackTrace);
            return ErrorPage(error: snapshot.error);
          }

          if (!snapshot.hasData) {
            return LoadingPage();
          }

          tz.initializeTimeZones();

          return ValueListenableBuilder(
              valueListenable: loginIn,
              builder: (_, value, child) {
                if (value) {
                  return MultiProvider(
                    providers: [
                      ChangeNotifierProvider(create: (_) => clipboardState!),
                      ChangeNotifierProvider(create: (_) => todoListState!),
                      ChangeNotifierProvider(create: (_) => dailyAttendanceState!)
                    ],

                    child: RootPage(),
                  );
                } else {
                  return LoginPage();
                }
              }
          );

        }
    );
  }
}