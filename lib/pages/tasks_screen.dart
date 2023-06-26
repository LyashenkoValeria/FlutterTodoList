import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_todo_list/dialogs/add_task_dialog.dart';
import 'package:flutter_todo_list/dialogs/google_sign_in.dart';
import 'package:flutter_todo_list/dialogs/remove_task_dialog.dart';
import 'package:provider/provider.dart';

class TasksScreen extends StatefulWidget {
  final String categoryID;
  final String userID;

  TasksScreen({Key? key, required this.categoryID, required this.userID});

  @override
  State<TasksScreen> createState() =>
      _TasksScreenState(categoryID: categoryID, userID: userID);
}

class _TasksScreenState extends State<TasksScreen> {
  final String categoryID;
  final String userID;

  _TasksScreenState({required this.categoryID, required this.userID});

  int totalLength = 0;
  int readyLength = 0;

  @override
  Widget build(BuildContext context) {
    final dbTasks = FirebaseFirestore.instance
        .collection('userTasks')
        .doc(userID)
        .collection('categories')
        .doc(categoryID)
        .collection('tasks');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cписок дел'),
        actions: [
          IconButton(
              onPressed: () {
                final provider =
                    Provider.of<GoogleSignInProvider>(context, listen: false);
                provider.googleLogout();
              },
              icon: const Icon(Icons.exit_to_app))
        ],
      ),
      body: StreamBuilder(
        stream: dbTasks.snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            totalLength = 0;
            readyLength = 0;
            updateDB();
            return const Center(
                child: Text(
              'У вас пока нет заданий в данной категории',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20),
            ));
          } else {
            return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (BuildContext context, int index) {
                  readyLength = 0;
                  totalLength = snapshot.data!.docs.length;
                  for (var doc in snapshot.data!.docs) {
                    if (doc.get('isChecked')) readyLength++;
                  }
                  updateDB();
                  return StatefulBuilder(
                    builder: (context, setState) {
                      return Dismissible(
                        key: Key(snapshot.data!.docs[index].id),
                        child: Card(
                          elevation: 5,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                          child: ListTile(
                            leading: Checkbox(
                              activeColor: const Color(0xFF082427),
                              value:
                                  snapshot.data!.docs[index].get('isChecked'),
                              onChanged: (bool? value) {
                                dbTasks
                                    .doc(snapshot.data!.docs[index].id)
                                    .update({'isChecked': value!});
                              },
                            ),
                            title: Text(
                              snapshot.data!.docs[index].get('taskTitle'),
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                  decoration: snapshot.data!.docs[index]
                                          .get('isChecked')
                                      ? TextDecoration.lineThrough
                                      : null),
                            ),
                            subtitle: snapshot.data!.docs[index].get('desc').toString().isNotEmpty ?
                                Text(snapshot.data!.docs[index].get('desc')) : null,
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Color(0xFF082427),
                              ),
                              onPressed: () {
                                dbTasks
                                    .doc(snapshot.data!.docs[index].id)
                                    .delete();
                              },
                            ),
                          ),
                        ),
                        onDismissed: (direction) {
                          dbTasks
                              .doc(snapshot.data!.docs[index].id)
                              .delete();
                        },
                      );
                    },
                  );
                });
          }
        },
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          RemoveTaskDialog(categoryID: categoryID, userID: userID),
          AddTaskDialog(categoryID: categoryID, userID: userID),
        ],
      ),
    );
  }

  void updateDB() {
    FirebaseFirestore.instance
        .collection('userCategories')
        .doc(userID.toString())
        .collection('categories')
        .doc(categoryID.toString())
        .update({'all': totalLength, 'ready': readyLength});
  }
}
