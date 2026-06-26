import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/task_service.dart';
import '../services/settings_service.dart';
import '../models/task.dart';
import '../ui/widgets/glass_card.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final TaskService _taskService = TaskService();
  final SettingsService _settingsService = SettingsService();

  @override
  void initState() {
    super.initState();
    _taskService.addListener(_onUpdate);
    _settingsService.addListener(_onUpdate);
  }

  @override
  void dispose() {
    _taskService.removeListener(_onUpdate);
    _settingsService.removeListener(_onUpdate);
    super.dispose();
  }

  void _onUpdate() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final tasks = _taskService.tasks;
    // Sort tasks: incomplete first, then by due date
    final sortedTasks = _sortTasks(tasks);

    return Column(
      children: [
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tasks',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: -0.5,
                  shadows: [Shadow(color: Colors.black87, offset: Offset(0, 2), blurRadius: 10)],
                ),
              ),
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: const Icon(Icons.add_task, color: Colors.white, size: 22),
                ),
                onPressed: () => Navigator.pushNamed(context, '/add-task'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: GlassCard(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
              color: Colors.black.withOpacity(0.25),
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: tasks.isEmpty
                  ? Center(
                      child: Text(
                        'No tasks yet. Tap + to add one!',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: sortedTasks.length,
                      itemBuilder: (context, index) {
                        final task = sortedTasks[index];
                        return _buildTaskItem(task);
                      },
                    ),
            ),
          ),
        ),
      ],
    );
  }

  List<Task> _sortTasks(List<Task> tasks) {
    final sorted = List<Task>.from(tasks);
    sorted.sort((a, b) {
      // Incomplete tasks first
      if (a.isCompleted != b.isCompleted) {
        return a.isCompleted ? 1 : -1;
      }
      // Then by due date (null dates last)
      if (a.dueDate == null && b.dueDate == null) return 0;
      if (a.dueDate == null) return 1;
      if (b.dueDate == null) return -1;
      return a.dueDate!.compareTo(b.dueDate!);
    });
    return sorted;
  }

  String _getDueDateLabel(DateTime? dueDate) {
    if (dueDate == null) return '';
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final dueDay = DateTime(dueDate.year, dueDate.month, dueDate.day);
    
    if (dueDay.isAtSameMomentAs(today)) {
      return 'Due today';
    } else if (dueDay.isAtSameMomentAs(tomorrow)) {
      return 'Due tomorrow';
    }
    return '';
  }

  bool _isOverdue(DateTime? dueDate, bool isCompleted) {
    if (dueDate == null || isCompleted) return false;
    return dueDate.isBefore(DateTime.now());
  }

  Widget _buildTaskItem(Task task) {
    final isOverdue = _isOverdue(task.dueDate, task.isCompleted);
    final dueDateLabel = _getDueDateLabel(task.dueDate);
    final is24Hours = _settingsService.timeFormat == '24h';
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, '/add-task', arguments: task),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isOverdue ? Colors.red.withOpacity(0.15) : Colors.black.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
            border: task.isCompleted 
                ? null 
                : Border.all(
                    color: isOverdue ? Colors.redAccent.withOpacity(0.5) : Colors.white.withOpacity(0.1),
                    width: isOverdue ? 2 : 1,
                  ),
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => _taskService.toggleTaskCompletion(task.id),
                child: Icon(
                  task.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: task.isCompleted ? const Color(0xFF4A80F0) : (isOverdue ? Colors.redAccent : Colors.white54),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              // Color indicator
              Container(
                width: 3,
                height: 24,
                decoration: BoxDecoration(
                  color: isOverdue ? Colors.redAccent : task.color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: TextStyle(
                        color: task.isCompleted ? Colors.white38 : (isOverdue ? Colors.redAccent : Colors.white),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    if (task.dueDate != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (dueDateLabel.isNotEmpty) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: isOverdue 
                                    ? Colors.redAccent.withOpacity(0.3) 
                                    : const Color(0xFF4A80F0).withOpacity(0.3),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                dueDateLabel,
                                style: TextStyle(
                                  color: isOverdue ? Colors.redAccent : const Color(0xFF4A80F0),
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            DateFormat(is24Hours ? 'MMM d, HH:mm' : 'MMM d, h:mm a').format(task.dueDate!),
                            style: TextStyle(
                              color: isOverdue ? Colors.redAccent : Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.white38, size: 20),
                onPressed: () => _taskService.deleteTask(task.id),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
