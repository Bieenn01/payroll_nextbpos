import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_payroll_nextbpo/backend/dashboardFunc/sidebar/flutter_event.dart';
import 'package:project_payroll_nextbpo/backend/dashboardFunc/sidebar/flutter_state.dart';


class SidebarMenuBloc extends Bloc<SidebarMenuEvent, SidebarMenuState> {
  SidebarMenuBloc() : super(SidebarMenuInitial()) {
    on<FetchSidebarMenuEvent>((_, emit) async {
      try {
        emit(SidebarMenuSuccess(_.menu!));
      } catch (e) {
        emit(
          SidebarMenuError(e.toString()),
        );
      }
    });
  }
}
