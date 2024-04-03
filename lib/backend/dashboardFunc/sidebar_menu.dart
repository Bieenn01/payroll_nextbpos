import 'package:animated_tree_view/animated_tree_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:project_payroll_nextbpo/backend/dashboardFunc/sidebar/animated_tree_view.dart';
import 'package:project_payroll_nextbpo/backend/user_model.dart';
import 'package:project_payroll_nextbpo/backend/dashboardFunc/sidebar/flutter_bloc.dart';
import 'package:project_payroll_nextbpo/backend/dashboardFunc/sidebar/flutter_event.dart';
import 'package:project_payroll_nextbpo/backend/dashboardFunc/sidebar/flutter_state.dart';
import 'package:project_payroll_nextbpo/backend/dashboardFunc/sidebar/menu_navigation.dart';
import 'package:project_payroll_nextbpo/frontend/login.dart';
import 'package:shimmer/shimmer.dart' as ShimmerPackage;

class SidebarMenu extends StatefulWidget {
  @override
  _SidebarMenuState createState() => _SidebarMenuState();
  const SidebarMenu({Key? key}) : super(key: key);
}

class _SidebarMenuState extends State<SidebarMenu> {
  Map<String, bool> hoverStates = {};
  late Future<TreeNode> menuTreeFuture = getMenuTree();
  
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
                      color: Colors.white,
                      width: 200,
                      child: Column(
                        children: [
                          // Widget at the top side of the sidebar (preference).
                          Container(
                            color: Colors.white,
                            width: 200,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                top: 15,
                                left: 12,
                                right: 12,
                                bottom: 15,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Column(
                                    children: [
                                      Image.asset(
                                        'assets/images/nextbpologo-removebg.png', // Replace 'assets/logo.png' with the path to your image asset
                                        width:
                                            500, // Adjust the width of the image as needed
                                        height:
                                            80, // Adjust the height of the image as needed
                                      ),
                                      SizedBox(
                                          width:
                                              10), // Adjust the spacing between image and text as needed
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Divider(),
                          // Sidebar menu widget
                          Expanded(
                            child: Container(
                              color: Colors.white,
                              child: FutureBuilder<TreeNode>(
                                future: menuTreeFuture,
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return _buildShimmerLoading();
                                  } else if (snapshot.hasError) {
                                    return Center(
                                      child: Text(
                                        'Error: ${snapshot.error}',
                                        style: TextStyle(
                                          color: Colors.red,
                                        ),
                                      ),
                                    );
                                  } else {
                                    return TreeView.simple(
                                      tree: snapshot.data!,
                                      indentation: const Indentation(width: 0),
                                      expansionBehavior: ExpansionBehavior
                                          .collapseOthersAndSnapToTop,
                                      showRootNode: false,
                                      expansionIndicatorBuilder:
                                          (context, node) {
                                        return ChevronIndicator.rightDown(
                                          alignment: Alignment.centerLeft,
                                          tree: node,
                                          color: Colors.black,
                                          icon: Icons.arrow_right,
                                        );
                                      },
                                      onItemTap: (item) {
                                        if (item.key == 'Logout') {
                                          FirebaseAuth.instance.signOut();
                                          Navigator.of(context).pushReplacement(
                                            MaterialPageRoute(
                                              builder: (context) => Login(),
                                            ),
                                          );
                                        } else {
                                          BlocProvider.of<SidebarMenuBloc>(
                                                  context)
                                              .add(
                                            FetchSidebarMenuEvent(
                                                menu: item.key),
                                          );
                                        }
                                      },
                                      builder: (context, node) {
                                        final isSelected =
                                            state.menu == node.key;
                                        final isExpanded = node.isExpanded;
                                        bool isHovered =
                                            hoverStates[node.key] ?? false;
                                        return MouseRegion(
                                          onHover: (_) {
                                            setState(() {
                                              hoverStates[node.key] = true;
                                            });
                                          },
                                          onExit: (_) {
                                            setState(() {
                                              hoverStates[node.key] = false;
                                            });
                                          },
                                          cursor: SystemMouseCursors.click,
                                          child: Container(
                                            color: node.level >= 2 ||
                                                    isExpanded ||
                                                    isHovered
                                                ? const Color.fromARGB(
                                                    255, 154, 207, 205)
                                                : Colors.white,
                                            height: 42,
                                            width: 250,
                                            alignment: Alignment.center,
                                            child: Padding(
                                              padding: node.level >= 2
                                                  ? const EdgeInsets.only(
                                                      left: 27)
                                                  : const EdgeInsets.only(
                                                      left: 0),
                                              child: Container(
                                                width: 250,
                                                height: 45,
                                                alignment: Alignment.centerLeft,
                                                decoration: BoxDecoration(
                                                  color: isSelected || isHovered
                                                      ? node.isLeaf
                                                          ? const Color
                                                              .fromARGB(
                                                              255, 20, 161, 156)
                                                          : null
                                                      : null,
                                                  borderRadius:
                                                      const BorderRadius.only(
                                                    topLeft:
                                                        Radius.circular(50),
                                                    bottomLeft:
                                                        Radius.circular(50),
                                                  ),
                                                ),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 25),
                                                  child: node.level >= 2
                                                      ? Text(
                                                          node.key,
                                                          style:
                                                              const TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 15,
                                                          ),
                                                        )
                                                      : Row(
                                                          children: [
                                                            Icon(
                                                              node.data,
                                                              size: 20,
                                                              color:
                                                                  Colors.black,
                                                            ),
                                                            const SizedBox(
                                                                width: 6),
                                                            Text(
                                                              node.key == "/"
                                                                  ? "Menu"
                                                                  : node.key,
                                                              style:
                                                                  const TextStyle(
                                                                color: Colors
                                                                    .black,
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
                                    );
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    //menu
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
                return const SizedBox.expand();
              }
            },
          ),
        ),
      ),
    );
  }
}

Widget _buildShimmerLoading() {
  return SizedBox(
    width: 250, // Adjust the width to match the sidebar menu width
    child: ShimmerPackage.Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ListTile(
          //   leading: Container(
          //     width: 40,
          //     height: 40,
          //     decoration: BoxDecoration(
          //       shape: BoxShape.circle,
          //       color: Colors.white,
          //     ),
          //   ),
          //   title: Container(
          //     height: 16.0,
          //     width: 150.0,
          //     decoration: BoxDecoration(
          //       color: Colors.white,
          //       borderRadius: BorderRadius.circular(8.0),
          //     ),
          //   ),
          // ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Divider(
              color: Colors.grey[400],
              thickness: 0.5,
            ),
          ),
          ListTile(
            leading: Icon(
              Icons.dashboard,
              color: Colors.white,
            ),
            title: Container(
              height: 16.0,
              width: 150.0,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
          ),
          ListTile(
            leading: Icon(
              Icons.calendar_today,
              color: Colors.white,
            ),
            title: Container(
              height: 16.0,
              width: 150.0,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
          ),
          ListTile(
            leading: Icon(
              Icons.access_time_filled_outlined,
              color: Colors.white,
            ),
            title: Container(
              height: 16.0,
              width: 150.0,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
          ),
          ListTile(
            leading: Icon(
              Icons.calendar_month_outlined,
              color: Colors.white,
            ),
            title: Container(
              height: 16.0,
              width: 150.0,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
          ),
          // Add more list tiles as needed
        ],
      ),
    ),
  );
}

