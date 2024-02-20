import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({Key? key}) : super(key: key);

  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late MeetingDataSource _dataSource;

  @override
  void initState() {
    _dataSource = MeetingDataSource(_getDataSource());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SfCalendar(
        view: CalendarView.month,
        dataSource: _dataSource,
        monthViewSettings: MonthViewSettings(
          appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
        ),
        onTap: (calendarTapDetails) {
          if (calendarTapDetails.targetElement ==
              CalendarElement.calendarCell) {
            _showAddAppointmentDialog(calendarTapDetails.date!);
          } else if (calendarTapDetails.targetElement ==
              CalendarElement.appointment) {
            final Meeting meeting =
                calendarTapDetails.appointments![0] as Meeting;
            _showEditAppointmentDialog(meeting);
          }
        },
      ),
    );
  }

  List<Meeting> _getDataSource() {
    final List<Meeting> meetings = <Meeting>[];

    return meetings;
  }

  void _showAddAppointmentDialog(DateTime selectedDate) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Appointment'),
          content: Text('Add your appointment details here.'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final newMeeting = Meeting(
                  'New Appointment',
                  selectedDate,
                  selectedDate.add(Duration(hours: 1)),
                  Colors.blue,
                  false,
                );
                _dataSource.addMeeting(newMeeting);
                Navigator.of(context).pop();
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _showEditAppointmentDialog(Meeting meeting) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Appointment'),
          content: Text('Edit your appointment details here.'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final updatedMeeting = Meeting(
                  'Updated Appointment',
                  meeting.from,
                  meeting.to,
                  Colors.green,
                  false,
                );
                _dataSource.updateMeeting(meeting, updatedMeeting);
                Navigator.of(context).pop();
              },
              child: Text('Update'),
            ),
            TextButton(
              onPressed: () {
                _dataSource.deleteMeeting(meeting);
                Navigator.of(context).pop();
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}

class MeetingDataSource extends CalendarDataSource {
  MeetingDataSource(List<Meeting> source) {
    appointments = source;
  }

  void addMeeting(Meeting meeting) {
    appointments!.add(meeting);
    notifyListeners(CalendarDataSourceAction.add, <Meeting>[meeting]);
  }

  void deleteMeeting(Meeting meeting) {
    appointments!.remove(meeting);
    notifyListeners(CalendarDataSourceAction.remove, <Meeting>[meeting]);
  }

  void updateMeeting(Meeting oldMeeting, Meeting newMeeting) {
    final index = appointments!.indexOf(oldMeeting);
    appointments![index] = newMeeting;
    notifyListeners(CalendarDataSourceAction.remove, <Meeting>[oldMeeting]);
    notifyListeners(CalendarDataSourceAction.add, <Meeting>[newMeeting]);
  }

  @override
  DateTime getStartTime(int index) {
    return appointments![index].from;
  }

  @override
  DateTime getEndTime(int index) {
    return appointments![index].to;
  }

  @override
  String getSubject(int index) {
    return appointments![index].eventName;
  }

  @override
  Color getColor(int index) {
    return appointments![index].background;
  }

  @override
  bool isAllDay(int index) {
    return appointments![index].isAllDay;
  }
}

class Meeting {
  Meeting(this.eventName, this.from, this.to, this.background, this.isAllDay);

  String eventName;
  DateTime from;
  DateTime to;
  Color background;
  bool isAllDay;
}
