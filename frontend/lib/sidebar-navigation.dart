import 'package:flutter/material.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
      title: "Sidebar Navigation",
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int index = 0;
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          NavigationRail(
            destinations: const [
              NavigationRailDestination(icon: Icon(Icons.add), label: Text("add")),
              NavigationRailDestination(icon: Icon(Icons.calendar_month), label: Text("calendar"))
            ],

            onDestinationSelected: (index) {
              setState(() {
                this.index = index;
              });
            },

            selectedIndex: index,
            useIndicator: true,
            backgroundColor: Colors.black.withOpacity(0.05),
          ),


          Expanded(child: buildMainContent(context))
        ],
      ),
    );
  }

  Widget buildMainContent(BuildContext context) {
    switch (index) {
      case 0:
        return const Center(child: Icon(Icons.add),);
      case 1:
        return const Center(child: Icon(Icons.calendar_month),);
      default:
        throw Exception("no such index");
    }
  }
}