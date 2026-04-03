import 'package:artifact/Utilities/app_color.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../Provider_Data/dark_mode.dart';
import 'category_screen.dart';
import 'home_screen.dart';

class BottomBar extends StatefulWidget {
  // final User? user;
  const BottomBar({super.key});

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  @override
  Widget build(BuildContext context) {
    final themProvider = Provider.of<AppStateNotifier>(context);
    // final bottomBarProvider = Provider.of<BottomBarProvider>(context);
    // final List<Widget> views = [
    //   const HomeScreen(),
    //   const CategoryScreen()
    // ];
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        backgroundColor: themProvider.isDarkModeOn ? Color.fromRGBO(255, 255, 255, 0.2):Colors.white,
        activeColor: themProvider.isDarkModeOn ? Colors.white : Colors.white,
        inactiveColor: themProvider.isDarkModeOn ? Colors.white : Colors.black,
        iconSize: 25,
        items: <BottomNavigationBarItem>[
          _bottomNavigationBarItem(Icons.home, context),
          _bottomNavigationBarItem(Icons.window_rounded, context),
        ],
      ),

      tabBuilder: (context, index) {
        switch (index) {
          case 0:
            return CupertinoTabView(builder: (context) {
              return CupertinoPageScaffold(
                child:HomeScreen(),
              );
            });
          case 1:
            return CupertinoTabView(builder: (context) {
              return  CupertinoPageScaffold(
                  child:CategoryScreen()
              );
            });
          default:
            return CupertinoTabView(builder: (context) {
              return CupertinoPageScaffold(
                child:BottomBar(),
              );
            });
        }
      },
    );
  }
}

BottomNavigationBarItem _bottomNavigationBarItem(
    IconData icon, BuildContext context) {
  return BottomNavigationBarItem(
    activeIcon: Container(
      width: double.infinity,
      height: double.infinity,
      color: ColorX.pinkX,
      padding: const EdgeInsets.only(top: 6.0),
      child: Column(
        children: [
          Expanded(
            child: Icon(icon, color: Colors.black),
          ),
        ],
      ),
    ),
    icon: Padding(
      padding: const EdgeInsets.only(top: 6.0),
      child: Column(
        children: [
          Expanded(
            child: Icon(icon),
          ),
        ],
      ),
    ),
  );
}

