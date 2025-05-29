import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // For formatting date
import 'package:provider/provider.dart';
import 'package:simple_login/const.dart';
import 'package:simple_login/toast.dart';
import 'package:simple_login/store.dart'; // Assuming you have the AppStore for global state management
import 'dart:convert';

void main() => runApp(MaterialApp(home: TaskMainPage()));

class TaskMainPage extends StatefulWidget {
  final int? currentTabIndex;

  TaskMainPage({this.currentTabIndex});

  @override
  _TaskMainPageState createState() => _TaskMainPageState();
}

class _TaskMainPageState extends State<TaskMainPage>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> myTasks = [];
  List<Map<String, dynamic>> assignedTasks = [];
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.currentTabIndex ?? 0,
    );

    // Add listener to refresh tasks when tab changes
    _tabController.addListener(_onTabChanged);

    fetchTasks();
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged); // Clean up listener
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      fetchTasks(); // Refresh tasks when tab changes
    }
  }

  void reloadTasks() {
    fetchTasks();
  }

  void fetchTasks() async {
    final loggedInUser = Provider.of<AppStore>(context, listen: false).loggedInUser;

    final userID = loggedInUser?.userID;
    if (userID == null) return;

    final requestBody = {"userID": userID};

    final url = Uri.parse(GET_TASK_URL);

    print("🎄 fetch tasks: $requestBody");

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final allTasks = List<Map<String, dynamic>>.from(data['tasks'] ?? []);

      final my = <Map<String, dynamic>>[];
      final assigned = <Map<String, dynamic>>[];

      for (var task in allTasks) {
        if (task['assignTo']['id'] == userID) {
          my.add(task);
        } else {
          assigned.add(task);
        }
      }

      setState(() {
        myTasks = my;
        assignedTasks = assigned;
      });
    } else {
      print("Failed to fetch tasks: ${response.statusCode}");
    }
  }

  void _addTask(Map<String, dynamic> task) {
    setState(() {
      if (task['assignedTo'] == null) {
        myTasks.add(task);
      } else {
        assignedTasks.add(task);
      }
    });
  }

  Future<void> updateTaskStatus(
    Map<String, dynamic> task,
    bool? newValue,
  ) async {
    final taskID = task['_id'];

    final requestBody = {'taskId': taskID};

    final url = Uri.parse(GET_TASK_COMPLETED_URL);

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestBody),
    );

    final data = json.decode(response.body);

    if (response.statusCode == 200) {
      if (data['success']) {
        Toast.show(context, data['message'], type: ToastType.success);
        fetchTasks();
      } else {
        Toast.show(context, 'Failed to complete task', type: ToastType.error);
      }
    } else {
      print("Failed to update task status: ${response.statusCode}");
    }
  }

  Widget buildTaskCard(
    Map<String, dynamic> task, {
    required bool showCheckbox,
  }) {
    final isCompleted = task['completed'] == true;
    final dueDate =
        task['dueDate'] != null
            ? DateFormat('yyyy-MM-dd').format(DateTime.parse(task['dueDate']))
            : null;
    final completedDate =
        task['completedDate'] != null
            ? DateFormat('yyyy-MM-dd').format(DateTime.parse(task['completedDate']))
            : null;
    final initials =
        (task['assignedTo'] ?? task['assignedBy'] ?? 'U')
            .toString()
            .split(' ')
            .map((e) => e.isNotEmpty ? e[0] : '')
            .take(2)
            .join()
            .toUpperCase();

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showCheckbox)
              Checkbox(
                value: isCompleted,
                onChanged: (newValue) async {
                  await updateTaskStatus(task, newValue);
                },
                activeColor: Colors.deepPurple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              )
            else
              Icon(Icons.assignment_ind, color: Colors.grey[400], size: 28),
            SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task['title'] ?? '',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isCompleted ? Colors.grey : Colors.black,
                      decoration: isCompleted ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    showCheckbox
                        ? 'Assigned by ${task['assignedBy'] ?? 'You'}'
                        : 'Assigned to ${task['assignTo']?['preferredName'] ?? ''}',
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 2),
                  if (task['notes'] != null && task['notes'].toString().isNotEmpty)
                    Text(
                      task['notes'],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 13, color: Colors.grey[800]),
                    ),
                  SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        isCompleted ? Icons.check_circle : Icons.access_alarm,
                        color: isCompleted ? Colors.green : Colors.grey[700],
                        size: 16,
                      ),
                      SizedBox(width: 4),
                      Text(
                        isCompleted
                            ? 'Completed on ${completedDate ?? ''}'
                            : dueDate != null
                                ? 'Due on $dueDate'
                                : '',
                        style: TextStyle(
                          color: isCompleted ? Colors.green : Colors.grey[700],
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 8, top: 2),
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                initials,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tasks'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [Tab(text: "My Tasks"), Tab(text: "Assigned Tasks")],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          myTasks.isEmpty
              ? Center(child: Text('No tasks yet.'))
              : ListView.builder(
                  itemCount: myTasks.length,
                  itemBuilder: (context, index) =>
                      buildTaskCard(myTasks[index], showCheckbox: true),
                ),
          assignedTasks.isEmpty
              ? Center(child: Text('No assigned tasks yet.'))
              : ListView.builder(
                  itemCount: assignedTasks.length,
                  itemBuilder: (context, index) => buildTaskCard(
                    assignedTasks[index],
                    showCheckbox: false,
                  ),
                ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.lightBlue,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(
          Icons.add,
          size: 28,
        ),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TaskAddPage()),
          );
          if (result != null && result == 'reload') {
            reloadTasks();
          }
        },
      ),
    );
  }
}

