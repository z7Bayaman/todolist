import 'package:flutter/material.dart';

void main() {
  runApp(TodoApp());
}

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todolist',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: TodoListScreen(),
    );
  }
}

class Task {
  String title;
  bool isCompleted;
  DateTime deadline;
  DateTime? completedAt;
  String category;

  Task({
    required this.title,
    this.isCompleted = false,
    required this.deadline,
    this.completedAt,
    required this.category,
  });
}

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  _TodoListScreenState createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  final List<Task> tasks = [];
  final TextEditingController _taskController = TextEditingController();
  DateTime? _selectedDeadline;
  String _selectedCategory = "Покупки";

  final List<String> categories = ["Все", "Покупки", "Работа", "Обучение"];
  String _filterCategory = "Все";

  void _addTask() {
    if (_taskController.text.isEmpty || _selectedDeadline == null) return;
    setState(() {
      tasks.add(Task(
        title: _taskController.text,
        deadline: _selectedDeadline!,
        category: _selectedCategory,
      ));
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
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        setState(() {
          _selectedDeadline = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Task> filteredTask = _filterCategory == "Все"
        ? tasks
        : tasks.where((task) => task.category == _filterCategory).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Todo List'),
        actions: [
          DropdownButton<String>(
            value: _filterCategory,
            onChanged: (String? newValue) {
              setState(() {
                _filterCategory = newValue!;
              });
            },
            items: categories.map((String category) {
              return DropdownMenuItem<String>(
                value: category,
                child: Text(category),
              );
            }).toList(),
          ),
        ],
      ),
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
                DropdownButton<String>(
                  value: _selectedCategory,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedCategory = newValue!;
                    });
                  },
                  items: categories
                      .where((cat) => cat != "Все")
                      .map((String category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
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
              itemCount: filteredTask.length,
              itemBuilder: (context, index) {
                final task = filteredTask[index];
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
                  subtitle: Text(
                      "Категория: ${task.category} | Дедлайн: ${task.deadline.toLocal()}"),
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
