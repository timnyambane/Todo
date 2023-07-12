import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sqlprac/database/db_helper.dart';
import 'package:sqlprac/model/todo_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descController = TextEditingController();
  DateTime? dueDateTime;
  bool showDetails = false, isStarred = false;

  Future<void> _saveTask() async {
    final String title = titleController.text;
    final String description = descController.text;
    final int dateCreated = DateTime.now().millisecondsSinceEpoch;
    final int dueDate = dueDateTime?.millisecondsSinceEpoch ?? 0;

    await DatabaseHelper.instance.insertTask(
      Task(
        title: title,
        description: description,
        dateCreated: dateCreated,
        dueDate: dueDate,
        isStarred: isStarred,
      ),
    );

    titleController.clear();
    descController.clear();
    setState(() {
      dueDateTime = null;
      isStarred = false;
    });

    debugPrint("Added successfully");
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    titleController.dispose();
    descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text("SQL Task"),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Task>>(
        future: DatabaseHelper.instance.getTasks(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final tasks = snapshot.data!;
            return ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                final formattedDate = DateFormat('d MMMM, H:mm').format(
                    DateTime.fromMillisecondsSinceEpoch(task.dateCreated));
                return Card(
                  color: Colors.brown[100],
                  child: ListTile(
                    title: Text(
                      task.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(formattedDate),
                    trailing: task.isStarred == true
                        ? const Icon(
                            Icons.star,
                            color: Colors.red,
                          )
                        : const Icon(
                            Icons.star_border,
                            color: Colors.red,
                          ),
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
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
                                    icon: const Icon(Icons.subject),
                                  ),
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
                                          context: (context),
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
                                      isStarred
                                          ? Icons.star
                                          : Icons.star_border,
                                    ),
                                  ),
                                ],
                              ),
                              TextButton(
                                  onPressed: _saveTask,
                                  child: const Text("Save"))
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
            setState(() {
              showDetails = false;
            });
          });
        },
        elevation: 0,
        child: const Icon(Icons.add),
      ),
    );
  }
}
