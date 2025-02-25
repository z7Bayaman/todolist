import 'package:flutter/material.dart';

void main() {
  runApp(TodoApp());
}

class TodoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todolist',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TodoListScreen(),
    );
  }
}

class Task {
  String title;
  bool isCompleted;
  DateTime deadline;
  DateTime? completedAt;

  Task({
    required this.title,
    this.isCompleted = false,
    required this.deadline,
    this.completedAt,
  });
}

class TodoListScreen extends StatefulWidget {
  @override
  _TodoListScreenState createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  final List<Task> tasks = [];
  final TextEditingController _taskController = TextEditingController();
  DateTime? _selectedDeadline;

  void _addTask() {
    if (_taskController.text.isEmpty || _selectedDeadline == null) return;
    setState(() {
      tasks
          .add(Task(title: _taskController.text, deadline: _selectedDeadline!));
      _taskController.clear();
      _selectedDeadline = null;
    });
  }

  void _toggleTaskCompletion(Task task) {
    setState(() {
      task.isCompleted = !task.isCompleted;
      task.completedAt = task.isCompleted ? DateTime.now() : null;
    });
  }

  void _deleteTask(Task task) {
    setState(() {
      tasks.remove(task);
    });
  }

  Future<void> _selectDeadline(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDeadline = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Todo List')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _taskController,
                    decoration: InputDecoration(labelText: 'Введите задачу'),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () => _selectDeadline(context),
                ),
                ElevatedButton(
                  onPressed: _addTask,
                  child: Text('Добавить'),
                )
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return ListTile(
                  title: Text(
                    task.title,
                    style: TextStyle(
                      decoration:
                          task.isCompleted ? TextDecoration.lineThrough : null,
                      color: task.isCompleted
                          ? (task.completedAt!.isBefore(task.deadline)
                              ? Colors.green
                              : Colors.red)
                          : Colors.black,
                    ),
                  ),
                  subtitle: Text("Дедлайн: ${task.deadline.toLocal()}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(task.isCompleted ? Icons.undo : Icons.check),
                        onPressed: () => _toggleTaskCompletion(task),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => _deleteTask(task),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
