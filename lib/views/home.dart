import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sqlprac/controllers/todo_controller.dart';
import 'package:get/get.dart';

class HomeScreen extends StatelessWidget {
  final TodoController todoController = Get.put(TodoController());

  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text("SQL Task"),
        centerTitle: true,
      ),
      body: Obx(() {
        if (todoController.tasks.isEmpty) {
          return const Center(child: Text("No Tasks"));
        } else {
          return ListView.builder(
            itemCount: todoController.tasks.length,
            itemBuilder: (context, index) {
              final task = todoController.tasks[index];
              final formattedDate = DateFormat.MMMEd().format(
                DateTime.fromMillisecondsSinceEpoch(task.dueDate!),
              );
              return GestureDetector(
                onLongPress: () {
                  showDialog(
                    barrierDismissible: false,
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(task.title),
                              Icon(
                                task.isStarred!
                                    ? Icons.star
                                    : Icons.star_border,
                              ),
                            ]),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(task.description!),
                            Chip(
                              label: Text(formattedDate),
                              backgroundColor: Colors.blue[100],
                            )
                          ],
                        ),
                        actions: [
                          MaterialButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('Close'),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: Card(
                  child: ListTile(
                    leading: Checkbox(
                      value: task.isComplete,
                      onChanged: (value) {
                        todoController.updateTaskCompletion(
                          task,
                          value ?? false,
                        );
                      },
                    ),
                    title: Text(
                      task.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Wrap(children: [
                      Chip(
                        label: Text(formattedDate),
                        backgroundColor: Colors.blue[100],
                      ),
                    ]),
                    trailing: PopupMenuButton(
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Text('Edit'),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete'),
                        ),
                      ],
                      onSelected: (value) {
                        if (value == 'edit') {
                          todoController.showTaskDialog(
                            context,
                            task: task,
                          );
                        } else if (value == 'delete') {
                          todoController.deleteTask(task);
                        }
                      },
                    ),
                  ),
                ),
              );
            },
          );
        }
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          todoController.showTaskDialog(context);
        },
        elevation: 0,
        child: const Icon(Icons.add),
      ),
    );
  }
}
