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
import 'package:project_payroll_nextbpo/frontend/loginScreen.dart';


class SidebarMenu extends StatelessWidget {
  const SidebarMenu({Key? key}) : super(key: key);
  @override
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
                      color: const Color.fromARGB(255, 207, 188, 168),
                      width: 250,
                      child: Column(
                        children: [
                          // Widget at the top side of the sidebar (preference).
                          Container(
                            color: Color.fromARGB(255, 231, 183, 135),
                            width: 250,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                top: 15,
                                left: 12,
                                right: 12,
                                bottom: 15,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    "SidebarMenu",
                                    style: TextStyle(
                                      color: Colors.white,
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
                              color: Color.fromARGB(255, 207, 188, 168),
                              child: TreeView.simple(
                                tree: menuTree,
                                indentation: const Indentation(width: 0),
                                expansionIndicatorBuilder: (context, node) {
                                  return ChevronIndicator.rightDown(
                                    alignment: Alignment.centerLeft,
                                    tree: node,
                                    color: Colors.white,
                                    icon: Icons.arrow_right,
                                  );
                                },
                                onItemTap: (item) {
                                  if (item.key == 'Logout') {
                                    FirebaseAuth.instance
                                        .signOut(); // Sign out the user
                                    Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(
                                          builder: (context) => LoginScreen()),
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
                                          ? const Color(
                                              0xFF313136) // For coloring the background of child nodes
                                          : const Color.fromARGB(
                                              255, 207, 188, 168),
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
                                                    ? const Color(
                                                        0xFF2c45e8) // The color for the active node.
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
                                                      color: Colors.white,
                                                      fontSize: 14,
                                                    ),
                                                  )
                                                : Row(
                                                    children: [
                                                      Icon(
                                                        node.data,
                                                        size: 20,
                                                        color: Colors.white,
                                                      ),
                                                      const SizedBox(
                                                        width: 6,
                                                      ),
                                                      Text(
                                                        node.key,
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 14,
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
                    Expanded(
                      child: ScreensView(menu: state.menu),
                    ),
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
                return const SizedBox.shrink();
              }
            },
          ),
        ),
      ),
    );
  }
}
