import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sqlprac/database/db_helper.dart';
import 'package:sqlprac/models/todo_model.dart';
import 'package:get/get.dart';

class TodoController extends GetxController {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descController = TextEditingController();
  final RxList<Task> tasks = <Task>[].obs;
  DateTime? dueDateTime;
  bool showDetails = false;
  bool isStarred = false;

  @override
  void onInit() {
    fetchTasks();
    super.onInit();
  }

  Future<void> fetchTasks() async {
    final List<Task> taskList = await DatabaseHelper.instance.getTasks();
    tasks.value = taskList;
  }

  Future<void> saveTask(BuildContext context) async {
    final String title = titleController.text;
    final String description = descController.text;
    final int dateCreated = DateTime.now().millisecondsSinceEpoch;
    final int dueDate = dueDateTime?.millisecondsSinceEpoch ?? 0;

    final newTask = Task(
      title: title,
      description: description,
      dateCreated: dateCreated,
      dueDate: dueDate,
      isStarred: isStarred,
    );

    await DatabaseHelper.instance.insertTask(newTask);

    titleController.clear();
    descController.clear();
    dueDateTime = null;
    isStarred = false;

    debugPrint("Added successfully");
    Navigator.pop(context);

    fetchTasks();
  }

  void updateTask(Task task) async {
    task.title = titleController.text;
    task.description = descController.text;
    task.dueDate = dueDateTime?.millisecondsSinceEpoch;
    task.isStarred = isStarred;

    await DatabaseHelper.instance.updateTask(task);

    titleController.clear();
    descController.clear();
    dueDateTime = null;
    isStarred = false;

    debugPrint("Updated successfully");
    Get.back();

    fetchTasks();
  }

  void updateTaskCompletion(Task task, bool value) {
    task.isComplete = value;
    DatabaseHelper.instance.updateTask(task);

    fetchTasks();
  }

  void deleteTask(Task task) async {
    await DatabaseHelper.instance.deleteTask(task.id!);

    debugPrint("Deleted successfully");
    fetchTasks();
  }

  void showTaskDialog(BuildContext context, {Task? task}) {
    final isEditing = task != null;
    final buttonText = isEditing ? 'Edit' : 'Save';

    if (task != null) {
      // Editing an existing task
      titleController.text = task.title;
      descController.text = task.description!;
      dueDateTime = task.dueDate != null
          ? DateTime.fromMillisecondsSinceEpoch(task.dueDate!)
          : null;
      isStarred = task.isStarred!;
    } else {
      titleController.clear();
      descController.clear();
      dueDateTime = null;
      isStarred = false;
    }

    showModalBottomSheet(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20.0),
        ),
      ),
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        hintText: 'New task',
                        border: InputBorder.none,
                      ),
                      autofocus: true,
                    ),
                    Visibility(
                      visible: showDetails,
                      child: TextField(
                        controller: descController,
                        decoration: const InputDecoration(
                          hintText: 'Add details',
                          border: InputBorder.none,
                        ),
                        style: const TextStyle(fontSize: 13),
                        maxLines: 3,
                      ),
                    ),
                    if (dueDateTime != null)
                      Wrap(
                        spacing: 8,
                        children: [
                          Chip(
                            label: Text(
                              DateFormat('E, d MMMM, H:mm')
                                  .format(dueDateTime!),
                            ),
                            deleteIcon: const Icon(Icons.close),
                            onDeleted: () {
                              setState(() {
                                dueDateTime = null;
                              });
                            },
                          ),
                        ],
                      ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Row(
                          children: [
                            IconButton(
                                onPressed: () {
                                  setState(() {
                                    showDetails = !showDetails;
                                  });
                                },
                                icon: const Icon(Icons.subject)),
                            IconButton(
                              onPressed: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime(2100),
                                );
                                if (date != null) {
                                  final time = await showTimePicker(
                                    context: context,
                                    initialTime: TimeOfDay.now(),
                                  );
                                  if (time != null) {
                                    setState(() {
                                      dueDateTime = DateTime(
                                        date.year,
                                        date.month,
                                        date.day,
                                        time.hour,
                                        time.minute,
                                      );
                                    });
                                  }
                                }
                              },
                              icon: const Icon(Icons.schedule),
                            ),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  isStarred = !isStarred;
                                });
                              },
                              icon: Icon(
                                  isStarred ? Icons.star : Icons.star_border),
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: () {
                            if (isEditing) {
                              updateTask(task);
                            } else {
                              saveTask(context);
                            }
                          },
                          child: Text(buttonText),
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
    ).whenComplete(() {
      showDetails = false;
    });
  }

  @override
  void dispose() {
    titleController.dispose();
    descController.dispose();
    super.dispose();
  }
}
