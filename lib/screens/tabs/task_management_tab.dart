import 'package:flutter/material.dart';
import '../../models/household_model.dart';
import '../../services/auth_service.dart';
import 'package:family_task_app/l10n/app_localizations.dart';

class TaskManagementScreen extends StatefulWidget {
  final String familyId;
  const TaskManagementScreen({Key? key, required this.familyId}) : super(key: key);

  @override
  _TaskManagementScreenState createState() => _TaskManagementScreenState();
}

class _TaskManagementScreenState extends State<TaskManagementScreen> {
  final AuthService _authService = AuthService();
  List<TaskConfig> _tasks = [];
  bool _isLoading = true;

  // --- CẬP NHẬT LẠI TÊN GỌI KỊCH BẢN Ở ĐÂY ---
  Map<int, String> _getScenarioLabels(BuildContext context) {
    return {
      1: AppLocalizations.of(context)!.scenarioRotate,
      2: AppLocalizations.of(context)!.scenarioSingle,
      3: AppLocalizations.of(context)!.scenarioContract,
      5: AppLocalizations.of(context)!.scenarioTurnBased,
    };
  }

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  void _loadTasks() async {
    setState(() => _isLoading = true);
    List<TaskConfig> list = await _authService.getTaskConfigs(widget.familyId);
    setState(() {
      _tasks = list;
      _isLoading = false;
    });
  }

  // Hàm lấy mô tả chi tiết để hiện bên dưới Dropdown
  String _getScenarioDescription(BuildContext context, int scenario) {
    switch (scenario) {
      case 1:
        return AppLocalizations.of(context)!.scenarioRotateDesc;
      case 2:
        return AppLocalizations.of(context)!.scenarioSingleDesc;
      case 3:
        return AppLocalizations.of(context)!.scenarioContractDesc;
      case 5:
        return AppLocalizations.of(context)!.scenarioTurnBasedDesc;
      default:
        return "";
    }
  }

  void _showAddTaskDialog() {
    final _nameController = TextEditingController();
    final _offsetController = TextEditingController(text: "0");
    int _selectedScenario = 1;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(
               children: [
                 Icon(Icons.add_task, color: Colors.teal),
                 SizedBox(width: 10),
                 Text(AppLocalizations.of(context)!.addNewTask, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
               ]
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Tên công việc
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.taskNameLabel,
                      hintText: AppLocalizations.of(context)!.taskNameHint,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: Icon(Icons.edit, color: Colors.teal),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                  ),
                  SizedBox(height: 16),

                  // 2. Chọn kịch bản
                  Text(AppLocalizations.of(context)!.taskDivisionLabel, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal[800])),
                  SizedBox(height: 8),
                  DropdownButtonFormField<int>(
                    value: _selectedScenario,
                    isExpanded: true, // Để text dài không bị lỗi
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    items: _getScenarioLabels(context).entries.map((entry) {
                      return DropdownMenuItem(
                        value: entry.key,
                        child: Text(
                          entry.value, 
                          style: TextStyle(fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setStateDialog(() => _selectedScenario = val!);
                    },
                  ),
                  
                  // 3. Hiển thị giải thích chi tiết
                  Container(
                    margin: EdgeInsets.only(top: 12),
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade100)
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info, size: 20, color: Colors.blue),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _getScenarioDescription(context, _selectedScenario),
                            style: TextStyle(fontSize: 13, color: Colors.blue[900]),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 4. Nhập Offset (Chỉ hiện khi chọn Xoay vòng)
                  if (_selectedScenario == 1) ...[
                    SizedBox(height: 16),
                    TextField(
                      controller: _offsetController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.offsetLabel,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        helperText: AppLocalizations.of(context)!.offsetHelperText,
                        prefixIcon: Icon(Icons.exposure_plus_1, color: Colors.teal),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(AppLocalizations.of(context)!.cancel, style: TextStyle(color: Colors.grey)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
                ),
                onPressed: () async {
                  if (_nameController.text.isNotEmpty) {
                    await _authService.addTaskConfig(
                      widget.familyId,
                      _nameController.text,
                      _selectedScenario,
                      int.tryParse(_offsetController.text) ?? 0,
                    );
                    Navigator.pop(context);
                    _loadTasks();
                  }
                },
                child: Text(AppLocalizations.of(context)!.saveTask),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Light background
      body: Column(
        children: [
          // Custom Header
          Container(
            padding: EdgeInsets.fromLTRB(24, 50, 24, 30),
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
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.arrow_back, color: Colors.white),
                  ),
                ),
                SizedBox(width: 16),
                Text(
                  AppLocalizations.of(context)!.taskManagement,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          // Body
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator(color: Colors.teal))
                : _tasks.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.teal.shade50,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.playlist_add, size: 64, color: Colors.teal.shade300),
                            ),
                            SizedBox(height: 24),
                            Text(
                              AppLocalizations.of(context)!.noTasksYet,
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[800]),
                            ),
                            SizedBox(height: 8),
                            Text(
                              AppLocalizations.of(context)!.tapPlusToAdd,
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.all(20),
                        itemCount: _tasks.length,
                        itemBuilder: (context, index) {
                          final task = _tasks[index];
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
                            child: ListTile(
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              leading: Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.teal.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(_getIconForScenario(task.scenario), color: Colors.teal),
                              ),
                              title: Text(task.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(
                                  _getScenarioLabels(context)[task.scenario] ?? AppLocalizations.of(context)!.other,
                                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                                ),
                              ),
                              trailing: IconButton(
                                icon: Icon(Icons.delete_outline, color: Colors.red.shade300),
                                onPressed: () async {
                                  // Thêm confirm dialog cho chắc chắn
                                  bool confirm = await showDialog(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                      title: Text(AppLocalizations.of(context)!.deleteThisTask),
                                      content: Text(AppLocalizations.of(context)!.areYouSureDeleteTask(task.title)),
                                      actions: [
                                        TextButton(onPressed: ()=>Navigator.pop(ctx, false), child: Text(AppLocalizations.of(context)!.cancel, style: TextStyle(color: Colors.grey))),
                                        ElevatedButton(
                                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                            onPressed: ()=>Navigator.pop(ctx, true), 
                                            child: Text(AppLocalizations.of(context)!.delete)
                                        ),
                                      ],
                                    )
                                  ) ?? false;

                                  if (confirm) {
                                     await _authService.removeTaskConfig(widget.familyId, task);
                                     _loadTasks();
                                  }
                                },
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddTaskDialog,
        icon: Icon(Icons.add_task),
        label: Text(AppLocalizations.of(context)!.addTaskFab),
        backgroundColor: Colors.teal,
        elevation: 4,
      ),
    );
  }

  IconData _getIconForScenario(int scenario) {
    switch (scenario) {
      case 2: return Icons.person; // Sống 1 mình
      case 3: return Icons.attribution; // Thầu khoán
      case 5: return Icons.touch_app; // Theo lượt
      default: return Icons.sync; // Xoay vòng
    }
  }
}