import 'package:shelly_pdu/pages/actions_page.dart';
import 'package:shelly_pdu/pages/dashboard_page.dart';
import 'package:shelly_pdu/pages/device_list_page.dart';
import 'package:shelly_pdu/pages/device_page.dart';
import 'package:shelly_pdu/pages/statistics_page.dart';
import 'package:shelly_pdu/pages/switch_list_page.dart';
import 'package:shelly_pdu/pages/switch_page.dart';
import 'package:shelly_pdu/util/navigation.dart';
import 'package:flutter/material.dart';
import 'package:shelly_pdu/util/theme.dart';
import 'package:url_strategy/url_strategy.dart';
import 'package:flutter/services.dart';

ThemeData themeData = getSystemTheme();

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
      overlays: [SystemUiOverlay.bottom]);

  setPathUrlStrategy();

  runApp(const ShellyPDUApp());
}

class ShellyPDUApp extends StatefulWidget {
  const ShellyPDUApp({super.key});

  @override
  ShellyPDUAppState createState() => ShellyPDUAppState();

  static ShellyPDUAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<ShellyPDUAppState>();
}

class ShellyPDUAppState extends State<ShellyPDUApp> {
  ThemeData theme = getSystemTheme();

  // changes the widget state when updating the theme through changing the theme variable to the given theme.
  updateTheme(ThemeData theme) {
    setState(() {
      this.theme = theme;
    });
    themeData = theme;
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Shelly PDU",
      debugShowCheckedModeBanner: false,
      theme: theme,
      home: const DashboardPage(),
      onGenerateRoute: _generateRoute,
    );
  }

  Route<dynamic> _generateRoute(RouteSettings settings) {
    var uri = Uri.parse(settings.name!);

    // Handle '/switch/[sid]' route
    if (uri.pathSegments.length == 2 && uri.pathSegments.first == 'switch') {
      var sid = uri.pathSegments[1];
      navIndex[0] = 1;
      return createRoute(
        SwitchPage(sid: sid),
        routeSettings: settings,
      );
    }
    // Handle '/device/[did]' route
    else if (uri.pathSegments.length == 2 &&
        uri.pathSegments.first == 'device') {
      var did = uri.pathSegments[1];
      navIndex[0] = 2;
      return createRoute(
        DevicePage(did: did),
        routeSettings: settings,
      );
    }

    // Handle all other routes, as well as root and default route
    switch (settings.name) {
      case '/':
        navIndex[0] = 0;
        return createRoute(const DashboardPage(), routeSettings: settings);
      case '/switches':
        navIndex[0] = 1;
        return createRoute(const SwitchListPage(), routeSettings: settings);
      case '/devices':
        navIndex[0] = 2;
        return createRoute(const DeviceListPage(), routeSettings: settings);
      case '/statistics':
        navIndex[0] = 3;
        return createRoute(const StatisticsPage(), routeSettings: settings);
      case '/actions':
        navIndex[0] = 4;
        return createRoute(const ActionsPage(), routeSettings: settings);
      default:
        navIndex[0] = 0;
        return createRoute(const DashboardPage(), routeSettings: settings);
    }
  }
}
