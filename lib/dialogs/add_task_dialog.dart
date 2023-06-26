import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddTaskDialog extends StatefulWidget {
  final String categoryID;
  final String userID;

  const AddTaskDialog(
      {Key? key, required this.categoryID, required this.userID})
      : super(key: key);

  @override
  State<AddTaskDialog> createState() =>
      _AddTaskDialogState(categoryID: categoryID, userID: userID);
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  final String categoryID;
  final String userID;

  _AddTaskDialogState({required this.categoryID, required this.userID});

  String taskTitle = '';
  String taskDesc = '';

  final ButtonStyle roundButtonStyle = ElevatedButton.styleFrom(
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(10)),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final dbTasks = FirebaseFirestore.instance
        .collection('userTasks')
        .doc(userID)
        .collection('categories')
        .doc(categoryID)
        .collection('tasks');

    return ElevatedButton(
      onPressed: () {
        taskTitle = '';
        taskDesc = '';
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return StatefulBuilder(
                builder: (context, setState) {
                  return AlertDialog(
                    title: const Text('Новое задание'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          decoration: const InputDecoration(
                              labelText: 'Название',
                              border: OutlineInputBorder()),
                          onChanged: (String newTask) {
                            taskTitle = newTask;
                          },
                        ),
                        const Padding(padding: EdgeInsets.only(bottom: 20)),
                        TextField(
                          decoration: const InputDecoration(
                              labelText: 'Описание',
                              border: OutlineInputBorder()),
                          onChanged: (String newDesc) {
                            taskDesc = newDesc;
                          },
                        ),
                      ],
                    ),
                    actions: [
                      OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: roundButtonStyle,
                        child: const Text('Отменить'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          if (taskTitle.isNotEmpty) {
                            dbTasks.add({
                              'taskTitle': taskTitle,
                              'desc': taskDesc,
                              'isChecked': false
                            });
                            Navigator.of(context).pop();
                          }
                        },
                        style: roundButtonStyle,
                        child: const Text('Добавить'),
                      ),
                    ],
                  );
                },
              );
            });
      },
      style: roundButtonStyle,
      child: const Icon(
        Icons.add,
      ),
    );
  }
}
