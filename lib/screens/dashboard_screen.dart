import 'package:flutter/material.dart';
import '../helpers/zodiac_helper.dart';
import '../helpers/calendar_style_helper.dart';
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
            setState(() {
              _sentRequests.clear();
              for (var req in requests) {
                _sentRequests[req.taskId] = req;
              }
            });
          }
        });
  }

  // Load Calendar Events
  void _loadCalendarEvents() {
    _calendarService.getEventsStream(widget.familyId).listen((events) {
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
          // Refresh selected events if selected day exists
          if (_selectedDay != null) {
            _selectedEvents = _getEventsForDay(_selectedDay!);
          }
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
      backgroundColor: Colors.grey[50],
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.teal))
          : Column(
              children: [
                _buildHeader(),
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
                          _buildSwapRequests(),
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
              onPressed: () => _openCalendar(context),
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
          .orderBy('created_at', descending: true)
          .limit(1)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return SizedBox.shrink();
        }

        var notice = PenaltyNotice.fromFirestore(snapshot.data!.docs.first);

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
              Text(
                notice.content,
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMyTaskList() {
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

        Widget tailWidget;

        if (task.isDone) {
          tailWidget = SizedBox.shrink();
        } else if (request == null || request.status == 'rejected') {
          tailWidget = IconButton(
            icon: Icon(Icons.swap_horiz, color: Colors.blue.shade300),
            tooltip: "Đổi việc này",
            onPressed: () => _showSwapDialog(task),
          );
        } else if (request.status == 'pending') {
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
                tailWidget,
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

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
            final zodiacGradient = ZodiacHelper.getGradient(_focusedDay.year);
            final canChi = ZodiacHelper.getCanChi(_focusedDay.year);

            // 1. Check Tet Holiday (Lunar Logic)
            final lunarDate = Lunar(date: _focusedDay, createdFromSolar: true);
            final bool isTetHoliday = (lunarDate.month == 12 && lunarDate.day >= 29) || 
                                      (lunarDate.month == 1 && lunarDate.day <= 6);

            // 2. Check Special Holiday (Solar/Lunar Logic)
            final HolidayTheme? holidayTheme = ZodiacHelper.getSpecialHolidayTheme(
              _focusedDay, 
              lunarDay: lunarDate.day,
              lunarMonth: lunarDate.month,
            );

            // 3. Determine Active Theme Colors
            List<Color> activeGradient;
            Color activeColor;
            bool useRedTheme = false;

            if (holidayTheme != null) {
              activeGradient = holidayTheme.gradient;
              activeColor = activeGradient[0];
              useRedTheme = holidayTheme.isRedTheme;
            } else if (isTetHoliday) {
              activeGradient = CalendarStyleHelper.tetGradient;
              activeColor = CalendarStyleHelper.tetRed;
              useRedTheme = true;
            } else {
              activeGradient = [zodiacGradient[0], zodiacGradient[1]];
              activeColor = zodiacGradient[0];
              useRedTheme = false;
            }

            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              clipBehavior: Clip.hardEdge, 
              backgroundColor: Colors.transparent, 
              elevation: 0, 
              insetPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.9,
                decoration: CalendarStyleHelper.dialogDecoration.copyWith(
                  border: Border.all(
                    color: activeColor.withOpacity(0.5),
                    width: 2,
                  ),
                ),
                child: Stack(
                  children: [
                    // === 1. BACKGROUND LAYERS ===
                    Positioned.fill(
                      child: ZodiacHelper.buildZodiacBackground(
                        _focusedDay.year,
                        opacity: 0.08,
                        isTet: isTetHoliday, // Tet logic for background pattern
                        holidayTheme: holidayTheme, // Special holiday override
                      ),
                    ),
                    CalendarStyleHelper.buildCornerOrnament(true, zodiacGradient: (isTetHoliday || holidayTheme != null) ? activeGradient : null), 
                    CalendarStyleHelper.buildCornerOrnament(false, zodiacGradient: (isTetHoliday || holidayTheme != null) ? activeGradient : null),

                    // === 2. MAIN CONTENT ===
                    Column(
                      children: [
                        // --- HEADER SECTION ---
                        Container(
                          padding: EdgeInsets.fromLTRB(24, 20, 16, 12),
                          decoration: BoxDecoration(
                            border: Border(bottom: BorderSide(color: Colors.black12)),
                            color: useRedTheme 
                                ? activeColor.withOpacity(0.05) 
                                : Colors.white.withOpacity(0.85),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ShaderMask(
                                      shaderCallback: (bounds) => LinearGradient(
                                        colors: useRedTheme 
                                            ? activeGradient 
                                            : [zodiacGradient[0], zodiacGradient[1], zodiacGradient[0]],
                                        stops: useRedTheme ? [0.0, 1.0] : [0.0, 0.5, 1.0],
                                      ).createShader(bounds),
                                      child: Text(
                                        "Lịch Vạn Niên",
                                        style: CalendarStyleHelper.calendarTitleStyle(activeColor),
                                      ),
                                    ),
                                    SizedBox(height: 6),
                                    Row(
                                      children: [
                                        // Badge con giáp
                                        ZodiacHelper.buildZodiacBadge(_focusedDay.year),
                                        SizedBox(width: 8),
                                        // Badge tháng
                                        Container(
                                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: useRedTheme ? activeColor.withOpacity(0.3) : Colors.grey.shade400
                                            ),
                                            borderRadius: BorderRadius.circular(12),
                                            color: Colors.white,
                                          ),
                                          child: Text(
                                            "Tháng ${_focusedDay.month}",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: useRedTheme ? activeColor : Colors.grey.shade700,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              // Close Button
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () => Navigator.pop(context),
                                  borderRadius: BorderRadius.circular(20),
                                  child: Container(
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: useRedTheme ? Colors.white : Colors.grey.shade100, 
                                      shape: BoxShape.circle,
                                      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                                      border: useRedTheme ? Border.all(color: activeColor.withOpacity(0.2)) : null,
                                    ),
                                    child: Icon(
                                      Icons.close, 
                                      color: useRedTheme ? activeColor : Colors.grey[800], 
                                      size: 22
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // ─── SCROLLABLE BODY ───
                        Expanded(
                          child: SingleChildScrollView(
                            physics: BouncingScrollPhysics(),
                            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // ── CALENDAR GRID ──
                                TableCalendar<CalendarEvent>(
                                  firstDay: DateTime.utc(2020, 10, 16),
                                  lastDay: DateTime.utc(2030, 3, 14),
                                  focusedDay: _focusedDay,
                                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                                  eventLoader: _getEventsForDay,
                                  calendarFormat: CalendarFormat.month,
                                  availableGestures: AvailableGestures.horizontalSwipe,
                                  rowHeight: 64, // Tăng chiều cao ô ngày

                                  // Navigation Header
                                  headerStyle: HeaderStyle(
                                    formatButtonVisible: false,
                                    titleCentered: true,
                                    titleTextStyle: TextStyle(
                                      color: zodiacGradient[0],
                                      fontWeight: FontWeight.w900,
                                      fontSize: 18,
                                      fontFamily: 'serif',
                                      letterSpacing: 0.5,
                                    ),
                                    leftChevronIcon: Container(
                                      padding: EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: zodiacGradient[0].withOpacity(0.08),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(Icons.chevron_left, color: zodiacGradient[0], size: 22),
                                    ),
                                    rightChevronIcon: Container(
                                      padding: EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: zodiacGradient[0].withOpacity(0.08),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(Icons.chevron_right, color: zodiacGradient[0], size: 22),
                                    ),
                                    headerMargin: EdgeInsets.only(bottom: 8),
                                  ),

                                  // Day-of-week style
                                  daysOfWeekStyle: DaysOfWeekStyle(
                                    weekdayStyle: TextStyle(
                                      color: zodiacGradient[0].withOpacity(0.7),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                    ),
                                    weekendStyle: TextStyle(
                                      color: Color(0xFFE53935).withOpacity(0.7),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                    ),
                                  ),

                                  // Calendar Style (fallback — custom builders override most)
                                  calendarStyle: CalendarStyle(
                                    outsideDaysVisible: false,
                                    cellMargin: EdgeInsets.all(3),
                                    defaultTextStyle: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF263238)),
                                    weekendTextStyle: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFFD32F2F)),
                                    todayDecoration: BoxDecoration(),
                                    selectedDecoration: BoxDecoration(),
                                    markerDecoration: BoxDecoration(),
                                  ),

                                  // Handlers
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

                                  // Custom Builders
                                  calendarBuilders: CalendarBuilders(
                                    markerBuilder: (context, date, events) {
                                      // Markers handled inside cell builders
                                      return SizedBox();
                                    },
                                    defaultBuilder: (context, day, focusedDay) =>
                                        _buildCalendarCell(day, zodiacGradient: zodiacGradient),
                                    selectedBuilder: (context, day, focusedDay) =>
                                        _buildCalendarCell(day, isSelected: true, zodiacGradient: zodiacGradient),
                                    todayBuilder: (context, day, focusedDay) =>
                                        _buildCalendarCell(day, isToday: true, zodiacGradient: zodiacGradient),
                                    outsideBuilder: (context, day, focusedDay) => SizedBox(),
                                  ),
                                ),

                                // ── DECORATIVE DIVIDER ──
                                CalendarStyleHelper.buildDecorativeDivider(zodiacGradient),

                                // ── EVENT SECTION ──
                                Builder(
                                  builder: (context) {
                                    final lunarSelected = Lunar(date: _selectedDay!, createdFromSolar: true);
                                    String? solarHoliday = _getSolarHoliday(_selectedDay!);
                                    String? lunarHoliday = _getLunarHoliday(lunarSelected);
                                    List<String> holidays = [
                                      if (solarHoliday != null) solarHoliday,
                                      if (lunarHoliday != null) lunarHoliday,
                                    ];
                                    String? holiday = holidays.isNotEmpty ? holidays.join(", ") : null;

                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Event header
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "📅 Ngày ${_selectedDay!.day}/${_selectedDay!.month}/${_selectedDay!.year}",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                    color: Color(0xFF263238),
                                                  ),
                                                ),
                                                SizedBox(height: 2),
                                                Text(
                                                  "Âm lịch: ${lunarSelected.day}/${lunarSelected.month}",
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: CalendarStyleHelper.lunarTextColor,
                                                    fontStyle: FontStyle.italic,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Material(
                                              color: Colors.transparent,
                                              child: InkWell(
                                                onTap: () => _showAddEventDialog(context, setStateDialog),
                                                borderRadius: BorderRadius.circular(12),
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                                  decoration: BoxDecoration(
                                                    gradient: LinearGradient(colors: zodiacGradient),
                                                    borderRadius: BorderRadius.circular(12),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: zodiacGradient[0].withOpacity(0.3),
                                                        blurRadius: 6,
                                                        offset: Offset(0, 2),
                                                      ),
                                                    ],
                                                  ),
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Icon(Icons.add, color: Colors.white, size: 18),
                                                      SizedBox(width: 4),
                                                      Text("Thêm", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),

                                        SizedBox(height: 12),

                                        // Holiday banner
                                        if (holiday != null)
                                          Container(
                                            width: double.infinity,
                                            margin: EdgeInsets.only(bottom: 12),
                                            padding: EdgeInsets.all(14),
                                            decoration: CalendarStyleHelper.holidayBannerDecoration(zodiacGradient),
                                            child: Row(
                                              children: [
                                                Container(
                                                  padding: EdgeInsets.all(8),
                                                  decoration: BoxDecoration(
                                                    color: Color(0xFFE53935).withOpacity(0.1),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: Text("🏮", style: TextStyle(fontSize: 18)),
                                                ),
                                                SizedBox(width: 12),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        "Ngày lễ",
                                                        style: TextStyle(
                                                          fontSize: 11,
                                                          color: Colors.grey[600],
                                                          fontWeight: FontWeight.w600,
                                                        ),
                                                      ),
                                                      SizedBox(height: 2),
                                                      Text(
                                                        holiday,
                                                        style: TextStyle(
                                                          color: Color(0xFFC62828),
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),

                                        // Event list or empty state
                                        if (_selectedEvents.isEmpty)
                                          Container(
                                            margin: EdgeInsets.symmetric(vertical: 20),
                                            padding: EdgeInsets.all(24),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withOpacity(0.6),
                                              borderRadius: BorderRadius.circular(16),
                                              border: Border.all(color: Colors.grey.shade200),
                                            ),
                                            child: Center(
                                              child: Column(
                                                children: [
                                                  Icon(Icons.event_available, size: 40, color: Colors.grey.shade300),
                                                  SizedBox(height: 8),
                                                  Text(
                                                    "Chưa có sự kiện",
                                                    style: TextStyle(color: Colors.grey[500], fontSize: 14),
                                                  ),
                                                  SizedBox(height: 4),
                                                  Text(
                                                    "Nhấn nút \"Thêm\" để tạo sự kiện mới",
                                                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )
                                        else
                                          ListView.separated(
                                            shrinkWrap: true,
                                            physics: NeverScrollableScrollPhysics(),
                                            itemCount: _selectedEvents.length,
                                            separatorBuilder: (context, index) => SizedBox(height: 10),
                                            itemBuilder: (context, index) {
                                              final event = _selectedEvents[index];
                                              return Container(
                                                decoration: CalendarStyleHelper.eventCardDecoration(
                                                  hasReminder: event.hasReminder,
                                                ),
                                                child: Padding(
                                                  padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                                  child: Row(
                                                    children: [
                                                      // Icon
                                                      Container(
                                                        padding: EdgeInsets.all(10),
                                                        decoration: BoxDecoration(
                                                          color: (event.hasReminder
                                                                  ? Color(0xFFE53935)
                                                                  : Color(0xFF42A5F5))
                                                              .withOpacity(0.1),
                                                          borderRadius: BorderRadius.circular(12),
                                                        ),
                                                        child: Icon(
                                                          event.hasReminder ? Icons.notifications_active : Icons.event_note,
                                                          color: event.hasReminder ? Color(0xFFE53935) : Color(0xFF42A5F5),
                                                          size: 22,
                                                        ),
                                                      ),
                                                      SizedBox(width: 12),
                                                      // Content
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Text(
                                                              event.title,
                                                              style: TextStyle(
                                                                fontWeight: FontWeight.w700,
                                                                fontSize: 15,
                                                                color: Color(0xFF263238),
                                                              ),
                                                            ),
                                                            if (event.note.isNotEmpty) ...[
                                                              SizedBox(height: 3),
                                                              Text(
                                                                event.note,
                                                                style: TextStyle(
                                                                  color: Colors.grey[600],
                                                                  fontSize: 13,
                                                                ),
                                                                maxLines: 2,
                                                                overflow: TextOverflow.ellipsis,
                                                              ),
                                                            ],
                                                            if (event.hasReminder) ...[
                                                              SizedBox(height: 4),
                                                              Row(
                                                                children: [
                                                                  Icon(Icons.alarm, size: 12, color: Colors.orange),
                                                                  SizedBox(width: 4),
                                                                  Text(
                                                                    "Có nhắc nhở",
                                                                    style: TextStyle(
                                                                      fontSize: 11,
                                                                      color: Colors.orange[700],
                                                                      fontWeight: FontWeight.w600,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          ],
                                                        ),
                                                      ),
                                                      // Delete button
                                                      Material(
                                                        color: Colors.transparent,
                                                        child: InkWell(
                                                          onTap: () async {
                                                            await _calendarService.deleteEvent(widget.familyId, event.id);
                                                            setStateDialog(() {
                                                              _selectedEvents = _getEventsForDay(_selectedDay!);
                                                            });
                                                          },
                                                          borderRadius: BorderRadius.circular(8),
                                                          child: Padding(
                                                            padding: EdgeInsets.all(8),
                                                            child: Icon(Icons.delete_outline, size: 20, color: Colors.grey[400]),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        SizedBox(height: 24),
                                      ],
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
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

  // Build Calendar Cell with Lunar Date — Premium Design
  Widget _buildCalendarCell(
    DateTime day, {
    bool isSelected = false,
    bool isToday = false,
    List<Color>? zodiacGradient,
  }) {
    final lunarDate = Lunar(date: day, createdFromSolar: true);
    final gradient = zodiacGradient ?? ZodiacHelper.getGradient(day.year);

    String? solarHoliday = _getSolarHoliday(day);
    String? lunarHoliday = _getLunarHoliday(lunarDate);
    bool isWeekend = day.weekday == DateTime.saturday || day.weekday == DateTime.sunday;
    bool hasHoliday = solarHoliday != null || lunarHoliday != null;
    bool isRam = lunarDate.day == 15; // Rằm
    bool isMung1 = lunarDate.day == 1; // Mùng 1
    bool hasEvents = _getEventsForDay(day).isNotEmpty;

    // Cell decoration
    BoxDecoration cellDecor;
    if (isSelected) {
      cellDecor = CalendarStyleHelper.selectedCellDecoration(gradient);
    } else if (isToday) {
      cellDecor = CalendarStyleHelper.todayCellDecoration(gradient);
    } else if (hasHoliday) {
      cellDecor = CalendarStyleHelper.holidayCellDecoration();
    } else {
      cellDecor = CalendarStyleHelper.defaultCellDecoration();
    }

    // Text styles
    TextStyle dayStyle = CalendarStyleHelper.solarDateStyle(isSelected, isToday, isWeekend);
    TextStyle lunarStyle = CalendarStyleHelper.lunarDateStyle(isSelected);

    if (!isSelected && hasHoliday) {
      dayStyle = dayStyle.copyWith(color: Color(0xFFE53935));
      lunarStyle = lunarStyle.copyWith(color: Color(0xFFE53935), fontWeight: FontWeight.bold);
    }

    return Container(
      margin: EdgeInsets.all(2),
      clipBehavior: Clip.hardEdge,
      decoration: cellDecor,
      child: Stack(
        clipBehavior: Clip.hardEdge,
        alignment: Alignment.center,
        children: [
          // Main content
          Padding(
            padding: EdgeInsets.symmetric(vertical: 4),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Ngày dương — To, đậm
                Text("${day.day}", style: dayStyle),
                // Ngày âm — Nhỏ, nhạt
                Text(
                  "${lunarDate.day}/${lunarDate.month}",
                  style: lunarStyle,
                ),
              ],
            ),
          ),

          // Bottom markers
          Positioned(
            bottom: 2,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Đỏ: Ngày lễ
                if (hasHoliday)
                  CalendarStyleHelper.buildHolidayMarker(),
                // Vàng: Rằm / Mùng 1
                if (!hasHoliday && (isRam || isMung1))
                  CalendarStyleHelper.buildLunarSpecialMarker(),
                // Có sự kiện
                if (hasEvents) ...[
                  if (hasHoliday || isRam || isMung1) SizedBox(width: 3),
                  Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white70 : Color(0xFF42A5F5),
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
          ),
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

                    await _calendarService.addEvent(newEvent);

                    if (_setReminder && reminderTime != null) {
                      await NotificationService.scheduleEventReminder(
                        id.hashCode,
                        "Nhắc nhở: ${newEvent.title}",
                        newEvent.note,
                        reminderTime,
                      );
                    }

                    Navigator.pop(context);

                    setStateParent(() {
                      // Trigger rebuild or let stream update
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
}
