import 'package:flutter/material.dart';
import 'dart:ui';
import '../models/household_model.dart';
import '../models/weekly_schedule_model.dart';
import '../services/task_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';
import 'tabs/admin_screen.dart';
import '../screens/tabs/task_management_tab.dart';
import '../models/notification_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:uuid/uuid.dart';
import 'package:vnlunar/vnlunar.dart';
import '../models/calendar_event_model.dart';
import '../services/calendar_service.dart';
import '../services/notification_service.dart';
import '../models/swap_request_model.dart';

class DashboardScreen extends StatefulWidget {
  final String familyId;
  final Member currentUser;

  const DashboardScreen({
    Key? key,
    required this.familyId,
    required this.currentUser,
  }) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final TaskService _taskService = TaskService();
  final CalendarService _calendarService = CalendarService();
  WeeklySchedule? _schedule;
  bool _isLoading = true;

  // Calendar State
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<CalendarEvent>> _events = {};
  List<CalendarEvent> _selectedEvents = [];
  Map<String, SwapRequest> _sentRequests = {}; // taskId -> Request

  @override
  void initState() {
    super.initState();
    _loadData();
    _selectedDay = _focusedDay;
    _loadCalendarEvents();
    _listenToSentRequests();
  }

  void _listenToSentRequests() {
    _taskService
        .getSentSwapRequestsStream(widget.familyId, widget.currentUser.name)
        .listen((requests) {
          if (mounted) {
            // Sort by createdAt ascending (oldest to newest)
            requests.sort((a, b) => a.createdAt.compareTo(b.createdAt));
            print("DEBUG: Received ${requests.length} sent requests");
            for (var r in requests) {
              print(
                "DEBUG: Request for taskId: ${r.taskId} - Status: ${r.status}",
              );
            }
            setState(() {
              _sentRequests.clear();
              for (var req in requests) {
                _sentRequests[req.taskId] = req;
              }
            });
          }
        });
  }

  // Load Calendar Events (keep existing Code)
  void _loadCalendarEvents() {
    _calendarService.getEventsStream(widget.familyId).listen((events) {
      // ... existing code ...
      if (mounted) {
        setState(() {
          _events = {};
          for (var event in events) {
            DateTime date = DateTime(
              event.date.year,
              event.date.month,
              event.date.day,
            );
            if (_events[date] == null) _events[date] = [];
            _events[date]!.add(event);
          }
          _selectedEvents = _getEventsForDay(_selectedDay!);
        });
      }
    });
  }

  List<CalendarEvent> _getEventsForDay(DateTime day) {
    DateTime date = DateTime(day.year, day.month, day.day);
    return _events[date] ?? [];
  }

  // Tải dữ liệu
  void _loadData() async {
    setState(() => _isLoading = true);
    WeeklySchedule data = await _taskService.getOrGenerateWeeklySchedule(
      widget.familyId,
    );
    setState(() {
      _schedule = data;
      _isLoading = false;
    });
  }