class TaskAddPage extends StatefulWidget {
  @override
  _TaskAddPageState createState() => _TaskAddPageState();
}

class _TaskAddPageState extends State<TaskAddPage> {
  String taskTitle = '';
  String taskNotes = '';
  DateTime? taskDueDate;
  String? taskAssignedTo;
  String? taskAssignedToUserID;
  bool isFormValid = false;

  void _validateForm() {
    setState(() {
      isFormValid =
          taskTitle.trim().isNotEmpty &&
          taskNotes.trim().isNotEmpty &&
          taskDueDate != null;
    });
  }

  void _saveTask() async {
    if (isFormValid) {
      final loggedInUser = context.read<AppStore>().loggedInUser;

      final requestBody = {
        'userID': loggedInUser?.userID,
        'title': taskTitle,
        'notes': taskNotes,
        'dueDate': taskDueDate?.toIso8601String(),
        'assignTo': taskAssignedToUserID,
      };

      print("📃 Task: $requestBody");

      final url = Uri.parse(ADD_TASK_URL);
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      final data = json.decode(response.body);
      if (response.statusCode == 200) {
        if (data['success']) {
          Toast.show(
            context,
            'Task created successfully!',
            type: ToastType.success,
          );
          Navigator.pop(context, 'reload');
        } else {
          Toast.show(context, 'Failed to create task!', type: ToastType.error);
        }
      }
    }
  }

