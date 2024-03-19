import 'package:shelly_pdu/main.dart';
import 'package:flutter/material.dart';
import 'package:shelly_pdu/util/theme.dart';

import 'package:package_info_plus/package_info_plus.dart';

List<int> navIndex = [0];

class PageDestination {
  const PageDestination(this.label, this.icon, this.destination);

  final String label;
  final IconData icon;
  final String destination;
}

Widget buildNavBarIcon(BuildContext context, IconData icon, Color color) {
  return Padding(
      padding: const EdgeInsets.all(5),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, size: 25, color: color),
      ]));
}

List<PageDestination> destinations = const <PageDestination>[
  PageDestination('Dashboard', Icons.dashboard_rounded, "dashboard"),
  PageDestination('Switches', Icons.power_settings_new_rounded, "switches"),
  PageDestination('Devices', Icons.computer_rounded, "devices"),
  PageDestination('Statistics', Icons.bar_chart_rounded, "statistics"),
  PageDestination('Actions', Icons.play_circle_rounded, "actions"),
];

bool isDesktop(BuildContext context) {
  final double width = MediaQuery.of(context).size.width;
  return width > 800;
}

AppBar appBar(BuildContext context, bool openDrawerOnIcon) {
  return AppBar(
    title: Text(
      "Shelly PDU",
      style: Theme.of(context)
          .textTheme
          .titleMedium!
          .copyWith(color: Colors.white),
    ),
    flexibleSpace: Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
      ),
      child: Padding(
          padding: const EdgeInsets.only(right: 10),
          child: Align(
              alignment: Alignment.centerRight,
              child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    useDarkTheme = !useDarkTheme;
                    ShellyPDUApp.of(context)!.updateTheme(getSystemTheme());
                  },
                  child: useDarkTheme
                      ? const Icon(Icons.wb_sunny_rounded, color: Colors.white)
                      : const Icon(Icons.nightlight_rounded,
                          color: Colors.white)))),
    ),
    leading: Builder(builder: (BuildContext context) {
      return IconButton(
        icon: SizedBox(
            height: 40, child: Image.asset('assets/images/shelly-icon.png')),
        onPressed:
            openDrawerOnIcon ? () => Scaffold.of(context).openDrawer() : null,
      );
    }),
    elevation: 0,
  );
}

Widget buildSidebarItem(
    BuildContext context, IconData icon, String text, String route) {
  return Material(
      type: MaterialType.transparency,
      child: ListTile(
        leading: Icon(icon),
        title: Text(text,
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                color: Theme.of(context).colorScheme.onSurface, fontSize: 16)),
        onTap: () {
          updatePageNavIndex(route);
          Navigator.pushNamed(context, "/$route");
        },
      ));
}

PageRouteBuilder createRoute(Widget widget, {RouteSettings? routeSettings}) {
  return PageRouteBuilder(
    settings: routeSettings,
    pageBuilder: (context, animation, secondaryAnimation) => widget,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return child; // No transition
    },
  );
}

updatePageNavIndex(String route) {
  if (route.contains("switch")) {
    navIndex.add(1);
  } else if (route.contains("device")) {
    navIndex.add(2);
  } else if (route.contains("statistics")) {
    navIndex.add(3);
  } else if (route.contains("actions")) {
    navIndex.add(4);
  }
}

class PageFrame extends StatefulWidget {
  final Widget body;

  const PageFrame({super.key, required this.body});

  @override
  State<PageFrame> createState() => PageFrameState();
}

class PageFrameState extends State<PageFrame> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  late bool enableDesktopLayout, enableExtendedRail;

  Widget buildMobileLayout() {
    return Scaffold(
      appBar: appBar(context, true),
      drawer: Drawer(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(20), bottomRight: Radius.circular(20)),
        ),
        child: Container(
            decoration: BoxDecoration(
                border: const Border(
                  right: BorderSide(width: 0.0, color: Colors.transparent),
                  left: BorderSide(width: 0.0, color: Colors.transparent),
                ),
                color: Theme.of(context).colorScheme.background),
            child: Container(
                padding: EdgeInsets.zero,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Wrap(children: [
                      SizedBox(
                        width: double.infinity,
                        child: DrawerHeader(
                            decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.secondary),
                            child: Container(
                                padding: const EdgeInsets.only(bottom: 20),
                                child: SizedBox(
                                    height: 30,
                                    child: Image.asset(
                                        'assets/images/shelly-icon.png')))),
                      ),
                      ...destinations.map((PageDestination destination) {
                        return buildSidebarItem(context, destination.icon,
                            destination.label, destination.destination);
                      }).toList()
                    ]),
                    getVersionLabel()
                  ],
                ))),
      ),
      body: widget.body,
    );
  }

  Future<String> getVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }

  Widget getVersionLabel() {
    return Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
            padding: const EdgeInsets.only(bottom: 15),
            child: FutureBuilder<String>(
                future: getVersion(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Text(
                        enableExtendedRail || !enableDesktopLayout
                            ? "Version ${snapshot.data}"
                            : "v${snapshot.data}",
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            color: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .color!
                                .withAlpha(100)));
                  }

                  return const SizedBox.shrink();
                })));
  }

  Widget buildDesktopLayout(BuildContext context) {
    return Scaffold(
      appBar: appBar(context, false),
      key: scaffoldKey,
      body: Row(
        children: <Widget>[
          Padding(
              padding: const EdgeInsets.only(left: 7),
              child: SizedBox(
                  width: enableExtendedRail ? 200 : 80,
                  child: OverflowBox(
                    maxWidth:
                        double.infinity, // intended to overflow vertically
                    child: NavigationRail(
                      backgroundColor: Colors.transparent,
                      extended: enableExtendedRail,
                      minWidth: 80,
                      minExtendedWidth: 200,
                      indicatorShape: const CircleBorder(),
                      labelType: NavigationRailLabelType.none,
                      unselectedLabelTextStyle:
                          Theme.of(context).textTheme.bodyLarge,
                      selectedLabelTextStyle:
                          Theme.of(context).textTheme.bodyLarge,
                      destinations: destinations.map(
                        (PageDestination destination) {
                          return NavigationRailDestination(
                            label: Text(destination.label,
                                style:
                                    Theme.of(context).textTheme.headlineSmall),
                            icon: buildNavBarIcon(context, destination.icon,
                                Theme.of(context).colorScheme.onBackground),
                            selectedIcon: buildNavBarIcon(
                                context,
                                destination.icon,
                                Theme.of(context).colorScheme.onPrimary),
                          );
                        },
                      ).toList(),
                      trailing: Expanded(child: getVersionLabel()),
                      selectedIndex: navIndex.last,
                      useIndicator: true,
                      indicatorColor: Theme.of(context).colorScheme.primary,
                      onDestinationSelected: (int index) {
                        PageDestination destination = destinations[index];
                        Navigator.pushNamed(
                                context, "/${destination.destination}")
                            .then((value) {
                          setState(() {
                            if (navIndex.length > 1) {
                              navIndex.removeLast();
                            }
                          });
                        });

                        setState(() {
                          navIndex.add(index);
                        });
                      },
                    ),
                  ))),
          const VerticalDivider(),
          Expanded(
              child: Center(
                  child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1000),
                      child: widget.body)))
        ],
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    enableDesktopLayout = MediaQuery.of(context).size.width >= 800;
    enableExtendedRail = MediaQuery.of(context).size.width >= 1300;
  }

  @override
  Widget build(BuildContext context) {
    return enableDesktopLayout
        ? buildDesktopLayout(context)
        : buildMobileLayout();
  }
}