  // Xử lý khi tick vào checkbox
  void _onToggleTask(int index) async {
    if (_schedule == null) return;

    // Gọi service update DB
    await _taskService.toggleTaskStatus(
      widget.familyId,
      _schedule!.weekId,
      _schedule!.assignments,
      index,
    );

    // Reload lại data để cập nhật UI
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Light background
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.teal))
          : Column(
              children: [
                _buildHeader(), // Custom Header replacement for AppBar
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async => _loadData(),
                    color: Colors.teal,
                    child: SingleChildScrollView(
                      physics: AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(height: 20),
                          _buildWeeklyHeader(),
                          SizedBox(height: 12),
                          _buildSwapRequests(), // Show pending requests
                          SizedBox(height: 12),
                          _buildPenaltyNoticeBoard(),
                          SizedBox(height: 10),

                          // PHẦN 1: VIỆC CỦA TÔI
                          Text(
                            "🎯 Việc cần làm",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueGrey[800],
                            ),
                          ),
                          SizedBox(height: 12),
                          _buildMyTaskList(),

                          SizedBox(height: 24),

                          // PHẦN 2: TÌNH TRẠNG CHUNG
                          Text(
                            "🏠 Tình trạng cả nhà",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueGrey[800],
                            ),
                          ),
                          SizedBox(height: 12),
                          _buildAllTasksList(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.fromLTRB(24, 60, 24, 30),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.teal.shade800, Colors.teal.shade400],
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.teal.withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Xin chào,",
                  style: TextStyle(color: Colors.teal.shade100, fontSize: 16),
                ),
                SizedBox(height: 4),
                Text(
                  widget.currentUser.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.home, color: Colors.teal.shade50, size: 14),
                      SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          "ID nhà: ${widget.familyId}",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.teal.shade50,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 16),
          Row(
            children: [
              // Admin Settings
              if (widget.currentUser.isAdmin)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: PopupMenuButton<String>(
                    icon: Icon(Icons.settings, color: Colors.white),
                    splashRadius: 24,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    onSelected: (String choice) {
                      if (choice == 'members') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                AdminScreen(familyId: widget.familyId),
                          ),
                        );
                      } else if (choice == 'tasks') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                TaskManagementScreen(familyId: widget.familyId),
                          ),
                        );
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'members',
                        child: Row(
                          children: [
                            Icon(Icons.people, color: Colors.blue),
                            SizedBox(width: 8),
                            Text("Thành viên"),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'tasks',
                        child: Row(
                          children: [
                            Icon(Icons.list_alt, color: Colors.green),
                            SizedBox(width: 8),
                            Text("Công việc"),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              SizedBox(width: 12),
              // Logout
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(Icons.logout, color: Colors.white),
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.clear();
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => LoginScreen()),
                      (route) => false,
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyHeader() {
    return GestureDetector(
      onTap: () => _openCalendar(context),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.teal.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.calendar_month, color: Colors.teal, size: 28),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Tuần ${_schedule?.weekId.split('_W')[1] ?? '...'}",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey[800],
                    ),
                  ),
                  Text(
                    "Xem lịch & Sự kiện",
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
              onPressed: () =>
                  _openCalendar(context), // Keep button functional too
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPenaltyNoticeBoard() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Households')
          .doc(widget.familyId)
          .collection('Notifications')
          .orderBy('created_at', descending: true) // Lấy cái mới nhất
          .limit(1)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return SizedBox.shrink(); // Không có phạt thì ẩn đi
        }

        var notice = PenaltyNotice.fromFirestore(snapshot.data!.docs.first);

        // Chỉ hiện nếu thông báo được tạo cách đây dưới 2 ngày (để không hiện mãi cái cũ)
        if (DateTime.now().difference(notice.createdAt).inDays > 2) {
          return SizedBox.shrink();
        }

        return Container(
          width: double.infinity,
          margin: EdgeInsets.only(bottom: 16),
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            border: Border.all(color: Colors.red),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.red),
                  SizedBox(width: 8),
                  Text(
                    "NHẮC NHỞ VI PHẠM",
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(notice.content, style: TextStyle(fontSize: 14)),
            ],
          ),
        );
      },
    );
  }

  // Widget hiển thị việc của tôi
  Widget _buildMyTaskList() {
    // Lọc ra việc của user hiện tại
    final myTasks =
        _schedule?.assignments
            .where((t) => t.assignedTo == widget.currentUser.name)
            .toList() ??
        [];

    if (myTasks.isEmpty) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 48,
              color: Colors.teal.withOpacity(0.5),
            ),
            SizedBox(height: 12),
            Text(
              "Bạn đã hoàn thành hết việc! 🎉",
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return Column(
      children: myTasks.map((task) {
        int originalIndex = _schedule!.assignments.indexOf(task);
        SwapRequest? request = _sentRequests[task.taskId];
        print(
          "DEBUG: Building task ${task.taskId} - Request Status: ${request?.status}",
        );

        // Determine UI based on request status
        Widget tailWidget;

        if (task.isDone) {
          tailWidget = SizedBox.shrink();
        } else if (request == null || request.status == 'rejected') {
          // No request or Rejected -> Show Swap Button
          tailWidget = IconButton(
            icon: Icon(Icons.swap_horiz, color: Colors.blue.shade300),
            tooltip: "Đổi việc này",
            onPressed: () => _showSwapDialog(task),
          );
        } else if (request.status == 'pending') {
          // Pending -> Show Cancel Button
          tailWidget = TextButton.icon(
            icon: Icon(Icons.close, size: 16, color: Colors.red),
            label: Text(
              "Hủy yêu cầu",
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
            onPressed: () async {
              await _taskService.cancelSwapRequest(widget.familyId, request.id);
            },
          );
        } else if (request.status == 'accepted') {
          // Accepted -> Show Text
          tailWidget = Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              "Đã được chấp nhận",
              style: TextStyle(
                fontSize: 12,
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        } else {
          tailWidget = SizedBox.shrink();
        }

        return Container(
          margin: EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // Checkbox
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Checkbox(
                    value: task.isDone,
                    activeColor: Colors.teal,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    onChanged: (val) => _onToggleTask(originalIndex),
                  ),
                ),
                SizedBox(width: 12),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.taskName,
                        style: TextStyle(
                          decoration: task.isDone
                              ? TextDecoration.lineThrough
                              : null,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: task.isDone ? Colors.grey : Colors.black87,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        task.isDone ? "Đã hoàn thành" : "Chưa hoàn thành",
                        style: TextStyle(
                          color: task.isDone ? Colors.green : Colors.orange,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                // Dynamic Tail Widget (Swap/Cancel/Status)
                tailWidget,
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // Widget hiển thị danh sách tất cả (Read-only)
  Widget _buildAllTasksList() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: _schedule?.assignments.length ?? 0,
        separatorBuilder: (ctx, i) =>
            Divider(height: 1, color: Colors.grey[100]),
        itemBuilder: (context, index) {
          final task = _schedule!.assignments[index];
          bool isMe = task.assignedTo == widget.currentUser.name;

          return ListTile(
            leading: CircleAvatar(
              backgroundColor: task.isDone
                  ? Colors.green.shade100
                  : Colors.grey.shade100,
              child: Icon(
                task.isDone ? Icons.check : Icons.work_outline,
                color: task.isDone ? Colors.green : Colors.grey,
                size: 20,
              ),
            ),
            title: Text(
              task.taskName,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.blueGrey[900],
              ),
            ),
            subtitle: Text(
              "Phụ trách: ${isMe ? 'Bạn' : task.assignedTo}",
              style: TextStyle(
                fontSize: 13,
                color: isMe ? Colors.teal : Colors.grey[600],
              ),
            ),
            trailing: isMe
                ? Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.teal.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "Tôi",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.teal,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : null,
          );
        },
      ),
    );
  }

  void _openCalendar(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                padding: EdgeInsets.all(16),
                height: MediaQuery.of(context).size.height * 0.85,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Lịch Vạn Niên",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.blueGrey.shade900,
                                fontFamily: 'serif',
                              ),
                            ),
                            Text(
                              "Năm ${_getVietnameseZodiac(_focusedDay.year)} ${_focusedDay.year}",
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: Icon(Icons.close, color: Colors.grey[800]),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    Divider(color: Colors.red.shade200),
                    // Calendar Content
                    TableCalendar<CalendarEvent>(
                      firstDay: DateTime.utc(2020, 10, 16),
                      lastDay: DateTime.utc(2030, 3, 14),
                      focusedDay: _focusedDay,
                      selectedDayPredicate: (day) =>
                          isSameDay(_selectedDay, day),
                      eventLoader: _getEventsForDay,
                      calendarFormat: CalendarFormat.month,
                      headerStyle: HeaderStyle(
                        formatButtonVisible: false,
                        titleCentered: true,
                        titleTextStyle: TextStyle(
                          color: Colors.red.shade900,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                        leftChevronIcon: Icon(
                          Icons.chevron_left,
                          color: Colors.red.shade700,
                        ),
                        rightChevronIcon: Icon(
                          Icons.chevron_right,
                          color: Colors.red.shade700,
                        ),
                      ),
                      calendarStyle: CalendarStyle(
                        todayDecoration: BoxDecoration(
                          color: Colors.orange.shade300,
                          shape: BoxShape.circle,
                        ),
                        selectedDecoration: BoxDecoration(
                          color: Colors.red.shade600,
                          shape: BoxShape.circle,
                        ),
                        markerDecoration: BoxDecoration(
                          color: Colors.teal,
                          shape: BoxShape.circle,
                        ),
                        outsideDaysVisible: false,
                      ),
                      onDaySelected: (selectedDay, focusedDay) {
                        setStateDialog(() {
                          _selectedDay = selectedDay;
                          _focusedDay = focusedDay;
                          _selectedEvents = _getEventsForDay(selectedDay);
                        });
                      },
                      onPageChanged: (focusedDay) {
                        setStateDialog(() {
                          _focusedDay = focusedDay;
                        });
                      },
                      calendarBuilders: CalendarBuilders(
                        markerBuilder: (context, date, events) {
                          if (events.isEmpty) return SizedBox();
                          return Positioned(
                            bottom: 1,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: events.take(3).map((event) {
                                return Container(
                                  margin: EdgeInsets.symmetric(horizontal: 1.5),
                                  width: 5,
                                  height: 5,
                                  decoration: BoxDecoration(
                                    color: event.hasReminder
                                        ? Colors.red
                                        : Colors.blue,
                                    shape: BoxShape.circle,
                                  ),
                                );
                              }).toList(),
                            ),
                          );
                        },
                        defaultBuilder: (context, day, focusedDay) =>
                            _buildCalendarCell(day),
                        selectedBuilder: (context, day, focusedDay) =>
                            _buildCalendarCell(day, isSelected: true),
                        todayBuilder: (context, day, focusedDay) =>
                            _buildCalendarCell(day, isToday: true),
                      ),
                    ),
                    Divider(),
                    Builder(
                      builder: (context) {
                        // Calculate holiday for selected day
                        final lunarSelected = Lunar(
                          date: _selectedDay!,
                          createdFromSolar: true,
                        );
                        String? solarHoliday = _getSolarHoliday(_selectedDay!);
                        String? lunarHoliday = _getLunarHoliday(lunarSelected);

                        // Combine them if both exist
                        List<String> holidays = [];
                        if (solarHoliday != null) holidays.add(solarHoliday);
                        if (lunarHoliday != null) holidays.add(lunarHoliday);

                        String? holiday = holidays.isNotEmpty
                            ? holidays.join(", ")
                            : null;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Sự kiện ngày ${_selectedDay!.day}/${_selectedDay!.month}",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.add_circle,
                                    color: Colors.blue,
                                  ),
                                  onPressed: () => _showAddEventDialog(
                                    context,
                                    setStateDialog,
                                  ),
                                ),
                              ],
                            ),
                            if (holiday != null)
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(8),
                                margin: EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.red.shade200,
                                  ),
                                ),
                                child: Text(
                                  "🎉 Hôm nay là: $holiday",
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                    Expanded(
                      child: _selectedEvents.isEmpty
                          ? Center(child: Text("Không có sự kiện"))
                          : ListView.builder(
                              itemCount: _selectedEvents.length,
                              itemBuilder: (context, index) {
                                final event = _selectedEvents[index];
                                return ListTile(
                                  dense: true,
                                  leading: Icon(
                                    Icons.event_note,
                                    color: event.hasReminder
                                        ? Colors.red
                                        : Colors.blue,
                                  ),
                                  title: Text(event.title),
                                  subtitle: Text(event.note),
                                  trailing: IconButton(
                                    icon: Icon(
                                      Icons.delete,
                                      size: 20,
                                      color: Colors.grey,
                                    ),
                                    onPressed: () async {
                                      await _calendarService.deleteEvent(
                                        widget.familyId,
                                        event.id,
                                      );
                                      // Update UI locally inside Dialog
                                      setStateDialog(() {
                                        _selectedEvents = _getEventsForDay(
                                          _selectedDay!,
                                        );
                                      });
                                    },
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Build Calendar Cell with Lunar Date
  Widget _buildCalendarCell(
    DateTime day, {
    bool isSelected = false,
    bool isToday = false,
  }) {
    // Convert to Lunar
    final lunarDate = Lunar(date: day, createdFromSolar: true);

    String? solarHoliday = _getSolarHoliday(day);
    String? lunarHoliday = _getLunarHoliday(lunarDate);

    BoxDecoration? decoration;
    TextStyle dayStyle = TextStyle(color: Colors.black);
    TextStyle lunarStyle = TextStyle(fontSize: 10, color: Colors.grey);
    TextStyle holidayStyle = TextStyle(
      fontSize: 9,
      color: Colors.red,
      fontWeight: FontWeight.bold,
    );

    if (isSelected) {
      decoration = BoxDecoration(color: Colors.blue, shape: BoxShape.circle);
      dayStyle = TextStyle(color: Colors.white, fontWeight: FontWeight.bold);
      lunarStyle = TextStyle(fontSize: 10, color: Colors.white70);
      holidayStyle = TextStyle(
        fontSize: 9,
        color: Colors.white,
        fontWeight: FontWeight.bold,
      );
    } else if (isToday) {
      decoration = BoxDecoration(
        color: Colors.blue.withOpacity(0.3),
        shape: BoxShape.circle,
      );
      dayStyle = TextStyle(color: Colors.blue, fontWeight: FontWeight.bold);
    }

    // Custom Highlighting for Holidays (Only if not selected)
    if (!isSelected) {
      if (solarHoliday != null) {
        dayStyle = TextStyle(color: Colors.red, fontWeight: FontWeight.bold);
      }
      if (lunarHoliday != null) {
        lunarStyle = TextStyle(
          fontSize: 10,
          color: Colors.red,
          fontWeight: FontWeight.bold,
        );
      }
    }

    return Container(
      margin: EdgeInsets.all(4.0),
      alignment: Alignment.center,
      decoration: decoration,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("${day.day}", style: dayStyle),
          Text("${lunarDate.day}/${lunarDate.month}", style: lunarStyle),
        ],
      ),
    );
  }

  String? _getSolarHoliday(DateTime solar) {
    if (solar.day == 1 && solar.month == 1) return "Tết Dương Lịch";
    if (solar.day == 3 && solar.month == 2)
      return "Ngày thành lập Đảng Cộng sản Việt Nam";
    if (solar.day == 14 && solar.month == 2) return "Ngày Valentine";
    if (solar.day == 27 && solar.month == 2) return "Ngày Thầy thuốc Việt Nam";
    if (solar.day == 8 && solar.month == 3) return "Ngày Quốc tế Phụ nữ";
    if (solar.day == 26 && solar.month == 3) return "Ngày thành lập Đoàn TNCS";
    if (solar.day == 30 && solar.month == 4) return "Ngày Giải phóng Miền Nam";
    if (solar.day == 1 && solar.month == 5) return "Ngày Quốc tế Lao động";
    if (solar.day == 7 && solar.month == 5)
      return "Ngày Chiến thắng Điện Biên Phủ";
    if (solar.day == 19 && solar.month == 5) return "Ngày Sinh nhật Bác Hồ";
    if (solar.day == 1 && solar.month == 6) return "Ngày Quốc tế Thiếu nhi";
    if (solar.day == 28 && solar.month == 6) return "Ngày Gia đình Việt Nam";
    if (solar.day == 27 && solar.month == 7) return "Ngày Thương binh Liệt sĩ";
    if (solar.day == 19 && solar.month == 8)
      return "Ngày Cách mạng Tháng Tám thành công";
    if (solar.day == 2 && solar.month == 9) return "Ngày Quốc Khánh";
    if (solar.day == 10 && solar.month == 10) return "Ngày Giải phóng Thủ đô";
    if (solar.day == 20 && solar.month == 10) return "Ngày Phụ nữ Việt Nam";
    if (solar.day == 20 && solar.month == 11) return "Ngày Nhà giáo Việt Nam";
    if (solar.day == 22 && solar.month == 12)
      return "Ngày thành lập Quân đội Nhân dân Việt Nam";
    return null;
  }

  String? _getLunarHoliday(Lunar lunar) {
    if (lunar.day == 1 && lunar.month == 1) return "Tết Nguyên Đán";
    if (lunar.day == 2 && lunar.month == 1) return "Tết Nguyên Đán";
    if (lunar.day == 3 && lunar.month == 1) return "Tết Nguyên Đán";
    if (lunar.day == 4 && lunar.month == 1) return "Tết Nguyên Đán";
    if (lunar.day == 5 && lunar.month == 1) return "Tết Nguyên Đán";
    if (lunar.day == 15 && lunar.month == 1) return "Tết Nguyên Tiêu";
    if (lunar.day == 3 && lunar.month == 3) return "Tết Hàn Thực";
    if (lunar.day == 10 && lunar.month == 3) return "Giỗ Tổ Hùng Vương";
    if (lunar.day == 15 && lunar.month == 4) return "Lễ Phật Đản";
    if (lunar.day == 5 && lunar.month == 5) return "Tết Đoan Ngọ";
    if (lunar.day == 15 && lunar.month == 7) return "Lễ Vu Lan";
    if (lunar.day == 15 && lunar.month == 8) return "Tết Trung Thu";
    if (lunar.day == 15 && lunar.month == 12) return "Rằm Tháng Chạp";
    if (lunar.day == 23 && lunar.month == 12) return "Ngày Ông Công Ông Táo";
    if ((lunar.day == 30 || lunar.day == 29) && lunar.month == 12)
      return "Đêm Giao Thừa";
    return null;
  }

  // Show Dialog to Add Event
  void _showAddEventDialog(BuildContext context, StateSetter setStateParent) {
    final TextEditingController _titleController = TextEditingController();
    final TextEditingController _noteController = TextEditingController();
    bool _setReminder = false;
    TimeOfDay _time = TimeOfDay(hour: 9, minute: 0);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("Thêm sự kiện"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _titleController,
                      decoration: InputDecoration(labelText: "Tiêu đề"),
                    ),
                    TextField(
                      controller: _noteController,
                      decoration: InputDecoration(labelText: "Ghi chú"),
                    ),
                    SwitchListTile(
                      title: Text("Bật nhắc nhở"),
                      value: _setReminder,
                      onChanged: (val) {
                        setState(() => _setReminder = val);
                      },
                    ),
                    if (_setReminder)
                      ListTile(
                        title: Text("Chọn giờ: ${_time.format(context)}"),
                        trailing: Icon(Icons.access_time),
                        onTap: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: _time,
                          );
                          if (picked != null) {
                            setState(() => _time = picked);
                          }
                        },
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Hủy"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_titleController.text.isEmpty) return;

                    final String id = Uuid().v4();
                    DateTime eventDate = DateTime(
                      _selectedDay!.year,
                      _selectedDay!.month,
                      _selectedDay!.day,
                    );

                    DateTime? reminderTime;
                    if (_setReminder) {
                      reminderTime = DateTime(
                        eventDate.year,
                        eventDate.month,
                        eventDate.day,
                        _time.hour,
                        _time.minute,
                      );
                    }

                    final newEvent = CalendarEvent(
                      id: id,
                      title: _titleController.text,
                      note: _noteController.text,
                      date: eventDate,
                      familyId: widget.familyId,
                      createdBy: widget.currentUser.name,
                      hasReminder: _setReminder,
                      reminderTime: reminderTime,
                    );

                    // Add to Firestore
                    await _calendarService.addEvent(newEvent);

                    // Schedule notification if reminder set
                    if (_setReminder && reminderTime != null) {
                      // Use hashcode of ID for notification ID (simple hack)
                      await NotificationService.scheduleEventReminder(
                        id.hashCode,
                        "Nhắc nhở: ${newEvent.title}",
                        newEvent.note,
                        reminderTime,
                      );
                    }

                    Navigator.pop(context); // Close Add Dialog

                    // Update Parent UI (Event List)
                    setStateParent(() {
                      // The stream listener will handle updating _events map,
                      // but we might want to manually refresh the list immediately for snappiness
                      // or just rely on stream.
                      // For now stream is async, so list might update a split second later.
                    });
                  },
                  child: Text("Lưu"),
                ),
              ],
            );
          },
        );
      },
    );
  }
  // --- SWAP REQUEST UI ---

  Widget _buildSwapRequests() {
    return StreamBuilder<List<SwapRequest>>(
      stream: _taskService.getSwapRequestsStream(
        widget.familyId,
        widget.currentUser.name,
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty)
          return SizedBox.shrink();

        return Container(
          padding: EdgeInsets.all(12),
          margin: EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.amber.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.amber.shade200),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(Icons.swap_horiz, color: Colors.amber.shade800),
                  SizedBox(width: 8),
                  Text(
                    "Yêu cầu đổi việc mới!",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.amber.shade900,
                    ),
                  ),
                ],
              ),
              ...snapshot.data!
                  .map(
                    (req) => Card(
                      elevation: 0,
                      color: Colors.white,
                      margin: EdgeInsets.only(top: 8),
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${req.fromUser} muốn đổi việc:",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[700],
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              req.taskName,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () => _taskService
                                      .respondToSwapRequest(req, false),
                                  child: Text(
                                    "Từ chối",
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                                SizedBox(width: 8),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.teal,
                                    foregroundColor: Colors.white,
                                  ),
                                  onPressed: () async {
                                    await _taskService.respondToSwapRequest(
                                      req,
                                      true,
                                    );
                                    // Reload data to show updated task list immediately
                                    _loadData();
                                  },
                                  child: Text("Đồng ý"),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ],
          ),
        );
      },
    );
  }

  void _showSwapDialog(TaskAssignment task) async {
    // Lấy danh sách thành viên (trừ bản thân)
    var householdDoc = await FirebaseFirestore.instance
        .collection('Households')
        .doc(widget.familyId)
        .get();
    var household = Household.fromFirestore(householdDoc.data()!);
    List<String> otherMembers = household.members
        .where((m) => m.name != widget.currentUser.name)
        .map((e) => e.name)
        .toList();

    if (otherMembers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Không có thành viên khác để đổi!")),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Đổi việc '${task.taskName}' cho ai?",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              ...otherMembers
                  .map(
                    (member) => ListTile(
                      leading: CircleAvatar(child: Text(member[0])),
                      title: Text(member),
                      trailing: Icon(Icons.send, color: Colors.teal),
                      onTap: () async {
                        Navigator.pop(ctx);
                        String id = Uuid().v4();
                        SwapRequest req = SwapRequest(
                          id: id,
                          familyId: widget.familyId,
                          weekId: _schedule!.weekId,
                          taskId: task.taskId,
                          taskName: task.taskName,
                          fromUser: widget.currentUser.name,
                          toUser: member,
                          status: 'pending',
                          createdAt: DateTime.now(),
                        );
                        await _taskService.sendSwapRequest(req);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Đã gửi yêu cầu đổi cho $member"),
                          ),
                        );
                      },
                    ),
                  )
                  .toList(),
            ],
          ),
        );
      },
    );
  }

  String _getVietnameseZodiac(int year) {
    List<String> zodiacs = [
      "Thân (Khỉ)",
      "Dậu (Gà)",
      "Tuất (Chó)",
      "Hợi (Lợn)",
      "Tý (Chuột)",
      "Sửu (Trâu)",
      "Dần (Hổ)",
      "Mão (Mèo)",
      "Thìn (Rồng)",
      "Tỵ (Rắn)",
      "Ngọ (Ngựa)",
      "Mùi (Dê)",
    ];
    return zodiacs[year % 12];
  }

  String _getZodiacImage(int year) {
    int index = year % 12;
    // Map index to English keywords for image search or specific URLs
    // 0: Monkey, 1: Rooster, 2: Dog, 3: Pig, 4: Rat, 5: Ox, 6: Tiger, 7: Cat, 8: Dragon, 9: Snake, 10: Horse, 11: Goat

    // Using high quality generic art style images (Placeholder)
    switch (index) {
      case 10: // Horse (2026)
        return 'https://static.vecteezy.com/system/resources/previews/065/384/128/non_2x/3d-red-podium-round-stage-for-happy-chinese-new-year-2026-horse-zodiac-vector.jpg'; // Placeholder adjusted to look festive
      case 8: // Dragon (2024)
        return 'https://img.freepik.com/premium-vector/vietnamese-new-year-dragon-decoration_23-2151110000.jpg'; // Example
      case 9: // Snake (2025)
        return 'https://thumbs.dreamstime.com/b/year-snake-chinese-zodiac-symbol-vector-illustration-163456789.jpg';
      default:
        // Fallback to a nice generic Lunar New Year background if specific animal not found
        return 'https://img.freepik.com/free-vector/flat-tet-background_23-2149233000.jpg';
    }
  }
}
