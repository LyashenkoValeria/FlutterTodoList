import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RemoveTaskDialog extends StatefulWidget {
  final String categoryID;
  final String userID;

  const RemoveTaskDialog(
      {Key? key, required this.categoryID, required this.userID})
      : super(key: key);

  @override
  State<RemoveTaskDialog> createState() =>
      _RemoveTaskDialogState(categoryID: categoryID, userID: userID);
}

class _RemoveTaskDialogState extends State<RemoveTaskDialog> {
  final String categoryID;
  final String userID;

  _RemoveTaskDialogState({required this.categoryID, required this.userID});

  DeleteOption? delOptions = DeleteOption.all;

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
        delOptions = DeleteOption.all;
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return StatefulBuilder(builder: (context, setState) {
                return AlertDialog(
                  title: const Text('Удаление заданий'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RadioListTile(
                        title: const Text('Удалить все задания'),
                        value: DeleteOption.all,
                        groupValue: delOptions,
                        onChanged: (DeleteOption? value) {
                          setState(() {
                            delOptions = value;
                          });
                        },
                        controlAffinity: ListTileControlAffinity.trailing,
                      ),
                      RadioListTile(
                        title: const Text('Удалить выполненные задания'),
                        value: DeleteOption.checked,
                        groupValue: delOptions,
                        onChanged: (DeleteOption? value) {
                          setState(() {
                            delOptions = value;
                          });
                        },
                        controlAffinity: ListTileControlAffinity.trailing,
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
                        dbTasks.get().then((snapshot) {
                          for (DocumentSnapshot ds in snapshot.docs) {
                            if (delOptions == DeleteOption.all ||
                                (delOptions == DeleteOption.checked &&
                                    ds.get('isChecked'))) {
                              ds.reference.delete();
                            }
                          }
                        });
                        Navigator.of(context).pop();
                      },
                      style: roundButtonStyle,
                      child: const Text('Удалить'),
                    ),
                  ],
                );
              });
            });
      },
      style: roundButtonStyle,
      child: const Icon(
        Icons.clear_all,
      ),
    );
  }
}

enum DeleteOption { all, checked }