  Future<void> _selectDueDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: taskDueDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != taskDueDate) {
      setState(() {
        taskDueDate = pickedDate;
      });
      _validateForm();
    }
  }

  Future<void> _assignTaskToPeople() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PeoplesPage()),
    );
    if (result != null) {
      setState(() {
        taskAssignedTo = result['name'];
        taskAssignedToUserID = result['id'];
      });
      _validateForm();
    }
  }

  @override
  Widget build(BuildContext context) {
    final labelStyle = TextStyle(
      fontWeight: FontWeight.w600,
      color: Colors.grey[800],
      fontSize: 15,
    );

    final hintStyle = TextStyle(color: Colors.grey[500], fontSize: 14);

    final inputDecoration = InputDecoration(
      hintStyle: hintStyle,
      isDense: true,
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.grey[500]!, width: 1.5),
      ),
      border: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
    );

    Widget buildField({
      required IconData icon,
      required String label,
      required Widget field,
    }) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 14.0, right: 12.0),
            child: Icon(icon, color: Colors.grey[400], size: 20),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: labelStyle),
                const SizedBox(height: 4),
                field,
              ],
            ),
          ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Add Task', style: TextStyle(color: Colors.grey[800])),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.grey[700]),
        elevation: 0.5,
      ),
      backgroundColor: Colors.grey[50],
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
        child: ListView(
          children: [
            buildField(
              icon: Icons.check_circle_outline,
              label: 'Title',
              field: TextFormField(
                decoration: inputDecoration.copyWith(
                  hintText: 'Enter task title',
                ),
                onChanged: (val) {
                  taskTitle = val;
                  _validateForm();
                },
              ),
            ),
            const SizedBox(height: 24),
            buildField(
              icon: Icons.person_outline,
              label: 'Assign to',
              field: TextFormField(
                readOnly: true,
                onTap: _assignTaskToPeople,
                controller: TextEditingController(text: taskAssignedTo ?? ''),
                decoration: inputDecoration.copyWith(
                  hintText: 'Leave blank to assign to self',
                ),
              ),
            ),
            const SizedBox(height: 24),
            buildField(
              icon: Icons.calendar_today_outlined,
              label: 'Due date',
              field: TextFormField(
                readOnly: true,
                onTap: _selectDueDate,
                controller: TextEditingController(
                  text: taskDueDate == null
                      ? ''
                      : '${taskDueDate!.year}-${taskDueDate!.month.toString().padLeft(2, '0')}-${taskDueDate!.day.toString().padLeft(2, '0')}',
                ),
                decoration: inputDecoration.copyWith(hintText: '(Optional)'),
              ),
            ),
            const SizedBox(height: 24),
            buildField(
              icon: Icons.notes_outlined,
              label: 'Notes',
              field: TextFormField(
                maxLines: 3,
                decoration: inputDecoration.copyWith(hintText: '(Optional)'),
                onChanged: (val) {
                  taskNotes = val;
                  _validateForm();
                },
              ),
            ),
            const SizedBox(height: 36),
            Align(
              alignment: Alignment.center,
              child: ElevatedButton(
                onPressed: isFormValid ? _saveTask : null,
                child: Text('Save'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[400],
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  elevation: 0,
                  textStyle: TextStyle(fontSize: 16),
                  disabledBackgroundColor: Colors.grey[300],
                  disabledForegroundColor: Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PeoplesPage extends StatelessWidget {
  PeoplesPage({super.key});

  @override
  Widget build(BuildContext context) {
    List<PeopleItem> people = Provider.of<AppStore>(context).people;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Assign to People',
          style: TextStyle(color: Colors.grey[800]),
        ),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.grey[700]),
        elevation: 0.5,
      ),
      backgroundColor: Colors.grey[50],
      body: ListView.separated(
        itemCount: people.length,
        separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey[300]),
        itemBuilder: (context, index) {
          final person = people[index];
          return ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            leading: CircleAvatar(
              radius: 26,
              backgroundImage: NetworkImage(
                'https://i.pravatar.cc/150?u=${person.id}',
              ),
              backgroundColor: Colors.grey[200],
            ),
            title: Text(
              person.preferredName,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[800],
                fontSize: 16,
              ),
            ),
            subtitle: Text(
              "${person.email}",
              style: TextStyle(
                fontWeight: FontWeight.w400,
                color: Colors.grey[800],
                fontSize: 12,
              ),
            ),
            onTap: () {
              Navigator.pop(context, {
                'name': person.preferredName,
                'id': person.id,
              });
            },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            tileColor: Colors.white,
            hoverColor: Colors.grey[100],
          );
        },
      ),
    );
  }
}
