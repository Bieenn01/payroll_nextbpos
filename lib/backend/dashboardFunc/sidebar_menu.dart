import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:animated_tree_view/animated_tree_view.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:project_payroll_nextbpo/backend/dashboardFunc/sidebar/animated_tree_view.dart';
import 'package:project_payroll_nextbpo/backend/dashboardFunc/sidebar/flutter_bloc.dart';
import 'package:project_payroll_nextbpo/backend/dashboardFunc/sidebar/flutter_event.dart';
import 'package:project_payroll_nextbpo/backend/dashboardFunc/sidebar/flutter_state.dart';
import 'package:project_payroll_nextbpo/backend/dashboardFunc/sidebar/menu_navigation.dart';
import 'package:project_payroll_nextbpo/frontend/login.dart';

class SidebarMenu extends StatefulWidget {
  @override
  _SidebarMenuState createState() => _SidebarMenuState();
  const SidebarMenu({Key? key}) : super(key: key);
}

class _SidebarMenuState extends State<SidebarMenu> {
  Map<String, bool> expansionState = {};
  late List<bool> _isExpandedList;

  void initState() {
    super.initState();
    _isExpandedList = List<bool>.filled(menuTree.length, true);
  }

  Widget build(BuildContext context) {
    return ScreenUtilInit(
      builder: (BuildContext context, Widget? child) => MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => SidebarMenuBloc()
              ..add(FetchSidebarMenuEvent(menu: "Dashboard")),
          ),
        ],
        child: Scaffold(
          backgroundColor: const Color(0xFFe2e1e4),
          body: BlocBuilder<SidebarMenuBloc, SidebarMenuState>(
            builder: (context, state) {
              if (state is SidebarMenuSuccess) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      color: Colors.white,
                      width: 200,
                      child: Column(
                        children: [
                          // Widget at the top side of the sidebar (preference).
                          Container(
                            color: Colors.white,
                            width: 200,
                            child: const Padding(
                              padding: EdgeInsets.only(
                                top: 15,
                                left: 12,
                                right: 12,
                                bottom: 15,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "NextBpoSolutions",
                                    style: TextStyle(
                                      color: Color.fromARGB(255, 4, 123, 109),
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Sidebar menu widget
                          Expanded(
                            child: Container(
                              color: Colors.white,
                              child: TreeView.simple(
                                tree: menuTree,
                                indentation: const Indentation(width: 0),
                                // All nodes are expanded initially
                                
                                expansionIndicatorBuilder: (context, node) {
                                  // Always show rightDown indicator as all nodes are expanded
                                  return ChevronIndicator.rightDown(
                                    alignment: Alignment.centerLeft,
                                    tree: node,
                                    color: Colors.black,
                                    icon: Icons.arrow_right,
                                  );
                                },
                                onItemTap: (item) {
                                  if (item.key == 'Logout') {
                                    FirebaseAuth.instance
                                        .signOut(); // Sign out the user
                                    Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(
                                          builder: (context) => Login()),
                                    ); // Navigate back to the login screen
                                  } else {
                                    BlocProvider.of<SidebarMenuBloc>(context)
                                        .add(FetchSidebarMenuEvent(
                                            menu: item.key));
                                  }
                                },
                                builder: (context, node) {
                                  final isSelected = state.menu == node.key;
                                  final isExpanded = node.isExpanded;
                                  return MouseRegion(
                                    cursor: SystemMouseCursors.click,
                                    child: Container(
                                      color: node.level >= 2 || isExpanded
                                          ? Color.fromARGB(255, 154, 207,
                                              205) // For coloring the background of child nodes
                                          : Colors.white,
                                      height:
                                          42, // Padding between one menu and another.
                                      width: 250,
                                      alignment: Alignment.center,
                                      child: Padding(
                                        padding: node.level >= 2
                                            ? const EdgeInsets.only(
                                                left:
                                                    27) // Padding for the children of the node
                                            : const EdgeInsets.only(left: 0),
                                        child: Container(
                                          width: 250,
                                          height:
                                              45, // The size dimension of the active button
                                          alignment: Alignment.centerLeft,
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? node.isLeaf
                                                    ? Color.fromARGB(
                                                        255,
                                                        20,
                                                        161,
                                                        156) // The color for the active node.
                                                    : null
                                                : null,
                                            borderRadius:
                                                const BorderRadius.only(
                                              topLeft: Radius.circular(
                                                50,
                                              ),
                                              bottomLeft: Radius.circular(
                                                50,
                                              ),
                                            ),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                              left: 25,
                                            ),
                                            child: node.level >= 2
                                                ? Text(
                                                    node.key,
                                                    style: const TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 15,
                                                    ),
                                                  )
                                                : Row(
                                                    children: [
                                                      Icon(
                                                        node.data,
                                                        size: 20,
                                                        color: Colors.black,
                                                      ),
                                                      const SizedBox(
                                                        width: 6,
                                                      ),
                                                      Text(
                                                        node.key == "/"
                                                            ? "Menu"
                                                            : node.key,
                                                        style: TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 18,
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    //menu
                    //Expanded(
                      //child: ScreensView(menu: state.menu),
                    //),
                  ],
                );
              } else if (state is SidebarMenuError) {
                return const Center(
                  child: Text(
                    "An error has occurred. Please try again later.",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                    ),
                  ),
                );
              } else {
                return const SizedBox.expand();
              }
            },
          ),
        ),
      ),
    );
  }
  
}
